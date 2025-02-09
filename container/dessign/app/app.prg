#define VK_ESCAPE	27

request DBFCDX
request tweb

function main()

	hb_threadStart( @WebServer() )	
	
	while inkey(0) != VK_ESCAPE
	end

retu nil 

//----------------------------------------------------------------------------//

function WebServer()

	local oServer 	:= Httpd2()
	
	oServer:SetPort( 81 )
	oServer:SetDirFiles( 'data' )
	
	//	Routing...			

		oServer:Route( '/'		, 'index.html' )  												
		oServer:Route( 'test'	, 'screen1.html' )  														
		oServer:Route( 'screen2', 'screen2.html' )  														
		
	//	-----------------------------------------------------------------------//	
	
	IF ! oServer:Run()
	
		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF
	
RETURN 0

//----------------------------------------------------------------------------//

function AppPathData() 		// Abosolute path

#ifdef __PLATFORM__WINDOWS
    retu HB_DIRBASE() + 'data\'
#else
    retu HB_DIRBASE() + 'data/'
#endif 

retu nil
 

function AppPathImages() 	// Relative Path

#ifdef __PLATFORM__WINDOWS
    retu 'data\images\'
#else
    retu 'data/images/'
#endif 

retu nil 

//---------------------------------------------------------------------------//