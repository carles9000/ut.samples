#include 'lib/uhttpd2/uhttpd2.ch'
#include "../lib/tweb/tweb.ch"

function myapi( oDom )

	do case
		case oDom:GetProc() == 'run_dlg' ; DoInitDialog( oDom )       

		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send()

// --------------------------------------------------------- //

function DoInitDialog( oDom )

	local cHtml := DlgScreen()

	oDom:SetDialog( 'mydlg', cHtml, 'Test timer (show console)' )

return nil



function DlgScreen()

   LOCAL o, oDlg

   DEFINE DIALOG oDlg

   DEFINE FORM o ID 'refreshtest'  API 'api_dlg' OF oDlg

   INIT FORM o

      ROWGROUP o
			SAY ID 'id-testvalue' VALUE ltrim(str( hb_milliseconds()) ) GRID 6  ALIGN 'left' OF o
      ENDROW o

      ROWGROUP o
         	GET ID 'my_time'  LABEL 'Time'  READONLY OF o
      ENDROW o


      ROWGROUP o
			BUTTON ID 'id-test'   LABEL 'Refresh'  ACTION 'button-refresh'  ALIGN 'left' ;
				WIDTH '100px' GRID 3 CLASS 'btn-primary' OF o
      ENDROW o

   ENDFORM o

	HTML o

		<script>		

			$( document ).ready(function() {

				oDlg = _dialogs[ 'mydlg' ]		//	Get Dialog Object from UT
				
				oDlg.bind('hidden.bs.modal', function(){	
					console.log( 'EXIT...')
					StopTimer();		
				});
			
			})

			async function miFuncion() {
			  
			  StopTimer()		  
			  
			  await MsgApi('api_dlg', 'test_time');
			  
			  InitTimer()
			}

			function InitTimer() {
			  console.log('Init Timer');
			  timerId = setInterval(miFuncion, 2000);
			}

			function StopTimer() {
			  console.log('Stop Timer');
			  clearInterval(timerId);
			  timerId = null;
			}

			InitTimer();

		</script>
	ENDTEXT

   INIT DIALOG oDlg RETURN

RETURN nil