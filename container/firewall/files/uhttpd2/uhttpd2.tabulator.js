/*
**	module.....: uhttpd2tabulator.js -- Tabulator for uhttpd2 (Harbour)
**	version....: 1.05
**  	last update: 11/11/2023
**
**	(c) 2022-2025 by Carles Aubia
**
*/



class UTabulator {

	id = null 
	table = null
	cargo = null 	
	init = null
	
	constructor( id ) {  // Constructor
		this.id = id;
		this.table = Tabulator.findTable("#" + id )[0];					
	}	
	

	Init( options, events, filter, cargo ) {		

	
		// UTabulatorValidOptions( options )
	

		//	IMPORTANTE. Miramos si existe ya un tabulator en el selector que queremos
		//	volver ainicializar. En caso de que exista, lo matamos

			var z = Tabulator.findTable('#' + this.id)[0];
			
			if (z) 			
			  z.destroy()
			  
		//	-----------------------------------------------
		
		
		this.cargo = cargo 
		
		var table = new Tabulator( '#' + this.id, options ) 						
		
		//	Define Events...
		
			table.on("tableBuilding", function(){
				//console.log( 'tableBuilding...' )
			});		
		
			table.on("tableBuilt", function(){
			
				if ( typeof init == 'string' ) {
				
					var fn =  window[ init ]			
			
					if ( typeof fn == "function") {					
						var u = fn.apply(null, [] );						
					}
				}
				
				//console.log( 'tableBuilt!!!' )
				//lReady = true 
				//console.log( 'tableBuilt2!!!', lReady )
			});
		
			if ( events ) {											

				//	We are looking for the dialog (parent)

					var oDlg	= $('#'+this.id).parents('[data-dialog]' )						

					if ( oDlg.length == 0 ){ 
						console.log( "data-dialog don't defined" )						
						return false 
					}
					
					var id_parent	= $(oDlg[0]).attr('id')
					var cApi 		= $('#'+id_parent).data('api')																				
				
				//	--------------------------------
	
				var fn 
				
				for (let i = 0; i < events.length; i++) {

					if ( 'proc' in events[i] ) {
						
						if ( cApi != '' ) {						
						
							table.on( events[i][ 'name' ], function(e,o,u){							

								var oPar = new Object()
								
								switch ( events[i][ 'name' ] ) {
							
									case 'cellEdited':							
								
										var oCell = new Object()
											oCell[ 'index' ] = table.options.index 
											oCell[ 'field' ] = e.getColumn().getDefinition().field 
											oCell[ 'title' ] = e.getColumn().getDefinition().title 
											oCell[ 'value' ] = e.getValue()
											oCell[ 'oldvalue' ] = e.getOldValue()
											oCell[ 'cargo' ] = cargo
											oCell[ 'row' ] = e.getData()

										oPar[ 'cell' ] = oCell 
								
										break;
										
									case 'cellClick':	
									
										//	https://tabulator.info/docs/5.5/components#component-cell
										
										var oCol = o.getColumn();
									
										var oCell = new Object()
											oCell[ 'index' ] = table.options.index
											oCell[ 'field' ] = o.getField()
											oCell[ 'title' ] = oCol.getDefinition().title 
											oCell[ 'value' ] = o.getValue()
											oCell[ 'oldvalue' ] = o.getOldValue()
											oCell[ 'cargo' ] = cargo
											oCell[ 'row' ] = o.getData()

										oPar[ 'cell' ] = oCell 
										
										

										break;
								}								

								MsgApi( cApi, events[i][ 'proc' ], oPar, id_parent ) 
							})														
						} else {
							console.error( "Don't exist api for " + events[i][ 'proc' ])
						}											
				
					} else {
					
						var fn =  window[ events[i][ 'function' ] ]
				
						if (typeof fn === "function") {															
							table.on( events[i][ 'name' ], fn )												
						}
					}					
				}			
			}
			
		//	Define Filter 
		
			if ( filter ) {			
				this.Filter( filter.id, filter.fields )			
			}
			
			
	}

	
	Proc( cCmd, value, cMessage ) {					
	
		if ( $.type( this.table ) == 'undefined' ) {
			console.error( "Table don't exist: " + this.id )
			return null 
		}

		
		switch ( cCmd ) {
				
			case 'setData':
			
				this.table.setData( value.data )
					.then(function(){
						//run code after table has been successfully updated
					})
					.catch(function(error){
						//handle error loading data						
					});	
				
				this.table.clearCellEdited();												
			
				break;	
				
			case 'addData':				
				this.table.addData( value.data, value.index, value.top );				
				break;

			case 'updateData':				
				this.table.updateData( value.data );				
				break;		

			case 'updateRow':		
	
				this.table.updateRow( value.index, value.row );				
				break;					

			case 'clean':	

				this.table.clearData();
				break;
				
			case 'title':	

				var cId = this.id + '_title'
				$('#' + cId ).html( value )
				
				break;

			case 'getData': 		
			
				var nIndex
				var o 		= this.table.getRows()	
				var oRows 	= {}				
		
				o.forEach(function (cell) { 

					nIndex = cell.getIndex()			
					
					if ( typeof nIndex != 'undefined') {			
						oRows[ nIndex ] = cell.getData()										
					} else {
						console.error( 'TWeb: Index error table' )
					}
				});				
				
				

				return oRows
				break;	

			
			case 'getDataChanged': 							
				
				var o 		=  this.table.getEditedCells()				                											
				var oRows 	= {}	
				var nIndex				
				
                o.forEach(function (cell) { 
				
					nIndex = cell.getRow().getIndex()									
					
					if ( !(nIndex in oRows) ){
						oRows[ nIndex ] = cell.getRow().getData()
					}
					
                });						
			
				return oRows							
				break;				

			case 'getSelectedData': 		

				return  this.table.getSelectedData();
				break;
				
			case 'deleteRow': 		
			
				this.table.deleteRow( value.ids );
				break;


			case 'clearEdited': 
			
				this.table.clearCellEdited();																
				break;	
				
			case 'TableNavigateRight': 
				//	No trabaja correctamente 
				
				//	this.table.navigateRight();
				break;				

			case 'alert':	

				//	UMsg() usa el dialog de jquery. Desde aqui abre el dialog y se produce undefined
				//	evento de close que lo cierra. De momento usaremos el alert que soporta bien el 
				//	mensaje
				//	UMsg( value.msg  )
				
				alert( value.msg )																			
				break;	

			case 'clearAlert':				
				this.table.clearAlert();														
				break;				

			case 'print':				
				this.table.print( value.par1, value.par2);														
				break;
				
			case 'download':				
				this.table.download( value.format, value.file );														
				break;
							
			
			case 'restoreOldValue':
			
				//	Xec cell.restoreOldValue();
				//	Xec cell.getOldValue();
				//	cell.getValue();
				
				break;
				
			case 'destroy': 
			
				this.table.destroy();																
				break;					
		}									
	}
	


