function myapi( oDom )

	do case

		CASE oDom:GetProc() == 'getValues'  	;	MyTest( oDom )	
		CASE oDom:GetProc() == 'action-1'  	;	oDom:SetMsg( 'Action 1' )
		CASE oDom:GetProc() == 'action-2'  	;	oDom:SetMsg( 'Action 2' )

		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send()

// --------------------------------------------------------- //

STATIC FUNCTION MyTest ( oDom  )

	local cValue := oDom:Get( 'id-ao_000_status' )
	
	do case
		case cValue == 'ONE' 
			oDom:SetClass( 'id-do1_man','btn btn-outline-danger'   )
			oDom:SetClass( 'id-do1_cas','btn btn-outline-success'  )	
			
		case cValue == 'TWO' 
			oDom:SetClass( 'id-do1_man','btn btn-outline-success'  )
			oDom:SetClass( 'id-do1_cas','btn btn-outline-danger'   )
		
		case cValue == 'THREE' 		
			oDom:SetClass( 'id-do1_man', 'btn btn-outline-secondary' )
			oDom:SetClass( 'id-do1_cas', 'btn btn-outline-secondary' )	
	endcase 	
	

RETU nil 
