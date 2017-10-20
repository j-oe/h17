<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:iirds="http://iirds.tekom.de/iirds" exclude-result-prefixes="xs" version="2.0">
    
    <!-- 
        PI-Class(r) -> iiRDS Mapping Transformation 
        (c) 2017, Jan Oevermann / Claudia Oberle (ICMS GmbH)
        LICENSE: MIT
    -->
    
    <xsl:variable name="iirds.map" select="document('map.xml')" />
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="@*[some $x in distinct-values($iirds.map/descendant::convert/@attr-src) satisfies ($x=local-name())]">
        <xsl:variable name="attr-name" select="local-name()"/>
        <xsl:variable name="attr-val"  select="."/>
        
        <xsl:for-each-group select="$iirds.map/descendant::convert[@pi-value = $attr-val][@attr-src = $attr-name]" group-by="parent::submap/@key">
            <xsl:attribute name="{concat('iirds:', current-grouping-key())}" select="@iirds-value"/>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>