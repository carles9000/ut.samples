function Api_Query( oDom )

	//	Auth system...
	
		if ! Authorization()
			retu nil
		endif
		
	//	-------------------------

	do case	
		
		case oDom:GetProc() == 'sel_server'		; DoSel_Server( oDom )															
		case oDom:GetProc() == 'clean'				; DoNav_Reset( oDom )													
		case oDom:GetProc() == 'execute'			; DoNav_Execute( oDom )
		
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

static function DoSel_Server( oDom )	

	local hConfig := { 'columns' => {}, 'data' => {}	}						
	local cServer := oDom:Get( 'nav_server')
	
	oDom:TableInit( 'brw', hConfig )				
	
	if !empty( cServer )
		oDom:SetJs( "MsgNotify( 'New Server was selected: "  +  cServer + "')" )
	endif
	
retu nil 

// -------------------------------------------------- //

static function DoNav_Execute( oDom )

	local cServer 	:= oDom:Get( 'nav_server' )
	local cSql 	:= oDom:Get( 'nav_sql' )
	local hInfo 	:= InitInfo( oDom )	
	local cSqlUpper 

	//	Check sql
	
		if empty( cSql )
			oDom:SetMsg( 'Sql empty !')
			retu nil
		endif 
		
		cSqlUpper := Upper( cSql )
		
		if at( 'DELETE', cSqlUpper ) > 0 .or. ;
		   at( 'UPDATE', cSqlUpper ) > 0 .or. ;
		   at( 'DROP', cSqlUpper ) > 0
		   
		   oDom:SetMsg( 'Ai ai ai...')
		   retu nil
		endif
		
		hInfo[ 'sql' ] 	:= cSql 
		hInfo[ 'conn' ]	:= cServer
		
		
	//	Check server
	
		if empty( cServer )
			oDom:SetMsg( 'Select server please !')
			retu nil
		endif 	
		
	//	Load Connection 
	
		if ! LoadConn( oDom, hInfo )
			retu .f.
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

		LoadRows( oDom, hInfo, .T. )		//	.t. == Init Browse


	//	Close database connection

		CloseDb( oDom, hInfo )		

	
	//	Refresh Dom 

		Refresh_Nav( oDom, hInfo )				

retu nil 

// -------------------------------------------------- //

static function DoNav_Reset( oDom )

	local hConfig := { 'columns' => {}, 'data' => {}	}
	
	oDom:Set( 'nav_sql'			, '' )
	oDom:Set( 'nav_conn'		, '' )
	oDom:Set( 'nav_total'		, 0 )
	oDom:Set( 'nav_page'		, 0 )
	oDom:Set( 'nav_page_rows'	, '10' )
	oDom:Set( 'nav_page_total'	, '0' )			
	
	oDom:TableTitle( 'brw', '<h5>No data...</h5>' )					
	oDom:TableInit( 'brw', hConfig )	
	
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

static function Refresh_Nav( oDom, hInfo )

	oDom:Set( 'nav_sql'			, hInfo[ 'sql' ] )
	oDom:Set( 'nav_conn'		, hInfo[ 'conn' ] )
	oDom:Set( 'nav_total'		, hInfo[ 'total' ] )
	oDom:Set( 'nav_page'		, ltrim(str(hInfo[ 'page' ])) )
	oDom:Set( 'nav_page_rows'	, ltrim(str(hInfo[ 'page_rows' ])) )
	oDom:Set( 'nav_page_total'	, ltrim(str(hInfo[ 'page_total' ])) )
	
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
		
			oDom:SetError( hInfo[ 'db' ]:cError )
			
			hConfig := { 'columns' => {}, 'data' => {}	}						
			oDom:TableInit( 'brw', hConfig )			
			oDom:TableTitle( 'brw', '' )
			
			retu .f.
		endif
		
	//	Refresh total pages...
		
		hInfo[ 'page_total' ] := Int( hInfo[ 'total' ] / hInfo[ 'page_rows' ] ) + if( hInfo[ 'total' ] % hInfo[ 'page_rows' ] == 0, 0, 1 )

	//	Valid page 
	
		if hInfo[ 'page' ] > hInfo[ 'page_total' ] .or. hInfo[ 'page' ] <= 0
			hInfo[ 'page' ] := 1		
		endif					

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
	
	//	Load total pages
	
		nRowInit := ( hInfo[ 'page' ] -  1 ) * hInfo[ 'page_rows']
		
		if At( 'SELECT ', Upper(hInfo[ 'sql' ]) ) > 0
			cSql := hInfo[ 'sql' ] + ' LIMIT ' + ltrim(str(nRowInit)) + ', ' +  ltrim(str(hInfo[ 'page_rows']))
		else
			cSql := hInfo[ 'sql' ]
		endif
		
		//	If you want to set to UTF8
			hInfo[ 'db' ]:Query( 'SET NAMES utf8' )	
		
		IF !empty( hRes := hInfo[ 'db' ]:Query( cSql, @lError  ) )
		
			aRows := hInfo[ 'db' ]:FetchAll( hRes, .t. )			
			
			hInfo[ 'db' ]:Free_Result( hRes )

		ENDIF		
	
		if lError	
			oDom:SetError( hInfo[ 'db' ]:cError )
			
	
			hConfig := { 'columns' => {}, 'data' => {}	}						
			oDom:TableInit( 'brw', hConfig )			
			oDom:TableTitle( 'brw', '' )
			
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
						'printAsHtml' => .T.,;						
						'printHeader' => '<div style="text-align:center;"><h1>Printing report example...</h1></div><hr>',;
						'printFooter' => '<hr><div style="text-align:center;"><h2>Footer example</div>',;
						'printRowRange' => 'all',;
						'columns' => aCols, ;
						'data' => aRows;				
					}											

				oDom:TableTitle( 'brw', cTitle )
				oDom:TableInit( 'brw', hConfig )
		
			
			else 
			
				oDom:TableTitle( 'brw', cTitle )
				oDom:TableSetData( 'brw', aRows )
			
			endif
						
		endif		

retu .t.

// -------------------------------------------------- //

static function DoNav_Print( oDom )		

	oDom:TablePrint( 'brw' )
	
retu nil 

// -------------------------------------------------- //

static function DoNav_Refresh( oDom, hInfo )		
	
	//	Refresh Info 
	
		if hInfo == NIL 
			hInfo	:= InitInfo( oDom )
		endif
		
		if empty( hInfo[ 'conn' ] )
			retu nil
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
