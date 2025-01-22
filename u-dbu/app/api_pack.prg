#include 'lib\uhttpd2\uhttpd2.ch'
#include 'dbinfo.ch' 

function Api_Pack( oDom )

	do case	
		
		case oDom:GetProc() == 'pack'	; DoPack( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function DoPack( oDom )

	local oUser, oRepo 

	oUser	:= TDbf():New( 'users.dbf', 'users.cdx', 'user', {'exclusive' => .t. } )
	
	if oUser:lOpen
		oUser:Pack()
	endif	
	
	oRepo 	:= TDbf():New( 'repository.dbf', 'repository.cdx', 'name', {'exclusive' => .t. } )
	
	if oRepo:lOpen 
		oRepo:Pack()
	endif

	oDom:SetMsg( 'Packing done!' )
	
	DbCloseAll()
	
retu nil 