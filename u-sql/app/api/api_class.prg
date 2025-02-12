#include 'lib/uhttpd2/uhttpd2.ch'

#define DBF_NAME	'class.dbf'
#define DBF_CDX		'class.cdx'
#define DBF_TAG		'name'
#define ID_BRW 		'brwclass'


function Api_Class( oDom )

	do case					
		case oDom:GetProc() == 'update'		; RowUpdate( oDom )								
		case oDom:GetProc() == 'del'			; RowDel( oDom )								
		case oDom:GetProc() == 'new'			; RowAppend( oDom )												

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
	local oConsulta	:= ConsultaModel():New()
	local cError 		:= ''
	local cClass, nTimes

	if Len( aSelected ) == 0
		retu nil
	endif
	
	
	//	Check if class is used in consulta 		
		
		cClass := aSelected[1][ 'NAME' ]
		
		if ( nTimes := oConsulta:UsedClass( cClass ) ) > 0
			oDom:SetError( "You can't delete. Class used: " + ltrim(str(nTimes)) )
			retu nil 
		endif			
		
	//	-------------------------------------
	
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

		hRow 			:= oRepo:Blank()		
		hRow[ '_recno' ] 	:= ( oRepo:cAlias )->( Recno() )
		
		oDom:TableAddData( ID_BRW, { hRow } )

	else 
		oDom:SetMsg( cError, 'Error' )
	endif

retu nil 

// -------------------------------------------------- //
