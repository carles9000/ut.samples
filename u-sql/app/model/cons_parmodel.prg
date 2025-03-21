#include 'hbclass.ch' 

#define DBF_NAME  	'cons_par.dbf'
#define DBF_CDX  	'cons_par.cdx'
#define DBF_TAG  	'id_cons'


CLASS Cons_ParModel  FROM TDbf

	METHOD New()             						CONSTRUCTOR	
	
	METHOD GetAllChild( cSearch, lOnlyActive )		;
		INLINE ::Super:GetAllChild( 'ID_CONS', cSearch, lOnlyActive, DBF_TAG )

		
	METHOD UpdateKeyParent( cOldValue, cValue )
	
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS Cons_ParModel

	::lOpen 	:= .F.
	::cDbf	 	:= DBF_NAME
	::cCdx		:= DBF_CDX 
	::cTag		:= DBF_TAG 

	::Open()

RETU SELF

//----------------------------------------------------------------------------//

METHOD UpdateKeyParent( cOldValue, cValue )  CLASS Cons_ParModel

	(::cAlias)->( OrdSetFocus( DBF_TAG ) )

	::Super:UpdateKeyParent( 'ID_CONS', cOldValue, cValue )				

RETU NIL 