<#import "shiver/me/timbers/aws/cloudformation/smt-cloudformation-core.ftl" as cf>

<#macro test_parameter1>
    <@cf.parameter
    name="TestParameter1"
    type="String"
    description="test parameter 1 description"
    default="test default value"
    no_echo=true
    allowed_pattern="[a-z ]+"
    allowed_values=["test default value", "another test default value"]
    constraint_description="this is a test parameter so have contrived to use all the options"
    min_length=1
    max_length=100
    />
</#macro>

<#macro test_parameter2>
    <@cf.parameter name="TestParameter2" type="Number" min_value=1 max_value=100 last=true/>
</#macro>

<@cf.cloudformation_template_2010_09_09
description="test description"
metadata={"test-metadata-name": "test-metadata-name"}
parameters=[test_parameter1, test_parameter2]
mappings={"TestMapping": {"test_map": {"one": 1}}}
conditions={"TestCondition" : {"Fn::Equals" : [{"Ref" : "TestParameter1"}, "a test value"]}}
outputs=[test_output1, test_output2]
>
    <@cf.resource
    name="TestResource1"
    type="AWS::SSM::Parameter"
    depends_on=["TestResource2"]
    condition="TestCondition"
    >
        "Name" : "test_parameter1",
        "Type" : "String",
        "Value" : "a test parameter value"
    </@cf.resource>
    <@cf.resource
    name="TestResource2"
    type="AWS::SSM::Parameter"
    last=true
    >
        "Name" : "test_parameter2",
        "Type" : "String",
        "Value" : "another test parameter value"
    </@cf.resource>
</@cf.cloudformation_template_2010_09_09>

<#macro test_output1>
    <@cf.output
    name="TestOutput1"
    value="a test output value"
    description="This is a test output value."
    condition="TestCondition"
    export_name="TestExport"
    />
</#macro>

<#macro test_output2>
    <@cf.output name="TestOutput2" value="another test output value" last=true/>
</#macro>