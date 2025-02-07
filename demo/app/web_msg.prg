#include "../lib/tweb/tweb.ch" 

#define CRLF Chr(13)+Chr(10)

// -------------------------------------------------- //

function Ping_Data()

	local hData := GetMsgServer()
	
	_d( hData )
	
	UAddHeader("Content-Type", "application/json")		
	
	UWrite( hb_jsonEncode( hData ) )
	
retu nil 

// -------------------------------------------------- //

function Ping_DataRecno()

	local cRecno 	:= GetMsgServer()
	local nRecno 	:= Val( cRecno )	
	local cInfo 	:= ''
	
#ifdef __PLATFORM__WINDOWS
	USE ( 'data\test.dbf' ) SHARED NEW VIA 'DBFCDX'		
#else 
	USE ( 'data/test.dbf' ) SHARED NEW VIA 'DBFCDX'
#endif

	GOTO nRecno
	
	cInfo += FIELD->first + ' ' + FIELD->last  + CRLF
	cInfo += FIELD->street + ' ' + FIELD->city + ' ' + FIELD->state + CRLF
	cInfo += FIELD->notes	
	
	UWrite( cInfo )
	
retu nil 

// -------------------------------------------------- //