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
	
	oServer:SetPort( 81 )	
	
	//	Routing...			

		oServer:Route( '/'		, 'index.html' )  												
		oServer:Route( 'form2'	, 'form2.html' )  												
				
	//	-----------------------------------------------------------------------//	
	
	IF ! oServer:Run()
	
		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF
	
RETURN 0

//----------------------------------------------------------------------------//