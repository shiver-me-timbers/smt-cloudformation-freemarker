<#import "shiver/me/timbers/aws/cloudformation/smt-cloudformation-core.ftl" as cf>
<#import "shiver/me/timbers/aws/cloudformation/smt-cloudformation-codecommit.ftl" as cc>
<#import "shiver/me/timbers/aws/cloudformation/smt-cloudformation-codebuild.ftl" as cb>
<#import "shiver/me/timbers/aws/cloudformation/smt-cloudformation-codepipeline.ftl" as cp>
<#import "shiver/me/timbers/aws/cloudformation/smt-cloudformation-codepipeline-actions.ftl" as ca>

<@cf.cloudformation_template_2010_09_09 description="test description">
    <#assign code_commit_resource_name="CodeCommit"/>
    <#assign code_commit_repo_name="test_code_commit"/>
    <#assign code_commit_trigger>
        <@cc.code_commit_trigger
        name="test_code_commit_trigger"
        branches=["master", "test_branch"]
        custom_data="some stuff to send along with the trigger"
        destination_arn="test_arn_for_code_pipeline"
        events=["all"]
        />
    </#assign>
    <@cc.code_commit
    name=code_commit_resource_name
    repository_name=code_commit_repo_name
    repository_description="test code commit description"
    triggers=[code_commit_trigger]
    />

    <#assign pipeline_role_arn="test_pipeline_role_arn"/>
    <#assign source_output_artifact>
        <@cp.code_pipeline_stage_action_artifact name="source_code_output_artifact"/>
    </#assign>
    <#assign code_pipeline_s3_bucket="test_bucket"/>
    <#assign encryption_key>
        <@cp.code_pipeline_artifact_store_encryption_key id="test_encryption_key"/>
    </#assign>
    <#assign artifact_store>
        <@cp.code_pipeline_artifact_store location=code_pipeline_s3_bucket encryption_key=encryption_key/>
    </#assign>
    <#assign disable_transition>
        <@cp.code_pipeline_disable_inbound_stage_transitions stage_name="Deploy" reason="disabled as test"/>
    </#assign>

    <#assign code_build_resource_name="CodeBuild"/>
    <#assign code_test_resource_name="CodeTest"/>
    <#assign code_build_name="code_build"/>
    <#assign code_test_name="code_test"/>
    <#assign build_output="build_output_artifact"/>
    <#assign build_output_artifact>
        <@cp.code_pipeline_stage_action_artifact name=build_output/>
    </#assign>
    <#assign build_role="build_role"/>

    <#assign deploy_role="deploy_role"/>

    <@cp.code_pipeline
    depends_on=[code_commit_resource_name, code_build_resource_name, code_test_resource_name]
    artifact_store=artifact_store
    role_arn=pipeline_role_arn
    disable_inbound_stage_transitions=[disable_transition]
    restart_execution_on_update=true
    >


        <#assign stack_name="test_stack_name"/>
        <#assign change_set_name="test_change_set_name"/>
        <#assign deploy_output_artifact>
            <@cp.code_pipeline_stage_action_artifact name="deploy_output_artifact"/>
        </#assign>

        <@cp.code_pipeline_stage name="Source">
            <@ca.code_pipeline_stage_action_code_commit
            name="Source"
            repository_name="test_code_commit_repo"
            output_artifacts=source_output_artifact
            poll_for_source_changes=true
            last=true
            />
        </@cp.code_pipeline_stage>
        <@cp.code_pipeline_stage name="Build">
            <@ca.code_pipeline_stage_action_code_build
            name="Build"
            project_name=code_build_name
            input_artifacts=source_output_artifact
            output_artifacts=build_output_artifact
            role_arn=build_role
            run_order=1
            />
            <@ca.code_pipeline_stage_action_code_build
            name="Test"
            category="Test"
            project_name=code_test_name
            input_artifacts=build_output_artifact
            role_arn=build_role
            run_order=2
            last=true
            />
        </@cp.code_pipeline_stage>
        <@cp.code_pipeline_stage name="Deploy" last=true>
            <@ca.code_pipeline_stage_action_cloudformation
            name="CreateChangeSet"
            stack_name=stack_name
            action_mode="CHANGE_SET_REPLACE"
            changeset_name=change_set_name
            capabilities="CAPABILITY_NAMED_IAM"
            template_configuration="template_config.json"
            template_path="${build_output}::template.json"
            input_artifacts=[build_output_artifact]
            role_arn=deploy_role
            run_order=1
            />
            <@ca.code_pipeline_stage_action_cloudformation
            name="DeployChangeSet"
            stack_name=stack_name
            action_mode="CHANGE_SET_EXECUTE"
            changeset_name=change_set_name
            output_file_name="template_output.json"
            output_artifacts=deploy_output_artifact
            role_arn=deploy_role
            run_order=2
            last=true
            />
        </@cp.code_pipeline_stage>
    </@cp.code_pipeline>

    <#assign code_build_source>
        <@cb.code_build_source type="CODEPIPELINE">
version: 0.2

phases:
  build:
    commands:
      - mvn clean compile
cache:
  paths:
    - '/root/.m2/repository/**/*'
