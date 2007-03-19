
<!---
Create a new instance of the zip component.  The Zip Component will work with 
the specified zip file.  
--->
<cfset myZip = CreateObject("Component", "zip.zip").init(expandPath("example.zip")) />

<!--- add an entire directory into the zip file --->
<cfset myZip.addDirectory(expandPath("photos")) />

