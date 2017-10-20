<xsl:stylesheet version="2.0" 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"  
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:iirds="http://iirds.tekom.de/iirds#"
    xmlns:fc="http://fastclass.de/fc#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    exclude-result-prefixes="xs xh">

    <xsl:output method="xml" omit-xml-declaration="no" indent="yes" />

    <!--
    Publish to iiRDS Package
    Part of out.iirds
    (c) 2017, Jan Oevermann // License: MIT
    -->

    <!-- Default Params -->
    <xsl:param name="tmp.dir" as="xs:string" />
    <xsl:param name="pub.dir" as="xs:string" />
    <xsl:param name="base.dir" as="xs:string" />
    <xsl:param name="publication" as="xs:string" />

    <!-- File protocoll for cross-platform file URLs -->
    <xsl:variable name="file" as="xs:string">file:///</xsl:variable>

    <!-- Base URL for infoflow publications -->
    <xsl:variable name="if.base" as="xs:string">http://infoflow.icms.de/publication/</xsl:variable>

    <!-- Name of Publication -->
    <xsl:variable name="pub.name" select="document(concat($file, $pub.dir, '/', $publication, '.pub'))/publication/meta/name"/>

    <!-- iiRDS Schema Implementation -->
    <xsl:variable name="iirds" select="document('iirds/iiRDS_RFC_0.9.rdfs')"/>
    <xsl:variable name="iirds.uri">http://iirds.tekom.de/iirds#</xsl:variable> 
    <xsl:variable name="iirds.short">iirds:</xsl:variable>
    
    <!-- fastclass Metadata -->
    <xsl:variable name="fc.meta" select="true()" as="xs:boolean"/>
    
    <!-- Root template for XML tree structure -->
    <xsl:template match="/">

        <rdf:RDF>
            <!-- generate basic package metadata -->
            <iirds:Package rdf:about="{concat($if.base, $publication)}">
                <iirds:Version>0.9</iirds:Version>
                <iirds:language>de-DE</iirds:language>
                <iirds:formatRestriction>A</iirds:formatRestriction>
                <iirds:title>
                    <xsl:value-of select="$pub.name"/>
                </iirds:title>
                <iirds:identifier>
                    <xsl:value-of select="$publication"/>
                </iirds:identifier>
                <iirds:has-author>infoflow</iirds:has-author>
            </iirds:Package>
            
            <!-- generate directory nodes to keep original structure of document -->
            <iirds:DirectoryNode rdf:about="{concat($if.base, $publication, '/outline')}">
                <iirds:has-directory-structure-type rdf:resource="http://iirds.tekom.de/iirds#TableOfContents" /> 
                <xsl:apply-templates select="descendant::xh:section[1]" mode="toc" />
            </iirds:DirectoryNode>
            
            <xsl:apply-templates />
        </rdf:RDF>
    </xsl:template>
        
    <xsl:template match="xh:section">
        <xsl:variable name="section.id" select="@id" />
        
        <xsl:variable name="node.ref" select="."/>

        <iirds:Topic rdf:about="{concat($if.base, $publication, '/', $section.id)}">
            <!-- relation to parent package -->
            <iirds:is-part-of-package rdf:resource="{concat($if.base, $publication)}" />
            
            <!-- relation to file rendition -->
            <iirds:has-rendition>
                <iirds:Rendition rdf:about="{concat($if.base, $publication, '/', $section.id, '/xhtml')}">
                    <iirds:format>application/xhtml+xml</iirds:format>
                    <iirds:source>
                        <xsl:value-of select="concat('../CONTENT/modules/', $publication, '_', $section.id, '.xhtml')"/>
                    </iirds:source>
                </iirds:Rendition>
                <iirds:Rendition rdf:about="{concat($if.base, $publication, '/', $section.id, '/document')}">
                    <iirds:format>application/xml</iirds:format>
                    <iirds:source>
                        <xsl:value-of select="concat('../CONTENT/document/', $publication, '.xml')"/>
                    </iirds:source>
                    <iirds:has-selector>
                        <iirds:FragmentSelector>
                            <dcterms:conformsTo rdf:resource="http://tools.ietf.org/rfc/rfc3023"/>
                            <rdf:value><!--
                                -->#<xsl:value-of select="$section.id"/><!--
                         --></rdf:value>
                        </iirds:FragmentSelector>
                    </iirds:has-selector>
                </iirds:Rendition>
            </iirds:has-rendition> 
            
            <!-- generate iiRDS metadata -->
            <xsl:for-each select="@iirds:*">
                <xsl:variable name="iirds.name" select="local-name()"/>
                <xsl:variable name="iirds.class" select="concat($iirds.uri, $iirds.name)"/>
                <xsl:variable name="iirds.instance" select="."/>
                
                <xsl:variable name="iirds.rel" 
                    select="if ($iirds//rdf:Property[rdfs:range/@rdf:resource = $iirds.class]) 
                            then ($iirds//rdf:Property[rdfs:range//@rdf:resource = $iirds.class]/@rdf:about) 
                            else ($iirds//rdf:Property[rdfs:range/@rdf:resource = $iirds//rdfs:Class[@rdf:about = $iirds.class]/rdfs:subClassOf/@rdf:resource]/@rdf:about)" />
                
                <xsl:variable name="element.name" select="concat($iirds.short, substring-after($iirds.rel, $iirds.uri))" />
                
                <xsl:element name="{$element.name}" rdf:about="{concat($if.base, $publication, '/', $section.id, '/', $iirds.nam)}">
                    <xsl:attribute name="rdf:resource" select="$iirds.instance"/>
                    
                    <xsl:if test="$fc.meta">
                        <xsl:for-each select="$node.ref/@fc:*[$iirds.name = local-name()]">
                            <xsl:attribute name="fc:confidence" select="."/>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:element>                
            </xsl:for-each>
             
        </iirds:Topic>
        
        <xsl:if test="not(doc-available(concat($file, $pub.dir, '/targets/iirds/CONTENT/modules/', $publication, '_', $section.id, '.xhtml')))">
            <xsl:result-document  
                href="{concat($file, $pub.dir, '/targets/iirds/CONTENT/modules/', $publication, '_', $section.id, '.xhtml')}" 
                exclude-result-prefixes="rdf rdfs iirds"
                omit-xml-declaration="no">
                <html>
                    <head>
                        <title>
                            <xsl:value-of select="xh:h1"/>
                        </title>
                    </head>
                    <body>
                        <xsl:apply-templates mode="copy"/>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:apply-templates select="xh:section"/>
    </xsl:template>
    
    <!-- TOC templates -->
    
    <xsl:template match="xh:section[not(preceding-sibling::xh:section)]" mode="toc">
        <xsl:variable name="section.id" select="@id" />
        
        <iirds:has-first-child>
            <iirds:DirectoryNode rdf:about="{concat($if.base, $publication, '/outline/', $section.id)}">
                <iirds:references-information-unit rdf:resource="{concat($if.base, $publication, '/', $section.id)}"/>
                <rdfs:label xml:lang="de">
                    <xsl:value-of select="xh:h1"/>
                </rdfs:label>
                <xsl:apply-templates select="child::xh:section[1]" mode="toc"/>
                <xsl:apply-templates select="following-sibling::xh:section[1]" mode="toc"/>                
            </iirds:DirectoryNode>
        </iirds:has-first-child>
        
        <iirds:has-next-sibling rdf:resource="http://iirds.tekom.de/iirds#nil"/>
    </xsl:template>
    
    <xsl:template match="xh:section[preceding-sibling::xh:section]" mode="toc">
        <xsl:variable name="section.id" select="@id" />
        
        <iirds:has-next-sibling>
            <iirds:DirectoryNode rdf:about="{concat($if.base, $publication, '/outline/', $section.id)}">
                <iirds:references-information-unit rdf:resource="{concat($if.base, $publication, '/', $section.id)}"/>
                <rdfs:label xml:lang="de">
                    <xsl:value-of select="xh:h1"/>
                </rdfs:label>
                <xsl:apply-templates select="child::xh:section[1]" mode="toc"/>                    
                
            </iirds:DirectoryNode>
        </iirds:has-next-sibling>
        
        <xsl:choose>
            <xsl:when test="following-sibling::xh:section">                
                <xsl:apply-templates select="following-sibling::xh:section[1]" mode="toc"/>
            </xsl:when>
            <xsl:otherwise>
                <iirds:has-next-sibling rdf:resource="http://iirds.tekom.de/iirds#nil"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Build flat html hierarchies -->
    <xsl:template match="xh:h1" mode="copy">
        <xsl:variable name="title.element" select="concat('h', count(ancestor::xh:section))" />
        <xsl:element name="{$title.element}">
            <xsl:apply-templates mode="copy"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="xh:title"/>
    <xsl:template match="xh:title" mode="copy"/>
    
    <!-- Metadata from original Pi-Fan files -->
    <xsl:template match="xh:p[@class='MetaDeckblatt']" mode="copy"/>

    <!-- Identity template -->
    <xsl:template match="@*[not(contains(name(), $iirds.short))]|node()[not(self::xh:section)]" mode="copy">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()" mode="copy"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>