#include 'hbclass.ch'

function myapi( oDom )
	
	do case				
		case oDom:GetProc() == 'keepalive'	; DoKeepAlive( oDom )
		
		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send() 

// --------------------------------------------------------- //

static function DoKeepAlive( oDom )

	local o := UDataKeepAlive( {|| TSimulateConnection():New() } )				
	
	oDom:SetMsg( o:MyData() )		
	
retu nil

// --------------------------------------------------------- //

CLASS TSimulateConnection

	METHOD New() 		CONSTRUCTOR 
	
	METHOD MyData() 	INLINE 'Value is ' + ltrim(str( hb_RandInt( 1, 1000 ) ) )

ENDCLASS 

METHOD New() CLASS TSimulateConnection 

	//	Simulating connexion with other system. 
	//	This process lapsed 2 seconds...

	_d( 'Initialiting...')
	
	SecondsSleep( 2 )
	
	_d( 'Connected !')	
	
RETU Self 
