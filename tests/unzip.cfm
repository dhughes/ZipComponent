<h3>List files in a zip</h3>

<cfset ZipFile = CreateObject("Java", "java.util.zip.ZipFile").init(JavaCast("string", expandPath("example.zip"))) />
<cfset ZipEntries = ZipFile.entries() />
<cfset ZipEntry = 0 />

<cfloop condition="#ZipEntries.hasMoreElements()#">
	<cfset ZipEntry = ZipEntries.nextElement() />
	<cfdump var="#getFileFromPath(ZipEntry.getName())#" /><br>
</cfloop>

<h3>Add files to a zip</h3>
<cffile action="copy" source="#expandPath("example.zip")#" destination="#expandPath("appendTo.zip")#" />

<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(expandPath("appendTo.zip")) />
<cfset ZipOutputStream = CreateObject("Java", "java.util.zip.ZipOutputStream").init(FileOutputStream) />
<cfset ZipOutputStream.setMethod(ZipOutputStreat.DEFLATED) />
<cfset ZipOutputStream.setLevel(9) />


<cfset ZipOutputStream.close() />
<cfset FileOutputStream.close() />