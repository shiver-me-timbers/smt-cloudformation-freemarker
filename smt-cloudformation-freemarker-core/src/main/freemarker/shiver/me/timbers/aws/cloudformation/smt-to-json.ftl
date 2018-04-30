<#macro to_json object>
    <#if object?is_hash || object?is_hash_ex>
{
        <#list object as key, value>
            <#assign map_value><@to_json object=value/></#assign>
  "${key}" : ${map_value?trim}<#if !key?is_last>,</#if>
        </#list>
}
    <#elseif object?is_enumerable>
[
        <#list object as item>
            <#assign value><@to_json object=item /></#assign>
  ${value?trim}<#if !item?is_last>,</#if>
        </#list>
]
    <#else>
        "${object?trim}"
    </#if>
</#macro>