function myapi( oDom )

	
	do case
		case oDom:GetProc() == 'dlg_1' 	; DoDlg_1( oDom )
		case oDom:GetProc() == 'dlg_2' 	; DoDlg_2( oDom )
		case oDom:GetProc() == 'dlg_3' 	; oDom:SetDialog( 'dlg_3',  ULoadHtml( 'dlg-3.html', oDom:Get( 'myget' ) ) )
		case oDom:GetProc() == 'dlg_4' 	; oDom:SetDialog( 'dlg_4',  ULoadHtml( 'dlg-4.html', oDom:Get( 'myget' ) ) )
		
		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send() 

// --------------------------------------------------------- //

function DoDlg_1( oDom )

	local cHtml := ULoadHtml( 'dlg-1.html' )
	oDom:SetDialog( 'dlg_1', cHtml, 'Select ')

return nil  

// --------------------------------------------------------- //

function DoDlg_2( oDom )

	local cHtml := ULoadHtml( 'dlg-2.html', oDom:Get( 'myget' )   )

	oDom:SetDialog( 'dlg_2', cHtml, 'Select ')

return nil 