function Api_Data( oDom )

	//	Auth system...
	
		if ! Authorization()
			retu nil
		endif
		
	//	-------------------------

	do case	
		
		case oDom:GetProc() == 'exe_preview'		; DoExe_Preview( oDom )															
		case oDom:GetProc() == 'exe_consulta'		; DoExe_Consulta( oDom )															
		case oDom:GetProc() == 'exe_refresh'		; DoExe_Refresh( oDom )															
		case oDom:GetProc() == 'back_tree'			; DoBack_Tree( oDom )															
		
		case oDom:GetProc() == 'nav_refresh'		; DoNav_Refresh( oDom )
		case oDom:GetProc() == 'nav_top'			; DoNav_Top( oDom )
		case oDom:GetProc() == 'nav_prev'			; DoNav_Prev( oDom )
		case oDom:GetProc() == 'nav_next'			; DoNav_Next( oDom )
		case oDom:GetProc() == 'nav_end'			; DoNav_End( oDom )
		case oDom:GetProc() == 'nav_print'			; DoNav_Print( oDom )

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function DoExe_Preview( oDom )	

	local cId_Consulta 	:= oDom:Get( 'id_consulta' )
	local hConsulta		:= {=>}	
	local aPar 			:= {}
	local cId_Form			:= 'prepare'
	local lError			:= .f.
	local oConsulta, oCons_Par, cHtml, cHtmlTable

	//	Load Consultation define...

		oConsulta 	:= ConsultaModel():New()
		
		if ! oConsulta:Get( cId_Consulta, @hConsulta )	
			oDom:SetMsg( 'Consulta not found: ' + cId_Consulta )
			retu nil
		endif	
	
	//	Load parameters consultation...
	
		oCons_Par 	:= Cons_ParModel():New()
		aPar 		:= oCons_Par:GetAllChild( cId_Consulta )	
	
		if len( aPar ) > 0
	
			//	Build Table parameters
			
				cHtmlTable := DoTableInputs( aPar, cId_Form, @lError ) 
				
				if ! lError 		
					cHtml	:= ULoadHtml( 'app\dlg_preview.html', cHtmlTable, .t., cId_Consulta, cId_Form )	// api_defsql
				else			
					cHtml	:= cHtmlTable
				endif					
			
			//	Show dialog
			
				oDom:SetDialog( cId_Form, cHtml, hConsulta[ 'DESCRIPTIO' ] )	
		else 
		
			DoExe_Consulta( oDom )
		
		endif

retu nil 

// -------------------------------------------------- //

static function DoExe_Consulta( oDom )	
	
	local hInfo := InitInfo( oDom )	
	local oLog	
	
	//	Recover parameters			

		hInfo[ 'consulta' ]	:= oDom:Get( 'id_consulta' )

		//	Maybe we can validate authorization for access to id_consulta, but...next stage ! 
	
			//_d( hInfo[ 'conn' ] )

	//	Load Consultation define...

		oDom:SetJs( "bootbox.hideAll()" )
	
		if ! BuildSql( oDom, hInfo )		
			retu .f.
		endif				

	//	Load Connection 
	
		if ! LoadConn( oDom, hInfo )
			retu .f.
		endif
		

		//oDom:DialogClose()
	
	//	Open Database

		if ! OpenDb( oDom, hInfo )		
			retu nil 
		endif		
	

	//	Refresh Total rows

		if ! TotalRows( oDom, hInfo )
			retu nil
		endif	


	//	Load data...

		LoadRows( oDom, hInfo, .T. )		//	.t. == Init Browse

	
	//	Close database connection

		CloseDb( oDom, hInfo )		
		
		
	//	Log...
	
		oLog := LogModel():New()
		
		oLog:Insert( 'CN', hInfo[ 'consulta' ] )
	
	//	Refresh Dom 

		Refresh_Nav( oDom, hInfo )

		oDom:Hide( 'tree' )
		oDom:Show( 'data' )		
	
retu nil

// -------------------------------------------------- //

static function SetConnection( cConn, hData )

	local hSession := USessionAll()
	
	hb_default( @cConn, '' )
	
	cConn := lower( cConn )
	
	if ! HB_HHasKey( hSession, 'connection' ) 
	
		hSession[ 'connection' ] := {=>}
	
	endif 
	
	hSession[ 'connection' ][ cConn ] := hData	

retu nil 

// -------------------------------------------------- //


static function GetConnection( cConn )
	
	local hConnection 	:= USession( 'connection' ) 
	
	hb_default( @cConn, '' )
	
	if empty( hConnection ) .or. empty( cConn )
		retu nil 
	endif
	
	if ! HB_HHasKey( hConnection, cConn )
		retu nil 
	endif		
	