	Filter( cId_Filter, aFields ) {			
	
		//	Fields
		
			var cHtml = '<div class="input-group">'
			
			cHtml += '<select class="form-control" id="' + cId_Filter + '_' + 'filter-field">' +
					 '<option></option>' 
						
			for (let i = 0; i < aFields.length; i++) {		
				cHtml += '<option value="' + aFields[i][0] + '">' + aFields[i][1] + '</option>'
			}

			cHtml += '</select>'
		
		//	Operators
		
			cHtml += '<select class="form-control" id="' + cId_Filter + '_' + 'filter-type">'
			cHtml += ' <option value="=">=</option>'
			cHtml += ' <option value="<"><</option>'
			cHtml += ' <option value="<="><=</option>'
			cHtml += ' <option value=">">></option>'
			cHtml += ' <option value=">=">>=</option>'
			cHtml += ' <option value="!=">!=</option>'
			cHtml += ' <option value="like">like</option>'
			cHtml += '</select>'
			
		//	Input search
		
			cHtml += '<input class="form-control" id="' + cId_Filter + '_' + 'filter-value" type="text" placeholder="value to filter">'

			cHtml += '<div class="input-group-append">'
			cHtml += '<button class="btn btn-secondary" id="' + cId_Filter + '_' + 'filter-clear">Clear Filter</button>'
			cHtml += '</div>'
			
			cHtml += '</div>'
		
		//	-------------------------------
			
			cHtml += '<script>'
			cHtml += " $('#" + cId_Filter + "_filter-field' ).bind('change', function() { UTabulatorFilterUpdate( '" + this.id + "','" + cId_Filter + "' ) } );"
			cHtml += " $('#" + cId_Filter + "_filter-type'  ).bind('change', function() { UTabulatorFilterUpdate( '" + this.id + "','" + cId_Filter + "' ) } );"
			cHtml += " $('#" + cId_Filter + "_filter-value' ).bind('keyup' , function() { UTabulatorFilterUpdate( '" + this.id + "','" + cId_Filter + "' ) } );"						
			cHtml += " $('#" + cId_Filter + "_filter-clear' ).bind('click' , function() { UTabulatorFilterClear ( '" + this.id + "','" + cId_Filter + "' ) } );"						
			cHtml += '</script>'
		
		//	-------------------------------
	
		$('#' + cId_Filter ).html( cHtml )
	}
	

}

