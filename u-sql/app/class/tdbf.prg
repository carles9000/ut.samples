#include 'lib/uhttpd2/uhttpd2.ch'	
#include 'hbclass.ch'	

CLASS TDbf

	DATA cDbf							INIT ''
	DATA cCdx							INIT ''
	DATA cTag							INIT ''
	DATA lOpen 							INIT .T.
	DATA cAlias 
	DATA nFields 						INIT 0
	DATA nMax							INIT 1000
	

	METHOD New( cDbf, cCdx, cTag, lOpen )  CONSTRUCTOR 
	
	METHOD Open()
	
	METHOD LoadAll( aFields ) 
	METHOD LoadHash( cKey, aFields, lOnlyActive )
	METHOD Update( nRecno, aFields, cError ) 
	METHOD Delete( nRecno, cError )	
	METHOD Append( cError )
	METHOD Goto( nRecno )
	
	METHOD Seek( u, lSoft )
	
	METHOD Blank()
	METHOD Row() 
	
	METHOD Get( cId, hRow, hFields )
	METHOD GetAllCombo( cKey, cField, lCheckActive )	
	METHOD GetAllChild( uValue, lCheckActive )
	
	METHOD UpdateKeyParent( cField, cOldValue, cValue )
	
ENDCLASS 



// -------------------------------------------------- //

METHOD New( cDbf, cCdx, cTag, lOpen ) CLASS TDbf

	hb_default( @cDbf, '')
	hb_default( @cCdx, '')
	hb_default( @cTag, '' )
	hb_default( @lOpen, .T. )	
	
	::cDbf  := cDbf
	::cCdx  := cCdx
	::cTag  := cTag
	::lOpen := lOpen
	
	if ::lOpen
		::Open()
	endif
	
RETU SELF

// -------------------------------------------------- //

METHOD Open() CLASS TDbf

	local cFileDbf, cAlias, cFileCdx, oError

	
	cFileDbf 	:= AppPathData() + ::cDbf		
	
	if !file( cFileDbf )
		UDo_Error( "No dbf file" )					
		retu nil
	endif	

	TRY
	
		::cAlias := NewAlias()

		use ( cFileDbf ) shared new alias (::cAlias) VIA 'DBFCDX' 		
		
		::nFields := (::cAlias)->( FCount() )
		
		if !empty( ::cCdx )
		
			cFileCdx 	:= AppPathData() + ::cCdx
			
			if file( cFileCdx )
		
				SET INDEX TO ( cFileCdx )
			
				if !empty( ::cTag )			
					(::cAlias)->( OrdSetFocus( ::cTag ) )
					
					if (::cAlias)->( IndexOrd() ) == 0
						UDo_Error( "Tag doesn't exist " + ::cTag )
					endif
					
				endif
					
			else 
				UDo_Error( "Cdx doesn't exist " + ::cCdx )			
			endif 
		endif 
		
	
	CATCH oError 

		Eval( ErrorBlock(), oError )
	
	END		

RETU nil

//	----------------------------------------------- //

METHOD LoadAll( aFields ) CLASS TDbf

	local aRows := {}
	local hRow  := {=>}
	local aStr, n, nFields, uValue, aSt
	local nSet 
	
	hb_default( @aFields, {} ) 
	

	if empty( aFields )
	
		aSt := ( ::cAlias)->( DbStruct() )
		
		for n := 1 to len( aSt )		
			Aadd( aFields, aSt[n][1] )
		next 		
	
	endif 

	nFields := len( aFields )
	
	for n := 1 to nFields
		aFields[n] := { aFields[n], (::cAlias)->( FieldPos( aFields[n] ) ), valtype( (::cAlias)->( FieldGet( FieldPos( aFields[n] )))) } 
	next 	
	
	(::cAlias)->( DbGoTop() )
	
	while (::cAlias)->( !eof() )
	
		hRow := {=>}
			
		hRow[ '_recno' ] := (::cAlias)->( Recno() )
		
		for n := 1 to nFields 
		
			uValue := (::cAlias)->( FieldGet( aFields[n][2] ) )
			
			do case
				case aFields[n][3] == 'C' ; uValue := hb_strtoUtf8( alltrim( uValue) ) 
				case aFields[n][3] == 'D' ; uValue := DToC( uValue )
			endcase			
			
			hRow[ aFields[n][1] ] := uValue
			
		next 
		
		Aadd( aRows, hRow  )
	
		(::cAlias)->( DbSkip() )
		
	end	

RETU aRows 

//	----------------------------------------------- //

