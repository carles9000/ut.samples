#include 'lib/uhttpd2/uhttpd2.ch'

#define DBF_NAME	'connections.dbf'
#define DBF_CDX		'connections.cdx'
#define DBF_TAG		'name'
#define ID_BRW 		'brwconn'


function Api_Connections( oDom )

	do case					
		case oDom:GetProc() == 'update'		; RowUpdate( oDom )								
		case oDom:GetProc() == 'del'			; RowDel( oDom )								
		case oDom:GetProc() == 'new'			; RowAppend( oDom )								
		
		case oDom:GetProc() == 'test_connect'	; Test_Connect( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function RowUpdate( oDom )

	local oCell 		:= oDom:Get( 'cell' )
	local oRepo 		:= TDbf():New( DBF_NAME, DBF_CDX, DBF_TAG )
	local cError := ''		
		
	//	You need to know parameteres received from client. The best solution is 
	//  checking to debug it, in special 'cell' parameter.	
	
				
	//	 Update
	
		if oRepo:Update( oCell['row'][ '_recno' ], {;
							'name' => lower(oCell['row'][ 'NAME' ]),;
							'descriptio' => oCell['row'][ 'DESCRIPTIO' ],;
							'ip' => oCell['row'][ 'IP' ],;  
							'port' => oCell['row'][ 'PORT' ],;
							'db' => oCell['row'][ 'DB' ],;
							'user' => oCell['row'][ 'USER' ],;							
							'psw' => oCell['row'][ 'PSW' ],;							
							'active' => oCell['row'][ 'ACTIVE' ];
						}, @cError )
						
			// oDom:SetJs( "MsgNotify( 'Update ok' )" )
		else 
			oDom:SetMsg( cError, 'Error' )
		endif

retu nil 

// -------------------------------------------------- //

static function RowDel( oDom )

	local hStr 		:= oDom:Get( ID_BRW )
	local aSelected	:= hStr[ 'selected' ]
	local oRepo 		:= TDbf():New( DBF_NAME, DBF_CDX, DBF_TAG )
	local cError 		:= ''

	if Len( aSelected ) == 0
		retu nil
	endif
	
	if oRepo:Delete( aSelected[1][ '_recno'], @cError )
		oDom:TableDelete( ID_BRW, aSelected[1][ '_recno'] )
	else 
		oDom:SetMsg( cError, 'Error' )
	endif


retu nil 

// -------------------------------------------------- //

static function RowAppend( oDom )

	local hStr 		:= oDom:Get( ID_BRW )	
	local oRepo 		:= TDbf():New( DBF_NAME, DBF_CDX, DBF_TAG )
	local cError 		:= ''
	local hrow
	
	if oRepo:Append( @cError )

		hRow 				:= oRepo:Blank()		
		hRow[ '_recno' ] 	:= ( oRepo:cAlias )->( Recno() )
		
		oDom:TableAddData( ID_BRW, { hRow } )

	else 
		oDom:SetMsg( cError, 'Error' )
	endif

retu nil 

// -------------------------------------------------- //

static function Test_Connect( oDom )
	
	local hSelect 		:= oDom:Get( ID_BRW )[ 'selected' ]
	local o, cIp, cDb, nPort, cUser, cPsw
	
	if len( hSelect) != 1
		retu nil 
	endif			
	
	cIP  	:= hSelect[1][ 'IP'] 
	cDB 	:= hSelect[1][ 'DB'] 
	nPort 	:= hSelect[1][ 'PORT'] 
	cUser 	:= hSelect[1][ 'USER'] 
	cPsw 	:= hSelect[1][ 'PSW'] 				
	
	o := WDO_MYSQL():New( cIP, cUser, cPsw, cDb, nPort )				
	
	IF o:lConnect	
	
		oDom:SetMsg( 'Version: ' + o:VersionName() + '<br>Connection Succesfully!' )
		
	ELSE 
	
		oDom:SetMsg( o:cError )
		
	ENDIF
	
retu nil 
