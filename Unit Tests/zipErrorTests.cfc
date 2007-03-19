<cfcomponent extends="org.cfcunit.framework.TestCase">
	
	<cffunction name="setup" returntype="void">
		<cfset var keyFile = expandPath("/zip/zipkey.txt") />
		<cfset var tempFile = expandPath("/zip/~zipkey.txt") />
		
		<cfset variables.baseTestDirectory = getDirectoryFromPath(getCurrentTemplatePath()) />
		
		<cfif fileExists(keyFile)>
			<cffile action="rename" source="#keyFile#" destination="#tempFile#" />
		</cfif>
	</cffunction>
	
	<cffunction name="testInitNoKeyArgument" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cfset myZip.list() />
		
		<cftry>
			<cfset myZip.list() />
			<cfcatch type="Zip.checkLicense.ZipComponentNotLicensed" />
			<cfcatch>
				<cfset fail("Unlicensed zip component did not cause error 'Zip.checkLicense.ZipComponentNotLicensed' to be thrown.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testInitInvalidKeyArgument" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip"), "adsasddasasddasdsa") />
		
		<cfset myZip.list() />
		
		<cftry>
			<cfset myZip.list() />
			<cfcatch type="Zip.checkLicense.ZipComponentNotLicensed" />
			<cfcatch>
				<cfset fail("Unlicensed zip component did not cause error 'Zip.checkLicense.ZipComponentNotLicensed' to be thrown.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testInitInvalidKeyFile" returntype="void" access="public">
		<cfset var myZip = 0 />
		
		<cffile action="write" file="#expandPath("/zip/zipkey.txt")#" output="fsdfdsdsfafdsdfsfdsfsda" />
		
		<cfset myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip"), "adsasddasasddasdsa") />
		
		<cfset myZip.list() />
		
		<cftry>
			<cfset myZip.list() />
			<cfcatch type="Zip.checkLicense.ZipComponentNotLicensed" />
			<cfcatch>
				<cfset fail("Unlicensed zip component did not cause error 'Zip.checkLicense.ZipComponentNotLicensed' to be thrown.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
		
		<cffile action="delete" file="#expandPath("/zip/zipkey.txt")#" />
	</cffunction>
	
	<cffunction name="testListCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.list() />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddDirectoryCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.addDirectory(expandPath(".")) />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddDirectoryInvalidDirecory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.addDirectory(expandPath("test/directory/")) />
			<cfcatch type="Zip.addDirectory.PathToDirectoryDoesNotExist" />
			<cfcatch>
				<cfset fail("Invalid directory did not cause 'Zip.addDirectory.PathToDirectoryDoesNotExist' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddDirectoryNotDirecory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.addDirectory(expandPath("/zipTests/zipErrorTests.cfc")) />
			<cfcatch type="Zip.addDirectory.PathToDirectoryMustBeADirectory" />
			<cfcatch>
				<cfset fail("Invalid directory did not cause 'Zip.addDirectory.PathToDirectoryMustBeADirectory' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractAllCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.extractAll(expandPath(".")) />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testDeleteDirectoryCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.deleteDirectory("/test") />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testDeleteDirectoryInvalidDirecory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
	  <cftry>
			<cfset myZip.deleteDirectory("/foobar") />
			<cfcatch type="Zip.deleteDirectory.PathToZippedDirectoryIsNotADirectory" />
			<cfcatch>
				<cfset fail("Invalid folder did not cause 'Zip.deleteDirectory.PathToZippedDirectoryIsNotADirectory' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractDirectoryCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.extractDirectory("/", expandPath("test/directory")) />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractDirectoryInvalidZipDirecory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.extractDirectory("/foobar", expandPath("test/directory")) />
			<cfcatch type="Zip.extractDirectory.PathToZippedDirectoryIsNotADirectory" />
			<cfcatch>
				<cfset fail("Invalid folder did not cause 'Zip.extractDirectory.PathToZippedDirectoryIsNotADirectory' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractDirectoryDirecoryFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.extractDirectory("/1041.mst", expandPath("test/directory")) />
			<cfcatch type="Zip.extractDirectory.PathToZippedDirectoryIsNotADirectory" />
			<cfcatch>
				<cfset fail("Invalid folder did not cause 'Zip.extractDirectory.PathToZippedDirectoryIsNotADirectory' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddFileCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.addFile(variables.baseTestDirectory & "testFile.txt") />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddFileInvalidFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.addFile(variables.baseTestDirectory & "foobar.txt") />
			<cfcatch type="Zip.addFile.PathToFileDoesNotExist" />
			<cfcatch>
				<cfset fail("Invalid file did not throw 'Zip.addFile.PathToFileDoesNotExist' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddFileFileDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cfif NOT DirectoryExists(expandPath("testDir"))>
			<cfdirectory action="create" directory="#expandPath("testDir")#" />
		</cfif>
		
		<cftry>
			<cfset myZip.addFile(expandPath("testDir")) />
			<cfcatch type="Zip.addFile.PathToFileCanNotBeADirectory" />
			<cfcatch>
				<cfset fail("Invalid file did not throw 'Zip.addFile.PathToFileCanNotBeADirectory' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
		
		<cfif DirectoryExists(expandPath("testDir"))>
			<cfdirectory action="delete" directory="#expandPath("testDir")#" />
		</cfif>
	</cffunction>
	
	<cffunction name="testEntryExistsInvalidName" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.entryExists("@@@") />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Invalid name did not cause 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testIsFileInvalidName" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.isFile("@@@") />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Invalid name did not cause 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testIsDirectoryInvalidName" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.isDirectory("@@@") />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Invalid name did not cause 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testWriteAsTextFileInvalidName" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.writeAsTextFile("/", "This is a test.") />
			<cfcatch type="Zip.writeAsBinaryFile.PathToZippedFileCanNotBeDirectory" />
			<cfcatch>
				<cfset fail("Invalid name did not cause 'Zip.writeAsBinaryFile.PathToZippedFileCanNotBeDirectory' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testReadAsTextFileInvalidName" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.readAsTextFile("foobar.txt") />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Invalid name did not cause 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testReadAsTextFileDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.readAsTextFile("/") />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Directory did not cause 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testDeleteFileFileDirectory" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.deleteFile("/temp") />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Invalid file did not throw 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- extract from corrupt file --->
	<cffunction name="testExtractFileCorruptZipFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/corrupt.zip")) />
		
		<cftry>
			<cfset myZip.extractFile("testFile.txt", expandPath(".")) />
			<cfcatch type="Zip.readZipFile.CouldNotReadZipFile" />
			<cfcatch>
				<cfset fail("Corrupt zip file did not cause method to throw 'Zip.readZipFile.CouldNotReadZipFile' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- extract entry which doesn't exist --->
	<cffunction name="testExtractInvalidFile" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.extractFile("testFile.txt", expandPath(".")) />
			<cfcatch type="Zip.getZipEntry.InvalidZipEntry" />
			<cfcatch>
				<cfset fail("Invalid entry did not cause method to throw 'Zip.getZipEntry.InvalidZipEntry' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- set invalid setCompression setting too low --->
	<cffunction name="testsetCompressionTooLow" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.setCompression(-10) />
			<cfcatch type="Zip.setCompression.InvalidCompressionArgument" />
			<cfcatch>
				<cfset fail("Invalid compression setting did not cause method to throw 'Zip.setCompression.InvalidCompressionArgument' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- set invalid setCompression setting too high --->
	<cffunction name="testsetCompressionTooHigh" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip").init(expandPath("/zipTests/appendTo.zip")) />
		
		<cftry>
			<cfset myZip.setCompression(20) />
			<cfcatch type="Zip.setCompression.InvalidCompressionArgument" />
			<cfcatch>
				<cfset fail("Invalid compression setting did not cause method to throw 'Zip.setCompression.InvalidCompressionArgument' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	
	
	
	
	<!--- continue on with addFile tests --->
	
	<cffunction name="teardown" returntype="void">
		<cfset var keyFile = expandPath("/zip/zipkey.txt") />
		<cfset var tempFile = expandPath("/zip/~zipkey.txt") />
		<cfif fileExists(tempFile)>
			<cffile action="rename" source="#tempFile#" destination="#keyFile#" />
		</cfif>
	</cffunction>
	
</cfcomponent>