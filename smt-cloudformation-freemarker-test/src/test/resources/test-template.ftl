<#assign test_variable = "a test string"/>
{
<#list ["one", "two", "three"] as number>
  "${number}": "${test_variable}"<#if !numer?is_last>,</#if>
</#list>
}