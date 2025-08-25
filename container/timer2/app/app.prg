#define VK_ESCAPE	27

request DBFCDX
request TWEB

function main()

	hb_threadStart( @WebServer() )

	while inkey(0) != VK_ESCAPE
	end

retu nil

//----------------------------------------------------------------------------//

function WebServer()

	local oServer 	:= Httpd2()
	local aMyConfig

	oServer:SetPort( 81 )
	oServer:lDebug := .t.

	
	//	Routing...

  oServer:Route( '/'  , 'index.html' )
  oServer:Route( 'refresh_timer', 'refresh_timer' )
  oServer:Route( 'ping_server', 'ping_server' )
   

	//	-----------------------------------------------------------------------//

	IF ! oServer:Run()

		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF

RETURN 0

//----------------------------------------------------------------------------//
