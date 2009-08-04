

<cfset myZip = CreateObject("Component", "myZip").init(expandPath("appendTo.zip")) />
<cfdump var="#myZip.listByDate('1/1/2005')#" />

<cfset myZip.addDirectory(expandPath("/test"), "/test") />
<cfdump var="#myZip.listByDate('1/1/2005')#" />

<cfset myZip.addFile(expandPath("/test/test.txt")) />
<cfdump var="#myZip.listByDate('1/1/2005')#" />

<cfset myZip.deleteFile("/test/test.txt") />
<cfdump var="#myZip.listByDate('1/1/2005')#" />