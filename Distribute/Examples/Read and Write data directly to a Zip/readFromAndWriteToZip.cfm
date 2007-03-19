
<!---
Create a new instance of the zip component.  By specifying a zip file
name which doesn't exist you will create a new zip file. 
--->
<cfset myZip = CreateObject("Component", "zip.zip").init(expandPath("example.zip")) />

<!--- you can write data directly int a zip file using the writeAsTextFile method --->
<cfset myZip.writeAsTextFile("example file.txt", "This is some sample text.") />

<!--- read the text back out of the zip file --->
<cfset text = myZip.readAsTextFile("example file.txt") />

<!--- output the text from the zip file --->
<cfoutput>
	#text#
</cfoutput>