artifacts:
  files:
    - '**/*'
        </@cb.code_build_source>
    </#assign>
    <#assign code_build_environment>
        <@cb.code_build_environment
        compute_type="BUILD_GENERAL1_SMALL"
        image="aws/codebuild/eb-java-8-amazonlinux-64:2.4.3"
        privileged_mode=true
        >
            <@cb.code_build_environment_variable name="TEST" value="test value"/>
        </@cb.code_build_environment>
    </#assign>
    <#assign code_build_cache>
        <@cb.code_build_cache type="S3" location="${code_pipeline_s3_bucket}/cache/build"/>
    </#assign>
    <#assign code_build_artifacts>
        <@cb.code_build_artifacts type="CODEPIPELINE"/>
    </#assign>
    <#assign code_build_tag>
        <@cf.tag key="test_tag" value="Test tag value."/>
    </#assign>
    <@cb.code_build
    name=code_build_resource_name
    build_name=code_build_name
    description="Build Project"
    source=code_build_source
    environment=code_build_environment
    service_role=build_role
    cache=code_build_cache
    artifacts=code_build_artifacts
    tags=[code_build_tag]
    />

    <#assign code_test_source>
        <@cb.code_build_source type="CODEPIPELINE">
version: 0.2

phases:
  build:
    commands:
      - mvn clean test
cache:
  paths:
    - '/root/.m2/repository/**/*'
artifacts:
  files:
    - '**/*'
        </@cb.code_build_source>
    </#assign>
    <#assign code_test_environment>
        <@cb.code_build_environment
        compute_type="BUILD_GENERAL1_SMALL"
        image="aws/codebuild/eb-java-8-amazonlinux-64:2.4.3"
        />
    </#assign>
    <#assign code_test_vpc_config>
        <@cb.code_build_vpc_config
        vpc_id="test_vpc_id"
        subnet_ids=["test_subnet_id1", "test_subnet_id2", "test_subnet_id3"]
        security_group_ids=["test_security_group_id1", "test_security_group_id2", "test_security_group_id3"]
        />
    </#assign>
    <@cb.code_build
    name=code_test_resource_name
    build_name=code_test_name
    description="Test Project"
    source=code_test_source
    environment=code_test_environment
    service_role=build_role
    cache=code_build_cache
    artifacts=code_build_artifacts
    vpc_config=code_test_vpc_config
    />

    <@cp.code_pipeline
    name="GitHubPipeline"
    artifact_store=artifact_store
    role_arn=pipeline_role_arn
    disable_inbound_stage_transitions=[disable_transition]
    restart_execution_on_update=true
    >
        <@cp.code_pipeline_stage name="Source">
            <@ca.code_pipeline_stage_action_github
            name="Source"
            owner="test_owner"
            repo="test_repo"
            oauth_token="test_oauth_token"
            branch="test_branch"
            output_artifacts=source_output_artifact
            last=true
            />
        </@cp.code_pipeline_stage>
        <@cp.code_pipeline_stage name="Build">
            <@ca.code_pipeline_stage_action_jenkins
            name="Build"
            provider="jenkins_build_provider"
            project_name="jenkins_build"
            input_artifacts=[source_output_artifact]
            output_artifacts=[build_output_artifact]
            run_order=1
            />
            <@ca.code_pipeline_stage_action_jenkins
            name="Test"
            category="Test"
            provider="jenkins_test_provider"
            project_name="jenkins_test"
            run_order=2
            last=true
            />
        </@cp.code_pipeline_stage>
        <@cp.code_pipeline_stage name="Deploy" last=true>
            <@ca.code_pipeline_stage_action_manual
            name="ManualDeploy"
            run_order=1
            />
            <@ca.code_pipeline_stage_action_code_deploy
            name="DeployApplication"
            application_name="deploy_application_name"
            deployment_group_name="deploy_group_name"
            input_artifacts=build_output_artifact
            run_order=2
            />
            <@ca.code_pipeline_stage_action_ops_works
            name="DeployConfiguration"
            stack="ops_works_stack"
            app="ops_works_app"
            layer="ops_works_layer"
            input_artifacts=build_output_artifact
            run_order=3
            last=true
            />
        </@cp.code_pipeline_stage>
    </@cp.code_pipeline>

    <@cp.code_pipeline
    name="S3Pipeline"
    artifact_store=artifact_store
    role_arn=pipeline_role_arn
    disable_inbound_stage_transitions=[disable_transition]
    restart_execution_on_update=true
    last=true
    >
        <@cp.code_pipeline_stage name="Source">
            <@ca.code_pipeline_stage_action_s3
            name="Source"
            s3_bucket="source_s3_bucket"
            s3_object_key="test/s3/source.zip"
            output_artifacts=source_output_artifact
            last=true
            />
        </@cp.code_pipeline_stage>
        <@cp.code_pipeline_stage name="Build">
            <@ca.code_pipeline_stage_action_lambda
            name="Build"
            function_name="lambda_build_function"
            input_artifacts=[source_output_artifact]
            output_artifacts=[build_output_artifact]
            run_order=1
            last=true
            />
        </@cp.code_pipeline_stage>
        <@cp.code_pipeline_stage name="Deploy" last=true>
            <@ca.code_pipeline_stage_action_ecs
            name="DeployApplication"
            cluster_name="test_cluster_name"
            service_name="test_service_name"
            input_artifacts=build_output_artifact
            run_order=2
            />
            <@ca.code_pipeline_stage_action_elastic_beanstalk
            name="DeployConfiguration"
            application_name="test_eb_application_name"
            environment_name="test_eb_environment_name"
            input_artifacts=build_output_artifact
            run_order=3
            last=true
            />
        </@cp.code_pipeline_stage>
    </@cp.code_pipeline>
</@cf.cloudformation_template_2010_09_09>