METHOD LoadHash( cKey, aFields, lOnlyActive ) CLASS TDbf

	local hRows := {=>}
	local hRow  := {=>}
	local aStr, n, nFields, uValue, aSt, nPosKey, lExist_Active, cKeyValue
	local nSet 
	
	hb_default( @cKey, '' ) 	
	hb_default( @aFields, {} ) 	
	hb_default( @lOnlyActive, .t. ) 	
	
	if empty( cKey )
		retu hRows 
	endif

	if empty( aFields )
	
		aSt := ( ::cAlias)->( DbStruct() )
		
		for n := 1 to len( aSt )		
			Aadd( aFields, aSt[n][1] )
		next 		
	
	endif 
	
	nPosKey 		:= (::cAlias)->( FieldPos( cKey) )
	lExist_Active 	:= if( (::cAlias)->( FieldPos( 'active' ) ) > 0, .T., .F. )		
	
	if nPosKey == 0
		retu hRows 
	endif

	nFields := len( aFields )
	
	for n := 1 to nFields
		aFields[n] := { aFields[n], (::cAlias)->( FieldPos( aFields[n] ) ), valtype( (::cAlias)->( FieldGet( FieldPos( aFields[n] )))) } 
	next 	
	
	(::cAlias)->( DbGoTop() )
	
	while (::cAlias)->( !eof() )
	
		cKeyValue 	:= lower(alltrim((::cAlias)->( FieldGet( nPosKey ) )))
		hRow 		:= {=>}
			
		hRow[ '_recno' ] := (::cAlias)->( Recno() )
		
		if lExist_Active
			
			if (::cAlias)->active				

				hRows[ cKeyValue ] := LoadRegister( ::cAlias, aFields, nFields )
				
			else	
			
				if !lOnlyActive
					hRows[ cKeyValue ] := LoadRegister( ::cAlias, aFields, nFields )
				endif
				
			endif	
			
		else

			hRows[ cKeyValue ] := LoadRegister( ::cAlias, aFields, nFields )
			
		endif
		
	
		(::cAlias)->( DbSkip() )
		
	end	

RETU hRows 

//	----------------------------------------------- //

static function LoadRegister( cAlias, aFields, nFields )

	local hRow := {=>}
	local n, uValue
	
	
	for n := 1 to nFields 
	
		uValue := (cAlias)->( FieldGet( aFields[n][2] ) )
		
		do case
			case aFields[n][3] == 'C' ; uValue := hb_strtoUtf8( alltrim( uValue) ) 
			case aFields[n][3] == 'D' ; uValue := DToC( uValue )
		endcase			
		
		hRow[ aFields[n][1] ] := uValue
		
	next 		

retu hRow

//	----------------------------------------------- //

METHOD Update( nRecno, hFields, cError ) CLASS TDbf

	local lUpdate := .f.
	local n, j, h, nPos, oError

	(::cAlias)->( DbGoTo( nRecno ) )
		
	if (::cAlias)->( Rlock() )		
	
		lUpdate := .t.
	
		for n :=  1 to len(hFields)
		
			h := HB_HPairAt( hFields, n )

			nPos := (::cAlias)->( FieldPos( h[1] ) )

			try
				(::cAlias)->( Fieldput( nPos, h[2] ) )		
			catch oError

				cError  := 'Field: ' + UValToChar( h[1] )
				cError  += '<br>Error: ' + oError:description
				
				if valtype( oError:args ) == 'A'
					cError  += '<br>Args: ' 
					for j := 1 to len(oError:args)
						cError  += '<br>&nbsp;&nbsp;[' + ltrim(str(j))+ ']: ' + UValToChar( oError:args[j] )					
					next					
				endif
				
				lUpdate := .f.
			end 
		
		next			
		
		(::cAlias)->( DbCommit() )
		(::cAlias)->( DbUnlock() )		
		
	else 
		cError := 'Lock error'
	endif

RETU lUpdate

//	----------------------------------------------- //

METHOD GoTo( nRecno ) CLASS TDbf
	
	hb_default( @nRecno, 0 )	

	(::cAlias)->( DbGoTo( nRecno ) )
	
RETU NIL 
	
//	----------------------------------------------- //

METHOD Delete( nRecno, cError ) CLASS TDbf

	local lDelete := .f.
	
	(::cAlias)->( DbGoto(  nRecno ) )
	
	if (::cAlias)->( Rlock() )			
	
		(::cAlias)->( DbDelete() )	
		
		(::cAlias)->( DbUnlock() )
		
		lDelete := .T. 
		
	else 
		cError := 'Lock error'				
	endif		
	
	
RETU lDelete 

//	----------------------------------------------- //

METHOD Append( nRecno, cError ) CLASS TDbf	
	
	(::cAlias)->( DbAppend() )		
	
RETU .t.

//	----------------------------------------------- //

METHOD Seek( cUser, lSoftSeek  ) CLASS TDbf		
	
	hb_default( @lSoftSeek, .f. )
	
retu (::cAlias)->( DbSeek( cUser, lSoftSeek ) )		

//	----------------------------------------------- //

METHOD Blank() CLASS TDbf	

	local nRecno :=  (::cAlias)->( recno() )	
	local hRow 		:= {=>}
		
	(::cAlias)->( DbGobottom() )
	(::cAlias)->( DbSkip(1) )			
	
	hRow := ::Row()	
		
	(::cAlias)->( DbGoTo( nRecno ) )

RETU hRow

//	----------------------------------------------- //

