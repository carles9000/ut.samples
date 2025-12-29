function myapi( oDom )
	
	do case
		case oDom:GetProc() == 'login' 		; DoLogin( oDom )				
		case oDom:GetProc() == 'logout' 		; DoLogout( oDom )				
		case oDom:GetProc() == 'reload' 		; URedirect( '/' )			
		case oDom:GetProc() == 'search' 		; URedirect( 'search' )			
		case oDom:GetProc() == 'search_sid' 	; DoSearch_SID( oDom )		
		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send() 

// --------------------------------------------------------- //

function DoLogin( oDom )

	local cName 	:= oDom:get( 'name' )
	local hData 	:= {=>}

	if empty( cName ) .or. len(cName) > 10 	
		oDom:SetMsg( 'Name max 10 characters' )
		retu nil 
	endif 
	
	hData[ 'user' ] 	:= cName	
	hData[ 'cargo' ] 	:= ltrim(str(hb_milliseconds()))
				
	USessionStart()
	Usession( 'credentials', hData )
	
	Mylog( hData[ 'user' ] , 'api-login', UGetSession()[ 'sid' ]  )	
	
	URedirect( '/' )

return nil  


// --------------------------------------------------------- //

function DoLogout( oDom )

	local hCredentials 

	if USessionReady()
	
		hCredentials := USession( 'credentials' )
		
		Mylog( hCredentials[ 'user' ] , 'api-logout', UGetSession()[ 'sid' ]  )	
		
		USessionEnd()
	endif 
	
	URedirect( 'login' )	
	
retu nil 

// --------------------------------------------------------- //

function DoSearch_SID( oDom )

	local cSID 		:= oDom:get( 'sid' )	
	local cHtml 	:= '<pre>'
	local nLen 		:= 0
	local nTotal	:= 0
	local hCredentials

	if empty( cSID ) 		
		retu nil 
	endif 
	
	if ! USessionReady()
		oDom:Redirect( 'login' )
		retu nil 
	endif	
	
	hCredentials 	:= USession( 'credentials' )		

	MyLog( hCredentials[ 'user' ] , 'api-search', UGetSession()[ 'sid' ] )	
	
	use 'data\track.dbf' shared new alias (NewAlias())
	set index to track
	
	nTotal:= RecCount()
	
	dbseek( cSID )
	
	while !eof() .and. alltrim( field->cargo ) == cSID 	
	
		nLen++

		cHtml += alltrim(field->user) + ' ' + field->hora + ' ' + ;
		         alltrim(field->ip) + ' ' + alltrim(field->action) + '<br>'
		
		dbskip()
	
	end 
	
	dbcloseall()

	oDom:SetDialog( 'dlg_log', cHtml, hCredentials[ 'user' ] + ' - Found: ' + ltrim(str(nLen)) + '/' + ltrim(str(nTotal))  )

return nil  
