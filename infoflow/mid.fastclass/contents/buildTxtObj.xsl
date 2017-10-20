<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="text"/>
    
    <!--
    Build JSON text object for processing with JS
    Part of mid.classify
    (c) 2016, Jan Oevermann // License: MIT
    -->
    
    <xsl:template match="/">[
        <xsl:apply-templates select="//section" mode="flat"/>
        ]  </xsl:template>
    
    <xsl:template match="*" mode="flat">
        <!-- get all text from element -->
        <xsl:variable name="txt">
            <xsl:apply-templates select="*" mode="text" />
        </xsl:variable>
        <!-- get all signal text from element -->
        <xsl:variable name="sig">
            <xsl:apply-templates select="child::h1 | child::h2" />
        </xsl:variable>
        {
        "xid": "<xsl:value-of select="@id"/>",
        "txt": "<xsl:value-of select="normalize-space(replace($txt, '[\\&quot;&#10;\s]+', ' '))"/>",
        "sig": "<xsl:value-of select="normalize-space(replace($sig, '[\\&quot;&#10;\s]+', ' '))"/>"
        }
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
    
    <xsl:template match="*" mode="text">
        <xsl:value-of select="text()" />
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="*" mode="text" />
    </xsl:template>
</xsl:stylesheet>