#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY => ALWAYS

function Api_DefSql( oDom )

	//	Auth system...
	
		if ! Authorization()
			retu nil
		endif
		
	//	-------------------------

	do case	
		
		case oDom:GetProc() == 'add'				; AddField( oDom )															
		
		case oDom:GetProc() == 'panel'				; DoPanel( oDom )															

	//	Consultation
		
		case oDom:GetProc() == 'consulta_upd'		; DoConsulta_Upd( oDom )															
		case oDom:GetProc() == 'consulta_new'		; DoConsulta_New( oDom )															
		case oDom:GetProc() == 'consulta_del'		; DoConsulta_Del( oDom )
			
		case oDom:GetProc() == 'scr_detail'		; DoScr_Detail( oDom )															
		case oDom:GetProc() == 'scr_consulta'		; DoScr_Consulta( oDom )	

		
	//	Detail
	
		case oDom:GetProc() == 'detail_upd'		; DoDetail_Upd( oDom )															
		case oDom:GetProc() == 'detail_new'		; DoDetail_New( oDom )															
		case oDom:GetProc() == 'detail_del'		; DoDetail_Del( oDom )	
		case oDom:GetProc() == 'detail_save'		; DoDetail_Save( oDom )
		
		case oDom:GetProc() == 'detail_test_sql'	; DoDetail_Test_Sql( oDom )	
		
		case oDom:GetProc() == 'preview_param'		; DoPreview_Param( oDom )	
		case oDom:GetProc() == 'preview_sql'		; DoPreview_Sql( oDom )	
		
		

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function AddField( oDom )

	
retu nil

// -------------------------------------------------- //

static function DoPanel( oDom )

	local cId := oDom:GetTrigger()
	local cValue := oDom:Get( cId )	
	
	do case 
		case cValue == 'consulta'
			oDom:Show( 'consulta' )
			oDom:Hide( 'detail' )
			
		case cValue == 'detail'
			oDom:Show( 'detail' )
			oDom:Hide( 'consulta' )
			
		case cValue == 'closeall'
			oDom:Hide( 'detail' )
			oDom:Hide( 'consulta' )			
	endcase
		
	
retu nil

// -------------------------------------------------- //

static function DoConsulta_New( oDom )

	local hStr 		:= oDom:Get( 'brwconsulta' )	
	local oRepo 		:= TDbf():New( 'consulta.dbf', 'consulta.cdx', 'consulta' )
	local cError 		:= ''
	local hRow
	
	if oRepo:Append( @cError )

		hRow 				:= oRepo:Blank()		
		hRow[ '_recno' ] 	:= ( oRepo:cAlias )->( Recno() )
		
		oDom:TableAddData( 'brwconsulta', { hRow } )

	else 
		oDom:SetMsg( cError, 'Error' )
	endif



retu nil 

// -------------------------------------------------- //

static function DoConsulta_Del( oDom )

	local hStr 		:= oDom:Get( 'brwconsulta' )
	local aSelected	:= hStr[ 'selected' ]
	local oRepo 		:= TDbf():New( 'consulta.dbf', 'consulta.cdx', 'consulta' )
	local cError 		:= ''

	if Len( aSelected ) == 0
		retu nil
	endif
	
	if oRepo:Delete( aSelected[1][ '_recno'], @cError )
		oDom:TableDelete( 'brwconsulta', aSelected[1][ '_recno'] )
	else 
		oDom:SetMsg( cError, 'Error' )
	endif


retu nil 

// -------------------------------------------------- //

static function DoConsulta_Upd( oDom )

	local oCell 		:= oDom:Get( 'cell' )
	//local oRepo 		:= TDbf():New( 'consulta.dbf', 'consulta.cdx', 'consulta')
	local oConsulta	:= ConsultaModel():New()
	local cError := ''		
		
	//	You need to know parameteres received from client. The best solution is 
	//  checking to debug it, in special 'cell' parameter.	
	
		//_d( oCell ) 

		/*
		if oCell[ 'field' ] == 'CONSULTA' .and.  ;
			!empty( oCell[ 'value' ]  ) .and. ;
			lower(oCell[ 'value']) <> lower(oCell[ 'oldvalue' ])
			
			oDom:TableUpdateRow( 'brwconsulta', oCell[ 'row' ][ oCell[ 'index' ]], { 'CONSULTA' => oCell[ 'oldvalue'] })
			oDom:SetError( "You can't change this value" )

			retu nil			
		endif		
		*/
		
	//	 Update
	/*
		if oRepo:Update( oCell['row'][ '_recno' ], {;
							'consulta' => lower(oCell['row'][ 'CONSULTA' ]),;
							'descriptio' => oCell['row'][ 'DESCRIPTIO' ],;							
							'active' => oCell['row'][ 'ACTIVE' ];
						}, @cError )
		*/				
			// oDom:SetJs( "MsgNotify( 'Update ok' )" )

		if oConsulta:Update( oCell['row'][ '_recno' ], {;
							'consulta' => lower(oCell['row'][ 'CONSULTA' ]),;
							'descriptio' => oCell['row'][ 'DESCRIPTIO' ],;							
							'active' => oCell['row'][ 'ACTIVE' ];
						}, @cError, oCell )

		
			
		else 
			oDom:SetMsg( cError, 'Error' )
		endif

