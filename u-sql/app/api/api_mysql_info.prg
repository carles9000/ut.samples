function Api_MySql_Info( oDom )

	//	Auth system...
	
		if ! Authorization()
			retu nil
		endif
		
	//	-------------------------

	do case					
		case oDom:GetProc() == 'info'		; DoInfo( oDom )								
		
		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function DoInfo( oDom )

	local cServer := oDom:Get( 'server') 
	local oConn, hConn, oDb, hRes, cSql, lError
	local aRows := {}
	local aCols := {}	
	local aStruct, n, hConfig
	
	if empty( cServer )
		oDom:TableSetData( 'brwinfo', {} )		
		retu nil 
	endif 
		
	
	oConn := ConnectionModel():New()
	
	if ! oConn:GetId( cServer	, @hConn )	
		oDom:SetError( 'Connection not found: ' + cServer )
		oDom:TableSetData( 'brwinfo', {} )
		retu .f.
	endif	
	

	oDb := WDO_MYSQL():New( hConn[ 'IP' ], hConn[ 'USER' ], hConn[ 'PSW' ], hConn[ 'DB' ], hConn[ 'PORT' ] )	
	
	IF ! oDb:lConnect

		oDom:SetError( oDb:cError )
		oDom:TableSetData( 'brwinfo', {} )
		retu .f.
		
	ENDIF	
	
	cSql := 'SHOW STATUS WHERE variable_name LIKE "Threads_%" OR variable_name = "Connections";'
	
	IF !empty( hRes := oDb:Query( cSql, @lError  ) )
	
		aRows := oDb:FetchAll( hRes, .t. )			
		
		oDb:Free_Result( hRes )

	ENDIF	
	
	_d( aRows )
/*
				aStruct := oDb:DbStruct()		
				
				for n := 1 to len( aStruct )
					Aadd( aCols, { 'field' => aStruct[n][1], 'title' => aStruct[n][1]} )
				next 
//						'columns' => aCols, ;
				hConfig := { ;
						'height' => '300px',;
						'data' => aRows;				
					}											
				
*/
				oDom:TableSetData( 'brwinfo', aRows )	
	
	oDb:Close()
retu nil 

// -------------------------------------------------- //
