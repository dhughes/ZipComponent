

<cfset myZip = CreateObject("Component", "myZip").init(expandPath("appendTo.zip")) />
<cfdump var="#myZip.listByDate('1/1/2005')#" />
