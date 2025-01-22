function Api_Functional( oDom )
	
	if oDom:GetProc() != 'login'
	
		//	API Security Access
		
			if ! USessionReady()
				URedirect( 'upd_login' )
				retu nil
			endif	
	
	endif

	do case
		case oDom:GetProc() == 'getid'			; GetId( oDom )						
		case oDom:GetProc() == 'upd_salary'	; Upd_Salary( oDom )						
		case oDom:GetProc() == 'upd_data'		; Upd_Data( oDom )						
		
		case oDom:GetProc() == 'login'			; Upd_Login( oDom )										
		
		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function GetId( oDom )

	local cAlias
	local nId 		:= Val( oDom:Get( 'id' ) )		
	local h			:= {=>}
	local lFound
	local cKeyId	:= ''
	
	//	Acceso a API Security
	
		if ! USessionReady()
			URedirect( 'upd_login' )
			retu nil
		endif	
		
	//	Authorization	
	
		if ! MyAuthorization( oDom, nId )
			retu nil
		endif 
		
	//	Initiating vars...	
	
		h[ 'first' ] 	:= ''
		h[ 'last' ] 	:= ''
		h[ 'street' ] 	:= ''
		h[ 'salary' ] 	:= ''	
	
	//	Validating Input data...
	

	//	Process	
	
		cAlias 	:= OpenDbf( 'test.dbf', 'test.cdx', 'ID' )	
		lFound := (cAlias)->( DbSeek( nId ) )		
		
		if lFound

			h[ 'first' ] 	:= (cAlias)->first 					
			h[ 'last' ] 	:= (cAlias)->last 					
			h[ 'street' ] 	:= (cAlias)->street 
			h[ 'salary' ] 	:= (cAlias)->salary 
			 
			cKeyId := USetToken( nId )
			
		endif
		
	//	Respuesta...
	
		oDom:Set( 'keyid'	, cKeyId )
		
		oDom:Set( 'first'	, h[ 'first' ] )
		oDom:Set( 'last'	, h[ 'last' ] )
		oDom:Set( 'street'	, h[ 'street' ] )
		oDom:Set( 'salary'	, h[ 'salary' ] )
		
		if lFound 
			oDom:Show( 'data' )
			oDom:Enable( 'salary' )
			oDom:Enable( 'btn_upd' )
			oDom:Focus( 'first' )
		else 
			oDom:Hide( 'data' )
			oDom:Disable( 'salary' )
			oDom:Disable( 'btn_upd' )
			oDom:SetError( "ID don't exist&nbsp<b>" + ltrim(str(nId)) )
		endif				
	
retu nil

// -------------------------------------------------- //

static function Upd_Salary( oDom )

	local cAlias	
	local nId 		:= Val( oDom:Get( 'id' ) )	
	local nSalary	:= Val( oDom:Get( 'salary' ) )	
	local lFound
	
	//	Acceso a API Security
	
		if ! USessionReady()
			URedirect( 'upd_login' )
			retu nil
		endif	
		
	//	Valid ID 

		if ! MyCheckHacker( oDom, nId )
			retu nil 
		endif
	
	//	Authorization	
	
		if ! MyAuthorization( oDom, nId )
			retu nil
		endif 		
		
	//	Validating Input data...


	//	Process for update...

		cAlias 	:= OpenDbf( 'test.dbf', 'test.cdx' )
		(cAlias)->( OrdSetFocus( 'ID' ) )
		
		lFound := (cAlias)->( DbSeek( nId ) )

		if lFound 
			if (cAlias)->( Rlock() )
				(cAlias)->salary := nSalary
				oDom:SetMsg( "Id: <b>" + ltrim(str(nId)) + "</b> => Salary updated !" )
				
				oDom:Set( 'id', '' )
				oDom:Set( 'salary', '' )			
				
				oDom:Hide( 'data' )
				oDom:Disable( 'salary' )
				oDom:Disable( 'btn_upd' )			
				
			else
				oDom:SetError( 'Error de bloqueo' )
			endif
		else
		
			oDom:SetError( "ID don't exist&nbsp<b>" + ltrim(str(nId))  )
			
		endif		

retu nil 

// -------------------------------------------------- //