retu nil 

// -------------------------------------------------- //

function DoScr_Detail( oDom )		

	local hStr 		:= oDom:Get( 'brwconsulta' )
	local aSelected	:= hStr[ 'selected' ]	
	local cError 		:= ''
	local nRecno, hRow
	local oCons, oCons_Par, aCons_Par

	if Len( aSelected ) <> 1		
		oDom:SetJs( "MsgNotify( 'Select row !' )" )
		retu nil
	endif
	
	nRecno := aSelected[1][ '_recno' ]
	
	oCons 		:= ConsultaModel():New()
	oCons_Par 	:= Cons_ParModel():New()
	
	//	Load Header
	
		oCons:Goto( nRecno )
	
		hRow := oCons:Row()	
		
	//	Load Positions
	
		aCons_Par := oCons_Par:GetAllChild( hRow[ 'CONSULTA' ] )
	
	//	Refresh Data... --------------------------------------
	
		oDom:Set( 'c_consulta'  	, hRow[ 'CONSULTA' ] )
		oDom:Set( 'c_descriptio'	, hRow[ 'DESCRIPTIO' ] )
		oDom:Set( 'c_active'	 	, hRow[ 'ACTIVE' ] )
		oDom:Set( 'c_id_conn'	 	, hRow[ 'ID_CONN' ] )
		oDom:Set( 'c_id_class'		, hRow[ 'ID_CLASS' ] )
		oDom:Set( 'c_sql'			, hRow[ 'SQL' ] )
		
		oDom:TableSetData( 'brwdetail', aCons_Par )
		
		
		oDom:Hide( 'consulta' )	
		oDom:Show( 'detail' )
	
	
	oDom:Console( _c(hRow) )


retu nil 

// -------------------------------------------------- //

function DoScr_Consulta( oDom )

	oDom:Hide( 'detail' )	
	oDom:Show( 'consulta' )

retu nil 


// -------------------------------------------------- //

static function DoDetail_Save( oDom )

	local hStr 		:= oDom:Get( 'brwconsulta' )
	local aSelected	:= hStr[ 'selected' ]			
	local hFields 		:= {=>}
	local cError		:= ''	
	local oConsulta, nRecno, aRowBrw	

	if Len( aSelected ) <> 1		
		oDom:SetJs( "MsgNotify( 'Select row !' )" )
		retu nil
	endif
	
	//	Save data...

		oConsulta := ConsultaModel():New()
	
		nRecno := aSelected[ 1 ][ '_recno' ]		
		
		hFields[ 'DESCRIPTIO' ] 	:= oDom:Get( 'c_descriptio' )
		hFields[ 'ACTIVE' ] 		:= oDom:Get( 'c_active' )
		hFields[ 'ID_CONN' ] 		:= oDom:Get( 'c_id_conn' )
		hFields[ 'ID_CLASS' ] 		:= oDom:Get( 'c_id_class' )
		hFields[ 'ID_CLASS' ] 		:= oDom:Get( 'c_id_class' )
		hFields[ 'SQL' ]	 		:= oDom:Get( 'c_sql' )


		if oConsulta:Update( nRecno, hFields, @cError )

			aRowBrw := { 'DESCRIPTIO' => hFields[ 'DESCRIPTIO' ],;
						  'ACTIVE' => hFields[ 'ACTIVE' ] }

		
			oDom:SetJs( "MsgNotify( 'Updated Ok' )" )						
			oDom:TableUpdateRow( 'brwconsulta', nRecno, aRowBrw )
			
		else
		
			oDom:SetMsg( cError )
		
		endif

	
retu nil 


// -------------------------------------------------- //

