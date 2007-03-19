
<!---
Create a new instance of the zip component.  By specifying a zip file
name which doesn't exist you will create a new zip file. 
--->
<cfset myZip = CreateObject("Component", "zip.zip").init(expandPath("newZipFile.zip")) />

<!--- add a file into the zip file --->
<cfset myZip.addFile(expandPath("bagOfBugers.JPG")) />


