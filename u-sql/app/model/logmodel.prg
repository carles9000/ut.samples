#include 'hbclass.ch' 

#define DBF_NAME  	'log.dbf'
#define DBF_CDX  	'log.cdx'
#define DBF_TAG  	'date'


CLASS LogModel  FROM TDbf

	METHOD New()             		CONSTRUCTOR				
	
	METHOD Insert( cEvent, cValue )  
	
ENDCLASS

//------------------------------------------------------------ //

METHOD New() CLASS LogModel

	::lOpen 	:= .F.
	::cDbf	 	:= DBF_NAME
	::cCdx		:= DBF_CDX 
	::cTag		:= DBF_TAG 

	::Open()

RETU SELF


//------------------------------------------------------------ //

METHOD Insert( cEvent, cValue ) CLASS LogModel

	hb_default( @cEvent, '' )
	hb_default( @cValue, '' )

	if (::cAlias)->( DbAppend() )
	
		(::cAlias)->date   := date()
		(::cAlias)->time   := time()
		(::cAlias)->user   := Usession( 'credentials' )[ 'user' ]
		(::cAlias)->event  := cEvent
		(::cAlias)->value  := cValue
		
		(::cAlias)->( DbCommit() )
	
	endif
	
retu nil