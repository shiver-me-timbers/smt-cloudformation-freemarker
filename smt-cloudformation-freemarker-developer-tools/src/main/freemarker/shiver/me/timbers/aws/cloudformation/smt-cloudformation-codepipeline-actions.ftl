<#import "smt-cloudformation-codepipeline.ftl" as cp>

<#--
  -- CodePipeline Stage Action S3
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param s3_bucket: the name of the S3 bucket.
  -- @param s3_object_key: the key of the S3 object.
  -- @param output_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the artifact name or ID
  --                          that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param poll_for_source_changes: should the pipeline poll the bucket for changes.
  -->
<#macro code_pipeline_stage_action_s3
name
s3_bucket
s3_object_key
output_artifacts=""
role_arn=""
run_order=0
poll_for_source_changes=false
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Source"
        owner="AWS"
        provider="S3"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    output_artifacts=[output_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "S3Bucket": "${s3_bucket}",
      "S3ObjectKey": "${s3_object_key}",
      "PollForSourceChanges": ${poll_for_source_changes?c}
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action CodeCommit
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param repository_name: the name ofthe CodeCommit reporisotry.
  -- @param output_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the artifact name or ID
  --                          that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param branch_name: the name of the branch that should be checkout out.
  -- @param poll_for_source_changes: should the pipeline poll the repository for changes.
  -->
<#macro code_pipeline_stage_action_code_commit
name
repository_name
output_artifacts=""
role_arn=""
run_order=0
branch_name="master"
poll_for_source_changes=false
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Source"
        owner="AWS"
        provider="CodeCommit"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    output_artifacts=[output_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "RepositoryName": "${repository_name}",
      "BranchName": "${branch_name}",
      "PollForSourceChanges": ${poll_for_source_changes?c}
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action GitHub
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param owner: the owner of the repo.
  -- @param repo: the name of the repo.
  -- @param branch: the name of the branch that should be checkout out.
  -- @param oauth_token: the OAuth token to use to acess the GitHub repo.
  -- @param output_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the artifact name or ID
  --                          that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param poll_for_source_changes: should the pipeline poll the repository for changes.
  -->
<#macro code_pipeline_stage_action_github
name
owner
repo
oauth_token
output_artifacts=""
role_arn=""
run_order=0
branch="master"
poll_for_source_changes=false
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Source"
        owner="ThirdParty"
        provider="GitHub"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    output_artifacts=[output_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "Owner": "${owner}",
      "Repo": "${repo}",
      "Branch": "${branch}",
      "OAuthToken": "${oauth_token}",
      "PollForSourceChanges": ${poll_for_source_changes?c}
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action CloudFormation
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-action-reference.html#w2ab2c13c13b9
  --
  -- @param name: the action name.
  -- @param stack_name: the name of an existing stack or a stack that you want to create.
  -- @param action_mode: the AWS CloudFormation action that AWS CodePipeline invokes when processing the associated
  --                     stage. Valid values ("CHANGE_SET_EXECUTE", "CHANGE_SET_REPLACE", "CREATE_UPDATE",
  --                     "DELETE_ONLY", "REPLACE_ON_FAILURE"),
  -- @param input_artifacts: an array of <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or
  --                         ID of the artifact that the action consumes, such as a test or build artifact.
  -- @param output_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the artifact name or ID
  --                          that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param capabilities: For stacks that contain certain resources, explicit acknowledgement that AWS CloudFormation
  --                      might create or update those resources.
  -- @param changeset_name: the name of an existing change set or a new change set that you want to create for the
  --                        specified stack.
  -- @param template_path: the location of an AWS CloudFormation template file, which follows the format
  --                       "ArtifactName::TemplateFileName".
  -- @param template_configuration: the location of a template configuration file, which follows the format
  --                                "ArtifactName::TemplateConfigurationFileName".
  -- @param output_file_name: a name for the output file, such as CreateStackOutput.json.
  -- @param role_arn: the ARN of the IAM service role that AWS CloudFormation assumes when it operates on resources in a
  --                  stack.
  --
  -- @nested a JSON object that specifies values for template parameters.
  -->
<#macro code_pipeline_stage_action_cloudformation
name
stack_name
action_mode
input_artifacts=[]
output_artifacts=""
role_arn=""
run_order=0
capabilities=""
changeset_name=""
template_path=""
template_configuration=""
output_file_name=""
role_arn=""
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Deploy"
        owner="AWS"
        provider="CloudFormation"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=input_artifacts
    output_artifacts=[output_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
        <#assign parameter_overrides>
            <#nested/>
        </#assign>
    {
      "StackName": "${stack_name}",
      "ActionMode": "${action_mode}"<#if capabilities?has_content>,
      "Capabilities": "${capabilities}"</#if><#if changeset_name?has_content>,
      "ChangeSetName": "${changeset_name}"</#if><#if template_path?has_content>,
      "TemplatePath": "${template_path}"</#if><#if parameter_overrides?has_content>,
      "ParameterOverrides": ${parameter_overrides}</#if><#if template_configuration?has_content>,
      "TemplateConfiguration": "${template_configuration}"</#if><#if output_file_name?has_content>,
      "OutputFileName": "${output_file_name}"</#if><#if role_arn?has_content>,
      "RoleArn": "${role_arn}"</#if>
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action CodeBuild
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param project_name: the name of the CodeBuild project.
  -- @param category: the category of the build. Validvalues ("Build", "Test").
  -- @param input_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or ID of the
  --                         artifact that the action consumes, such as a test or build artifact.
  -- @param output_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the artifact name or ID
  --                          that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -->
<#macro code_pipeline_stage_action_code_build
name
project_name
category="Build"
input_artifacts=""
output_artifacts=""
role_arn=""
run_order=0
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category=category
        owner="AWS"
        provider="CodeBuild"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=[input_artifacts]
    output_artifacts=[output_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "ProjectName": "${project_name}"
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action CodeDeploy
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param application_name: the name of the CodeDeploy application.
  -- @param deployment_group_name: the name of the CodeDeploy deployment group.
  -- @param input_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or ID of the
  --                         artifact that the action consumes, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -->
<#macro code_pipeline_stage_action_code_deploy
name
application_name
deployment_group_name
input_artifacts=""
role_arn=""
run_order=0
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Deploy"
        owner="AWS"
        provider="CodeDeploy"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=[input_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "ApplicationName": "${application_name}",
      "DeploymentGroupName": "${deployment_group_name}"
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action ElasticBeanstalk
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param application_name: the name of the Elastic Beanstalk application.
  -- @param environment_name: the name of the Elastic Beanstalk environment.
  -- @param input_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or ID of the
  --                         artifact that the action consumes, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -->
<#macro code_pipeline_stage_action_elastic_beanstalk
name
application_name
environment_name
input_artifacts=""
role_arn=""
run_order=0
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Deploy"
        owner="AWS"
        provider="ElasticBeanstalk"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=[input_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "ApplicationName": "${application_name}",
      "EnvironmentName": "${environment_name}"
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action Lambda
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/actions-invoke-lambda-function.html
  --
  -- @param name: the action name.
  -- @param function_name: then ame of the AWS Lambda function.
  -- @param input_artifacts: an array of <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or ID
  --                         of the artifact that the action consumes, such as a test or build artifact.
  -- @param output_artifacts: an array of <@cp.code_pipeline_stage_action_artifact/> directive that contains the
  --                          artifact name or ID that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param user_parameters: a string containing custom data that will be sent to the Lambda in the event data.
  -->
<#macro code_pipeline_stage_action_lambda
name
function_name
input_artifacts=[]
output_artifacts=[]
role_arn=""
run_order=0
user_parameters=""
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Invoke"
        owner="AWS"
        provider="Lambda"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=input_artifacts
    output_artifacts=output_artifacts
    role_arn=role_arn
    run_order=run_order
    >
    {
      "FunctionName": "${function_name}"<#if user_parameters?has_content>,
      "UserParameters": "${user_parameters}"</#if>
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action OpsWorks
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param stack: the name of the OpsWorks stack.
  -- @param app: the name of the OpsWorks app.
  -- @param input_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or ID of the
  --                         artifact that the action consumes, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param layer: the name of the OpsWorks layer.
  -->
<#macro code_pipeline_stage_action_ops_works
name
stack
app
input_artifacts=""
role_arn=""
run_order=0
layer=""
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Deploy"
        owner="AWS"
        provider="OpsWorks"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=[input_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "Stack": "${stack}",
      "App": "${app}"<#if layer?has_content>,
      "Layer": "${layer}"</#if>
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action ECS
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param cluster_name: the name of the ECS cluster.
  -- @param service_name: the name of the ECS service.
  -- @param input_artifacts: a <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or ID of the
  --                         artifact that the action consumes, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -- @param file_name: the name of the image definitions file.
  -->
<#macro code_pipeline_stage_action_ecs
name
cluster_name
service_name
input_artifacts=""
role_arn=""
run_order=0
file_name=""
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Deploy"
        owner="AWS"
        provider="ECS"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=[input_artifacts]
    role_arn=role_arn
    run_order=run_order
    >
    {
      "ClusterName": "${cluster_name}",
      "ServiceName": "${service_name}"<#if file_name?has_content>,
      "FileName": "${file_name}"</#if>
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action Jenkins
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param provider: the name of the action you provided in the AWS CodePipeline Plugin for Jenkins.
  -- @param project_name: the name of the Jenkins project.
  -- @param category: the category of the build. Validvalues ("Build", "Test").
  -- @param input_artifacts: an array of <@cp.code_pipeline_stage_action_artifact/> directive that contains the name or
  --                         ID of the artifact that the action consumes, such as a test or build artifact.
  -- @param output_artifacts: an array of <@cp.code_pipeline_stage_action_artifact/> directive that contains the
  --                          artifact name or ID that is a result of the action, such as a test or build artifact.
  -- @param role_arn: the Amazon Resource Name (ARN) of a service role that the action uses.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -->
<#macro code_pipeline_stage_action_jenkins
name
provider
project_name
category="Build"
input_artifacts=[]
output_artifacts=[]
role_arn=""
run_order=0
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category=category
        owner="Custom"
        provider=provider
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    input_artifacts=input_artifacts
    output_artifacts=output_artifacts
    role_arn=role_arn
    run_order=run_order
    >
    {
      "ProjectName": "${project_name}"
    }
    </@cp.code_pipeline_stage_action>
</#macro>

<#--
  -- CodePipeline Stage Action Manual
  -- Documentation:
  --   https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  --
  -- @param name: the action name.
  -- @param run_order: the order in which AWS CodePipeline runs this action.
  -->
<#macro code_pipeline_stage_action_jenkins
name
run_order=0
>
    <#assign action_type_id>
        <@cp.code_pipeline_stage_action_type_id
        category="Approval"
        owner="AWS"
        provider="Manual"
        version="1"
        />
    </#assign>
    <@cp.code_pipeline_stage_action
    name=name
    action_type_id=action_type_id
    run_order=run_order
    />
</#macro>