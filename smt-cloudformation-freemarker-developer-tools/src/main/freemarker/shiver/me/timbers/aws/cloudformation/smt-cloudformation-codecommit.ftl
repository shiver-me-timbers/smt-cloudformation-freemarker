<#import "smt-cloudformation-core.ftl" as cf>

<#--
  -- CodeCommit
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codecommit-repository.html
  --
  -- @param repository_name: the name for the AWS CodeCommit repository.
  -- @param name: the name of the Cloudformation resource
  -- @param depends_on: the names of Cloudformation resources that this resource depends on.
  -- @param condition: the condition that must be true for this resource to be creatred.
  -- @param last: true if this is the las resource in the list. This will prevent the trailing comma from being printed.
  -- @param repository_description: A description about the AWS CodeCommit repository.
  -- @param triggers: a list of <@code_commit_trigger/> directives that define the actions to take in response to events
  --                  that occur in the repository.
  -->
<#macro code_commit
repository_name
name="CodeCommit"
depends_on=[]
condition=""
last=false
repository_description=""
triggers=[]
>
    <@cf.resource
    name=name
    type="AWS::CodeCommit::Repository"
    depends_on=depends_on
    condition=condition
    last=last
    >
    "RepositoryName" : "${repository_name}<#if repository_description?has_content>,
    "RepositoryDescription" : "${repository_description}"</#if><#if triggers?has_content>,
    "Triggers" : [
        <#list triggers as trigger>
            ${trigger}
        </#list>
    ]
    </#if>
    </@cf.resource>
</#macro>

<#--
  -- CodeCommit Trigger
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codecommit-repository-triggers.html
  --
  -- @param name: the name of the trigger
  -- @param branches: an array of the names of the branches that should be attached to this trigger
  -- @param custom_data: additional information to be sent with the trigger
  -- @param destination_arn: the ARN of the resource targeted by this trigger
  -- @param events: an array of the names of the events that should fire this trigger.
  --                Valid values ("all", "updateReference", "createReference", "deleteReference")
  -->
<#macro code_commit_trigger name branches=[] custom_data="" destination_arn="" events=[]>
      {
        "Name" : "${name}"<#if branches?has_content>,
        "Branches" : [
    <#list branches as branch>
          "${branch}"
    </#list>
        ]</#if><#if custom_data?has_content>,
        "CustomData" : "${custom_data}"</#if><#if destination_arn?has_content>,
        "DestinationArn" : "${destination_arn}"</#if><#if events?has_content>,
        "Events" : [
    <#list events as event>
          "${event}"
    </#list>
        ]</#if>
      }
</#macro>
