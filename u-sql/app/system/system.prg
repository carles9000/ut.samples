#define CRLF  chr(10)+chr(13)

function CheckIni()

	LOCAL cFileIni	:= HB_DIRBASE() + 'app.ini'
	LOCAL hIni 	:= hb_iniRead( HB_DIRBASE() + 'app.ini', .F. )
	LOCAl hConfig 	:= {=>}
	local cHeader 
	
	if file( cFileIni )			

		hIni := hb_iniRead( cFileIni, .F. )				
	
		hConfig[ 'port' ] 			:= Val( IniLoad( hIni, 'main', 'port', '81' ) )
		hConfig[ 'path_mysql' ] 	:= IniLoad( hIni, 'main', 'path_mysql', 'c:\xampp\htdocs\' ) 
			
		/*	Ex. Add info to ini file
			? "Adding section 'Added', with key NEW = new"
			hIni[ "Added" ] := { => }
			hIni[ "Added" ][ "NEW" ] := "new"				
		*/

		
	else
	
		cHeader := '# ------------------------------------' + CRLF
		cHeader += '# UT (UHttpd2+TWeb/Engine)' + CRLF
		cHeader += '#' + CRLF 
		cHeader += '# Copyright 2022-2023 Charly Aubia' + CRLF
		cHeader += '# ------------------------------------' + CRLF 
	
		hIni := {=>}
		hIni[ 'main' ] := {=>}
		hIni[ 'main' ][ 'port' ]		:= '81'
		hIni[ 'main' ][ 'path_mysql' ]	:= 'c:\xampp\htdocs\'
		
				
   //IF hb_iniWrite( "parseini_out.ini", hIni, "#Generated file; don't touch", "#End of file" )
	   IF hb_iniWrite( cFileIni, hIni, cHeader )
		  //_d( "File written" )
	   ELSE
		  //_d( "Can't write file" )
	   ENDIF
	   
	    hConfig := CheckIni()	   		
		
	endif

retu hConfig 

// -------------------------------------------------- //

static function IniLoad( hIni, cGroup, cLabel, uDefault )

	local uValue := ''

	hb_default( @cGroup, '' )
	hb_default( @cLabel, '' )

	if !empty( cGroup ) .and. !empty( cLabel )	

		HB_HCaseMatch( hIni, .F. )
		
		if HB_HHasKey( hIni, cGroup ) 
		
			HB_HCaseMatch( hIni[ cGroup ], .F. )
			
			if HB_HHasKey( hIni[ cGroup ], cLabel )	
				uValue := hIni[ cGroup ][ cLabel ] 
			else
				if !empty( uDefault )
					uValue := uDefault
				endif							
			endif
			
		endif
		
	else 
	
		if !empty( uDefault )
			uValue := uDefault
		endif
		
	endif				
	
retu uValue 

// -------------------------------------------------- //

function CheckDbfs()
	local cAlias

	if !hb_DirExists( AppPathData() )
		HB_DirBuild( AppPathData() )
	endif 

	if !file( AppPathData() + 'users.dbf' )
		InitDbfUsers()
	endif
	
	if !file( AppPathData() + 'connections.dbf' )
		InitDbfConnections()
	endif	
	
	if !file( AppPathData() + 'class.dbf' )
		InitDbfClass()
	endif	

	if !file( AppPathData() + 'consulta.dbf' )
	
	else
		if !file( AppPathData() + 'consulta.cdx' )
			USE ( AppPathData() + 'consulta.dbf' ) NEW VIA 'DBFCDX'
			cAlias := Alias()
			
			(cAlias)->( OrdCreate(  AppPathData() + 'consulta.cdx' , 'consulta', 'consulta' ) )		
			(cAlias)->( DbCloseArea())
		endif
	endif
	
retu nil 



// -------------------------------------------------- //

static function InitDbfUsers()

	LOCAL aStruct := { ;
			   { "USER"		, "C", 10, 0 }, ;
			   { "NAME"		, "C", 20, 0 }, ;
			   { "PROFILE"	, "C",  1, 0 }, ;
			   { "ACTIVE"	, "L",  1, 0 }, ;
			   { "PASSWORD" , "C", 36, 0 } ;
			}
	LOCAL cAlias
			   
	dbCreate( AppPathData() + 'users.dbf', aStruct, "DBFCDX" )
	
	USE ( AppPathData() + 'users.dbf' ) NEW VIA 'DBFCDX'
	cAlias := Alias()
	
	(cAlias)->( OrdCreate(  AppPathData() + 'users.cdx' , 'user', 'user' ) )
	
	SET INDEX TO ( AppPathData() + 'users.cdx' )	
	
	(cAlias)->( DbAppend() )
	(cAlias)->user			:= 'admin'
	(cAlias)->name			:= 'Administrator U-Dbu' 
	(cAlias)->profile 		:= 'A'
	(cAlias)->active 		:= .t.
	(cAlias)->password		:= hb_md5( '1234' )
	
	(cAlias)->( DbAppend() )
	(cAlias)->user			:= 'user'
	(cAlias)->name			:= 'Mr. User for U-Dbu' 
	(cAlias)->profile 		:= 'U'
	(cAlias)->active 		:= .t.
	(cAlias)->password		:= hb_md5( '1234' )			

	(cAlias)->( DbCloseArea() )
		
retu nil 

// -------------------------------------------------- //

static function InitDbfConnections()

	LOCAL aStruct := { ;
			   { "NAME"			, "C", 20, 0 }, ;
			   { "DESCRIPTION"	, "C", 80, 0 }, ;
			   { "IP"			, "C", 20, 0 }, ;			   
			   { "PORT"			, "N",  5, 0 }, ;			   
			   { "DB"			, "C", 20, 0 }, ;			   
			   { "USER"			, "C", 20, 0 }, ;			   
			   { "PSW"			, "C", 20, 0 }, ;			   
			   { "ACTIVE"		, "L",  1, 0 }  ;			   
			}
	LOCAL cAlias
			   
	dbCreate( AppPathData() + 'connections.dbf', aStruct, "DBFCDX" )
	
	USE ( AppPathData() + 'connections.dbf' ) NEW VIA 'DBFCDX'
	cAlias := Alias()
	
	(cAlias)->( OrdCreate(  AppPathData() + 'connections.cdx' , 'name', 'name' ) )
	
	SET INDEX TO ( AppPathData() + 'connections.cdx' )	
	
	(cAlias)->( DbAppend() )
	(cAlias)->name			:= 'DUMMY'
	(cAlias)->descriptio 	:= 'Description of connection...'		
	(cAlias)->active 		:= .f.					

	(cAlias)->( DbCloseArea() )
		
retu nil 


// -------------------------------------------------- //

static function InitDbfClass()

	LOCAL aStruct := { ;
			   { "NAME"			, "C", 10, 0 }, ;
			   { "DESCRIPTION"	, "C", 80, 0 }, ;		   
			   { "ACTIVE"		, "L",  1, 0 }  ;			   
			}
	LOCAL cAlias
			   
	dbCreate( AppPathData() + 'class.dbf', aStruct, "DBFCDX" )
	
	USE ( AppPathData() + 'class.dbf' ) NEW VIA 'DBFCDX'
	cAlias := Alias()
	
	(cAlias)->( OrdCreate(  AppPathData() + 'class.cdx' , 'name', 'name' ) )
	
	SET INDEX TO ( AppPathData() + 'class.cdx' )	
	
	(cAlias)->( DbAppend() )
	(cAlias)->name			:= 'DUMMY'
	(cAlias)->descriptio 	:= 'Dummy class...'		
	(cAlias)->active 		:= .f.					

	(cAlias)->( DbCloseArea() )
		
retu nil

// -------------------------------------------------- //

function NewAlias( cPre )

	STATIC n := 0
	
	hb_default( @cPre, 'ALIAS')	
retu cPre + ltrim(str(++n))

// -------------------------------------------------- //
/*
function IsDllReady( cFile )

	local hDLL, lReady 
   
	hb_default( @cFile, '' )
   
	if empty( cFile )
		retu .f.
	endif

	hDLL 	:= LoadLibrary( cFile )
	lReady 	:= hDLL != 0
   
	if lReady
		FreeLibrary( hDLL )
	endif

return lReady
*/

// -------------------------------------------------- //