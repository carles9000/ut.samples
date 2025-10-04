// --------------------------------------------------------- //
// This is a Controller, load dat and create view for Proc_1 
// In app.prg we define route proc_1 than execute Init_Proc_1() 
// 
// --------------------------------------------------------- //
function Init_Proc_1()

	local hData, cHtml
	
	//	Is Auth...	
	
	//	Valid Parameteres...
	
	//	Load data... (maybe using model data...)
	
		hData	:= Model_Data()		
		
	//	Proc and process data... 

	//	Create view with data...				
	
		cHtml := ULoadHtml( 'proc_1.html', hData )				
		
retu cHtml 

// --------------------------------------------------------- //
// This es api for Proc_1. See proc_1.html and find api name... 
// --------------------------------------------------------- //

function Api_Proc_1( oDom )

	
	do case		
		case oDom:GetProc() == 'hello' 	; Go_Hello( oDom )
		
		otherwise
			oDom:SetError( "Proc doesn't exist: " + oDom:GetProc() )
	endcase

retu oDom:Send() 

// --------------------------------------------------------- //


static function Go_Hello( oDom )

	oDom:SetMsg( oDom:Get( 'id' ) )

retu nil