retu hConnection[ cConn ]

// -------------------------------------------------- //

static function InitInfo( oDom )

	local hInfo := {=>}

	hInfo[ 'sql' ] 			:= oDom:Get( 'nav_sql', '')
	hInfo[ 'consulta' ]		:= ''
	hInfo[ 'conn' ]			:= oDom:Get( 'nav_conn', '')
	hInfo[ 'total' ] 		:= 0
	hInfo[ 'page' ] 		:= Val( oDom:Get( 'nav_page', '1' ))
	hInfo[ 'page_rows' ] 	:= Val( oDom:Get( 'nav_page_rows', '10' ))
	hInfo[ 'page_total' ] 	:= 0
	
	hInfo[ 'conn_cfg' ] 	:= {=>}
	
	if !empty( hInfo[ 'conn' ] )
		hInfo[ 'conn_cfg' ] := GetConnection( hInfo[ 'conn' ] )
	endif
	
retu hInfo

// -------------------------------------------------- //

static function DoExe_Refresh( oDom )

	local oClass 		:= ClassModel():New()	
	local aItems		:= oClass:MakeItemsTree()
	//local cItems 		:= hb_jsonencode( aItems )

	oDom:SetJs( 'Tree_Refresh', aItems )
	
	
retu nil 

// -------------------------------------------------- //

static function Refresh_Nav( oDom, hInfo )

	oDom:Set( 'nav_sql'			, hInfo[ 'sql' ] )
	oDom:Set( 'nav_conn'		, hInfo[ 'conn' ] )
	oDom:Set( 'nav_total'		, hInfo[ 'total' ] )
	oDom:Set( 'nav_page'		, ltrim(str(hInfo[ 'page' ])) )
	oDom:Set( 'nav_page_rows'	, ltrim(str(hInfo[ 'page_rows' ])) )
	oDom:Set( 'nav_page_total'	, ltrim(str(hInfo[ 'page_total' ])) )
	
retu nil 

// -------------------------------------------------- //

static function DoBack_Tree( oDom )	

	oDom:Hide( 'data' )			
	oDom:Show( 'tree' )

retu nil

// -------------------------------------------------- //

static function DoNav_Top( oDom )

	local hInfo	:= InitInfo( oDom )
	
	//	Open Database
	
		if ! OpenDb( oDom, hInfo )		
			retu nil 
		endif
		
	//	Refresh Total rows

		if ! TotalRows( oDom, hInfo )
			retu nil
		endif		

	//	Update page
	
		hInfo[ 'page' ] := 1
		
	//	Load data...
	
		LoadRows( oDom, hInfo )
		
	//	Close database connection

		CloseDb( oDom, hInfo )			
	
	//	Refresh Dom 
	
		Refresh_Nav( oDom, hInfo )		

retu nil 

// -------------------------------------------------- //

static function DoNav_End( oDom )

	local hInfo	:= InitInfo( oDom )	

	//	Open Database
	
		if ! OpenDb( oDom, hInfo )		
			retu nil 
		endif
		
	//	Refresh Total rows

		if ! TotalRows( oDom, hInfo )
			retu nil
		endif		

	//	Update page
	
		hInfo[ 'page' ] := hInfo[ 'page_total' ]
		
	//	Load data...
	
		LoadRows( oDom, hInfo )
		
	//	Close database connection

		CloseDb( oDom, hInfo )			
	
	//	Refresh Dom 
	
		Refresh_Nav( oDom, hInfo )		

retu nil 


// -------------------------------------------------- //

static function DoNav_Prev( oDom )

	local hInfo	:= InitInfo( oDom )
	

	//	Open Database
	
		if ! OpenDb( oDom, hInfo )		
			retu nil 
		endif
		
	//	Refresh Total rows

		if ! TotalRows( oDom, hInfo )
			retu nil
		endif		

	//	Update page
	
		hInfo[ 'page' ]--	

		if hInfo[ 'page' ] <= 0
			hInfo[ 'page' ] := 1
		endif	
		
	//	Load data...
	
		LoadRows( oDom, hInfo )
		
	//	Close database connection

		CloseDb( oDom, hInfo )			
	
	//	Refresh Dom 
	
		Refresh_Nav( oDom, hInfo )		

retu nil 

// -------------------------------------------------- //

