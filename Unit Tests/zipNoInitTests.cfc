<cfcomponent extends="org.cfcunit.framework.TestCase">
	
	<cffunction name="setup" returntype="void">
		<cfset var keyFile = expandPath("/zip/zipkey.txt") />
		<cfset var tempFile = expandPath("/zip/~zipkey.txt") />
		<cfif fileExists(keyFile)>
			<cffile action="rename" source="#keyFile#" destination="#tempFile#" />
		</cfif>
	</cffunction>
	
	<cffunction name="testListNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
		
		<cftry>
			<cfset myZip.list() />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddDirectoryNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.addDirectory(expandPath(".")) />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractAllNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.extractAll(expandPath(".")) />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testDeleteDirectoryNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.deleteDirectory("/test") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractDirectoryNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.extractDirectory("/test", expandPath(".")) />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testAddFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.addFile(expandPath("zipTests.cfc")) />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testEntryExistsNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.entryExists("/test.txt") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testIsFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.isFile("/test.txt") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testIsDirectoryNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.isDirectory("/test") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testWriteAsTextFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.writeAsTextFile("/test.txt", "This is my test content") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testWriteAsBinaryFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.writeAsBinaryFile("/test.bin", ToBinary(ToBase64("AAAAAAA"))) />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testReadAsTextFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.readAsTextFile("/test.txt") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testReadAsBinaryFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.readAsBinaryFile("/test.bin") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testDeleteFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.deleteFile("/test.bin") />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testExtractFileNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.extractFile("/test.bin", expandPath(".")) />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testSetCompressionNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.setCompression(9) />
			<cfcatch>
				<cfset fail("Uninited zip component should not throw error when calling setCompression with valid value.  '#cfcatch.Type#' was thrown.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="testGetCompressionNoInit" returntype="void" access="public">
		<cfset var myZip = CreateObject("Component", "zip.zip") />
				
		<cftry>
			<cfset myZip.getCompression() />
			<cfcatch type="Zip.notInited.ZipComponentNotInited" />
			<cfcatch>
				<cfset fail("Uninited zip component did not throw 'Zip.notInited.ZipComponentNotInited' error.  '#cfcatch.Type#' was thrown instead.") />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="teardown" returntype="void">
		<cfset var keyFile = expandPath("/zip/zipkey.txt") />
		<cfset var tempFile = expandPath("/zip/~zipkey.txt") />
		<cfif fileExists(tempFile)>
			<cffile action="rename" source="#tempFile#" destination="#keyFile#" />
		</cfif>
	</cffunction>
	
</cfcomponent>