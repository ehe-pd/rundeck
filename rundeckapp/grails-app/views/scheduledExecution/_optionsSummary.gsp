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
    _optionsSummary.gsp
    
    Author: Greg Schueler <a href="mailto:greg@dtosolutions.com">greg@dtosolutions.com</a>
    Created: Aug 6, 2010 11:09:04 AM
    $Id$
 --%>
<g:if test="${options}">
<span class="argstring">
<g:each in="${options}" var="optionsel" status="i">
        <span class=" ${optionsel.secureInput?'secure':''}"
              title="${enc(html:optionsel.description)}">${enc(html:optionsel.name)}</span><g:if
        test="${optionsel.defaultValue}">: <code class="optvalue">${optionsel.secureInput?'*****':enc(html:optionsel.defaultValue)}</code></g:if><g:if
        test="${i <options.size()-1}">,</g:if>
</g:each>
</span>
</g:if>
<g:else>
    <span class="info note">None</span>
</g:else>
<g:if test="${edit}">
<g:if test="${options}">
    <span class="action textbtn ">edit</span>
</g:if>
<g:else>
    <span class="action textbtn ">add options</span>
</g:else>
</g:if>