static function DoNav_Next( oDom )

	local hInfo	:= InitInfo( oDom )	

	//	Open Database
	
		if ! OpenDb( oDom, hInfo )		
			retu nil 
		endif
		
	//	Refresh Total rows

		if ! TotalRows( oDom, hInfo )
			retu nil
		endif		

	//	Update page
	
		hInfo[ 'page' ]++	

		if hInfo[ 'page' ] > hInfo[ 'page_total' ]
			hInfo[ 'page' ] := hInfo[ 'page_total' ]		
		endif	
		
	//	Load data...
	
		LoadRows( oDom, hInfo )
		
	//	Close database connection

		CloseDb( oDom, hInfo )			
	
	//	Refresh Dom 
	
		Refresh_Nav( oDom, hInfo )		

retu nil 

// -------------------------------------------------- //

static function CloseDb( oDom, hInfo )

//	SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections";

	if HB_HHasKey( hInfo, 'db' ) .and. hInfo[ 'db' ]:ClassName() == 'WDO_MYSQL'	
		hInfo[ 'db' ]:Close()
	endif

retu nil 

// -------------------------------------------------- //

static function OpenDb( oDom, hInfo )

	local hConn := hInfo[ 'conn_cfg' ]
	
	hInfo[ 'db' ] := WDO_MYSQL():New( hConn[ 'IP' ], hConn[ 'USER' ], hConn[ 'PSW' ], hConn[ 'DB' ], hConn[ 'PORT' ] )	
	
	IF ! hInfo[ 'db' ]:lConnect

		oDom:SetError( hInfo[ 'db' ]:cError )
		retu .f.
		
	ENDIF	

retu .t.

// -------------------------------------------------- //

static function TotalRows( oDom, hInfo )

	local lError, hRes, hConfig	
	
	hInfo[ 'total' ] := 0

	//	Load total pages
	
		IF !empty( hRes := hInfo[ 'db' ]:Query( hInfo[ 'sql' ], @lError  ) )		
			
			hInfo[ 'total' ] := hInfo[ 'db' ]:Count( hRes ) 			
			
			hInfo[ 'db' ]:Free_Result( hRes )

		ENDIF	
	
		if lError	
	
			oDom:SetError( hInfo[ 'db' ]:cError + '<hr>' +  hInfo[ 'sql' ] )
			
			hConfig := { 'columns' => {}, 'data' => {}	}	
			
			oDom:SetScope( 'myform' )	
			oDom:TableInit( 'brwdata', hConfig )			
			oDom:TableTitle( 'brwdata', '' )
			
			retu .f.
		endif
		
		_d( 'SQL', hInfo[ 'sql' ] )
		
	
	//	Refresh total pages...
		
		hInfo[ 'page_total' ] := Int( hInfo[ 'total' ] / hInfo[ 'page_rows' ] ) + if( hInfo[ 'total' ] % hInfo[ 'page_rows' ] == 0, 0, 1 )

	
	//	Valid page 
	
		if hInfo[ 'page' ] > hInfo[ 'page_total' ] .or. hInfo[ 'page' ] <= 0
			hInfo[ 'page' ] := 1		
		endif					
	
retu .t.

// -------------------------------------------------- //

static function BuildSql( oDom, hInfo )

	local oConsulta 	:= ConsultaModel():New()
	local oCons_Par, aPar, cSql, n
	local cParameter, cInputParameter, bTransform, hConsulta
		
		if ! oConsulta:Get( hInfo[ 'consulta' ], @hConsulta )	
			oDom:SetMsg( 'Consulta not found: ' + hInfo[ 'consulta' ] )
			retu nil
		endif						
		
		cSql := hConsulta[ 'SQL' ]
	
	//	Load parameters consultation...
	
		oCons_Par 	:= Cons_ParModel():New()
		aPar 		:= oCons_Par:GetAllChild( hInfo[ 'consulta' ] )
				
		
	//	Build Sql from parameters input
		
		
		for n := 1 to len( aPar )			
		
			cParameter 		:= aPar[n][ 'PARAMETER' ]			
			cInputParameter 	:= oDom:Get( cParameter )							
			
			if !empty( aPar[n][ 'TRANSFORM' ]	)
			//_d( 'Transform -> ' + '{|u| ' + aPar[n][ 'TRANSFORM' ] + '} ' )
				bTransform := &( '{|u| ' + aPar[n][ 'TRANSFORM' ] + '} ' )
				cInputParameter := eval( bTransform, cInputParameter )
			endif 						
			
			//if !empty( cInputParameter )	// Pot ser 0,'',{=>},...
			
				if valtype( cInputParameter ) != 'C'
				//_d( 'WARNING parameter ' + cParameter + ' return value not character', cInputParameter )
					cInputParameter := HB_VALTOSTR( cInputParameter )
				endif			
			
				cParameter := '%' + cParameter	
				
				if At( cParameter, cSql ) > 0
					cSql := StrTran( cSql, cParameter, cInputParameter ) 
				endif				
				
			//endif 						
		
		next 					
		
	hInfo[ 'sql' ] 	:= cSql 
	hInfo[ 'conn' ]	:= hConsulta[ 'ID_CONN' ]
	