static function Upd_Data( oDom )

	local cAlias
	local nId 		:= Val( oDom:Get( 'id' ) )	
	local nSalary	:= Val( oDom:Get( 'salary' ) )	
	local lFound
	
	//	Acceso a API Security
	
		if ! USessionReady()
			URedirect( 'upd_login' )
			retu nil
		endif	
		
	//	Valid ID 

		if ! MyCheckHacker( oDom, nId )
			retu nil 
		endif		
		
	//	Authorization	
	
		if ! MyAuthorization( oDom, nId )
			retu nil
		endif 			
		
	//	Validating Input data...


	//	Process for update...		

		cAlias 	:= OpenDbf( 'test.dbf', 'test.cdx' )
		(cAlias)->( OrdSetFocus( 'ID' ) )
		
		lFound := (cAlias)->( DbSeek( nId ) )

		if lFound 
		
			if (cAlias)->( Rlock() )
			
				(cAlias)->first 	:= oDom:Get( 'first' )
				(cAlias)->last 	:= oDom:Get( 'last' )
				(cAlias)->street 	:= oDom:Get( 'street' )			
				
				oDom:SetMsg( "Id: <b>" + ltrim(str(nId)) + "</b> => Customer data was updated !" )		
				
			else
				oDom:SetError( 'Error de bloqueo' )
			endif
		else
		
			oDom:SetError( "ID don't exist&nbsp<b>" + ltrim(str(nId))  )
			
		endif		

retu nil 

// -------------------------------------------------- //
//	Roles security access
//	Can you edit Id == 1002 ?
// -------------------------------------------------- //
	
static function MyAuthorization( oDom, nId )

	//	Valid access...
 
		if nId == 1002
			oDom:Hide( 'data' )
			oDom:Set( 'salary', '' )
			oDom:Disable( 'salary' )
			oDom:Disable( 'btn_upd' )			
			oDom:SetError( 'You do not have access authorization' )
			retu .F.
		endif				

retu .T.

// -------------------------------------------------- //

static function MyCheckHacker( oDom, nId )

	local cKeyId 	:= oDom:Get( 'keyid' ) 
	
	//	Valid token ID
 	
		if empty( cKeyId ) 
			retu .F.
		endif

		if nId <> UGetToken( cKeyId ) 
			oDom:SetError( 'Hacked forbidden!!!' )
			retu .F.
		endif	

retu .T.

// -------------------------------------------------- //

static function Upd_Login( oDom )

	local cUser 	:= oDom:Get( 'user' )
	local cPsw 	:= oDom:Get( 'psw' )
	local hData	:= {=>}
	
	//	Validate parameters
	
		if len( cUser ) > 10 
			oDom:SetMsg( 'User too long. Max. 10 characters' )
			oDom:Focus( 'user' )
			retu nil
		endif
		
		if empty( cUser ) 
			oDom:SetMsg( 'User is empty' )
			oDom:Focus( 'user' )
			retu nil
		endif		
		
		if empty( cPsw ) 
			oDom:SetMsg( 'Psw is empty' )
			oDom:Focus( 'psw' )
			retu nil
		endif

	//	Process 
	
		if cUser = 'demo' .and. cPsw = '1234'
		
			hData[ 'user' ] := cUser
			hData[ 'name' ] := 'Mr. Demo'
			hData[ 'rol'  ] := 'B'			
		
			USessionStart()
			Usession( 'credentials', hData )
			URedirect( 'upd_sec' )
			
		else 
		
			oDom:SetError( 'User/Psw is wrong !' )			
			retu nil			
		
		endif
		
retu nil

// -------------------------------------------------- //
//	FUNCTIONS - VIA javascript, NO API
//	------------------------------------------------- //

function Upd_Info()
	
	local cHtml 			:= ''
	local hCredentials, oSession

	if ! USessionReady()
		URedirect( 'upd_login' )
		retu nil
	endif
	
	hCredentials := USession( 'credentials' )
	
	oSession := UGetSession()		
	
	cHtml := ULoadHtml( 'functional\upd_info.html', hCredentials, oSession )
	
	UWrite( cHtml )									

retu nil

// -------------------------------------------------- //

function Upd_Logout()

	USessionEnd()
	
	URedirect( 'upd' )

retu nil 

