<#import "smt-cloudformation-core.ftl" as cf>

<#--
  -- CodeBuild Project
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codecommit-repository.html
  --
  -- @param build_name: a name for the CodeBuild project. The name must be unique across all of the projects in your
  --                    AWS account.
  -- @param source: a <@code_build_source/> directive the contains the source code settings for the project.
  -- @param environment: a <@code_build_environment/> directive that contains the build environment settings for the
  --                     project.
  -- @param service_role: the ARN of the service role that AWS CodeBuild uses to interact with services on your behalf.
  -- @param artifacts: a <@code_build_artifacts/> directive that contains the output settings for artifacts that the
  --                   project generates during a build.
  -- @param name: the name of the Cloudformation resource
  -- @param depends_on: the names of Cloudformation resources that this resource depends on.
  -- @param condition: the condition that must be true for this resource to be creatred.
  -- @param last: true if this is the las resource in the list. This will prevent the trailing comma from being printed.
  -- @param badge_enabled: indicates whether AWS CodeBuild generates a publicly accessible URL for your project's build
  --                       badge.
  -- @param cache: a <@code_build_cache/> directive that contians the settings that AWS CodeBuild uses to store and
  --               reuse build dependencies.
  -- @param description: a description of the project. Use the description to identify the purpose of the project.
  -- @param encryption_key: the alias or Amazon Resource Name (ARN) of the AWS Key Management Service (AWS KMS) customer
  --                        master key (CMK) that AWS CodeBuild uses to encrypt the build output.
  -- @param timeout_in_minutes: the number of minutes after which AWS CodeBuild stops the build if it's not complete.
  -- @param triggers: a <@code_build_triggers/> directive that contains the settings for an existing AWS CodeBuild build
  --                  project that has its source code stored in a GitHub repository, enables AWS CodeBuild to begin
  --                  automatically rebuilding the source code every time a code change is pushed to the repository.
  -- @param vpc_config: a <@code_build_vpc_config/> directive that contains the settings that enable AWS CodeBuild to
  --                    access resources in an Amazon VPC.
  --                    https://docs.aws.amazon.com/codebuild/latest/userguide/vpc-support.html
  -- @param tags: an array of <@smt-cloudformation-core.ftl#tag/> directives that can contain extra meta data for the
  --              CodeBuild.
  -->
<#macro code_build
build_name
source
environment
service_role
artifacts
name="CodeBuild"
depends_on=[]
condition=""
last=false
badge_enabled=false
cache=""
description=""
encryption_key=""
timeout_in_minutes=0
triggers=""
vpc_config=""
tags=[]
>
    <@cf.resource
    name=name
    type="AWS::CodeCommit::Repository"
    depends_on=depends_on
    condition=condition
    last=last
    >
    "Name" : "${build_name}",
    "Source" : ${source},
    "Environment" : ${environment},
    "ServiceRole" : "${service_role}",
    "Artifacts" : ${artifacts}<#if badge_enabled>,
    "BadgeEnabled" : ${badge_enabled?c}</#if><#if cache?has_content>,
    "Cache" : ${cache}</#if><#if description?has_content>,
    "Description" : "${description}"</#if><#if encryption_key?has_content>,
    "EncryptionKey" : "${encryption_key}"</#if><#if timeout_in_minutes gt 0>,
    "TimeoutInMinutes" : ${timeout_in_minutes}</#if><#if triggers?has_content>,
    "Triggers" : ${triggers}</#if><#if vpc_config?has_content>,
    "VpcConfig" : ${vpc_config}</#if><#if tags?has_content>,
    "Tags" : [ Resource Tag, ... ]</#if>
    </@cf.resource>
</#macro>

<#--
  -- CodeBuild Project Source
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-source.html
  --
  -- @param type: The type of repository that contains your source code.
  --              Valid values ("CODECOMMIT", "CODEPIPELINE", "GITHUB", "GITHUB_ENTERPRISE", "BITBUCKET", "S3").
  -- @param location: The location of the source code in the specified repository type. Required unless type is
  --                  "CODEPIPELINE".
  --                  https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli
  -- @param git_clone_depth: The depth of history to download. Minimum value is 0.
  -- @param insecure_ssl: This is used with GitHub Enterprise only. Set to true to ignore SSL warnings while connecting
  --                      to your GitHub Enterprise project repository.
  -- @param auth_type: The authorization type to use. The only valid value is OAUTH, which represents the OAuth
  --                   authorization type.
  -- @param auth_resource: The resource value that applies to the specified authorization type.
  --
  -- @nested the build specification for the project. If this value is not provided, then the source code must contain a
  --         build spec file named buildspec.yml at the root level. If this value is provided, it can be either a single
  --         string containing the entire build specification, or the path to an alternate build spec file relative to
  --         the value of the built-in environment variable CODEBUILD_SRC_DIR.
  -->
<#macro code_build_source type location="" git_clone_depth=0 insecure_ssl=false auth_type="" auth_resource="">
    <#assign build_spec>
        <#nested>
    </#assign>
    <#assign build_spec = build_spec?remove_ending("\n")>
{
  "Type" : "${type}"<#if location?has_content>,
  "Location" : "${location}"</#if><#if git_clone_depth?has_content>,
  "GitCloneDepth" : ${git_clone_depth}</#if>,
  "BuildSpec" : <#if !build_spec?contains("\n")>"${build_spec}",<#else>{
    "Fn::Join": [
      "\n",
      [
    <#list build_spec?split("\n") as line>
        "${line}"<#if !line?is_last>,</#if>
    </#list>
      ]
    ]
  }
