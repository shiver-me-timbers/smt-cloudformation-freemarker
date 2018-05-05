<#import "smt-cloudformation-core.ftl" as cf>

<#--
  -- CodePipeline
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codepipeline-pipeline.html
  --
  -- @param artifact_store: an <@code_pipeline_artifact_store/> directive that defines the Amazon S3 location where AWS
  --                        CodePipeline stores pipeline artifacts.
  -- @param role_arn: a service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to
  --                  AWS services on your behalf.
  -- @param name: the name of your AWS CodePipeline pipeline.
  -- @param depends_on: the names of Cloudformation resources that this resource depends on.
  -- @param condition: the condition that must be true for this resource to be creatred.
  -- @param last: true if this is the las resource in the list. This will prevent the trailing comma from being printed.
  -- @param disable_inbound_stage_transitions: an array of <@code_pipeline_disable_inbound_stage_transitions/>
  --                                           directives that will prevents artifacts in a pipeline from transitioning
  --                                           to the stage that you specified.
  -- @param restart_execution_on_update: indicates whether to rerun the AWS CodePipeline pipeline after you update it.
  --
  -- @nested the body of this directive should be populated with <@code_pipeline_stage/> directives.
  -->
<#macro code_pipeline
artifact_store
role_arn
name="CodePipeline"
depends_on=[]
condition=""
last=false
disable_inbound_stage_transitions=[]
restart_execution_on_update=false
>
    <@cf.resource
    name=name
    type="AWS::CodePipeline::Pipeline"
    depends_on=depends_on
    condition=condition
    last=last
    >
    "ArtifactStore" : ${artifact_store},
    "RoleArn" : "${role_arn},
    "Name" : "${name}"<#if disable_inbound_stage_transitions?has_content>,
    "DisableInboundStageTransitions" : [
        <#list disable_inbound_stage_transitions as transition>
            ${transition}
        </#list>
    ]</#if><#if restart_execution_on_update>,
    "RestartExecutionOnUpdate" : ${restart_execution_on_update?c}</#if>,
    "Stages" : [
        <#nested/>
    ]
    </@cf.resource>
</#macro>

<#--
  -- CodePipeline ArtifactStore
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-artifactstore.html
  --
  -- @param location: the location where AWS CodePipeline stores artifacts for a pipeline, such as an S3 bucket.
  -- @param type: the type of the artifact store, such as Amazon S3. Valid values ("S3").
  -- @param encryption_key: the encryption key AWS CodePipeline uses to encrypt the data in the artifact store.
  -->
<#macro code_pipeline_artifact_store
location
type="S3"
encryption_key=""
>
  "Location" : "${location}",
  "Type" : "${type}"<#if encryption_key?has_content>,
  "EncryptionKey" : ${encryption_key}</#if>
</#macro>

<#--
  -- CodePipeline ArtifactStore EncryptionKey
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-artifactstore-encryptionkey.html
  --
  -- @param id: the ID of the key. For an AWS KMS key, specify the key ID or key Amazon Resource Number (ARN).
  -- @param type: the type of encryption key, such as KMS. Valid values ("KMS").
  -->
<#macro code_pipeline_artifact_store_encryption_key
id
type="KMS"
>
  "Id" : "${id}",
  "Type" : "${type}"
</#macro>

<#--
  -- CodePipeline DisableInboundStageTransitions
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-disableinboundstagetransitions.html
  --
  -- @param stage_name: an explanation of why the transition between two stages of a pipeline was disabled.
  -- @param reason: the name of the stage to which transitions are disabled.
  -->
<#macro code_pipeline_disable_inbound_stage_transitions
stage_name
reason
>
  "StageName" : "${stage_name}",
  "Reason" : "${reason}"
</#macro>

<#--
  -- CodePipeline Stage
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages.html
  --
  -- @param name: a name for this stage.
  -- @param blockers: an array of <@code_pipeline_stage_blocker/> directives that define the gates included in a stage.
  --
  -- @nested <@code_pipeline_stage_action*/> directives that define the actions to include in this stage.
  -->
<#macro code_pipeline_stage
name
actions
blockers=[]
>
  "Name" : "${name}",
  "Actions" : [
    <#nested/>
  ]<#if blockers?has_content>,
  "Blockers" : [
    <#list blockers as blocker>
        ${blocker}
    </#list>
  ]</#if>
</#macro>

<#--
  -- CodePipeline Stage Action
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions.html
  --
  -- @param name: the action name.
  -- @param action_type_id: a <@code_pipeline_stage_action_type_id/> directive that specifies the action type and the
  --                        provider of the action.
  -- @param input_artifacts: an array of <@code_pipeline_stage_action_artifact/> directive that contains the name or ID
  --                         of the artifact that the action consumes, such as a test or build artifact.
  -- @param output_artifacts: an array of <@code_pipeline_stage_action_artifact/> directive that contains the artifact
  --                          name or ID that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  --
  -- @nested the action's configuration. These are key-value pairs that specify input values for an action.
  -->
<#macro code_pipeline_stage_action
name
action_type_id
input_artifacts=[]
output_artifacts=[]
role_arn=""
run_order=0
>
    <#assign configuration>
        <#nested/>
    </#assign>
  "Name" : "${name}",
  "ActionTypeId" : ${action_type_id}<#if configuration?has_content>,
  "Configuration" ${configuration}: </#if><#if input_artifacts?has_content>,
  "InputArtifacts" : [
    <#list input_artifacts as artifact>
        ${artifact}
    </#list>
  ]</#if><#if output_artifacts?has_content>,
  "OutputArtifacts" : [
    <#list output_artifacts as artifact>
        ${artifact}
    </#list>
  ]</#if><#if role_arn?has_content>,
  "RoleArn" : "${role_arn}"</#if><#if run_order gt 0>,
  "RunOrder" : ${run_order}</#if>
</#macro>

<#--
  -- CodePipeline Stage Action ActionTypeId
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions-actiontypeid.html
  --
  -- @param category: a category that defines which action type the owner (the entity that performs the action)
  --                  performs. Valid values: ("Source", "Build", "Deploy", "Test", "Invoke", "Approval").
  -- @param owner: the entity that performs the action. Valid values ("AWS", "ThirdParty", "Custom").
  -- @param provider: the service provider that the action calls.
  -- @param version: a string that describes the action version.
  -->
<#macro code_pipeline_stage_action_type_id
category
owner
provider
version
>
{
  "Category" : "${category}",
  "Owner" : "${owner}",
  "Provider" : "${provider}",
  "Version" : "${version}"
}
</#macro>

<#--
  -- CodePipeline Stage Action Artifact
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions-inputartifacts.html
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions-outputartifacts.html
  --
  -- @param name: the name of the artifact.
  -->
<#macro code_pipeline_stage_action_artifact
name
>
{
  "Name" : "${name}"
}
</#macro>

<#--
  -- CodePipeline Stage Blocker
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-blockers.html
  --
  -- @param name: the name of the gate declaration.
  -- @param type: the type of gate declaration. Valid values ("Schedule").
  -->
<#macro code_pipeline_stage_blocker
name
type
>
{
  "Name" : "${name}",
  "Type" : "${type}"
}
</#macro>