static function DoDetail_Test_Sql( oDom )	

	local cConn 	:= oDom:Get( 'c_id_conn') 
	local cSql 	:= oDom:Get( 'c_sql' )
	local hStr 	:= oDom:Get( 'brwdetail' )
	local hBrwData	:= hStr[ 'data' ]
	local cError 	:= ''
	local hRow 	:= {=>}
	local cWarning := ''
	local oConn, oDb, hRes, n, h, cParameter, cTest
	
	//	Connection...
	
		if empty( cConn )
			oDom:SetMsg( 'Select connection' )
			retu nil 
		endif 
		
		oConn := ConnectionModel():New()
		
		if ! oConn:GetId( cConn, @hRow )

			oDom:SetMsg( 'Not found' )
			retu nil
		endif
		
	//	Parameters

		
		for n := 1 to len( hBrwData )

			h 			:= HB_HPairAt( hBrwData, n )
			cParameter := h[2][ 'PARAMETER' ]
			cTest 		:= h[2][ 'TEST' ]
			
			if !empty( cParameter ) .and. !empty( cTest )
			
				cParameter := '%' + cParameter
			
				if At( cParameter, cSql ) > 0
					cSql := StrTran( cSql, cParameter, cTest ) 
				else
					cWarning += 'Parameter ' + cParameter + ' declared, by never used !<br>'
				endif
				
			else 			
				
				cWarning += 'Problem parameter position ' + ltrim(str(n)) 			
			
			endif 

		next 

	//	Init connection...

	oDb := WDO_MYSQL():New( hRow[ 'IP' ], hRow[ 'USER' ], hRow[ 'PSW' ], hRow[ 'DB' ], hRow[ 'PORT' ] )		
	
	IF ! oDb:lConnect	
		oDom:SetMsg( oDb:cError )		
		retu nil
	ENDIF	
	
	if ! empty( cWarning )
		cWarning := '<hr><b><i class="fa fa-exclamation-triangle" aria-hidden="true"></i>&nbsp;Warning </b> ' + cWarning
	endif 
	
	
	IF !empty( hRes := oDb:Query( cSql )  )

		oDb:Free_Result( hRes )
		
		oDom:SetMsg( 'Sql correct !<br><br><code>' + cSql + '</code>' + cWarning )
		
	else
		oDom:SetMsg( oDb:cError + cWarning )
	endif	

	oDb:Close()	

retu nil 

// -------------------------------------------------- //

static function DoDetail_New( oDom )

	local hStr 		:= oDom:Get( 'brwdetail' )	
	local oCons_Par	:= Cons_ParModel():New() 
	local cError 		:= ''
	local hRow
	
	_d( oDom:GetAll())
	
	if oCons_Par:Append( @cError )

		hRow 				:= oCons_Par:Blank()		
		hRow[ '_recno' ] 	:= ( oCons_Par:cAlias )->( Recno() )
		hRow[ 'ID_CONS' ] 	:= oDom:Get( 'c_consulta' )
		
		oDom:TableAddData( 'brwdetail', { hRow } )

	else 
		oDom:SetMsg( cError, 'Error' )
	endif
	
retu nil 

// -------------------------------------------------- //

static function DoDetail_Del( oDom )

	local hStr 		:= oDom:Get( 'brwdetail' )
	local aSelected	:= hStr[ 'selected' ]	
	local oCons_Par	:= Cons_ParModel():New() 	
	local cError 		:= ''

	if Len( aSelected ) == 0
		retu nil
	endif
	
	if oCons_Par:Delete( aSelected[1][ '_recno'], @cError )
		oDom:TableDelete( 'brwdetail', aSelected[1][ '_recno'] )
	else 
		oDom:SetMsg( cError, 'Error' )
	endif


retu nil 

// -------------------------------------------------- //

static function DoDetail_Upd( oDom )

	local oCell 		:= oDom:Get( 'cell' )	
	local oCons_Par	:= Cons_ParModel():New() 	
	local cError := ''		
		

		
		

	//	 Update
	
		if oCons_Par:Update( oCell['row'][ '_recno' ], {;
							'id_cons' => lower(oCell['row'][ 'ID_CONS' ]),;
							'parameter' => oCell['row'][ 'PARAMETER' ],;
							'test' => oCell['row'][ 'TEST' ],;				
							'label' => oCell['row'][ 'LABEL' ],;				
							'type' => oCell['row'][ 'TYPE' ],;				
							'default' => oCell['row'][ 'DEFAULT' ],;				
							'transform' => oCell['row'][ 'TRANSFORM' ];				
						}, @cError )						
			
		else 
			oDom:SetMsg( cError, 'Error' )
		endif

retu nil 


