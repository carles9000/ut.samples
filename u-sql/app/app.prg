#include 'lib/uhttpd2/uhttpd2.ch'

request DBFCDX
request TWEB, WDO 
request ORDKEYNO, DBSKIP


//	Default codepage ------
REQUEST HB_CODEPAGE_ES850  	
REQUEST HB_LANG_ES
REQUEST HB_CODEPAGE_ESWIN 
REQUEST HB_CODEPAGE_ESMWIN
//	-----------------------

#define VK_ESCAPE	27
#define APP_TITLE 		'U-Sql'
#define APP_VERSION 	'v1.0'

// -------------------------------------------------- //

function main()

	hb_threadStart( @WebServer() )	
	
	while inkey(0) != VK_ESCAPE
	end

retu nil 

// -------------------------------------------------- //

function WebServer( hConfig )

	local oServer 		:= Httpd2()
	local hCfg 		:= Config()

	HB_HCaseMatch( hCfg, .F. )
	
	HB_SetEnv( 'WDO_PATH_MYSQL', HB_HGetDef( hCfg, 'path_mysql', '' ) )	

	oServer:SetPort( HB_HGetDef( hCfg, 'port', 81 ) )
	
	oServer:bInit := {|| ServerInfo( hCfg ) }
	
	//	Routing...			
		oServer:Route( '/'			 , 'main.html' )  												
		
		oServer:Route( 'login'		 , 'security/login.html' )  												
		oServer:Route( 'logout'	 , 'logout' )  				//	<< Func				
		

	//	Application	
		oServer:Route( 'mydata'  	 , 'app/mydata.html' )  
		oServer:Route( 'def_sql'    , 'app/def_sql.html' )  
		oServer:Route( 'query'    	 , 'app/query.html' )  
	
	
	//	System
		oServer:Route( 'server_info', 'system/server_info.html' )  
		oServer:Route( 'mysql_info' , 'system/mysql_info.html' )  
	
	
	//	Tables
		oServer:Route( 'users'		 , 'tables/users.html' )  												
		oServer:Route( 'connections', 'tables/connections.html' )  												
		oServer:Route( 'class'		 , 'tables/class.html' )  												
	
	//	Public
		oServer:Route( 'splash'	 , 'public/splash.html' )  												
		oServer:Route( 'about'		 , 'public/about.html' )  												
		
	//	-----------------------------------------------------------------------//	

	IF ! oServer:Run()
	
		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF
	
RETURN 0

// -------------------------------------------------- //

function ServerInfo( h) 	
	
	local hCfg 	:= UGetServerInfo()
	local cLibName	:= HB_GetEnv( 'WDO_PATH_MYSQL' ) + 'libmysql64.dll'	
	local cMsg 	:= 'Server ' + APP_TITLE + ' ' + APP_VERSION + ' was started...'
	local nLen 	:= len( cMsg )

	hCfg[ 'path' ] 			:= HB_DIRBASE()		
	hCfg[ 'os' ] 			:= os()
	hCfg[ 'harbour' ] 		:= version()
	hCfg[ 'builddate' ] 	:= HB_BUILDDATE()
	hCfg[ 'compiler' ] 		:= HB_compiler()
	hCfg[ 'codepage' ] 		:= hb_SetCodePage() + '/' + hb_cdpUniID( hb_SetCodePage() )
	hCfg[ 'version_tweb' ] 	:= TWebVersion()

	CConsole Replicate( '-', nLen )
	Console  cMsg
	Console Replicate( '-', nLen )
	

	Console  'Path.............: ' + lower( hCfg[ 'path' ] )
	Console  'Path mysql.......: ' + h[ 'path_mysql' ] 		
	Console  'Version httpd2...: ' + hCfg[ 'version' ] 	
	Console  'Start............: ' + hCfg[ 'start' ] 		
	Console  'Port.............: ' + ltrim(str(hCfg[ 'port' ])) 		
	Console  'OS...............: ' + hCfg[ 'os' ] 		
	Console  'Harbour..........: ' + hCfg[ 'harbour' ] 	
	Console  'Build date.......: ' + hCfg[ 'builddate' ] 	
	Console  'Compiler.........: ' + hCfg[ 'compiler' ] 	
	Console  'SSL..............: ' + if( hCfg[ 'ssl' ], 'Yes', 'No' )
	Console  'Trace............: ' + if( hCfg[ 'debug' ], 'Yes', 'No' )		
	Console  'Codepage.........: ' + hCfg[ 'codepage' ] 	
	Console  'UTF8 (actived)...: ' + if( hCfg[ 'utf8' ], 'Yes', 'No' )
	
	cMsg	:= 'MySql dll........: ' + cLibName + ' => ' + if( file( cLibName ), 'Ready', 'Fail' )
	nLen 	:= len( cMsg )
	
	Console  Replicate( '-', nLen )
	Console  cMsg
	Console  Replicate( '-', nLen )
	Console  'Escape for exit...' 		

retu nil 

// -------------------------------------------------- //

function Config()	

	local hCfg, o
	
	RddSetDefault( 'DBFCDX' )
	
	HB_LANGSELECT('ES')        
    HB_SetCodePage ( "ESWIN" )		
	
	SET( _SET_DBCODEPAGE, 'ESWIN' )		
	SET( _SET_DELETED, 'ON' )			
	
	SET AUTOPEN OFF 
	SET DATE FORMAT TO 'DD/MM/YYYY' 
	
	CheckDbfs()
	
	hCfg := CheckIni()	
	
	o := WDO_MYSQL()
	o:lShowError := .f.	
	
retu hCfg 

// -------------------------------------------------- //

function AppTitle() 		; retu APP_TITLE
function AppVersion() 	; retu APP_VERSION
function AppPathData()	; retu HB_DIRBASE() + 'data.sys\'

// -------------------------------------------------- //

function AppLoadConnect() 

	local oConn := TDbf():New( 'connections.dbf', 'connections.cdx', 'name' )
	local aRows := {}
	
	Aadd( aRows, '' )
	
	while (oConn:cAlias)->( !eof() )
	
		if (oConn:cAlias)->active
			Aadd( aRows, alltrim((oConn:cAlias)->name ))
		endif
		
		(oConn:cAlias)->(dbskip())
	end	

	(oConn:cAlias)->( DbCloseArea() )

retu aRows

// -------------------------------------------------- //

function AppGetConnect( cName ) 

	local cPath := ''
	local oConn := TDbf():New( 'connections.dbf', 'connections.cdx', 'name' )
	
	hb_default( @cName, '' )

	if oConn:Seek( cName )
		retu oConn:Row()
	endif

retu nil 