function Mylog( cName, cAction, cCargo  )

	use 'data\track.dbf' shared new alias (NewAlias())
	set index to track
	
	dbappend()
	
	field->fecha	:= date()
	field->hora	:= time()
	field->ip		:= UGetIp()
	field->user	:= cName	
	field->action 	:= cAction 	
	field->cargo 	:= cCargo
	
	dbcloseall()
	
retu nil 


function NewAlias( cPre )

	STATIC n := 0
	
	hb_default( @cPre, 'ALIAS')	
	
retu cPre + ltrim(str(++n))