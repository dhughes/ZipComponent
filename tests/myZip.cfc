<cfcomponent extends="zip.zip">
	
	<cffunction name="listByDate" access="public" hint="I list all the files in a zip modified on or after a specific date." output="false" returntype="query">
		<cfargument name="date" hint="I am the date to use when filtering the zip contents." required="yes" type="date">
		<cfset qList = list() />
		
		<cfquery name="qList" dbtype="query">
			SELECT *
			FROM qList
			WHERE lastModified > '#arguments.date#'
		</cfquery>
		
		<cfreturn qList />
	</cffunction>
	
</cfcomponent>