// -------------------------------------------------- //

static function DoPreview_Param( oDom )

	
	local hStr 	:= oDom:Get( 'brwdetail' )
	local hData	:= hStr[ 'data' ]
	local aItems	:= {}
	//local cSql 	:= oDom:Get( 'c_sql' )
	local cId_Form	:= 'xxx'
	local cTitle 	:= Alltrim( oDom:Get( 'c_descriptio') )
	local lError 	:= .f. 	
	local cHtml, cHtmlTable, h, n
	
	
	//	Load input parameters
	
		for n :=  1 to len(hData)
		
			h := HB_HPairAt( hData, n )
			
			Aadd( aItems, h[2])
			
		next 
	
		_d( aItems )
		
		
	
	//	Build Table parameters
	
		cHtmlTable := DoTableInputs( aItems, cId_Form, @lError ) 
		
		if ! lError 		
			cHtml	:= ULoadHtml( 'app\dlg_preview.html', cHtmlTable, .f. )	
		else			
			cHtml	:= cHtmlTable
		endif
			
		
	
	//	Mostra Dialeg
	
		oDom:SetDialog( cId_Form, cHtml, cTitle )			

retu nil

// -------------------------------------------------- //

function DoTableInputs( aItems, cId_Form, lError ) 

	local cHtml  := ''
	local cError := ''
	local n, h, cId, uValue
	
	cHtml += '<table>'	
	
	for n := 1 to len( aItems )
	
		h := aItems[n]
		
		hb_HCaseMatch( h, .f. )
		
		cId := cId_Form + '-' + h[ 'parameter' ]
		
		uValue := DoDefaultValue( h, @cError )
		//uValue := h[ 'default' ]
		
		
		if !empty( cError )
			lError := .t.
			retu cError
		endif
		
		
		
		do case
			case h[ 'type' ] == 'IT'	// Text

				cHtml += '<tr>'
				cHtml += '<td class="parameters">' + h[ 'label' ] + '</td>'
				cHtml += '<td><input type="text" id="' + cId + '" value="' + uValue + '" data-live="" ></td>'
				cHtml += '</tr>'
			
			
			case h[ 'type' ] == 'ID'	//	Date
			
				cHtml += '<tr>'
				cHtml += '<td class="parameters">' + h[ 'label' ] + '</td>'
				cHtml += '<td><input type="date" id="' + cId + '"  value="' + uValue + '" data-live="" ></td>'
				cHtml += '</tr>'
				
			case h[ 'type' ] == 'IN'	//	Number
			
				cHtml += '<tr>'
				cHtml += '<td class="parameters">' + h[ 'label' ] + '</td>'
				cHtml += '<td><input type="number" id="' + cId + '"  value="' + uValue + '" data-live="" ></td>'
				cHtml += '</tr>'			
				
			case h[ 'type' ] == 'IL'	//	Logic
			
				cHtml += '<tr>'
				cHtml += '<td class="parameters">' + h[ 'label' ] + '</td>'
				cHtml += '<td><input type="checkbox" id="' + cId + '"  value="' + uValue + '" data-live="" ></td>'
				cHtml += '</tr>'				
		endcase
		
	next 
	
	cHtml += '</table>'


retu cHtml 

// -------------------------------------------------- //


function DoDefaultValue( h, cError )

	local cFunc, b, uValue, oError, cType, cId
	
	hb_HCaseMatch( h, .f. )
	
	cId := h[ 'parameter' ]
	
	cError := ''

	if empty( h[ 'default' ] )
		retu ''
	endif
	
	if substr( h[ 'default' ], 1, 1) == '@' 
	
		cFunc  := alltrim( substr( h[ 'default' ], 2 ) )
		
		_d( cFunc )
		
		try
		
			b := &( '{|| ' + cFunc + '}' )
			uValue := eval( b )

			
		catch oError
		
			cError += 'Error parameter: ' + cId 
			cError += '<br>Default: ' + cFunc 
			cError += '<br>Error: ' + oError:description
			
			return ''

		end 
	else
	
		uValue := h[ 'default' ]				
		
	endif
	
			
	cType := valtype( uValue )
	
	if cType != 'C'
	
		cError += 'Error parameter: ' + cId 				
		cError += '<br>Error: Default value is not character.' 
		
		return ''			
	
	endif	
	
	
	
	_d( uValue )
	
retu uValue 

// -------------------------------------------------- //

static function DoPreview_Sql( oDom )

	oDom:SetMsg( oDom:GetList(.t. ) )
	
retu nil 

// -------------------------------------------------- //