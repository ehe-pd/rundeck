<div id="${enc(html:key)}_tooltip" style="display:none;" class="detailpopup node_entry ${islocal?'server':''} tooltipcontent" >
    <span >
        <i class="rdicon node ${runnable ? 'node-runnable' : ''} icon-small"></i>
        ${enc(html:node.nodename)}
    </span>
    <tmpl:nodeFilterLink key="name" value="${node.nodename}"
                         linkicon="glyphicon glyphicon-circle-arrow-right"/>
    <span class="nodedesc"></span>
    <div class="nodedetail">
    <g:render template="/framework/nodeDetailsSimple" bean="${node}" var="node"/>
    </div>
</div>
