#include 'hbclass.ch' 

#define DBF_NAME  	'class.dbf'
#define DBF_CDX  	'class.cdx'
#define DBF_TAG  	'name'


CLASS ClassModel  FROM TDbf

	METHOD New()             		CONSTRUCTOR
	
	METHOD GetAllCombo( lActive )	INLINE ::Super:GetAllCombo( 'NAME', 'DESCRIPTIO', lActive )
	
	METHOD MakeItemsTree()
	
ENDCLASS

//------------------------------------------------------------ //

METHOD New() CLASS ClassModel

	::lOpen 	:= .F.
	::cDbf	 	:= DBF_NAME
	::cCdx		:= DBF_CDX 
	::cTag		:= DBF_TAG 

	::Open()

RETU SELF


//------------------------------------------------------------ //

METHOD MakeItemsTree() CLASS ClassModel
	
	local oConsulta 	:= ConsultaModel():New()
	local aRows		:= oConsulta:LoadAll()
	local nLen 			:= len( aRows )
	local hClass 		:= ::LoadHash( 'NAME' )
	local aItems 		:= {}
	local hCI			:= {=>}
	local nGeneral		:= 0
	local j 			:= 0
	local n, hReg, h, cParent, cId, nPos

	//	Load used classes
	
		hCI[ 'A' ] := 'General' 

		for n := 1 to nLen 
		
			hReg := aRows[n]		
		
			if hReg[ 'ACTIVE' ]
		
				cParent := '???'
			
				if ! empty( hReg[ 'ID_CLASS' ] )
					if HB_HHasKey( hClass, hReg[ 'ID_CLASS' ] )
						cParent := hClass[ hReg[ 'ID_CLASS' ] ][ 'DESCRIPTIO' ]				
					endif
				
					if ! HB_HHasKey( hCI, hReg[ 'ID_CLASS' ] )
						hCI[ hReg[ 'ID_CLASS' ] ] := cParent				
					endif	
			
				endif
			endif

		next 
		
	//	Build Parent Tree
		
		for n := 1 to len( hCI )
		
			h := HB_HPairAt( hCI, n )		
		
			Aadd( aItems, {;
					'id' => h[1],;
					'parent' => '#',;
					'text' => h[2];					
				})	
				
		next 

	//	Add Items 
	
		for n := 1 to nLen 
		
			hReg := aRows[n]

			if hReg[ 'ACTIVE' ]
				
				cParent := hReg[ 'ID_CLASS' ]

				if 	empty( cParent )
					cParent := 'A'
					nGeneral++					
				endif
				
				cId := 'A' + ltrim(str( hReg[ '_recno' ]))
				
				Aadd( aItems, {;
						'id' => cId,;
						'parent' => cParent,;
						'text' => alltrim( hReg[ 'DESCRIPTIO' ] ),;
						'data' => alltrim( hReg[ 'CONSULTA' ] ),;
						'icon' => 'files/images/clip.png';
					})			
		
			endif 
		
		next 

	if nGeneral == 0	//	If don't exist, i will delete it
	
		nPos := Ascan( aItems, {|x,y| x['id'] == 'A'}) 
	
		if nPos > 0
			aItems := hb_Adel( aItems, nPos, .t. )	
		endif
	endif
		
retu aItems