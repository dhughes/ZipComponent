<cfcomponent hint="I am a component which can read, write and manipulate zip files.">

	<cfset variables.version = "1.2" />

	<cffunction name="init" access="public" output="false" returntype="WEB-INF.cftags.component" hint="I configure and return an instance of the Zip component.">
		<cfargument name="pathToZipFile" hint="I am the path to the zip file we are working with.  If I don't exist I will be created as needed." required="yes" type="string" />
		<cfargument name="key" hint="I am the license key to use." required="no" type="string" default="" />
		<cfset setPathToZipFile(arguments.pathToZipFile) />
		<cfset setCompression(6) />
		<cfset variables.licensed = false />	
		<cfset variables.key = "" />	
		<cfset variables.testMethodExecuted = false />
		<cfset variables.appText = "Z!pC0mponentW@sDel@yedBecauseM!fir5tKidLearnedToR!deH!sTr!keToday" />
		<cfset variables.charString = "0123456789ABCDEFGHJKLMNPQRTUVWXY" />
		
		<!--- set the key --->
		<cfif Len(arguments.key)>
			<cfset setKey(arguments.key) />
		<cfelse>
			<cfset loadLicenseFile() />
		</cfif>
		
		<!--- return the image object. --->
		<cfreturn this />
	</cffunction>
	
	<!--- getVersion --->
	<cffunction name="getVersion" access="public" hint="I return the zip component's version number" output="false" returntype="string">
		<cfreturn variables.version />
	</cffunction>	
	
	<!--- loadLicenseFile --->
	<cffunction name="loadLicenseFile" access="private" output="false" returntype="void" hint="I check for the existance of (and contents of) captchakey.txt and load it as the license key, if it exists.">
		<cfset var zipKey = getDirectoryFromPath(getCurrentTemplatePath()) & "zipkey.txt" />
		<cfset var key = "" />
		
		<!--- look for a file named zipkey.txt --->
		<cfif FileExists(zipKey)>
			<!--- read the key file, if possible --->
			<cffile action="read"
				file="#zipKey#"
				variable="key" />
			<!--- set the key (if not valid it won't be licensed) --->
			<cfset setKey(trim(key)) />
		</cfif>
	</cffunction>
	
	<!--- checkLicense --->
	<cffunction name="checkLicense" access="private" hint="I check the compoent configuration." output="false" returntype="void">
		<cfif NOT getLicensed()>
			<cfif variables.testMethodExecuted>
				<cfthrow message="Zip Component Not Licensed" detail="Thank you for trying out the Alagad Zip Component.  You have not provided a valid license key so this component is running in trial mode.  In trial mode you can only execute one method other than the init(), getCompression(), setCompression(), entryExists(), isDirectory() and isFile() methods.  By providing a license key you can remove this limitation." type="Zip.checkLicense.ZipComponentNotLicensed" />
			<cfelse>
				<cfset variables.testMethodExecuted = true />
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- list --->
	<cffunction name="list" access="public" hint="I return a query of all the files in this zip document." output="false" returntype="query">
		<cfset var qList = QueryNew("directory,file,fullPath,compressedSize,uncompressedSize,lastModified") />
		<cfset var ZipFile = 0 />
		<cfset var ZipEntries = 0 />
		<cfset var Date = 0 />
		
		<cfset checkLicense() />
		
		<cfif FileExists(getPathToZipFile())>
			<cfset ZipFile = readZipFile() />
			<cfset ZipEntries = ZipFile.entries() />
		</cfif>
		
		<!--- copy the entries into the new zip file --->
		<cfif IsObject(ZipEntries)>
			<cfloop condition="#ZipEntries.hasMoreElements()#">
				<cfset ZipEntry = ZipEntries.nextElement() />
				
				<!--- create a time object --->
				<cfset Date = CreateObject("Java", "java.util.Date").init(ZipEntry.getTime()) />
				
				<!--- append this entry to the query --->
				<cfif NOT ZipEntry.isDirectory()>
					<cfset QueryAddRow(qList) />
					<cfset QuerySetCell(qList, "directory", normalizeEntryName(GetDirectoryFromPath(ZipEntry.getName()))) />
					<cfset QuerySetCell(qList, "file", GetFileFromPath(ZipEntry.getName())) />
					<cfset QuerySetCell(qList, "fullPath", normalizeEntryName(ZipEntry.getName())) />
					<cfset QuerySetCell(qList, "compressedSize", ZipEntry.getCompressedSize()) />
					<cfset QuerySetCell(qList, "uncompressedSize", ZipEntry.getSize()) />
					<cfset QuerySetCell(qList, "lastModified", CreateODBCDateTime(Date)) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn qList />	
	</cffunction>
	
	<!--- addDirectory --->
	<cffunction name="addDirectory" access="public" hint="I add a directory into the zip file." output="false" returntype="void">
		<cfargument name="pathToDirectory" hint="I am the directory to add to the zip file." required="yes" type="string" />
		<cfargument name="pathToZippedDirectory" hint="I am the path to a directory in the zip file to place the new directory.  If not provided the root is used." required="no" type="string" default="/" />
		<cfargument name="recursive" hint="I indicate if the directory structure should be recursed or if only the first level should be added.  I default to true" required="no" type="boolean" default="true" />
		<cfset var Directory = CreateObject("Java", "java.io.File").init(arguments.pathToDirectory & "/") />
		<cfset var Files = 0 />
		<cfset var TempFile = GetTempFile(GetTempDirectory(), "azc_")/>
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		<cfset var ZipOutputStream = 0 />
		<cfset var ZipFile = 0 />
		<cfset var ZipEntries = 0 />
		<cfset var ZipEntry = 0 />
		<cfset var NewZipEntry = 0 />
		<cfset var ZipInputStream = 0 />
		<cfset var FileInputStream = 0 />
		<cfset var BufferedInputStream = 0 />
		<cfset var x = 0 />
		<cfset var zipFileName = "" />

		<cfset checkLicense() />
		
		<!--- insure the directory exists and is not a file --->
		<cfif NOT Directory.exists()>
			<cfthrow message="PathToDirectory Does Not Exist" detail="The directory specified by the PathToDirectory argument, '#arguments.pathToDirectory#', passed to the addDirectory method does not exist." type="Zip.addDirectory.PathToDirectoryDoesNotExist" />

		<cfelseif NOT Directory.isDirectory()>
			<cfthrow message="PathToDirectory Must Be A Directory" detail="The directory specified by the PathToDirectory argument, '#arguments.pathToDirectory#', passed to the addDirectory method is a file.  This argument must be a directory." type="Zip.addDirectory.PathToDirectoryMustBeADirectory" />
					
		</cfif>
		
		<!--- get a array of all the files that will be added --->
		<cfset Files = recurseDirectory(Directory, arguments.recursive) />
		
		<!--- <cfloop from="1" to="#ArrayLen(Files)#" index="x">
			<cfdump var="#Files[x].getCanonicalPath()#" /><br>
		</cfloop> --->
		
		<!--- create a temp zip file --->
		<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(JavaCast("String", TempFile)) />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
		<cfset ZipOutputStream = CreateObject("Java", "java.util.zip.ZipOutputStream").init(BufferedOutputStream) />
		
		<!--- configure the zip file --->
		<cfset ZipOutputStream.setMethod(ZipOutputStream.DEFLATED) />
		<cfset ZipOutputStream.setLevel(getCompression()) />
				
		<!--- add all of the current zip file's entries to the temp zip file (if a file with the same name as what's being added exists don't copy it) --->
		<cfif FileExists(getPathToZipFile())>
			<cfset ZipFile = readZipFile() />
			<cfset ZipEntries = ZipFile.entries() />
			
			<!--- copy the entries into the new zip file --->
			<cfloop condition="#ZipEntries.hasMoreElements()#">
				<cfset ZipEntry = ZipEntries.nextElement() />
				
				<!--- if this is the same name as the file being added then we will ignore it --->
				<cfif NOT findMatchingFile(ZipEntry, Files, arguments.pathToDirectory, arguments.pathToZippedDirectory)>
					<cfset ZipInputStream = ZipFile.getInputStream(ZipEntry) />
					
					<!--- add the entry to the ZipOutputStream --->
					<cfset NewZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", ZipEntry.getName())) />
					<cfset copyMetadata(ZipEntry, NewZipEntry) />					
					<cfset ZipOutputStream.putNextEntry(NewZipEntry) />
					
					<!--- copy the zip entry to the new zip file --->
					<cfset copyStream(ZipInputStream, ZipOutputStream) />
					
					<!--- close the FileInputStream and the current entry --->
					<cfset ZipInputStream.close() />
					<cfset ZipOutputStream.closeEntry() />
				</cfif>
			</cfloop>
			
			<!--- close the ZipFile --->
			<cfset ZipFile.close() />
		</cfif>
		
		<!--- loop over all the files being added --->
		<cfloop from="1" to="#ArrayLen(Files)#" index="x">
			<!--- create an input stream for the file being added --->
			<cfset FileInputStream = CreateObject("Java", "java.io.FileInputStream").init(JavaCast("String", Files[x])) />
			
			<!--- find out this entry's name --->
			<cfset zipFileName = Right(Files[x].getCanonicalPath(), Len(Files[x].getCanonicalPath()) - Len(arguments.pathToDirectory)) />
			<cfset zipFileName = normalizeEntryName(zipFileName, arguments.pathToZippedDirectory) />
			
			<!--- create an entry --->
			<cfset ZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", zipFileName)) />
			
			<!--- add the entry to the ZipOutputStream --->
			<cfset ZipOutputStream.putNextEntry(ZipEntry) />
			
			<!--- copy the file to be zipped data into the zip file --->
			<cfset copyStream(FileInputStream, ZipOutputStream) />
			
			<!--- close both streams --->
			<cfset FileInputStream.close() />
		</cfloop>
		
		<!--- close the zip outputstream --->
		<cfset ZipOutputStream.close() />
		
		<!--- move the temp file to the output file --->
		<cffile action="move" source="#TempFile#" destination="#getPathToZipFile()#" nameconflict="overwrite" />
	</cffunction>
	
	<!--- findMatchingFile --->
	<cffunction name="findMatchingFile" access="private" hint="I check to see if a provided zip entry name matches a file in an array of Files" output="false" returntype="boolean">
		<cfargument name="ZipEntry" hint="I am the zip entry to check for" required="yes" type="any" />
		<cfargument name="Files" hint="I am the array of files to check." required="yes" type="any" />
		<cfargument name="pathRoot" hint="I am the directory on the filesystem to remove from the File's path." required="yes" type="string" />
		<cfargument name="pathToZippedDirectory" hint="I am the zipped directory to prepend to the file's path." required="yes" type="string" />
		<cfset var x = 0 />
		<cfset var fileName = "" />
			
		<cfloop from="1" to="#ArrayLen(arguments.Files)#" index="x">
			<cfset fileName = Right(arguments.Files[x].getCanonicalPath(), Len(arguments.Files[x].getCanonicalPath()) - Len(arguments.pathRoot)) />
			<cfset fileName = normalizeEntryName(fileName, arguments.pathToZippedDirectory) />
			
			<cfif normalizeEntryName(arguments.ZipEntry.getName()) IS fileName>
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>
	
	<!---- recurseDirectory --->
	<cffunction name="recurseDirectory" access="private" hint="I get an array of files from a directory recursivly (or not)" output="false" returntype="array">
		<cfargument name="Directory" hint="I am the directory to recurse." required="yes" type="string" />
		<cfargument name="recursive" hint="I indicate if the directory structure should be recursed or if only the first level should be added.  I default to true" required="no" type="boolean" default="true" />
		<cfargument name="Files" hint="I am an array of files." required="no" type="array" default="#ArrayNew(1)#" />
		<cfset var Contents = arguments.Directory.listFiles() />
		<cfset var x = 0 />
		
		<cfloop from="1" to="#ArrayLen(Contents)#" index="x">
			<cfif Contents[x].isFile()>
				<cfset ArrayAppend(arguments.Files, Contents[x]) />
			</cfif>
			
			<cfif arguments.recursive AND Contents[x].isDirectory()>
				<cfset arguments.Files = recurseDirectory(Contents[x], arguments.recursive, arguments.Files) />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.Files />
	</cffunction>
	
	<!---- extractAll --->
	<cffunction name="extractAll" access="public" hint="I extract all files from the archive into the specified directory." output="false" returntype="void">
		<cfargument name="extractToDirectory" hint="I am the directory to extract the files into.  I am created if I don't alrady exist." required="yes" type="string" />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntries = ZipFile.entries() />
		<cfset var ZipEntry = 0 />
		<cfset var InputStream = 0 />
		<cfset var TargetFile = 0 />
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		
		<cfset checkLicense() />
		
		<!--- loop over all the entries in the zip file --->
		<cfloop condition="#ZipEntries.hasMoreElements()#">
			<!--- get this entry --->
			<cfset ZipEntry = ZipEntries.nextElement() />
			
			<!--- insure the target directory exists --->
			<cfset TargetFile = CreateObject("Java", "java.io.File").init(arguments.extractToDirectory & "/" & ZipEntry.getName()) />
			<!--- insure needed directoryies exists --->
			<cfif ZipEntry.isDirectory()>
				<!--- create the directory and leave it at that --->
				<cfset TargetFile.mkdirs() />
			<cfelse>
				<!--- create the parrent directories --->
				<cfset TargetFile.getParentFile().mkdirs() />
				
				<!--- extract the file --->
				<cfset InputStream = ZipFile.getInputStream(ZipEntry) />
				
				<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(TargetFile) />
				<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
				
				<!--- copy data --->
				<cfset copyStream(InputStream, BufferedOutputStream) />
		
				<!--- close both streams --->
				<cfset InputStream.close() />
				<cfset BufferedOutputStream.close() />
			</cfif>
		</cfloop>
		
		<!--- close the zip --->
		<cfset ZipFile.close() />		
	</cffunction>
	
	<!--- deleteDirectory --->
	<cffunction name="deleteDirectory" access="public" hint="I delete the specified directory and all of its files recursivly from the zip file." output="false" returntype="void">
		<cfargument name="pathToZippedDirectory" hint="I am the path to the directory to delete from the zip file." required="yes" type="string" />
		<cfset var TempFile = GetTempFile(GetTempDirectory(), "azc_")/>
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		<cfset var ZipOutputStream = 0 />
		<cfset var ZipFile = 0 />
		<cfset var ZipEntries = 0 />
		<cfset var ZipEntry = 0 />
		<cfset var NewZipEntry = 0 />
		<cfset var ZipInputStream = 0 />
		
		<cfset checkLicense() />
		
		<!--- normalize the pathToZippedDirectory name ---> 
		<cfset arguments.pathToZippedDirectory = normalizeEntryName(arguments.pathToZippedDirectory & "/") />
		
		<!--- insure the directory to delete exists --->
		<cfif NOT isDirectory(arguments.pathToZippedDirectory)>
			<cfthrow message="PathToZippedDirectory Is Not A Directory" detail="The directory specified by the PathToZippedDirectory argument, '#arguments.PathToZippedDirectory#', passed to the deleteDirectory method is not a directory or does not exist in the zip file.  This argument must be a directory which exists in the zip file." type="Zip.deleteDirectory.PathToZippedDirectoryIsNotADirectory" />
		</cfif>
		
		<!--- create a temp zip file --->
		<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(JavaCast("String", TempFile)) />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
		<cfset ZipOutputStream = CreateObject("Java", "java.util.zip.ZipOutputStream").init(BufferedOutputStream) />
		
		<!--- configure the outputstream --->
		<cfset ZipOutputStream.setMethod(ZipOutputStream.DEFLATED) />
		<cfset ZipOutputStream.setLevel(getCompression()) />
		
		<!--- add all of the current zip file's entries to the temp zip file (if a file with the same name as what's being deleted exists don't copy it) --->
		<cfif FileExists(getPathToZipFile())>
			<cfset ZipFile = CreateObject("Java", "java.util.zip.ZipFile").init(getPathToZipFile()) />
			<cfset ZipEntries = ZipFile.entries() />
			
			<!--- copy the entries into the new zip file --->
			<cfloop condition="#ZipEntries.hasMoreElements()#">
				<cfset ZipEntry = ZipEntries.nextElement() />
				
				<!--- if this is the same name as the file being added then we will ignore it --->
				<cfif NOT Left(normalizeEntryName(ZipEntry.getName()), Len(arguments.pathToZippedDirectory)) IS arguments.pathToZippedDirectory>
					<cfset ZipInputStream = ZipFile.getInputStream(ZipEntry) />
					
					<!--- add the entry to the ZipOutputStream --->
					<cfset NewZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", ZipEntry.getName())) />
					<cfset copyMetadata(ZipEntry, NewZipEntry) />
					<cfset ZipOutputStream.putNextEntry(NewZipEntry) />
					
					<!--- copy the zip entry to the new zip file --->
					<cfset copyStream(ZipInputStream, ZipOutputStream) />
					
					<!--- close the FileInputStream and the current entry --->
					<cfset ZipInputStream.close() />
					<cfset ZipOutputStream.closeEntry() />
				</cfif>
			</cfloop>
			
			<!--- close the ZipFile --->
			<cfset ZipFile.close() />
		</cfif>
		
		<!--- close both streams --->
		<cfset ZipOutputStream.close() />
				
		<!--- move the temp file to the output file --->
		<cffile action="move" source="#TempFile#" destination="#getPathToZipFile()#" nameconflict="overwrite" />
	</cffunction>
	
	<!--- extractDirectory --->
	<cffunction name="extractDirectory" access="public" hint="I extract all files from the specified directory in the archive into the specified directory.  Directory structure is mantained." output="false" returntype="void">
		<cfargument name="pathToZippedDirectory" hint="I am the directory to extract the files from." required="yes" type="string" />
		<cfargument name="extractToDirectory" hint="I am the directory to extract the files into." required="yes" type="string" />
		<cfargument name="recursive" hint="I indicate if this function should act recursivly." required="no" type="boolean" default="true" />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntries = ZipFile.entries() />
		<cfset var ZipEntry = 0 />
		<cfset var InputStream = 0 />
		<cfset var TargetFile = 0 />
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		<cfset var File = CreateObject("Java", "java.io.File").init(arguments.extractToDirectory) />
		<cfset var extract = false />
		
		<cfset checkLicense() />
		
		<!--- insure the directory entry exists in the zip file --->
		<cfif NOT isDirectory(arguments.pathToZippedDirectory)>
			<cfthrow message="PathToZippedDirectory Is Not A Directory" detail="The directory specified by the PathToZippedDirectory argument, '#arguments.PathToZippedDirectory#', passed to the extractDirectory method is a file.  This argument must be a directory." type="Zip.extractDirectory.PathToZippedDirectoryIsNotADirectory" />
		</cfif>
			
		<!--- normalize the pathToZippedDirectory name ---> 
		<cfset arguments.pathToZippedDirectory = normalizeEntryName(arguments.pathToZippedDirectory & "/") />
		
		<!--- loop over all the entries in the zip file --->
		<cfloop condition="#ZipEntries.hasMoreElements()#">
			<!--- get this entry --->
			<cfset ZipEntry = ZipEntries.nextElement() />
			
			<!--- determine if this entry should be extracted --->
			<cfset extract = false />
			
			<!--- only extract when the file is not a directory --->
			<cfif NOT ZipEntry.isDirectory()>
				<!--- are we extracting recursivly? --->
				<cfif arguments.recursive>
					<!--- recursivly extracting --->
					
					<!---
						Check to see if the entry is under the directory we're extracting
						If the directory being extracted is "" then we alwasy extract the file						
					--->
					<cfif arguments.pathToZippedDirectory IS "" OR Left(normalizeEntryName(ZipEntry.getName()), Len(arguments.pathToZippedDirectory)) IS arguments.pathToZippedDirectory>
						<cfset extract = true />
					</cfif>
				<cfelse>
					<!--- not-recursivly extracting --->
					
					<!--- check to see if the entry is directly under the directory we're extracting --->
					<cfif normalizeEntryName(GetDirectoryFromPath(normalizeEntryName(ZipEntry.getName()))) IS arguments.pathToZippedDirectory>
						<cfset extract = true />
					</cfif>
				</cfif>
			
			</cfif>
			
			<!--- if we're supposed to, extract the file --->
			<cfif extract>
				<!--- insure the target directory exists --->
				<cfset TargetFile = CreateObject("Java", "java.io.File").init(arguments.extractToDirectory & "/" & ZipEntry.getName()) />
								
				<!--- insure needed directoryies exists --->
				<cfif ZipEntry.isDirectory()>
					<!--- create the directory and leave it at that --->
					<cfset TargetFile.mkdirs() />
				<cfelse>
					<!--- create the parrent directories --->
					<cfset TargetFile.getParentFile().mkdirs() />
					
					<!--- extract the file --->
					<cfset InputStream = ZipFile.getInputStream(ZipEntry) />
					
					<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(TargetFile) />
					<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
					
					<!--- copy data --->
					<cfset copyStream(InputStream, BufferedOutputStream) />
			
					<!--- close both streams --->
					<cfset InputStream.close() />
					<cfset BufferedOutputStream.close() />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- close the zip --->
		<cfset ZipFile.close() />
	</cffunction>
	
	<!--- addFile --->
	<cffunction name="addFile" access="public" hint="I add the specified file to the zip file." output="false" returntype="void">
		<cfargument name="pathToFile" hint="I am the path to the file to add to the zip file." required="yes" type="string" />
		<cfargument name="pathToZipEntry" hint="I am the path to the directory in the zip file or directory to add the file into.  If I end in '/' I am a directory.  If I do not end in '/' I am a filename." required="no" type="string" default="" />
		<cfset var TempFile = GetTempFile(GetTempDirectory(), "azc_")/>
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		<cfset var ZipOutputStream = 0 />
		<cfset var ZipFile = 0 />
		<cfset var ZipEntries = 0 />
		<cfset var ZipEntry = 0 />
		<cfset var NewZipEntry = 0 />
		<cfset var ZipInputStream = 0 />
		<cfset var FileInputStream = 0 />
		<cfset var BufferedInputStream = 0 />
		<cfset var zipFileName = 0 />
		
		<cfif NOT Len(arguments.pathToZipEntry)>
			<cfset zipFileName = normalizeEntryName(GetFileFromPath(arguments.pathToFile)) />
		<cfelseif Right(arguments.pathToZipEntry, 1) IS "/">
			<cfset zipFileName = normalizeEntryName(GetFileFromPath(arguments.pathToFile), arguments.pathToZipEntry) />			
		<cfelse>
			<cfset zipFileName = normalizeEntryName(arguments.pathToZipEntry) />
		</cfif>
		
		<cfset checkLicense() />
		
		<!--- make sure the file to add exists --->
		<cfif DirectoryExists(arguments.pathToFile)>
			<cfthrow message="PathToFile Can Not Be A Directory" detail="The file specified by the PathToFile argument, '#arguments.pathToFile#', passed to the addFile method is a directory.  This argument must be a file." type="Zip.addFile.PathToFileCanNotBeADirectory" />
			
		<cfelseif NOT FileExists(arguments.pathToFile)>
			<cfthrow message="PathToFile Does Not Exist" detail="The file specified by the PathToFile argument, '#arguments.pathToFile#', passed to the addFile method does not exist." type="Zip.addFile.PathToFileDoesNotExist" />
			
		</cfif>
		
		<!--- create a temp zip file --->
		<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(JavaCast("String", TempFile)) />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
		<cfset ZipOutputStream = CreateObject("Java", "java.util.zip.ZipOutputStream").init(BufferedOutputStream) />
		
		<!--- configure the zip file --->
		<cfset ZipOutputStream.setMethod(ZipOutputStream.DEFLATED) />
		<cfset ZipOutputStream.setLevel(JavaCast("int", getCompression())) />
		
		<!--- add all of the current zip file's entries to the temp zip file (if a file with the same name as what's being added exists don't copy it) --->
		<cfif FileExists(getPathToZipFile())>
			<cfset ZipFile = readZipFile() />
			<cfset ZipEntries = ZipFile.entries() />
			
			<!--- copy the entries into the new zip file --->
			<cfloop condition="#ZipEntries.hasMoreElements()#">
				<cfset ZipEntry = ZipEntries.nextElement() />
				
				<!--- if this is the same name as the file being added then we will ignore it --->
				<cfif ZipEntry.getName() IS NOT zipFileName>
					<cfset ZipInputStream = ZipFile.getInputStream(ZipEntry) />
					
					<!--- add the entry to the ZipOutputStream --->
					<cfset NewZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", ZipEntry.getName())) />
					<cfset copyMetadata(ZipEntry, NewZipEntry) />
					<cfset ZipOutputStream.putNextEntry(NewZipEntry) />
					
					<!--- copy the zip entry to the new zip file --->
					<cfset copyStream(ZipInputStream, ZipOutputStream) />
					
					<!--- close the FileInputStream and the current entry --->
					<cfset ZipInputStream.close() />
					<cfset ZipOutputStream.closeEntry() />
				</cfif>
			</cfloop>
			
			<!--- close the ZipFile --->
			<cfset ZipFile.close() />
		</cfif>
		
		<!--- create an input stream for the file being added --->
		<cfset FileInputStream = CreateObject("Java", "java.io.FileInputStream").init(JavaCast("String", arguments.pathToFile)) />
		<cfset ZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", zipFileName)) />
		
		<!--- add the entry to the ZipOutputStream --->
		<cfset ZipOutputStream.putNextEntry(ZipEntry) />
		
		<!--- copy the file to be zipped data into the zip file --->
		<cfset copyStream(FileInputStream, ZipOutputStream) />
		
		<!--- close both streams --->
		<cfset FileInputStream.close() />
		<cfset ZipOutputStream.close() />
		
		<!--- move the temp file to the output file --->
		<cffile action="move" source="#TempFile#" destination="#getPathToZipFile()#" nameconflict="overwrite" />
	</cffunction>
	
	<!--- copyMetadata --->
	<cffunction name="copyMetadata" access="private" hint="I copy metadata between entries." output="false" returntype="void">
		<cfargument name="fromZipEntry" hint="I am the zip entry to copy metadata from." required="yes" type="any" />
		<cfargument name="toZipEntry" hint="I am the zip entry to copy metadata to." required="yes" type="any" />
		
		<cfset arguments.toZipEntry.setTime(arguments.fromZipEntry.getTime()) />
		<cfif ListFirst(server.ColdFusion.ProductVersion) GT 7>
			<cfset arguments.toZipEntry.setComment(arguments.fromZipEntry.getComment()) />
			<cfset arguments.toZipEntry.setExtra(arguments.fromZipEntry.getExtra()) />
		</cfif>
	</cffunction>				
	
	<!--- entryExists --->
	<cffunction name="entryExists" access="public" hint="I indicate if a particular entry exists in the zip file" output="false" returntype="boolean">
		<cfargument name="pathToZipEntry" hint="I am the path to the entry in the zip file." required="yes" type="string" />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntry = 0 />
		
		<!--- try to get the entry --->
		<cftry>
			<cfset ZipEntry = getZipEntry(ZipFile, normalizeEntryName(arguments.pathToZipEntry)) />
			<cfcatch>
				<cfset ZipFile.close() />
				<cfreturn false />
			</cfcatch>
		</cftry>
		
		<!--- if ZipEntry Exists it exists --->
		<cfif IsDefined("ZipEntry")>
			<cfset ZipFile.close() />
			<cfreturn true />
		<cfelse>
			<cfset ZipFile.close() />
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!--- isFile --->
	<cffunction name="isFile" access="public" hint="I indicate if a zip entry is a file" output="false" returntype="boolean">
		<cfargument name="pathToZipEntry" hint="I am the path to the file in the zip file." required="yes" type="string" />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntry = 0 />
		
		<!--- check to see if the entry is a directory --->
		<cfif isDirectory(arguments.pathToZipEntry)>
			<cfreturn false />
		</cfif>
		
		<!--- it's not a directory, get the entry and see if it's a file --->
		<cfset ZipEntry = getZipEntry(ZipFile, normalizeEntryName(arguments.pathToZipEntry)) />
		
		<!--- if ZipEntry Exists it exists --->
		<cfif NOT ZipEntry.isDirectory()>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!--- isDirectory --->
	<cffunction name="isDirectory" access="public" hint="I indicate if a zip entry is a directory" output="false" returntype="boolean">
		<cfargument name="pathToZipEntry" hint="I am the path to the directory in the zip file." required="yes" type="string" />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntries = ZipFile.entries() />
		<cfset var ZipEntry = 0 />
		<cfset arguments.pathToZipEntry = normalizeEntryName(arguments.pathToZipEntry & "/") />
		
		<!--- pathToZipEntry will be "" when it's the root directory --->
		<cfif pathToZipEntry IS "">
			<cfreturn true />
		</cfif>
		
		<cfloop condition="#ZipEntries.hasMoreElements()#">
			<cfset ZipEntry = ZipEntries.nextElement() />
			
			<cfif ZipEntry.isDirectory() AND Left(normalizeEntryName(ZipEntry.getName()), Len(arguments.pathToZipEntry)) IS arguments.pathToZipEntry>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>	
	
	<!--- readZipFile --->
	<cffunction name="readZipFile" access="private" hint="I read the zip file." output="false" returntype="any">
		<cfset var ZipFile = 0 />
		
		<cftry>
			<cfset ZipFile = CreateObject("Java", "java.util.zip.ZipFile").init(JavaCast("string", getPathToZipFile())) />
			<cfcatch>
				<cfthrow message="Could Not Read Zip File" detail="An error occurred when attempting to read from the zip file '#getPathToZipFile()#'.  The file may be corrupt." type="Zip.readZipFile.CouldNotReadZipFile" />
			</cfcatch>
		</cftry>
		
		<cfreturn ZipFile />
	</cffunction>
	
	<!--- getZipEntry --->
	<cffunction name="getZipEntry" access="private" hint="I get a specific entry from the zip file." output="false" returntype="any">
		<cfargument name="ZipFile" hint="I am the zipFile to get the entry from." required="yes" type="any" />
		<cfargument name="pathToZipEntry" hint="I am the path to the entry in the zip file to read." required="yes" type="string" />
		<cfset var ZipEntries = arguments.ZipFile.entries() />
		<cfset var ZipEntry = 0 />
		<cfset arguments.pathToZipEntry = normalizeEntryName(arguments.pathToZipEntry) />
		
		<!--- pathToZipEntry will be "" when it's the root directory --->
		<cfif pathToZipEntry IS "">
			<cfreturn true />
		</cfif>
		
		<cfloop condition="#ZipEntries.hasMoreElements()#">
			<cfset ZipEntry = ZipEntries.nextElement() />
			
			<cfif normalizeEntryName(ZipEntry.getName()) IS arguments.pathToZipEntry>
				<cfreturn ZipEntry />
			</cfif>
		</cfloop>
		
		<cfthrow message="Invalid Zip Entry" detail="The zip entry '#arguments.pathToZipEntry#' does not exist." type="Zip.getZipEntry.InvalidZipEntry" />
	</cffunction>
	
	<!--- normalizeEntryName --->
	<cffunction name="normalizeEntryName" access="private" hint="I normalize entry names." output="false" returntype="string">
		<cfargument name="pathToFile" hint="I am the path to normalize." required="yes" type="string" />
		<cfargument name="prependDirectory" hint="I am the directory to prepend." required="no" type="string" default="" />
		
		<cfset arguments.pathToFile = Replace(arguments.prependDirectory, "\", "/", "all") & "/" & Replace(arguments.pathToFile, "\", "/", "all") />
		<cfset arguments.pathToFile = ReReplace(arguments.pathToFile, "/+", "/", "all") />
		<cfset arguments.pathToFile = ReReplace(arguments.pathToFile, "^/*", "") />
		
		<cfreturn arguments.pathToFile />
	</cffunction>
	
	<!---- writeAsTextFile --->
	<cffunction name="writeAsTextFile" access="public" hint="I write the text contents passed in to the specified file in the zip document." output="false" returntype="string">
		<cfargument name="pathToZippedFile" hint="I am the path to the file in the zip file to write." required="yes" type="string" />
		<cfargument name="contents" hint="I am the contents to write to the file." required="yes" type="string" />
		<!--- I'm not checking the license here because I'm just going to call writeAsBinaryFile --->
		<cfset writeAsBinaryFile(arguments.pathToZippedFile, arguments.contents.getBytes()) />
	</cffunction>
	
	<!---- writeAsBinaryFile --->
	<cffunction name="writeAsBinaryFile" access="public" hint="I write the binary contents passed in to the specified file in the zip document." output="false" returntype="string">
		<cfargument name="pathToZippedFile" hint="I am the path to the file in the zip file to write." required="yes" type="string" />
		<cfargument name="contents" hint="I am the contents to write to the file." required="yes" type="binary" />
		<cfset var TempFile = GetTempFile(GetTempDirectory(), "azc_")/>
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		<cfset var ZipOutputStream = 0 />
		<cfset var ZipFile = 0 />
		<cfset var ZipEntries = 0 />
		<cfset var ZipEntry = 0 />
		<cfset var NewZipEntry = 0 />
		<cfset var ZipInputStream = 0 />
		<cfset var ByteArrayInputStream = 0 />
		<cfset var zipFileName = normalizeEntryName(arguments.pathToZippedFile) />
		<!---<cfset var SourceFile = 0 />
		<cfset var Destination = CreateObject("Java", "java.io.File").init(JavaCast("String", getPathToZipFile())) />--->
		
		<cfset checkLicense() />
		
		<!--- make sure the zipFileName is a file and not a directory --->
		<cfif NOT Len(GetFileFromPath(zipFileName))>
			<cfthrow message="PathToZippedFile Can Not Be Directory" detail="The zip entry specified by the pathToZippedFile argument must specify a file and not a directory." type="Zip.writeAsBinaryFile.PathToZippedFileCanNotBeDirectory" />
		</cfif>
		
		<!--- create a temp zip file --->
		<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(JavaCast("String", TempFile)) />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
		<cfset ZipOutputStream = CreateObject("Java", "java.util.zip.ZipOutputStream").init(BufferedOutputStream) />
		
		<!--- configure the outputstream --->
		<cfset ZipOutputStream.setMethod(ZipOutputStream.DEFLATED) />
		<cfset ZipOutputStream.setLevel(getCompression()) />
		
		<!--- add all of the current zip file's entries to the temp zip file (if a file with the same name as what's being added exists don't copy it) --->
		<cfif FileExists(getPathToZipFile())>
			<cfset ZipFile = readZipFile() />
			<cfset ZipEntries = ZipFile.entries() />
			
			<!--- copy the entries into the new zip file --->
			<cfloop condition="#ZipEntries.hasMoreElements()#">
				<cfset ZipEntry = ZipEntries.nextElement() />
				
				<!--- if this is the same name as the file being added then we will ignore it --->
				<cfif ZipEntry.getName() IS NOT zipFileName>
					<cfset ZipInputStream = ZipFile.getInputStream(ZipEntry) />
					
					<!--- add the entry to the ZipOutputStream --->
					<cfset NewZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", ZipEntry.getName())) />
					<cfset copyMetadata(ZipEntry, NewZipEntry) />
					<cfset ZipOutputStream.putNextEntry(NewZipEntry) />
					
					<!--- copy the zip entry to the new zip file --->
					<cfset copyStream(ZipInputStream, ZipOutputStream) />
					
					<!--- close the FileInputStream and the current entry --->
					<cfset ZipInputStream.close() />
					<cfset ZipOutputStream.closeEntry() />
				</cfif>
			</cfloop>
			
			<!--- close the ZipFile --->
			<cfset ZipFile.close() />
		</cfif>
		
		<!--- create an input stream for the content being added --->
		<cfset ByteArrayInputStream = CreateObject("Java", "java.io.ByteArrayInputStream").init(arguments.contents) />
		<cfset ZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", zipFileName)) />
		
		<!--- add the entry to the ZipOutputStream --->
		<cfset ZipOutputStream.putNextEntry(ZipEntry) />
		
		<!--- copy the file to be zipped data into the zip file --->
		<cfset copyStream(ByteArrayInputStream, ZipOutputStream) />
		
		<!--- close both streams --->
		<cfset ByteArrayInputStream.close() />
		<cfset ZipOutputStream.close() />
				
		<!--- move the temp file.  I'm using java 'cause CF doesn't alwasy let go of it's locks right away apparently
		<cfset SourceFile = CreateObject("Java", "java.io.File").init(JavaCast("String", TempFile)) />
		<cfset SourceFile.renameTo(Destination) /> --->
				
		<!--- move the temp file to the output file --->	
		<cffile action="move" source="#TempFile#" destination="#getPathToZipFile()#" nameconflict="overwrite" />	
	</cffunction>
	
	<!--- readAsTextFile --->
	<cffunction name="readAsTextFile" access="public" hint="I read an entry from the zip file and return it as text." output="false" returntype="string">
		<cfargument name="pathToZipEntry" hint="I am the path to the entry in the zip file to read." required="yes" type="string" />
		
		<cfset checkLicense() />
		
		<cfreturn readFile(arguments.pathToZipEntry).toString() />
	</cffunction>
	
	<!--- readAsBinaryFile --->
	<cffunction name="readAsBinaryFile" access="public" hint="I read an entry from the zip file and return it as binary data." output="false" returntype="binary">
		<cfargument name="pathToZipEntry" hint="I am the path to the entry in the zip file to read." required="yes" type="string" />
		
		<cfset checkLicense() />
		
		<cfreturn readFile(arguments.pathToZipEntry).toByteArray() />
	</cffunction>
	
	<!--- readFile --->
	<cffunction name="readFile" access="private" hint="I read an entry from the zip file and return it as ByteArrayOutputStream." output="false" returntype="any">
		<cfargument name="pathToZipEntry" hint="I am the path to the entry in the zip file to read." required="yes" type="string" />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntry = getZipEntry(ZipFile, normalizeEntryName(arguments.pathToZipEntry)) />
		<cfset var InputStream = 0 />
		<cfset var ByteArrayOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
				
		<!--- this method only extracts files --->
		<cfif ZipEntry.isDirectory()>
			<cfthrow message="PathToZipEntry Can Not Be A Directory" detail="The zip entry specified by the pathToZipEntry argument passed to the readFile method must be a file and not a directory." type="Zip.readAsTextFile.PathToZipEntryCanNotBeADirectory" />
		</cfif>
		
		<!--- get an input stream for the entry --->
		<cfset InputStream = ZipFile.getInputStream(ZipEntry) />
		
		<!--- create an output stream --->
		<cfset ByteArrayOutputStream = CreateObject("Java", "java.io.ByteArrayOutputStream").init() />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(ByteArrayOutputStream) />
		
		<!--- copy data from the input to the output stream --->
		<cfset copyStream(InputStream, BufferedOutputStream) />

		<!--- close both streams --->
		<cfset InputStream.close() />
		<cfset BufferedOutputStream.close() />

		<!--- close the ZipFile --->
		<cfset ZipFile.close() />
		
		<!--- return the data --->
		<cfreturn ByteArrayOutputStream />
	</cffunction>
	
	<!--- deleteFile --->
	<cffunction name="deleteFile" access="public" hint="I delete the specified file from the zip file." output="false" returntype="void">
		<cfargument name="pathToZippedFile" hint="I am the path to the file to add to the zip file." required="yes" type="string" />
		<cfset var TempFile = GetTempFile(GetTempDirectory(), "azc_")/>
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		<cfset var ZipOutputStream = 0 />
		<cfset var ZipFile = 0 />
		<cfset var ZipEntries = 0 />
		<cfset var ZipEntry = 0 />
		<cfset var NewZipEntry = 0 />
		<cfset var ZipInputStream = 0 />
		<cfset var zipFileName = normalizeEntryName(arguments.pathToZippedFile) />
		
		<cfset checkLicense() />
		
		<!--- insure the file to delete exists --->
		<cfset isFile(zipFileName) />
		
		<!--- create a temp zip file --->
		<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(JavaCast("String", TempFile)) />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
		<cfset ZipOutputStream = CreateObject("Java", "java.util.zip.ZipOutputStream").init(BufferedOutputStream) />
		
		<!--- configure the outputstream --->
		<cfset ZipOutputStream.setMethod(ZipOutputStream.DEFLATED) />
		<cfset ZipOutputStream.setLevel(getCompression()) />
		
		<!--- add all of the current zip file's entries to the temp zip file (if a file with the same name as what's being deleted exists don't copy it) --->
		<cfif FileExists(getPathToZipFile())>
			<cfset ZipFile = CreateObject("Java", "java.util.zip.ZipFile").init(getPathToZipFile()) />
			<cfset ZipEntries = ZipFile.entries() />
			
			<!--- copy the entries into the new zip file --->
			<cfloop condition="#ZipEntries.hasMoreElements()#">
				<cfset ZipEntry = ZipEntries.nextElement() />
				
				<!--- if this is the same name as the file being added then we will ignore it --->
				<cfif ZipEntry.getName() IS NOT zipFileName>
					<cfset ZipInputStream = ZipFile.getInputStream(ZipEntry) />
					
					<!--- add the entry to the ZipOutputStream --->
					<cfset NewZipEntry = CreateObject("Java", "java.util.zip.ZipEntry").init(JavaCast("String", ZipEntry.getName())) />
					<cfset copyMetadata(ZipEntry, NewZipEntry) />
					<cfset ZipOutputStream.putNextEntry(NewZipEntry) />
					
					<!--- copy the zip entry to the new zip file --->
					<cfset copyStream(ZipInputStream, ZipOutputStream) />
					
					<!--- close the FileInputStream and the current entry --->
					<cfset ZipInputStream.close() />
					<cfset ZipOutputStream.closeEntry() />
				</cfif>
			</cfloop>
			
			<!--- close the ZipFile --->
			<cfset ZipFile.close() />
		</cfif>
		
		<!--- close both streams --->
		<cfset ZipOutputStream.close() />
		
		<!--- move the temp file to the output file --->
		<cffile action="move" source="#TempFile#" destination="#getPathToZipFile()#" nameconflict="overwrite" />
	</cffunction>
	
	<!--- extractFile --->
	<cffunction name="extractFile" access="public" hint="I extract an entry from the zip file and write it to disk." output="false" returntype="void">
		<cfargument name="pathToZipEntry" hint="I am the path to the entry in the zip file to extract." required="yes" type="string" />
		<cfargument name="extractToPath" hint="I am the path to the file or directory to extract the entry into." required="yes" type="string" />
		<cfargument name="preserveDirectories" hint="I indicate if the directory structure should be maintianed when extracting the specified file.  If true, extractToPath must be a directory." required="no" type="boolean" default="false" />
		<cfset var File = CreateObject("Java", "java.io.File").init(JavaCast("string", arguments.extractToPath)) />
		<cfset var ZipFile = readZipFile() />
		<cfset var ZipEntry = getZipEntry(ZipFile, normalizeEntryName(arguments.pathToZipEntry)) />
		<cfset var InputStream = 0 />
		<cfset var FileOutputStream = 0 />
		<cfset var BufferedOutputStream = 0 />
		
		<cfset checkLicense() />
		
		<!--- this method only extracts files --->
		<cfset isDirectory(normalizeEntryName(arguments.pathToZipEntry)) />		
		
		<!--- check if the extractToPath exists --->
		<cfif preserveDirectories AND NOT File.exists()>
			<!--- create the extractToPath --->
			<cfset File.mkdirs() /> 
		<cfelseif NOT preserveDirectories AND NOT File.exists() AND NOT Len(GetFileFromPath(arguments.extractToPath))>
			<!--- create the extractToPath directory --->
			<cfset File.mkdirs() />
		</cfif>
		
		
		<cfif preserveDirectories AND NOT File.isDirectory()>
			<!--- if we're preserving the directory structure in the zip then insure that the extractToPath arg is a directory --->
			<cfthrow message="ExtractToPath Must Be Directory When PreserveDirectories Is True" detail="The path specified in the ExtractToPath argument must be a directory when the PreserveDirectories argument is true." type="Zip.extractFile.ExtractToPathMustBeDirectoryWhenPreserveDirectoriesIsTrue" />
		
		<cfelseif preserveDirectories AND File.isDirectory()>
			<!--- if we're preserving the directory structure then append the full path the zip file to the extract to path to get the full extraction path --->
			<cfset File = CreateObject("Java", "java.io.File").init(File.getPath() & "/" & ZipEntry.getName()) />
					
		<cfelseif NOT preserveDirectories AND File.isDirectory()>
			<!--- if we're not preserving the directory structure then append only the file represented by the zip entry to the extraction path to the get full path --->
			<cfset File = CreateObject("Java", "java.io.File").init(File.getPath() & "/" & GetFileFromPath(ZipEntry.getName())) />
		
		</cfif>
		
		<!--- get an input stream for the entry --->
		<cfset InputStream = ZipFile.getInputStream(ZipEntry) />
		
		<!--- make any needed parent directories --->
		<cfset File.getParentFile().mkdirs() />
		
		<!--- create an output stream --->		
		<cfset FileOutputStream = CreateObject("Java", "java.io.FileOutputStream").init(File) />
		<cfset BufferedOutputStream = CreateObject("Java", "java.io.BufferedOutputStream").init(FileOutputStream) />
		
		<!--- copy data from the input to the output stream --->
		<cfset copyStream(InputStream, BufferedOutputStream) />

		<!--- close both streams --->
		<cfset InputStream.close() />
		<cfset BufferedOutputStream.close() />

		<!--- close the ZipFile --->
		<cfset ZipFile.close() />
	</cffunction>
	
	<!--- copyStream --->
	<cffunction name="copyStream" access="private" hint="I extract the specified ZipEntry from the sepecified ZipInputStream to the specified path." output="false" returntype="void">
		<cfargument name="InputStream" hint="I am the InputStream to write to the output stream." required="yes" type="any" />
		<cfargument name="BufferedOutputStream" hint="I am the BufferedOutputStream being written to." required="yes" type="any" />
		<cfset var buffer = getByteArray(1024) />
		<cfset var len = 0 />

		<!--- copy data from the input stream to the output stream --->
		<cfloop condition="len IS NOT -1">
			<cfset len = arguments.InputStream.read(buffer) />
			<cfif len IS NOT -1>
				<cfset arguments.BufferedOutputStream.write(buffer, 0, len) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- getByteArray (http://weblogs.macromedia.com/cantrell/archives/2004/01/byte_arrays_and_1.cfm) --->
	<cffunction name="getByteArray" access="private" hint="I create a java byte array of the correct length." output="false" returnType="binary">
		<cfargument name="size" type="numeric" required="true"/>
		<cfset var emptyByteArray = createObject("java", "java.io.ByteArrayOutputStream").init().toByteArray()/>
		<cfset var byteClass = emptyByteArray.getClass().getComponentType()/>
		<cfset var byteArray = createObject("java","java.lang.reflect.Array").newInstance(byteClass, arguments.size)/>
		<cfreturn byteArray/>
	</cffunction>
	
	<!--- compression --->
    <cffunction name="setCompression" access="public" output="false" returntype="void">
		<cfargument name="compression" hint="I am the amount of compression to apply.  Values are 0 to 9." required="yes" type="numeric" />
		
		<cfif arguments.compression LT 0 OR arguments.compression GT 9>
			<cfthrow message="Invalid Compression Argument" detail="The Compression argument, currently '#arguments.compression#', passed to the setCompression method must be a numeric value between 0 and 9." type="Zip.setCompression.InvalidCompressionArgument" />
		</cfif>
		
		<cfset variables.compression = arguments.compression />
    </cffunction>
    <cffunction name="getCompression" access="public" output="false" returntype="numeric">
		<cftry>
			<cfreturn variables.compression />
			<cfcatch>
				<cfset notInited() />
			</cfcatch>
		</cftry>
    </cffunction>
	
	<!--- key --->
    <cffunction name="setKey" access="private" output="false" returntype="void">
       <cfargument name="key" hint="I am the key used to unlock the software.  This will preven the image from drawing Alagad Captcha across the image." required="yes" type="string" />
	   
	   <!--- validate the key --->
	   <cfif validateKey(arguments.key, getAppText())>
	   	 <cfset variables.licensed = true />
	   <cfelse>
	     <cfset variables.licensed = false />
	   </cfif>
    </cffunction>
	
	<cffunction name="getKey" access="private" output="false" returntype="string">
		<cfargument name="initialChars" required="true" type="string" />
		<cfargument name="appText" required="true" type="string" />
		<cfset var md5String = "" />
		<cfset var key = "" />
		
		<!--- get a hash of the string --->
		<cfset md5String = hash(initialChars & arguments.appText) />
		<cfset key = arguments.initialChars />
		
		<!--- 
			Loop over the hash, grabing 2 chars on each look, convert them to base 10 and mod 32 the results.
			This value is the character in the list of valid chars we will be using for this char in the resulting key.
		--->
		<cfloop from="1" to="32" index="i" step="2">
			<cfset key = key & Mid(getCharString(), (InputBaseN(Mid(md5String, i, 2),16) Mod 32) + 1, 1) />
		</cfloop>
		
		<cfif Len(key) IS 25>
			<!--- add dashes --->
			<cfset key = Insert("-", key, 20) />
			<cfset key = Insert("-", key, 15) />
			<cfset key = Insert("-", key, 10) />
			<cfset key = Insert("-", key, 5) />
		</cfif>
		
		<cfreturn key />
	</cffunction>
	
	<!--- key related --->
	<cffunction name="validateKey" access="private" output="false" returntype="boolean">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="appText" required="true" type="string" />
		<cfset var initialChars = "" />
		
		<!--- fix the key (remove all hyphens) --->
		<cfset arguments.key = Replace(arguments.key, "-", "", "all") />
	
		<!--- grab the first 9 chars --->
		<cfset initialChars = Left(arguments.key, 9) />
			
		<!--- get a key and compare to our current key  --->
		<cfreturn Replace(getKey(initialChars, arguments.appText), "-", "", "all") IS arguments.key />
	</cffunction>
	
	<!--- licensed --->
    <cffunction name="setLicensed" access="private" output="false" returntype="void">
       <cfargument name="licensed" hint="I indicate if the zip component is licensed." required="yes" type="boolean" />
       <cfset variables.licensed = arguments.licensed />
    </cffunction>
    <cffunction name="getLicensed" access="private" output="false" returntype="boolean">
		<cftry>
			<cfreturn variables.licensed />
			<cfcatch>
				<cfset notInited() />
			</cfcatch>
		</cftry>
    </cffunction>
	
	<!--- appText --->
    <cffunction name="getAppText" access="private" output="false" returntype="string">
		<cftry>
			<cfreturn variables.appText />
			<cfcatch>
				<cfset notInited() />
			</cfcatch>
		</cftry>
    </cffunction>
	
	<!--- charString --->
    <cffunction name="getCharString" access="private" output="false" returntype="string">
		<cftry>
			<cfreturn variables.charString />
			<cfcatch>
				<cfset notInited() />
			</cfcatch>
		</cftry>
    </cffunction>
	
	<!--- pathToZipFile --->
    <cffunction name="setPathToZipFile" access="private" output="false" returntype="void">
		<cfargument name="pathToZipFile" hint="I am the path to the zip file." required="yes" type="string" />
		<cfset variables.pathToZipFile = arguments.pathToZipFile />
    </cffunction>
    <cffunction name="getPathToZipFile" access="private" output="false" returntype="string">
		<cftry>
			<cfreturn variables.pathToZipFile />
			<cfcatch>
				<cfset notInited() />
			</cfcatch>
		</cftry>
    </cffunction>
	
	<!--- notInited --->
	<cffunction name="notInited" access="private" output="false" returntype="void">
		<cfthrow message="Zip Component Not Inited" detail="The component has not been configured.  You must first call the init() method before you can call any other methods." type="Zip.notInited.ZipComponentNotInited" />
	</cffunction>
	
</cfcomponent>