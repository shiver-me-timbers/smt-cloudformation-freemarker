<#import "smt-to-json.ftl" as j>

<#--
  -- Cloudformation Template
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html
  --
  -- @param description: a description of the template.
  -- @param metadata: a hash contain key values that provide additional information about the template.
  --                  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/metadata-section-structure.html
  -- @param parameters: an array of <@parameter/> directoves that represent values to pass to your template at runtime.
  -- @param mappings: A mapping of keys and associated values that you can use to specify conditional parameter values.
  --                  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/mappings-section-structure.html
  -- @param conditions: Conditions that control whether certain resources are created or whether certain resource
  --                    properties are assigned a value during stack creation or update.
  --                    https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/conditions-section-structure.html
  -- @param outputs: an arry of <@output/> directoves that describe the values that are returned whenever you view your
  --                 stack's properties.
  --
  -- @nested: the body of this directive should be populated with <@resource/> directives.
  -->
<#macro cloudformation_template_2010_09_09 description metadata={} parameters=[] mappings={} conditions={} outputs=[]>
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "${description}",
    <#if metadata?has_content>
  "Metadata": <@j.to_json object=metadata/>,
    </#if>
    <#if parameters?has_content>
  "Parameters": {
        <#list parameters as parameter>
            ${parameter}
        </#list>
  },
    </#if>
    <#if mappings?has_content>
  "Mappings": <@j.to_json object=mappings/>,
    </#if>
    <#if conditions?has_content>
  "Conditions": <@j.to_json object=conditions/>,
    </#if>
  "Resources": {
    <#nested>
  }<#if outputs?has_content>,
  "Outputs": {
    <#list outputs as output>
        ${output}
    </#list>
  }
</#if>
}
</#macro>

<#--
  -- Cloudformation Template Parameter
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html
  --
  -- @param name: the name of the parameter.
  -- @param type: the data type for the parameter. Valid values("String", "Number", "List<Number>", "CommaDelimitedList").
  --              Also can contain valuse from the following documentation:
  --              https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-specific-parameter-types
  --              https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-ssm-parameter-types
  -- @param description: a string of up to 4000 characters that describes the parameter.
  -- @param default: a value of the appropriate type for the template to use if no value is specified.
  -- @param no_echo: whether to mask the parameter value when anyone makes a call that describes the stack.
  -- @param allowed_pattern: a regular expression that represents the patterns to allow for "String" types.
  -- @param allowed_values: an array containing the list of values allowed for the parameter.
  -- @param constraint_description: a string that explains a constraint when the constraint is violated.
  -- @param min_length: an integer value that determines the smallest number of characters you want to allow for
  --                    "String" types.
  -- @param min_value: a numeric value that determines the smallest numeric value you want to allow for "Number" types.
  -- @param max_length: an integer value that determines the largest number of characters you want to allow for "String"
  --                    types.
  -- @param max_value: a numeric value that determines the largest numeric value you want to allow for "Number" types.
  -- @param last: true if this is the last parameter in the list. This will prevent the trailing comma from being
  --              printed.
  --
  -- @nested: the body of this directive should be populated with the Cloudformatuon resource properties JSON withough
  --          the surrounding "{}".
  -->
<#macro parameter
name
type
description=""
default=""
no_echo=false
allowed_pattern=""
allowed_values=[]
constraint_description=""
min_length=0
min_value=0
max_length=0
max_value=0
last=false
>
    "${name}": {
      "Type": "${type}"<#if description?has_content>,
      "Description": "${description}"</#if><#if default?has_content>,
      "Default": "${default}"</#if><#if no_echo>,
      "NoEcho": true</#if><#if allowed_pattern?has_content>,
      "AllowedPattern": "${allowed_pattern}"</#if><#if allowed_values?has_content>,
      "AllowedValues": [
    <#list allowed_values as value>
        "${value}"<#if !value?is_last>,</#if>
    </#list>
      ]
</#if><#if constraint_description?has_content>,
      "ConstraintDescription": "${constraint_description}"</#if><#if min_length gt 0>,
      "MinLength": ${min_length}</#if><#if min_value gt 0>,
      "MinValue": ${min_value}</#if><#if max_length gt 0>,
      "MaxLength": ${max_length}</#if><#if max_value gt 0>,
      "MaxValue": ${max_value}</#if>
    }<#if !last>,</#if>
</#macro>

<#--
  -- Cloudformation Template Resource
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/resources-section-structure.html
  --
  -- @param name:
  -- @param type: the type of resource.
  --              https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html
  -- @param depends_on: the resources that must be created before this resource can be created.
  -- @param condition: the name of the condition that must be true for this resource to be created.
  -- @param last: true if this is the last resource in the list. This will prevent the trailing comma from being printed.
  -->
<#macro resource name type depends_on=[] condition="" last=false>
    "${name}": {
      "Type": "${type}",
    <#if depends_on?has_content>
      "DependsOn": [
        <#list depends_on as dependency>
            "${dependency}"<#if !dependency?is_last>,</#if>
        </#list>
      ],
    </#if>
    <#if condition?has_content>
      "Condition": "${condition}",
    </#if>
      "Properties": {
    <#nested>
      }
    }<#if !last>,</#if>
</#macro>

<#--
  -- Cloudformation Template Output
  -- Documentation:
  --   https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html
  --
  -- @param name: an identifier for the current output.
  -- @param value: the value of the property returned by the aws cloudformation describe-stacks command.
  -- @param description: a "String" type that describes the output value.
  -- @param condition: the name of the condition that must be true for this output to be returned.
  -- @param export_name: the name of the resource output to be exported for a cross-stack reference.
  --                     https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/walkthrough-crossstackref.html
  -- @param last: true if this is the last output in the list. This will prevent the trailing comma from being printed.
  -->
<#macro output
name
value
description=""
condition=""
export_name=""
last=false
>
    "${name}": {
    <#if description?has_content>
      "Description": "${description}",</#if>
      "Value": "${value}"<#if condition?has_content>,
      "Condition": "${condition}"</#if><#if export_name?has_content>,
      "Export": {
        "Name": "${export_name}"
      }</#if>
    }<#if !last>,</#if>
</#macro>

<#macro tag key value>
    {
      "Key": "${key}",
      "Value": "${value}"
    }
</#macro>