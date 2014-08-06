<%@ page contentType="text/xml;charset=UTF-8" %><?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:taxo="http://purl.org/rss/1.0/modules/taxonomy/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
  <channel>
    <title>${g.enc(html:feedTitle)}</title>
    <link>${g.enc(html:feedLink)}</link>
    <description>${g.enc(html:feedDescription)}</description>

    <g:each in="${items}" var="item">
        
    <item>
        <title>${item.g.enc(html:title)}</title>
        <link>${item.g.enc(html:link)}</link>
        <guid>${item.g.enc(html:link)}</guid>
        <g:if test="${item.description}">
            <description>${g.enc(html:item.description)}</description>
        </g:if>
        <g:elseif test="${item.templateName && item.model}">
            <description>${g.enc(html:render(template:item.templateName,model:item.model))}</description>
        </g:elseif>
        <g:else>
            <description></description>
        </g:else>
        <pubDate><g:rfc822Date date="${item.date}"/></pubDate>
        ${'<dc:date>'}<g:w3cDate date="${item.date}"/>${'</dc:date>'}
    </item>
    </g:each>
  </channel>
</rss>