</#if><#if insecure_ssl>,
  "InsecureSsl" : ${insecure_ssl?c}</#if><#if auth_type?has_content>,
  "Auth" : {
    "Type" : "${auth_type}",
    "Resource" : "${auth_resource}"
  }
</#if>
}
</#macro>

<#--
  -- CodeBuild Project Environment
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-environment.html
  --
  -- @param compute_type: the type of compute environment.
  --                      Valid values ("BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", and "BUILD_GENERAL1_LARGE").
  -- @param image: the Docker image identifier that the build environment uses.
  -- @param type: the type of build environment. The only allowed value is "LINUX_CONTAINER".
  -- @param privileged_mode: Indicates how the project builds Docker images. Specify true to enable running the Docker
  --                         daemon inside a Docker container.
  --
  -- @nested the body of this directive should be populated with <@code_build_environment_variable/> directives.
  -->
<#macro code_build_environment compute_type image type="LINUX_CONTAINER" privileged_mode=false>
    <#assign environment_variables>
        <#nested>
    </#assign>
{
  "Type" : "${type}",
  "ComputeType" : "${compute_type}",
  "Image" : "${image}"<#if environment_variables?has_content>,
  "EnvironmentVariables" : [
    ${environment_variables}
  ]</#if><#if privileged_mode>,
  "PrivilegedMode" : ${privileged_mode?c}
</#if>
}
</#macro>

<#--
  -- CodeBuild Project Environment Variable
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-environmentvariable.html
  --
  -- @param name: the name of an environment variable.
  -- @param value: the value of the environment variable.
  -- @param type: the type of environment variable. Valid values ("PARAMETER_STORE", "PLAINTEXT").
  -->
<#macro code_build_environment_variable name value type="PLAINTEXT">
{
  "Name" : "${name}",
  "Value" : "${value}",
  "Type" : "${type}"
}
</#macro>

<#--
  -- CodeBuild Project Artifacts
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-artifacts.html
  --
  -- @param type: the type of build output artifact. Valid values ("CODEPIPELINE", "NO_ARTIFACTS", "S3");
  -- @param name: the name of the build output folder where AWS CodeBuild saves the build output artifacts.
  --              If you specify CODEPIPELINE or NO_ARTIFACTS for the Type property, don't specify this property.
  -- @param location: the location where AWS CodeBuild saves the build output artifacts.
  --                  If you specify CODEPIPELINE or NO_ARTIFACTS for the Type property, don't specify this property.
  -- @param packaging: indicates how AWS CodeBuild packages the build output artifacts. Valid values ("ZIP", "NONE").
  -- @param path: the path to the build output folder where AWS CodeBuild saves the build output artifacts.
  -- @param namespace_type: the information AWS CodeBuild adds to the build output path, such as a build ID.
  --                        Valid values ("BUILD_ID", "NONE").
  -->
<#macro code_build_artifacts type name="" location="" packaging="" path="" namespace_type="">
{
  "Type" : "${type}"<#if name?has_content>,
  "Name" : "${name}"</#if><#if location?has_content>,
  "Location" : "${location}"</#if><#if packaging?has_content>,
  "Packaging" : "${packaging}"</#if><#if path?has_content>,
  "Path" : "${path}"</#if><#if namespace_type?has_content>,
  "NamespaceType" : "${namespace_type}"</#if>
}
</#macro>

<#--
  -- CodeBuild Project Artifacts
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-artifacts.html
  --
  -- @param type: the type of cache for the build project to use. Valid values ("NO_CACHE", "S3").
  -- @param location: the Amazon S3 bucket name and prefix—for example, mybucket/prefix. This value is ignored when
  --                  type is set to NO_CACHE.
  -->
<#macro code_build_cache type location="">
{
  "Type" : "${type}"<#if location?has_content>,
  "Location" : "${location}"
</#if>
}
</#macro>

<#--
  -- CodeBuild Project Triggers
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-projecttriggers.html
  --
  -- @param webhook: specifies whether or not to begin automatically rebuilding the source code every time a code change
  --                 is pushed to the repository.
  -->
<#macro code_build_triggers webhook=false>
      {
    <#if webhook>
        "Webhook" : ${webhook?c}
    </#if>
      }
</#macro>

<#--
  -- CodeBuild Project Triggers
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-projecttriggers.html
  --
  -- @param vpc_id: the ID of the Amazon VPC.
  -- @param subnet_ids: an array of IDs of the subnets in the Amazon VPC. The maximum count is 16.
  -- @param security_group_ids: an array of IDs of the security groups in the Amazon VPC. The maximum count is 5.
  -->
<#macro code_build_vpc_config vpc_id subnet_ids security_group_ids>
{
  "VpcId" : "${vpc_id}",
  "Subnets" : [
    <#list subnet_ids as subnet_id>
    "${subnet_id}"<#if !subnet_id?is_last>,</#if>
    </#list>
  ],
  "SecurityGroupIds" : [
    <#list security_group_ids as security_group_id>
    "${security_group_id}"<#if !security_group_id?is_last>,</#if>
    </#list>
  ]
}
</#macro>
