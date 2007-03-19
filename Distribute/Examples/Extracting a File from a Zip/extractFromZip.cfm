
<!---
Create a new instance of the zip component.  The Zip Component will work with 
the specified zip file.  
--->
<cfset myZip = CreateObject("Component", "zip.zip").init(expandPath("example.zip")) />

<!--- extract a file from the zip file --->
<cfset myZip.extractFile("bagOfBugers.jpg", expandPath(".")) />