METHOD Row() CLASS TDbf	

	local nFields := (::cAlias)->( FCount() )
	local hRow 		:= {=>}
	local n, cType, uValue 	
	
	hRow[ '_recno' ] := (::cAlias)->( Recno() )
	
	for n := 1 to ::nFields
	
		uValue := (::cAlias)->( FieldGet( n ) )
		
		cType  := valtype( uValue )
		
		do case
			case cType == 'C' .or. cType == 'M'
				uValue := alltrim(uValue)
			case cType == 'D'
				uValue := DToC( '  -  -  ' )
		endcase
		
		hRow[ (::cAlias)->( FieldName( n ) ) ] := uValue
	
	next 					

RETU hRow

//	----------------------------------------------- //

METHOD GetAllCombo( cKey, cField, lOnlyActive, cTag ) CLASS TDbf

	local n 		:= 0		
	local hData 	:= {=>}
	local nPosKey, nPosField
	local lExist_Active
	
	hb_default( @lOnlyActive, .t. )	//	.t. = only active, .f. all
	hb_default( @cTag, '' )
	
	nPosKey 		:= (::cAlias)->( FieldPos( cKey) )
	nPosField 		:= (::cAlias)->( FieldPos( cField ) )
	lExist_Active 	:= if( (::cAlias)->( FieldPos( 'active' ) ) > 0, .T., .F. )	
	
	if !empty( cTag )	
		(::cAlias)->( OrdSetFocus( cTag ) )
	endif	
	
	(::cAlias)->( DbGoTop() )
	
	hData[ '' ] := ''
				

		while n <= ::nMax .and. (::cAlias)->( !eof() )														
	
			if lExist_Active
			
				if (::cAlias)->active			
					hData[ alltrim((::cAlias)->( FieldGet( nPosKey) )) ] := Alltrim( (::cAlias)->( FieldGet( nPosField) ))
				else	
					if !lOnlyActive
						hData[ alltrim((::cAlias)->( FieldGet( nPosKey) )) ] := Alltrim( (::cAlias)->( FieldGet( nPosField) ))
					endif
				endif
			
			else
			
				hData[ alltrim((::cAlias)->( FieldGet( nPosKey) )) ] := Alltrim( (::cAlias)->( FieldGet( nPosField) ))
			
			endif

			(::cAlias)->( DbSkip() )			
			
			n++
		end

RETU hData


//	----------------------------------------------- //

METHOD GetAllChild( cKey, uValue, lOnlyActive, cTag ) CLASS TDbf

	local aChild	:= {}
	local nPosKey, lExist_Active
	
	hb_default( @uValue, '' )
	hb_default( @lOnlyActive, .t. )	//	.t. = only active, .f. all
	hb_default( @cTag, '' )	
	
	nPosKey 		:= (::cAlias)->( FieldPos( cKey) )	
	lExist_Active 	:= if( (::cAlias)->( FieldPos( 'active' ) ) > 0, .T., .F. )	
	
	if !empty( cTag )	
		(::cAlias)->( OrdSetFocus( cTag ) )
	endif		

	(::cAlias)->( DbGoTop() )
	(::cAlias)->( DbSeek( uValue, .t. ) )
	
	//hRow[ '_recno' ] := (::cAlias)->( Recno() )
	

		while (::cAlias)->( FieldGet( nPosKey) ) = uValue .and. (::cAlias)->( !eof() )														

			if lExist_Active 
			
				if (::cAlias)->active							
					Aadd( aChild, ::Row() )
				else
					if !lOnlyActive
						Aadd( aChild, ::Row() )					
					endif
				endif
			
			else 
				Aadd( aChild, ::Row() )
			endif

			(::cAlias)->( DbSkip() )						

		end

RETU aChild


// -------------------------------------------------- //

METHOD Get( cId, hRow, hFields )	 CLASS TDbf

	local lFound 

	hRow := {=>}
	
	(::cAlias)->( dbGoTop() )
	
	lFound := (::cAlias)->( dbSeek( cId, .f. ) )
	
	if lFound
		hRow := ::Row()
	endif

retu lFound

//	----------------------------------------------- //

METHOD UpdateKeyParent( cField, cOldValue, cValue ) CLASS TDbf

	local nPos := (::cAlias)->( FieldPos( cField ) )
	local nRecno

	(::cAlias)->( DbSeek( cOldValue, .t. ) )
	
	while alltrim((::cAlias)->( fieldget( nPos ) )) == alltrim(cOldValue) .and. (::cAlias)->( !eof() )
	
		(::cAlias)->( DbSkip(1) )
		nRecno := (::cAlias)->( Recno() )
		(::cAlias)->( DbSkip(-1) )
		
		if (::cAlias)->( Rlock() )	
			(::cAlias)->( fieldput( nPos, cValue ) )	
		endif
	
		(::cAlias)->( dbgoto( nRecno ) )
		
	end 
	
	(::cAlias)->( DbUnlock() )	

retu nil

//	----------------------------------------------- //
