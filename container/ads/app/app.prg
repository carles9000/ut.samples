#include 'lib\ads\ads.ch' 

#define VK_ESCAPE	27

request DBFCDX
request TWEB

//	ADS -----------------------------------------------------------------

    REQUEST ADS
	REQUEST ADSKEYCOUNT, ADSKEYNO, ADSGETRELKEYPOS, ADSSETRELKEYPOS
	Request DbSetFilter  	
	
	#define __HBEXTERN__RDDADS__REQUEST
	#include 'lib\ads\rddads.hbx'
	
// 	--------------------------------------------------------------------

function main()

	rddRegister( "ADS", 1 )
	rddsetdefault( "ADS" )
	SET SERVER LOCAL    // REMOTE
	SET FILETYPE TO CDX

	hb_threadStart( @WebServer() )	
	
	while inkey(0) != VK_ESCAPE
	end

retu nil 

//----------------------------------------------------------------------------//

function WebServer()

	local oServer 	:= Httpd2()
	
	oServer:SetPort( 81 )	
	
	//	Routing...			

		oServer:Route( '/'	, 'index.html' )  												
				
	//	-----------------------------------------------------------------------//	
	
	IF ! oServer:Run()
	
		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF
	
RETURN 0

//----------------------------------------------------------------------------//