#include 'hbclass.ch' 

#define DBF_NAME  	'connections.dbf'
#define DBF_CDX  	'connections.cdx'
#define DBF_TAG  	'name'

CLASS ConnectionModel  FROM TDbf


	METHOD New()             			CONSTRUCTOR
	
	
	METHOD GetAllCombo( lOnlyActive )	INLINE ::Super:GetAllCombo( 'NAME', 'DESCRIPTIO', lOnlyActive )	
	
	METHOD GetId( cId, hRow, hFields ) 
	
	
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS ConnectionModel

	::lOpen 	:= .F.
	::cDbf	 	:= DBF_NAME
	::cCdx		:= DBF_CDX 
	::cTag		:= DBF_TAG 

	::Open()

RETU SELF

//----------------------------------------------------------------------------//

		
METHOD GetId( cId, hRow, hFields ) CLASS ConnectionModel
	
	(::cAlias)->( OrdSetFocus( ::cTag ) )
	
retu ::Super:Get( cId, @hRow, hFields )	


//----------------------------------------------------------------------------//
