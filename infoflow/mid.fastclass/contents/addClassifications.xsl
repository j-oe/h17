<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:iirds="http://iirds.tekom.de/iirds#"
    xmlns:fc="http://fastclass.de/fc#"
    exclude-result-prefixes="xs">
    
    <xsl:output method="xhtml" omit-xml-declaration="yes" indent="no" />
    <xsl:strip-space elements="*"/>
    
    <!--
    Add classifications based on CSV file (first col: id, second col: classification)
    Part of mid.classify
    (c) 2016, Jan Oevermann // License: MIT
    -->
    
    <!-- Default Params -->
    <xsl:param name="tmp.dir" as="xs:string" />
    <xsl:param name="pub.dir" as="xs:string" />
    <xsl:param name="base.dir" as="xs:string" />
    <xsl:param name="publication" as="xs:string" />
    <!-- File protocoll for cross-platform file URLs -->
    <xsl:variable name="file" as="xs:string">file:///</xsl:variable>
    
    <!--replace backslashes for unparsed-text()-->
    <xsl:variable name="sanitizedPath" select="replace(concat($file, $tmp.dir, '/classification.csv'), '\\', '/')" />
    <xsl:variable name="clf.file" select="unparsed-text($sanitizedPath)" />
    
    <!-- read classification assignment from CSV file and build XML object-->
    <xsl:variable name="classifications">
        <clf>
            <xsl:for-each select="tokenize($clf.file, '\n')">
                <xsl:variable name="assignment" select="tokenize(., ';')"/>
                <item id="{$assignment[1]}" cls="{$assignment[3]}" clf="{$assignment[2]}" cfd="{$assignment[4]}"/>  
            </xsl:for-each>
        </clf>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- Add classification to sections -->
    <xsl:template match="section">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <!-- assign classification where set-->
            <xsl:if test="$classifications//item[@id = current()/@id]">
                <xsl:for-each select="$classifications//item[@id = current()/@id]">
                    <xsl:variable name="entry" select="."/>
                    <xsl:if test="$entry/@clf != 'CLASSIFICATION_ERROR'">
                        <xsl:attribute name="{concat('iirds:', $entry/@cls)}" select="$entry/@clf" />
                        <xsl:attribute name="{concat('fc:', $entry/@cls)}" select="$entry/@cfd" />
                    </xsl:if>
                </xsl:for-each>
                
            </xsl:if>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>