function UTabulatorFilterUpdate( cId_Brw, cId_Filter ) {
	
	var cField = $( '#' + cId_Filter + '_' + 'filter-field').val()
	var cType = $( '#' + cId_Filter + '_' + 'filter-type').val()
	var cValue = $( '#' + cId_Filter + '_' + 'filter-value').val()

	var o 	 = new UTabulator( cId_Brw )		
	
	o.table.setFilter(cField,cType,cValue);	
}	

function UTabulatorFilterClear( cId_Brw, cId_Filter ) {	
	
	$( '#' + cId_Filter + '_' + 'filter-field').val( '' )
	$( '#' + cId_Filter + '_' + 'filter-type').val( '' )
	$( '#' + cId_Filter + '_' + 'filter-value').val( '')

	var o 	 = new UTabulator( cId_Brw )		
	
	o.table.clearFilter();
}	


//	Desde Harbour no podemos poner en el hash una @ a una funcion javascript, por lo que 
//  tenemos de ponerla como un string. Con esta funcion chequearemos si existe 
//  un string en el formatter y si es asi, comprobaremos que exista la funcion

function UTabulatorValidOptions( o ) {

	var oCols = o.columns;	
	
	for (let i = 0; i < oCols.length; i++) {
	
		if ( typeof oCols[i] == 'object'  ) { 
		
			//	Buscaremos en todas las claves de la columna (propiedades) si hay alguna que 
			//	empirze por '@'. Si es el caso, comprobaremos que exista la funcion en javascript 
			//  y la asignaremos como valor de la key.
			//
			//  Ejemplos de propierdades que pueden ser functions: formatter, editable, ...							
	

				for (var key in oCols[i] ) {								
					
					if ( typeof oCols[i][ key ] == 'string' && oCols[i][ key ].substr(0, 1) == '@' ) { 
						
						var cFunc = oCols[i][ key]						
						
						cFunc = cFunc.substr( 1, cFunc.length - 1 )						

						var fn =  window[ cFunc ]
						
						if (typeof fn === "function") {			
					
							oCols[i][ key ] = fn
						}						
					}
					
				} 
				
			//	Casos especiales...													
				if ( 'formatter' in oCols[i]) {

					if ( typeof oCols[i].formatter == 'string' ) {	
			
						var fn =  window[ oCols[i].formatter ]
						
						if (typeof fn === "function") {
							oCols[i].formatter = fn
						}												
					}		
				}
				
				if ( 'validator' in oCols[i]) {
				
					//	console.log( oCols[i].title )
					
					if ( typeof oCols[i].validator.type == 'string' ) {	
			
						var fn =  window[ oCols[i].validator.type ]
						
						if (typeof fn === "function") {
							oCols[i].validator.type = fn 
						}												
					}		
				}				
				
		}
	}

	
}


function UValidDate( cell, value, parameters ) {

	var dateFormat = parameters.inputFormat 	//	"DD/MM/YYYY";		
	
	var lOk = moment(value, dateFormat, true).isValid();

	return lOk
}

function UFormatLogic( cell, formatterParams, onRenderer ) {
	
	var cImg = ''

	if (cell.getValue()) {

		if ( formatterParams.yes )
			cImg = '<img src="' + formatterParams.yes + '" width="' + formatterParams.width + '" height="' + formatterParams.height  + '" ></img>'

	} else {
	
		if ( formatterParams.no )
			cImg = '<img src="' + formatterParams.no + '" width="' + formatterParams.width + '" height="' + formatterParams.height  + '" ></img>'
	
	}
	
	return cImg 
}