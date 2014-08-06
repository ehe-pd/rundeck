<%@ page import="java.util.regex.Pattern" %>
<%--
 Copyright 2010 DTO Labs, Inc. (http://dtolabs.com)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 --%>
<%--
    _optionValuesSelect.gsp
    
    Author: Greg Schueler <a href="mailto:greg@dtosolutions.com">greg@dtosolutions.com</a>
    Created: May 7, 2010 2:42:23 PM
    $Id$
 --%>

<g:set var="rkey" value="${rkey?:g.rkey()}"/>
<g:set var="fkey" value="${rkey}"/>
<g:set var="realFieldName" value="${(fieldPrefix?fieldPrefix:'')+(fieldName?fieldName:'option.'+optionSelect.name)}"/>

<g:if test="${optionSelect}">
    <div class="row">
    <g:set var="optName" value="${optionSelect.name}"/>
    <g:set var="fieldwatchid" value="${(fieldhiddenid?:rkey+'_'+optName+'_h')}"/>
    <g:set var="hasExtended" value="${!optionSelect.secureInput && (values || optionSelect.values || optionSelect.multivalued) && !err}"/>
    <g:set var="hasTextfield" value="${!optionSelect.enforced && !optionSelect.multivalued || optionSelect.secureInput || !optionSelect.enforced && err}"/>
    <g:set var="hasDefaulter" value="${!optionSelect.enforced && !optionSelect.multivalued && !optionSelect.secureInput && optionSelect.defaultValue && !(optionSelect.values.contains(optionSelect.defaultValue))}"/>
    <g:set var="textcolsize" value="${hasExtended?'8':'12'}"/>
    <g:set var="extcolsize" value="${hasTextfield?'4':'12'}"/>
    <%-- Print out the input box for random input --%>
    <g:if test="${hasTextfield }">
        <div class=" col-sm-${textcolsize}">
        <g:if test="${optionSelect.secureInput}">
            <g:passwordField name="${realFieldName}"
                class="optionvaluesfield  form-control"
                value="${optionSelect.defaultValue?optionSelect.defaultValue:''}"
                maxlength="256" size="40"
                id="${fieldwatchid}"/>
        </g:if>
        <g:else>
            <g:textField name="${realFieldName}"
                class="optionvaluesfield form-control"
                value="${selectedvalue?selectedvalue:selectedoptsmap && null!=selectedoptsmap[optName]?selectedoptsmap[optName]:optionSelect.defaultValue?optionSelect.defaultValue:''}"
                maxlength="256" size="40"
                id="${fieldwatchid}"/>
        </g:else>
            <%-- event handler: when text field is empty, show required option value warning icon if it exists--%>
            <wdgt:eventHandler for="${fieldwatchid}" state="empty" visible="true" targetSelector="${'#'+enc(html:optName)+'_state span.reqwarning'}" frequency="1"  inline='true'/>
        </div>
    </g:if>
    <g:elseif test="${optionSelect.enforced && err}">
        <div class=" col-sm-${textcolsize}">
        <span class="info note"><g:message code="Execution.option.enforced.values.could.not.be.loaded" /></span>
        <input type="hidden" name="${enc(html:realFieldName)}" id="${enc(html:fieldwatchid)}" value=""/>
        </div>
    </g:elseif>
    <%-- The Dropdown list --%>
    <g:if test="${hasExtended}">

        <div class=" col-sm-${extcolsize}">
    
        <g:set var="labelsSet" value="${values && values instanceof Map?values.keySet():values?values:optionSelect.values?optionSelect.values:[]}"/>
        <g:set var="valuesMap" value="${values && values instanceof Map?values:null}"/>
         %{-- set of all of the values that will be pre-shown in the multivalue list --}%
         <g:set var="labelsSetValues" value="${labelsSet?.collect {
                it instanceof Map ? it.value : it
            }}"/>

        <g:if test="${labelsSet && 1==labelsSet.size() && optionSelect.enforced}">
            <g:set var="selentry" value="${labelsSet.iterator().next()}"/>
            <g:if test="${selentry instanceof Map}">
                <g:set var="sellabel" value="${selentry.name}"/>
                <g:set var="selvalue" value="${selentry.value}"/>
            </g:if>
            <g:else>
                <g:set var="sellabel" value="${selentry}"/>
                <g:set var="selvalue" value="${valuesMap?valuesMap[sellabel]:sellabel}"/>
            </g:else>
            <g:hiddenField name="${realFieldName}" value="${selvalue}" id="${fieldwatchid}"/>
            <p class="form-control-static"><span class="singlelabel">${enc(html:sellabel)}</span></p>
        </g:if>
        <g:else>

            <g:if test="${optionSelect.multivalued}">
                <!-- use checkboxes -->
                <g:set var="defaultMultiValues" value="${optionSelect.listDefaultMultiValues()}"/>
                <div class="optionmultiarea " id="${enc(html:fieldwatchid)}">
                    <g:if test="${!optionSelect.enforced}">
                        <%-- variable input text fields --%>
                        <div class="container">
                        <div class="row">
                        <div class="col-sm-12 optionvaluemulti-add">
                            <span class="btn btn-default btn-xs obs_addvar" >
                                New Value <i class="glyphicon glyphicon-plus"></i>
                            </span>
                        </div>
                        </div>
                        </div>
                        <div class="">
                        <div id="${enc(html:rkey)}varinput" class="">

                        </div>
                        </div>
                        <g:if test="${selectedoptsmap && selectedoptsmap[optName] && selectedoptsmap[optName] instanceof String}">
                            %{
                                selectedoptsmap[optName]= selectedoptsmap[optName].split(Pattern.quote(optionSelect.delimiter)) as List
                                }%
                        </g:if>
                        %{--
                        Determine any new values (via selectedoptsmap) that should be added
                        to the multivalue list, and preselected
                         --}%
                        <g:set var="newvals" value="${selectedoptsmap ? labelsSetValues?selectedoptsmap[optName].findAll {  !labelsSetValues.contains(it) } : selectedoptsmap[optName] : null}"/>
                        <g:if test="${newvals}">
                            <g:javascript>
                                fireWhenReady('${enc(js:rkey)}varinput', function(){
                                <g:each in="${newvals}" var="nvalue">
                                    ExecutionOptions.addMultivarValue('${enc(js:optName)}','${enc(js:rkey)}varinput','${enc(js:nvalue)}');
                                </g:each>
                                }
                                );
                            </g:javascript>
                        </g:if>
                        <g:if test="${!labelsSet && !newvals}">
                            <g:javascript>
                                fireWhenReady('${rkey}varinput', function(){ ExecutionOptions.addMultivarValue('${enc(js:optName)}','${rkey}varinput'); } );
                            </g:javascript>
                        </g:if>
                    </g:if>
                    <g:each in="${labelsSet}" var="sellabel">
                        <g:set var="entry" value="${sellabel instanceof Map?sellabel:[name:sellabel,value:sellabel]}"/>
                        <div class="">
                        <div class="">
                        <div class="optionvaluemulti ">
                            <label>
                                <input type="checkbox" name="${enc(html:realFieldName)}" value="${enc(html:entry.value)}" ${selectedvalue && entry.value == selectedvalue || (defaultMultiValues? entry.value in defaultMultiValues : entry.value == optionSelect.defaultValue) || selectedoptsmap && entry.value in selectedoptsmap[optName] ? 'checked' : ''} />
                                ${enc(html:entry.name)}
                            </label>
                        </div>
                        </div>
                        </div>

                    </g:each>
                </div>
                <g:javascript>
                    fireWhenReady('${enc(js:fieldwatchid)}', function(){
                            $$('#${enc(js:fieldwatchid)} input[type="checkbox"]').each(function(e){
                                Event.observe(e,'change',ExecutionOptions.multiVarCheckboxChangeWarningHandler.curry('${enc(js:optName)}'));
                            });
                            $$('#${enc(js:fieldwatchid)} .obs_addvar').each(function(e){
                                Event.observe(e,'click', function(evt){
                                    var roc=_remoteOptionControl('_commandOptions');
                                    ExecutionOptions.addMultivarValue('${enc(js:optName)}','${enc(js:rkey)}varinput',null,roc.observeMultiCheckbox.bind(roc));
                                });
                            });
                        }
                    );
                </g:javascript>
            </g:if>
            <g:else>
                <g:set var="usesTextField" value="${!optionSelect.enforced || err}"/>
                <select class="optionvalues  form-control" id="${!usesTextField? enc(html:fieldwatchid): enc(html:rkey + '_sel')}"
                    ${!usesTextField ? 'name="' + enc(html:realFieldName) + '"' : ''}>
                    <g:if test="${!optionSelect.enforced && !optionSelect.multivalued}">
                        <option value="">-choose-</option>
                    </g:if>

                    <g:each in="${labelsSet}" var="sellabel">
                        <g:set var="entry" value="${sellabel instanceof Map?sellabel:[name:sellabel,value:sellabel]}"/>
                        <option value="${enc(html:entry.value)}" ${selectedvalue && entry.value == selectedvalue || entry.value == optionSelect.defaultValue || selectedoptsmap && entry.value == selectedoptsmap[optName] ? 'selected' : ''}>${enc(html:entry.name)}</option>
                    </g:each>
                </select>
                <g:if test="${usesTextField}">
                <%-- event handler: when select popup value is changed, copy the value to the textfield --%>
                    <wdgt:eventHandler for="${rkey}_sel" notequals="" copy="value" target="${fieldwatchid}" inline='true' multivaluedelimiter="${optionSelect.multivalued?optionSelect.delimiter:null}"/>
                </g:if>

            </g:else>

        </g:else>
        <g:if test="${optionSelect.enforced}">
            <g:javascript>
            fireWhenReady('${enc(js:optName)}_state',
            function(){ $$('${'#' + enc(js:optName)+'_state span.reqwarning'}').each(function(e){$(e).hide();}); }
            );

            </g:javascript>
        </g:if>
        </div>
    </g:if>
    <g:if test="${hasDefaulter}">
        <span class="textbtn textbtn-default"
              id="${enc(js:optName)}_setdefault"
              title="Click to use default value: ${enc(html:optionSelect.defaultValue)}"
            style="${wdgt.styleVisible(if: selectedoptsmap && selectedoptsmap[optName]!=optionSelect.defaultValue)}"
        >
            default: <g:truncate max="50">${enc(html:optionSelect.defaultValue)}</g:truncate>
        </span>
        <g:javascript>
            fireWhenReady('${enc(js:optName)}_setdefault',
            function(){ $$('${'#' + enc(js:optName) + '_setdefault'}').each(function(e){
                Event.observe(e,'click',function(evt){
                    $('${fieldwatchid}').setValue('${enc(js:optionSelect.defaultValue)}');
                });
            }); }
            );
            <wdgt:eventHandlerJS
                    for="${fieldwatchid}"
                    notequals="${enc(js:optionSelect.defaultValue)}"
                    visible="true"
                    target="${enc(html:optName) + '_setdefault'}"
                    frequency="1"
                    inline='true'/>
        </g:javascript>
    </g:if>

    <g:javascript>
        fireWhenReady('_commandOptions', function(){
            <g:if test="${optionSelect.multivalued}">
            _remoteOptionControl('_commandOptions').setFieldMultiId('${enc(js:optName)}','${enc(js:fieldwatchid)}');
            </g:if>
            <g:else>
            _remoteOptionControl('_commandOptions').setFieldId('${enc(js:optName)}','${enc(js:fieldwatchid)}');
            </g:else>
        });
    </g:javascript>

    <span class="loading"></span>
    </div>

</g:if>
<g:if test="${err}">
    <div class="row">
    <div class="col-sm-12">
    <g:if test="${err.code=='empty'}">
       <g:javascript>
        fireWhenReady('_commandOptions', function(){
            _remoteOptionControl('_commandOptions').setFieldRemoteEmpty('${enc(js:optName)}');
        });
        </g:javascript>
    </g:if>
    <g:expander key="${rkey}_error_detail" classnames="textbtn-warning">${enc(html:err.message)}</g:expander>

    <div class="alert alert-warning" style="display:none" id="${rkey}_error_detail">
        <g:if test="${err.exception}">
            <div>Exception: ${enc(html:err.exception.message)}</div>
        </g:if>
        <g:if test="${srcUrl}">
            <div>URL: ${enc(html:srcUrl)}</div>
        </g:if>
    </div>
    </div>
    </div>
</g:if>
<g:elseif test="${values}">
    %{--<g:img file="icon-tiny-ok.png" title="Remote option values loaded from URL: ${enc(html:srcUrl)}"/>--}%
</g:elseif>
