function MyApi( oDom )
	
	do case
		case oDom:GetProc() == 'hello' 	; DoHello( oDom )		
		case oDom:GetProc() == 'info' 		; DoInfo( oDom )		
	endcase

retu oDom:Send() 

// --------------------------------------------------------- //

static function DoHello( oDom )

	oDom:SetMsg( 'Hello from server Harbour at ' + time() )	

return nil 

// --------------------------------------------------------- //

static function DoInfo( oDom )
	
	USE 'data/test.dbf' SHARED NEW
	
	oDom:SetMsg( FIELD->first + ' ' + FIELD->last, 'User Information from test.dbf' )
	
	DbCloseAll()

return nil 