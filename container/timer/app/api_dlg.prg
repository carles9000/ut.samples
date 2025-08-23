#include 'lib/uhttpd2/uhttpd2.ch'

FUNCTION Api_Dlg( odom )

   DO CASE

      CASE oDom:GetProc() == 'button-refresh'	; oDom:Set( 'id-testvalue', ltrim(str( hb_milliseconds())) )
	  CASE oDom:GetProc() == 'test_time'  		; Show_Time( oDom )

      otherwise
         oDom:SetError( "Proc don't defined => " + oDom:GetProc())
   ENDCASE

RETURN oDom:Send()

// -----------------------------------------------------

FUNCTION Show_Time(oDom)

	oDom:SetDlg( 'refreshtest' )
	oDom:Set('my_time', time())
	oDom:Set('id-testvalue', ltrim(str( hb_milliseconds() )) )

RETU NIL
