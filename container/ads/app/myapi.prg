#define APP_KEY  		'UT1234'
#define DBF_TABLE 		'data\test.dbf'

function myapi( oDom )
	
	do case		
		case oDom:GetProc() == 'status' 	; DoStatus( oDom )
		case oDom:GetProc() == 'encrypt' 	; DoEncrypt( oDom )
		case oDom:GetProc() == 'decrypt' 	; DoDecrypt( oDom )
		
		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send() 

// --------------------------------------------------------- //

function DoStatus( oDom )

	local cHtml := ''	
	local cAlias
	
	use DBF_TABLE shared new
	cAlias := Alias()			
	
	cHtml := '<table border="1" width="100%">'
	cHtml += '<tr><td>Version ADS</td><td>' + AdsVersion() + '</td></tr>'
	cHtml += '<tr><td>Rdd Default</td><td>' + RddSetDefault() + '</td></tr>'
	cHtml += '<tr><td>File</td><td>' + DBF_TABLE + '</td></tr>'
	cHtml += '<tr><td>File rdd</td><td>' + (cAlias)->( RddName() ) + '</td></tr>'
	cHtml += '<tr><td>File encrypted</td><td>' + if( (cAlias)->( ADSIsTableEncrypted() ), 'Yes', 'No' ) + '</td></tr>'
	cHtml += '</table>'		

	oDom:SetMsg( cHtml  )	

return nil  

// --------------------------------------------------------- //

function DoEncrypt( oDom )

	local cHtml := ''	
	local cAlias
	
	use DBF_TABLE new
	cAlias := Alias()			
	
	(cAlias)->( ADSEnableEncryption( APP_KEY ) )
	
	if ! (cAlias)->( ADSIsTableEncrypted() )	
		(cAlias)->( ADSEncryptTable() )		
	endif

	oDom:SetMsg( LoadData( cAlias ), 'File encrypted !' )	

return nil 

// --------------------------------------------------------- //

function DoDecrypt( oDom )

	local cHtml := ''	
	local cAlias
	
	use DBF_TABLE new
	cAlias := Alias()			
	
	(cAlias)->( ADSEnableEncryption( APP_KEY ) )
	
	if  (cAlias)->( ADSIsTableEncrypted() )	
		(cAlias)->( ADSDeCryptTable() )		
	endif
	
	oDom:SetMsg( LoadData( cAlias ), 'File decrypted !' )		

return nil 

// --------------------------------------------------------- //

function LoadData( cAlias )
	
	local cHtml := ''
	local n 
	
	cHtml := '<table border="1" width="100%">'
	
	for n := 1 to 10
	
		cHtml += '<tr>'
		cHtml += '<td>' + (cAlias)->first + '</td>'
		cHtml += '<td>' + (cAlias)->last + '</td>'
		cHtml += '<td>' + (cAlias)->street + '</td>'
		cHtml += '</tr>'

		(cAlias)->( Dbskip() )
	next 
	
	cHtml += '</table>'
	
retu cHtml 