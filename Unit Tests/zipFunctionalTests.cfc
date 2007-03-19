<cfcomponent extends="org.cfcunit.framework.TestCase">
	
	<cffunction name="setup" returntype="void">
		<cfset var keyFile = expandPath("/zip/zipkey.txt") />
		<cfset var tempFile = expandPath("/zip/~zipkey.txt") />
		
		<cfset variables.baseTestDirectory = getDirectoryFromPath(getCurrentTemplatePath()) />
		
		<cfif fileExists(keyFile)>
			<cffile action="rename" source="#keyFile#" destination="#tempFile#" />
		</cfif>
	</cffunction>
	
	<cffunction name="testList" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		<cfset var qList = myZip.list() />
		
		<cfset assertTrue(IsQuery(qList)) />
		<cfset assertEqualsNumber(qList.recordcount, 16) />		
	</cffunction>
	
	<!--- test adding a directory to a zip file's root --->
	<cffunction name="testAddDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/new.zip")) />
		
		<cfset myZip.addDirectory(expandPath("/assets/images/icons")) />
	</cffunction>
	
	<!--- test adding a directory to an existing folder in a zip file --->
	<cffunction name="testAddDirectoryToExistingDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip component --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add a directory to an existing directory --->
		<cfset myZip.addDirectory(expandPath("/assets/images/icons"), "temp") />	
	</cffunction>
	
	<!--- test adding a directory to a new folder in a zip file --->
	<cffunction name="testAddDirectoryToNewDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip component --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add a directory to an existing directory --->
		<cfset myZip.addDirectory(expandPath("/assets/images/icons"), "foo") />	
	</cffunction>
	
	<!--- test adding a directory non-recursivly --->
	<cffunction name="testAddDirectoryToNonRecursivly" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip component --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add a directory to an existing directory --->
		<cfset myZip.addDirectory(expandPath("."), "foo", false) />	
	</cffunction>
	
	<!--- extract all to existing directory --->
	<cffunction name="testExtractAllToExistingDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- create a new directory --->
		<cfdirectory action="create" directory="#expandPath("/zipTests/temp")#" />
		
		<!--- add a directory to an existing directory --->
		<cfset myZip.extractAll(expandPath("/zipTests/temp")) />	
	</cffunction>
	
	<!--- extract all to new directory ---> 
	<cffunction name="testExtractAllToNewDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- add a directory to an existing directory --->
		<cfset myZip.extractAll(expandPath("/zipTests/temp")) />	
	</cffunction>

	<!--- delete directory from zip --->
	<cffunction name="testDeleteDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip component --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add a directory to an existing directory --->
		<cfset myZip.deleteDirectory("temp") />	
	</cffunction>
	
	<!--- extract directory to existing directory --->
	<cffunction name="testExtractDirectoryExistingDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- create a new directory --->
		<cfdirectory action="create" directory="#expandPath("/zipTests/temp")#" />
		
		<!--- extract directory to an existing directory --->
		<cfset myZip.extractDirectory("/", expandPath("/zipTests/temp"), false) />	
	</cffunction>
		
	<!--- extract directory to new directory --->
	<cffunction name="testExtractDirectoryNewDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- extract root directory to an existing directory --->
		<cfset myZip.extractDirectory("/", expandPath("/zipTests/temp")) />	
	</cffunction>
	
	<!--- extract root directory non-recursivly ---> 
 	<cffunction name="testExtractDirectoryRootExistingDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- create a new directory --->
		<cfdirectory action="create" directory="#expandPath("/zipTests/temp")#" />
		
		<!--- extract root directory to an existing directory --->
		<cfset myZip.extractDirectory("/", expandPath("/zipTests/temp"), false) />	
	</cffunction>

	<!--- add a new file to the zip --->
	<cffunction name="testAddFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add the file --->
		<cfset myZip.addFile(expandPath("/zipTests/testFile.txt")) />	
	</cffunction>
	
	<!--- add a file under a directory in the zip --->
	<cffunction name="testAddFileToDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add the file --->
		<cfset myZip.addFile(expandPath("/zipTests/testFile.txt"), "/temp/") />	
	</cffunction>
	
	<!--- check that a known entry exists and that a non existing entry does not --->
	<cffunction name="testEntryExists" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- add the file --->
		<cfset assertTrue(myZip.entryExists("autorun.inf")) />	
		<cfset assertFalse(myZip.entryExists("foobar")) />	
	</cffunction>

	<!--- insure that a known file is a file and that a know directory is not --->
	<cffunction name="testIsFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cfset assertTrue(myZip.isFile("autorun.inf")) />	
		
		<cfset assertFalse(myZip.isFile("temp")) />		
	</cffunction>
	
	<!--- test that a known directory is a directory and that a known file is not --->
	<cffunction name="testIsDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cfset assertFalse(myZip.isDirectory("autorun.inf")) />	
		
		<cfset assertTrue(myZip.isDirectory("temp")) />		
	</cffunction>
	
	<!--- write text to a file in the zip --->
	<cffunction name="testWriteAsTextFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- write some text to the zip --->
		<cfset myZip.writeAsTextFile("/test.txt", "This is some sample text") />
		
		<!--- confirm the file was added --->
		<cfset assertTrue(myZip.entryExists("/test.txt")) />
	</cffunction>
	
	<!--- write binary data to a file in the zip --->
	<cffunction name="testWriteAsBinaryFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- write some text to the zip --->
		<cfset myZip.writeAsBinaryFile("/test.bin", ToBinary(ToBase64("This is some sample text"))) />
		
		<!--- confirm the file was added --->
		<cfset assertTrue(myZip.entryExists("/test.bin")) />
	</cffunction>
	
	<!--- read a text file --->
	<cffunction name="testReadAsTextFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- read some data from the zip --->
		<cfset var data = myZip.readAsTextFile("autorun.inf") />
		
		<!--- confirm the file was added --->
		<cfset assertTrue(Len(data) GT 0) />
	</cffunction>
	
	<!--- read a binary file --->
	<cffunction name="testReadAsBinaryFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- read some data from the zip --->
		<cfset var data = myZip.readAsBinaryFile("1041.mst") />
		
		<!--- confirm the file was added --->
		<cfset assertTrue(IsBinary(data)) />
	</cffunction>
	
	<!--- delete a file from the zip --->
	<cffunction name="testDeleteFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip")) />
		
		<!--- add the file --->
		<cfset myZip.deleteFile("autorun.inf") />	
	</cffunction>
	
	<!--- extract a file to an existing directory --->
	<cffunction name="testExtractFileToExistingDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- create a temp directory --->
		<cfdirectory action="create" directory="#expandPath("/zipTests/temp")#" />
		
		<!--- extract the file --->
		<cfset myZip.extractFile("autorun.inf", expandPath("/zipTests/temp")) />
	</cffunction>
	
	<!--- extract a file to an non-existing directory --->
	<cffunction name="testExtractFileToNonExistingDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- extract the file --->
		<cfset myZip.extractFile("autorun.inf", expandPath("/zipTests/temp/")) />
	</cffunction>
	
	<!--- extract a file while preserving directories --->
	<cffunction name="testExtractFilePreserveDirectories" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<!--- extract the file --->
		<cfset myZip.extractFile("/temp/standard.car", expandPath("/zipTests/temp"), true) />
	</cffunction>
	
	<!--- set compression to valid values --->
	<cffunction name="testSetCompression" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		<cfset var x = 0 />
		
		<cfloop from="0" to="9" index="x">
			<cfset myZip.setCompression(x) />
		</cfloop>
	</cffunction>
	
	<!--- get the version --->
	<cffunction name="testGetVersion" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cfset assertTrue(IsNumeric(myZip.getVersion())) />
	</cffunction>

	<!--- write text to a file in the zip over an existing entry --->
	<cffunction name="testWriteAsTextFileAndRead" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip"), "5QU7V-6677P-26J2M-M0L19-0P1UB") />
		
		<!--- write some text to the zip --->
		<cfset myZip.writeAsTextFile("/autorun.inf", "This is some sample text") />

		<!--- confirm the file was added --->
		<cfset assertEqualsString(myZip.readAsTextFile("/autorun.inf"), "This is some sample text") />
	</cffunction>
	
	<!--- write binary to a file in the zip and read it back out again --->
	<cffunction name="testWriteAsBinaryFileAndRead" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		<cfset var binData = 0 />
		
		<!--- copy the appendTo.zip to new.zip --->
		<cffile action="copy" source="#expandPath("/zipTests/appendTo.zip")#" destination="#expandPath("/zipTests/new.zip")#" />
		
		<!--- init the zip --->
		<cfset myZip.init(expandPath("/zipTests/new.zip"), "5QU7V-6677P-26J2M-M0L19-0P1UB") />
		
		<!--- create some binary data --->
		<cfset binData = ToBinary(ToBase64("This is some sample data")) />
		
		<!--- write some text to the zip --->
		<cfset myZip.writeAsBinaryFile("data.bin", binData) />

		<!--- confirm the file was added --->
		<cfset assertTrue(ToString(myZip.readAsBinaryFile("data.bin")) IS ToString(binData)) />
	</cffunction>
	
	<!--- set compression 2 --->
	<cffunction name="testSetCompression2" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/new.zip"), "5QU7V-6677P-26J2M-M0L19-0P1UB") />
		<cfset var x = 0 />
		
		<!--- loop from 0 to 9 and add the same file to the zip with each compression setting. --->
		<cfloop from="0" to="9" index="x">
			<!--- set the compression level to the current settings --->
			<cfset myZip.setCompression(x) />
			
			<!--- add a file to the zip file --->
			<cfset myZip.addFile(expandPath("/zipTests/Alagad Zip Component Documentation.doc"), "Alagad Zip Component Documentation #x#.doc") />
		</cfloop>
		
		<cfabort>
	</cffunction>

	<cffunction name="teardown" returntype="void">
		<cfset var newFile = expandPath("/zipTests/new.zip") />
		<cfset var keyFile = expandPath("/zip/zipkey.txt") />
		<cfset var tempFile = expandPath("/zip/~zipkey.txt") />
		<cfset var tempDir = expandPath("/zipTests/temp") />
		
		<!--- rename the key file --->
		<cfif fileExists(tempFile)>
			<cffile action="rename" source="#tempFile#" destination="#keyFile#" />
		</cfif>
		
		<!--- delete the new file --->
		<cfif fileExists(newFile)>
			<cffile action="delete" file="#newFile#" />
		</cfif>
		
		<!--- delete the temp directory --->
		<cfif DirectoryExists(tempDir)>
			<cfdirectory action="delete" directory="#tempDir#" recurse="yes" />
		</cfif>
	</cffunction>
	
</cfcomponent>