#include 'hbclass.ch' 

#define DBF_NAME  	'consulta.dbf'
#define DBF_CDX  	'consulta.cdx'
#define DBF_TAG  	'consulta'


CLASS ConsultaModel  FROM TDbf

	METHOD New()             		CONSTRUCTOR
	
	//METHOD GetAllCombo( lActive )	INLINE ::Super:GetAllCombo( 'NAME', 'DESCRIPTIO', lActive )

	METHOD Update( uId, aFields, cError )
	METHOD UsedClass( cClass )

	
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS ConsultaModel

	::lOpen 	:= .F.
	::cDbf	 	:= DBF_NAME
	::cCdx		:= DBF_CDX 
	::cTag		:= DBF_TAG 

	::Open()		

RETU SELF

//----------------------------------------------------------------------------//

METHOD Update( cKey, hFields, cError, oCell ) CLASS ConsultaModel

	local lUpdate, oCons_Par

						
	lUpdate := ::Super:Update( cKey, hFields, @cError )														
				
	if lUpdate 

		if valtype( oCell ) == 'O' .and. oCell[ 'field' ] == 'CONSULTA'	
			
			oCons_Par := Cons_ParModel():New()
	
			oCons_Par:UpdateKeyParent( oCell[ 'oldvalue' ], oCell[ 'value' ] )						

		endif
	
	endif
		
retu lUpdate

//----------------------------------------------------------------------------//

METHOD UsedClass( cClass ) CLASS ConsultaModel

	local nTimes := 0

	hb_default( @cClass, '' )
	
	if empty( cClass )
		retu 0
	endif

	(::cAlias)->( OrdSetFocus( 'CLASS' ) )
	
	(::cAlias)->( DbSeek( cClass, .t. ) )
	
	while alltrim((::cAlias)->id_class) == cClass .and. (::cAlias)->( !eof() )
	
		nTimes++
		
		(::cAlias)->( DbSkip() )
	end 
	
retu nTimes

//----------------------------------------------------------------------------//