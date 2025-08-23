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

	//	SetFirewallFilter( <uFilter>, <cType> ) ---------------------------
	//	* <uFilter> can be string of ip separated with blank or array ips
	//	* <cType> can be 'blacklist' / 'whitelist'. 'Default blacklist'
	//
	//	If 'blacklist' deny IPs
	//	If 'whitelist' only can access to server IPs
	//  -------------------------------------------------------------------

	//	Test IPs via string
	//	oServer:SetFirewallFilter( "192.168.0.12 192.168.100.0" )
	//	oServer:SetFirewallFilter( "192.168.0.12 192.168.100.0", 'whitelist' )

	//	Test IPs via array
	//	oServer:SetFirewallFilter( { '192.168.0.12', '192.168.100.0' } )
	//	oServer:SetFirewallFilter( { '192.168.0.12', '192.168.100.0' }, 'whitelist' )

	//	-----------------------------------------------------------------------------

	//	Routing...

    oServer:Route( '/'  , 'index.html' )

	//	-----------------------------------------------------------------------//

	IF ! oServer:Run()

		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF

RETURN 0

//----------------------------------------------------------------------------//