retu .t. 

// -------------------------------------------------- //

static function LoadConn( oDom, hInfo )

	local oConn, hConn		

	if empty( hInfo[ 'conn' ]	 )
		oDom:SetMsg( 'Connection empty !' )
		retu .f.
	endif 		

	oConn := ConnectionModel():New()
	
	if ! oConn:GetId( hInfo[ 'conn' ]	, @hConn )	
		oDom:SetMsg( 'Connection not found: ' + hInfo[ 'conn' ] )
		retu .f.
	endif
	
	hInfo[ 'conn_cfg' ] := hConn
	
	SetConnection( hInfo[ 'conn' ], hInfo[ 'conn_cfg' ] )			

retu .t.

// -------------------------------------------------- //

static function LoadRows( oDom, hInfo, lInitBrw )

	local lError, hRes, hConfig, aStruct, n, a	
	local cSql
	local aRows := {}			
	local aCols := {}	
	local nRowInit, cTitle
	
	hb_default( @lInitBrw, .f. )
	
	//	If you want to set to UTF8
		hInfo[ 'db' ]:Query( 'SET NAMES utf8' )		
	
	//	Load total pages
	
		nRowInit := ( hInfo[ 'page' ] -  1 ) * hInfo[ 'page_rows']
		
		if at( 'LIMIT ', upper( hInfo[ 'sql' ] ) ) == 0		
			cSql := hInfo[ 'sql' ] + ' LIMIT ' + ltrim(str(nRowInit)) + ', ' +  ltrim(str(hInfo[ 'page_rows']))
		else
			cSql := hInfo[ 'sql' ] 
		endif
		
		
		IF !empty( hRes := hInfo[ 'db' ]:Query( cSql, @lError  ) )
		
			aRows := hInfo[ 'db' ]:FetchAll( hRes, .t. )			
			
			hInfo[ 'db' ]:Free_Result( hRes )

		ENDIF		
	
		if lError	
			oDom:SetError( hInfo[ 'db' ]:cError )
			
	
			hConfig := { 'columns' => {}, 'data' => {}	}						
			oDom:TableInit( 'brwdata', hConfig )			
			oDom:TableTitle( 'brwdata', '' )
			
		else
		
			cTitle := '<h5>Coincidences: ' + ltrim(str(hInfo[ 'total' ])) + ;
					  ' / Pages: ' +  ltrim(str( hInfo[ 'page_total' ])) + '</h5>'
		
			if lInitBrw	

				aStruct := hInfo[ 'db' ]:DbStruct()		
				
				for n := 1 to len( aStruct )
					Aadd( aCols, { 'field' => aStruct[n][1], 'title' => aStruct[n][1]} )
				next 

				hConfig := { ;
						'height' => '300px',;
						'columns' => aCols, ;
						'data' => aRows;				
					}		
					
				oDom:SetScope( 'myform' )

				oDom:TableTitle( 'brwdata', cTitle )
				oDom:TableInit( 'brwdata', hConfig )
		
			
			else 
			
				oDom:TableTitle( 'brwdata', cTitle )
				oDom:TableSetData( 'brwdata', aRows )
			
			endif
						
		endif		

retu .t.

// -------------------------------------------------- //

static function DoNav_Refresh_Rows( oDom )	

	local hInfo	:= InitInfo( oDom )			
	
	//	If refresh we'll go to page 1
	
		hInfo[ 'page' ] := 1
		
	//	Refresh Nav
		
		DoNav_Refresh( oDom, hInfo )
		
retu nil 

// -------------------------------------------------- //

static function DoNav_Refresh( oDom, hInfo )		
	
	//	Refresh Info 
	
		if hInfo == NIL 
			hInfo	:= InitInfo( oDom )
		endif

	//	Open Database
	
		if ! OpenDb( oDom, hInfo )		
			retu nil 
		endif
		
	//	Refresh Total rows

		if ! TotalRows( oDom, hInfo )
			retu nil
		endif		

	//	Load data...
	
		LoadRows( oDom, hInfo )
	
	//	Refresh Dom 
	
		Refresh_Nav( oDom, hInfo )	
		
	//	Close database connection

		CloseDb( oDom, hInfo )			
	
retu nil 

// -------------------------------------------------- //

static function DoNav_Print( oDom )		

	oDom:TablePrint( 'brwdata', 'aaa', 'bbb')
	
retu nil 
// -------------------------------------------------- //
