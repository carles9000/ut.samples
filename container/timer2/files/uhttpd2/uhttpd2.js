/*
**	module.....: uhttpd2.js -- module control for uhttpd2 (Harbour)
**	version....: Front 2.4
**  	last update: 02/01/2025
**
**	(c) 2022-2025 by Carles Aubia
**
*/

const UHTTPD2_VERSION = 'Front 2.4';

$( document ).ready(function() { console.info( 'UT ' + UHTTPD2_VERSION) })


function UHttpd2() {

	var oDom = new UDom()
	
	if ( typeof UHttpd2.dialog == 'undefined' ) {		
		UHttpd2.dialog = new Object()	
	}		
	
	this.SetDialog = function( bFunction ) { 				
		UHttpd2.dialog[ 'function' ] = bFunction		
	}
	
	this.dlg = function() { return UHttpd2.dialog }
	

	this.GetLive = function( cId ) {

		//	Search in children of id
		
			var o = $("#" + cId ).find( "[data-live]" )	
		
		var oControls = new Object()	
		
		var id 		


		var nI = 0

		for (nI = 0; nI < o.length; nI++) {
		
			id = $(o[nI]).attr( 'id')									

			//var type =  $(o[nI]).prop('type')
			var type =  UdomType( id )						
			var uValue = oDom.Get( id )
		
			if ( type == 'file' ) {
				id = cId + '-' + 'files'				
			}					

			
			//	Hem de testejar de posar a type en lloc de 'input' el type de variable
			//oControls[ id ] = { type: 'input', 'value' : uValue }
			oControls[ id ] = { type: type, 'value' : uValue }
			
			switch ( type ) {
			
				case 'radio':
				
					var cName = $('#'+id).attr("name");
					var value = $( 'input[name=' + cName + ']:checked' ).val();
									
					oControls[ cName ] = { type: 'radio', 'value' : value }
								
					break;						
			}		
		}

		return oControls	
	}
	
	this.InitOnChange = function( cId ) {
				
		//	Search in children of id
		
			var o 			= $("#" + cId ).find( "[data-onchange]" )		
		
		//	Check Ids with event
		
			if ( o.length == 0 )
				return null
			
		//	Check duplicated Id's for this event
		
			var nDuplicated = this.Duplicated_Ids( o, 'onchange' ) 
			
			if ( nDuplicated > 0 )		
				return nDuplicated

		for (i = 0; i < o.length; i++) {
		
			id = $(o[i]).attr( 'id') 
			
			

			$('#'+id ).bind( 'change', UOnChange )
		}

		return 0		
	}
		
	
	this.InitOnClick = function( cId ) {
		
		//	Search in children of id

			var o 			= $("#" + cId ).find( "[data-onclick]" )	

		//	Check Ids with event
		
			if ( o.length == 0 )
				return null
			
		//	Check duplicated Id's for this event in all DOM
		
			var nDuplicated = this.Duplicated_Ids( o, 'onclick' ) 
			
			if ( nDuplicated > 0 )		
				return nDuplicated
			
				
		
		for (i = 0; i < o.length; i++) {
		
			id = $(o[i]).attr( 'id')  
		
			$('#'+id ).bind( 'click', UOnClick )
		}			
		
		return 0	
	}	

	
	this.InitOnInit = function( cId ) {
	
		//	exist api ?
		
			cApi 	= $('#'+ cId).data('api')

			if ( cApi == null )
				return null 		
		
		//	exist data-init in TDialog ?

			var cProc 			= $("#" + cId ).data( 'oninit' )	
		
			if ( cProc == null )
				return null 

		var oPar 				= new Object()
			oPar[ 'dlg' ] 		= cId
			oPar[ 'api' ] 		= cApi
			oPar[ 'proc' ] 		= cProc 
			oPar[ 'controls' ] 	= JSON.stringify( this.GetLive( cId ) )	

		UShoot( 'api', oPar )		
	}
	
	this.Duplicated_Ids = function( o, cEvent ) {
		// Warning Duplicate IDs
		var nDuplicated = 0	;
		
		$(o).each(function(){

		  var ids = $('[id="'+this.id+'"]');
		  
		  if(ids.length>1 && ids[0]==this) {
			nDuplicated++
			console.warn( cEvent + ' -> Multiple IDs #'+this.id);
		  }	
		});
		
		//return ( nDuplicated > 0 )		
		return nDuplicated 
	}

}



function UInitDialog( cId ) {

	var h = new UHttpd2()
	
	var ids = $('[id="' + cId + '"]');


	if ( ids.length > 1 ){
		console.warn( "Warning!, Dialog Form id duplicated => " + cId )
		UMsgError( '<b>Dialog Form ID duplicated: </b>' + cId, '<h3>System Error</h3>' )
		return null;
	}		
	

		

	//	We initialize our dialog with the different events 
	//	that we want to manage...

		var n = 0
	
		n = h.InitOnChange( cId )
		n = h.InitOnClick( cId )
		
		

		
		if ( n > 0 )
			console.warn( "Warning!, Dialog id => " + cId + ", maybe dont working correctly. Id's duplicated")

		
		
	//	The first thing we will do is manage if the oninit clause exists

		h.InitOnInit( cId )
}


function UOnChange( id ) {
	
	var selectElement 	= event.target;

	//	Special case is TGetNumber ( input + buttons )
	
	if ( typeof id == 'object' ) {
	
		if ( selectElement.id == '' ) {
			id 	= selectElement.offsetParent.id;
		} else {
			id 	= selectElement.id;
		}
	}
	
	//	We are looking for the dialog (parent)

	var oDlg	= $('#'+id).parents('[data-dialog]' )	

	if ( oDlg.length == 0 ){ 
		//alert( "data-dialog don't defined")
		UMsgError( "<b>Error: </b> html => data-dialog tag don't defined", 'Programming')
		return false 
	}
			
	var id_parent		= $(oDlg[0]).attr('id')	
	var proc			= $('#'+id).data('onchange')
	var oHttpd2			= new UHttpd2()
	
	var oPar 			= new Object()
		oPar[ 'dlg' ] 		= id_parent
		oPar[ 'api' ] 		= $('#'+id_parent).data('api')
		oPar[ 'proc' ] 		= proc 
		oPar[ 'controls' ] 	= JSON.stringify( oHttpd2.GetLive(id_parent) )
		oPar[ 'trigger' ] 	= id

	UShoot( 'api', oPar )			
}

var _TWebPBS = false


function UOnClick() {

	var selectElement 	= event.target;
	var id 	
	var oMyOptions	= new Object()
	
	
	if ( selectElement.id == '' ) {
		id 	= selectElement.offsetParent.id;
	} else {
		id 	= selectElement.id;
	}

	//console.log( ' event.stopPropagation();' )
	// event.stopPropagation();
	 


	//	We are looking for the dialog (parent)

	if ( ! id )
		return null

	var oDlg	= $('#'+id).parents('[data-dialog]' )	
	
	if ( oDlg.length == 0 ){
		UMsgError( "<b>Error: </b> Html => data-dialog tag don't defined...", 'Programming' )
		return false 
	}

	
	var id_parent		= $(oDlg[0]).attr('id')		
	var proc			= $('#'+id).data('onclick')	
	var pbs				= $('#'+id).data('pbs')			//	[P]rocess [B]efore [S]end
	var cConfirm		= $('#'+id).data('confirm')	

	if ( typeof cConfirm == 'string' && cConfirm.length > 0 ) {
		if ( !confirm( cConfirm ) ) {
			return null	
		}
	}


	if ( typeof pbs == 'string' ) {

		try {			
		
			var fn =  window[ pbs ]
			
			
			if ( typeof fn == "function") {	

				//	Si ejecutamos un PBS haremos la llamada Ajax async para no bloquear
				//	cualquier posible accion definida en pbs 
				
					oMyOptions[ 'async' ] = true
					
				//	------------------------------------
		
				var u = fn.apply(null, [] );
		
				
				if ( typeof u == 'boolean' ) {
					if ( u == false )
						return null					
				} else 
					return null				
			} else {
				var cError = '<b>Parent Id:</b>' + id_parent + '<br><b>Id:</b> ' + id + '<br>' + '<b>pbs not found:</b> ' + pbs
				UMsg( cError, 'System Error' )
				return null				
			} 						
			
		} catch (e) {		
			var cError = '<b>Parent Id:</b>' + id_parent + '<br><b>Id:</b> ' + id + '<br>' + '<b>Error pbs:</b> '
			if (e instanceof SyntaxError) {
				cError += e.message				
			} else {
				cError += e				
				//throw e;
			}
			UMsg( cError, 'System Error' )
		}
	}
	
	var oHttpd2			= new UHttpd2()	
	
	var oPar 			= new Object()

		oPar[ 'dlg' ] 		= id_parent
		oPar[ 'api' ] 		= $('#'+id_parent).data('api')
		oPar[ 'proc' ] 		= proc 
		oPar[ 'controls' ] 	= JSON.stringify( oHttpd2.GetLive(id_parent) )	
		oPar[ 'trigger' ] 	= id
	
		
	//	En la parte final hemos de chequear si el Button procesará UPLOADS
	
	var cId_Files	= $('#'+id).data('upload')	
	

	if ( cId_Files ){			//	Click UPLOAD
	
		var o = $('#' + cId_Files)						
		
		if ( o.length != 1 ) {
			UMsgError( 'Error data-upload: ' + cId_Files )
			return null			
		}
	
		UFileUpload( cId_Files, oPar )	
		
	} else {					//	Click 

		UShoot( 'api', oPar, null, null, oMyOptions )			

	}
}



//	Upload Files -------------------------------------------

//	------------------------------------------------------------------------------------
//	Podremos usar de 2 maneras:
//	1.- Usando la api de httpd2. Para poder hacerlo cApi será un objeto de 3 keys:
//		cApi['key']
//		cApi['api']
//		cApi['proc']
//		cApi['trigger']
//
// 	2.- Usando como una funcion indepediente. cApi sera el nombre de la key del router.
//		Ademas le indicaremos una callback que recibirá datos del servidor una vez
//		haya procesado la subida
//
//	------------------------------------------------------------------------------------	

function UFileUpload( cId_File, cApi, fCallback, oPar ) {

	var fd 		= new FormData();								
	var lViaApi = ( $.type( cApi ) == 'object' )
	var nFiles 	

	
	if ( $('#' + cId_File ).length == 0 )
		return nul

	nFiles 	= $('#' + cId_File )[0].files.length 	

	if ( nFiles == 0 )
		return null
	
	
	if  ( lViaApi ){	

		var oHttpd2			= new UHttpd2()		
		
		fd.append( 'dlg', cApi[ 'dlg' ] )
		fd.append( 'api', cApi[ 'api' ] )		
		fd.append( 'proc', cApi[ 'proc' ] )			
		fd.append( 'controls', JSON.stringify( oHttpd2.GetLive(cApi[ 'dlg' ]) )	 )	
		fd.append( 'trigger', cApi[ 'trigger' ] )			
	
		
	} else { 
	
		if ( typeof fCallback != "function") {
			UMsgError( 'UFileUpload error. Callback is missing' )
			return null
		}	
		
		if ( $.type( oPar ) == 'object' ) {
		
			$.each( oPar, (index, value) =>{
			  fd.append( index, value )
			});
		}						
	}		
		
	//	----------------------------------------------------			
	
	for ( i=0; i < nFiles; i++ ) {
		var file = $('#' + cId_File )[0].files[i];
		//console.log( 'FILE', file )
		fd.append('file', file);				
	}
	
	if ( lViaApi )	
		UShoot( 'api', fd, true  )
	else
		UShoot( cApi , fd, true, fCallback )
		
}


function MsgApi( cApi, cProc, oNewPar, cIdForm, lAsyncro ) {


	var o = $("[data-api='" + cApi +"']");

	if ( o.length != 1 ) {
		
		
		var lFound = false;
		
		if ( typeof cIdForm == 'string' ) {
		
			for (let i = 0; i < o.length; i++) {
				
				var cId = $(o[i]).attr( 'id' )
				
				if ( cId == cIdForm ){
					lFound = true;
					break;
				}
			}					
		}			
 
		
		if ( !lFound ) {
			//console.error( 'Api not found: ' + cApi )		// CAF240129
			//return null									// CAF240129
			cId = cIdForm									// CAF240129
		}		
		
	} else {
	
		var cId = o.attr( 'id' )
	}

	var oHttpd2			= new UHttpd2()
	
	if ( typeof cId != 'string' ) {
		console.error( 'ID not defined in form with Api: ' + cApi )
		return null
	}
	
	var oLive = oHttpd2.GetLive( cId )

	var oPar 				= new Object()
		oPar[ 'dlg' ] 		= cId
		oPar[ 'api' ] 		= cApi
		oPar[ 'proc' ] 		= cProc 
		oPar[ 'controls' ] 	= null
		
		
	if ( $.type( oNewPar ) == 'object' ) {

		for (const key in oNewPar) {

			if (oNewPar.hasOwnProperty(key)) {
			
				oLive[  cId + '-' + key ] = { 'type' : 'param', 'value' : oNewPar[ key ] } ;				
			}
		}				
	}
	
	oPar[ 'controls' ] 	= JSON.stringify( oLive )
	

	
	if ( typeof lAsyncro == 'boolean' && lAsyncro ){ 

		var oMyOptions = new Object()
			oMyOptions[ 'async' ] = true 
			
		UShoot( 'api', oPar, null, null, oMyOptions )
	} else {
		UShoot( 'api', oPar )
	}
}

//	Ajax to Api --------------------------------------------

function UShoot( url, oPar, lFileUpload, fCallback, oMyOptions ) {

	lFileUpload = (typeof lFileUpload ) == 'boolean' ? lFileUpload : false ;	
	lAsyncro 	= (typeof lAsyncro ) == 'boolean' ? lAsyncro : false ;	


	//	console.log( window.location.origin ) --> ex. http://localhost/81 
	
	var cUrl = window.location.origin + '/' + url
	
	//$('#error').html( '' )

	//console.log( 'UShoot oPar', oPar )
				/*
					xhrFields: {
					  withCredentials: true
				   }
				  */
				  
	//	Valid parameters

		if ( lFileUpload ) {
	
	
		} else {
		
			if ( ! oPar.api  || oPar.api === '' ) {
				UMsgError( "<b>Error: </b> html => data-api tag don't defined", 'Programming' )
				return null
			}		
		}
		
	//	Check if WS exist (Prototipe Beta) 

		if (typeof _USocket !== 'undefined') {
		
			if ( $.type( _USocket ) == 'object' ) {
				oPar[ '_socket' ] = _USocket_Client
			}
		}
	
	// -------------------------------------------------
		
		
		
	var oOptions = {
					type: "POST",
					url: cUrl, //url,
					data: oPar,	
					cache: false,
					async: false, 
					beforeSend: function() {} 
				}
				
				
	if ( $.type(oMyOptions) == 'object' )	{
	
		for (const key in oMyOptions ) {		
			oOptions[ key ] = oMyOptions[ key]			
		}		
	}	


	if ( lFileUpload ) {
	
		oOptions[ 'processData' ] = false			
		oOptions[ 'contentType' ] = false
		
		/*
		//oOptions[ 'contentType' ] = 'multipart/form-data' 	//	false
		
		// This will override the content type header, 
		// regardless of whether content is actually sent.
		// Defaults to 'application/x-www-form-urlencoded'

		//oOptions[ 'beforeSend' ] = function(xhr) { 
		//	xhr.setRequestHeader('Content-Type', 'multipart/form-data');
		//}		
		*/
	}
	


	var oSend = $.ajax( oOptions )
		.fail( function(data, u ){ 
			switch ( data.readyState ) {
				case 4:
					//UMsgError( '<b>Route:</b> ' + oPar['api'] +'/' + oPar['proc']+ '<hr><br>' + data.responseText, 'Error' )
					UMsgError( '<b>Route:</b> ' + url + '<hr><br>' + data.responseText, 'Error' )
					break;
				case 0:
					UMsgError( '<b>Network error !</b>', 'Error' )
					break;
				
			}					
		})
		
		
		
	if ( typeof fCallback == "function") {	
	
		oSend.done( function( data ) { 	
			return fCallback.apply(null, [ data ] );	
		})	
	
	} else {
				

		oSend.done( function( data ) { 
		

				var o = new UDom()			
				
				//	Siempre recibiremos del server un hash
				//	Si es un string es que que cascado...			
				
				if (  $.type( data ) == 'string' ) {
				
					if ( data.length == 0 )
						return null 
				
					//	We can show error or msgerror or another trace system...
					//	At the moment whe can show...				
				
					//$('#error').html( data )				
					//return false 	
					
					try {
						data = jQuery.parseJSON( data )			
						
					} catch (e) {	
					
						if ( data ) {
							data.replace(/(\n)+/g, '<br />'); 
							UMsgError( data, 'System Error' )
						}
					}
				} 


		
				if ( data.trace ) { console.info( 'TRACE', data ) }
				if ( data.console ) { 
				
					for (i = 0; i < data.console.length; i++) {						
					
						if ( data.console[i][1] )
							console.info( data.console[i][1], data.console[i][0] ) 
						else
							console.info( data.console[i][0] ) 
							
					}
				}
				
				if ( data.confirm ) {	
				
					if ( ! confirm( data.confirm ) )
						return null													
				}
				
				
				if ( data.redirect ) {	
				
					switch ( data.redirect.type ) {
					
						case 'dialog':
							//UScreen( data.redirect.proc, 'dialog' )	
							UScreen( 'splash', 'dialog' )	
						
							break;
							
						case 'url':
					
							location.replace( data.redirect.proc );
					
							break;
					}
						
					return null				
				} 			
				
				if ( data.url ) {

					if ( data.url.target == '_self' ) 
						window.location.replace(  data.url.url )
					else 
						window.open( data.url.url, data.url.target, data.url.specs );
						
					return null				
				}

				if ( data.screen ) {
					
					//UScreen( 'client', '_dialog' )
					//UScreen( 'brw1', '_container', 'panel' )
					//UScreen( 'brw1', '_window' )
					
					if (typeof data.screen.proc == 'string' )				
						UScreen( data.screen.proc, data.screen.target, data.screen.id , data.screen.cargo )
					else {
						if ( data.screen.target == '_container' )  {					
							$('#' + data.screen.id ).html( data.screen.cargo )										
						}										
					}
				}
				
				if ( data.window ) {

					if ( data.window.url ) {											
						window.open( data.window.url, data.window.target, data.window.specs );
					}
						
					return null				
				}	
				
				if ( data.panel ) {

					if ( data.panel.id ) {											
						$('#' + data.panel.id ).html( data.panel.html )	
					}
						
					return null				
				}	
				
				if ( data.setter ) {

					for (i = 0; i < data.setter.length; i++) {
					
						id = data.setter[i]['id']						
						value = data.setter[i]['value']						
						cargo = data.setter[i]['cargo']
						
						o.Set( id, value, cargo )
					}								
				}
				
				if ( data.active ) {

					for (i = 0; i < data.active.length; i++) {
					
						id = data.active[i]['id']						
						value = data.active[i]['value']												
						
						o.Active( id, value )
					}								
				}	
				
				if ( data.table ) {	
		
				
					for (i = 0; i < data.table.length; i++) {																			
						
						id 			= data.table[i]['id']						
						action 		= data.table[i]['action']												
						value 		= data.table[i]['value']	
						msgconfirm 	= data.table[i]['msgconfirm']	
	
						var oTable = new UTabulator( id )								

						if ( typeof msgconfirm == 'string' ) {
						
							MsgYesNo( msgconfirm, function() {					
							
								if ( action == 'init' )
									oTable.Init( value.options, value.events, value.filter, value.cargo )
								else
									oTable.Proc( action, value )								
							})							
								
						} else {
						
							if ( action == 'init' )
								oTable.Init( value.options, value.events, value.filter, value.cargo )
							else
								oTable.Proc( action, value )																		
						}

					}						
				}								
				
				if ( data.class ) {

					for (i = 0; i < data.class.length; i++) {
					
						id = data.class[i]['id']						
						value = data.class[i]['class']	
						action = data.class[i]['action']

						o.Class( id, value, action )
					}								
				}

				if ( data.visibility ) {

					for (i = 0; i < data.visibility.length; i++) {
					
						id = data.visibility[i]['id']												
						action = data.visibility[i]['action']	
						
						o.Visibility( id, action )					
					}								
				}				


				
				if ( data.js ) {

					//	We receive the order to execute a Javascript function...
				
					var fn =  window[ data.js[ 'func' ] ]
					
					if ( typeof fn == "function") {																			
					
						//return fn.apply(null, [ data.js[ 'data' ] ] );										
						fn.apply(null, [ data.js[ 'data' ] ] );										
					} else {
						try {
					
							eval( data.js[ 'func' ] )
						} catch(err) {							
							console.error( 'UHttpd2: ' + err.message )
						}
					}							
				}
				
				
				//if ( data.msg ) {
					//UMsg( cHtml, cTitle, id, cargo  )					
				//}
				
				if ( data.error ) {	
					UMsgError( data.error, data.title )
				}

				if (data.dialog) {
							
					//UDialog( data.dialog.id, data.dialog.html, data.dialog.title )			
					UMsg( data.dialog.html, data.dialog.title, data.dialog.id, data.dialog.cargo )			
				}
		
				if ( data.alert) {						
					alert( data.alert )
				}

				
				
				if ( data.resetfiles ) {
					$('#' + data.resetfiles ).val( null )
				}
				
				if ( data.dialogclose ) {	

					if ( IsTWeb() ) {											

						if ( IsBootbox() ) {															
							
							if ( data.dialogclose.id in _dialogs ) {								
								
								var oDlg = _dialogs[ data.dialogclose.id ]
								
								oDlg.on('hidden.bs.modal', function () {								
									delete _dialogs[ data.dialogclose.id ];								
								})																								
								
								oDlg.modal( 'hide' )																															
							}
						}
						
					} else {

						//	Our dialog will be inside a jquery dialog. We should check if the parent of our 
						//	dialog has a jquery dialog control class -> ui-dialog-content
					
						id_dlg = $('#' + data.dialogclose ).parent().attr('id');			
					
						if ( $('#' + id_dlg).hasClass( 'ui-dialog-content' ) == true ) {					
							$('#'+id_dlg).dialog('close');
							$('#'+id_dlg).dialog('destroy').remove();
						}	
					}
				}

				if ( data.focus ) {	
					o.Focus( data.focus )
				}

				if ( data.msgapi ) {														
					MsgApi( data.msgapi[ 'api' ], data.msgapi[ 'proc' ], data.msgapi[ 'param' ], data.msgapi[ 'idform' ], true )
				}				

				
			})						
	

	}
}


//	Ajax to Screen --------------------------------------------

function UScreenClean( cName ) {
	$('#' + cName).html( '' )
}

function UScreen( cName, cType, cId, cargo ) {

	cType 		= (typeof cType ) == 'string' ? cType : 'container' ;
	cId 		= (typeof cId ) == 'string' && cId.length > 0 ? cId : cName ;
	cargo		= (typeof cargo ) == 'string' ? cargo : '' ;
	
	
	$('#error').html( '' )
	
	var oPar = new Object()
		oPar[ 'dlg' 	] = cId
		oPar[ 'type' 	] = cType
		//oPar[ 'cargo' 	] = cargo


	
	$.post( cName, oPar  )		
		.done( function( data ) { 	

			if ( data.success == false ){
			
				if ( data.redirect ) {				
					UScreen( data.redirect.proc, data.redirect.type  )									
				} else { 				
					//alert( data.msg )
					UDialog( 'sys', data.msg, 'System Error' )					
				}
				
				return null
			}
			
			
			switch ( cType ){
			
				case '_container':									
					
					if ( $('#' + cId).length == 0 ) {
						var elem = document.createElement('div');
						elem.id 	= cId ;	
						document.body.appendChild(elem);						
					}
				
				
					$('#' + cId ).html( data.html )
					break;
					
				case '_dialog':
			
					if ( $('#' + cId).length > 0 ) {
						
						return null					
					}
				
			
					var cId_Dlg = '_dlg_' + cId 				

					if ( $('#' + cId_Dlg).length == 0 ) {
						var dlg_elem = document.createElement('div');					
						dlg_elem.id 	= cId_Dlg ;	
						document.body.appendChild(dlg_elem);						

					} else {
						
						return null
					}					
					
					if ( cargo.length == 0 )
						cargo = 'Dialog'
					
				
					$( '#' + cId_Dlg  )
						.addClass("TDlg_body")
						.html( data.html )
						.dialog({
							width: 'auto',
							height: 'auto',
							resizable:false,
							title: cargo,
							dialogClass: "TDlg",
							close: function () {
								$(this).dialog ('destroy').remove ();
							}
						});				
				
			
					
					break;
					
				case '_window':
				
				console.log( '_window', cName )
					window.open( cName, 'MyWind', cId );
				
					break;
			}
					
			
		})
		.fail( function(data, u ){ 
			console.log( 'Error', data )
			
			switch ( data.readyState ) {
				case 4:
					UMsgError( '<b>Route:</b> ' + cName + '<hr><br>' + data.responseText, 'Error' )
					break;
				case 0:
					UMsgError( '<b>Network error !</b>', 'Error' )
					break;
				
			}
		})

}

function UMsg( cHtml, cTitle, id, cargo  ) { 
	
	if ( IsBootstrap() ) {

		if ( IsBootbox() ) {
			UBootbox( cHtml, cTitle, id, cargo )
		} else {
			UModal( cHtml, cTitle, 'info' )
		}
		
	} else {
		UDialog( '_msg_', cHtml, cTitle, 'TDlg_Msg', 'info' ) 
	}
}

function UMsgError( cHtml, cTitle ) {

	if ( IsBootstrap() )
		UModal( cHtml, cTitle, 'error' )
	else
		UDialog( '_msg_', cHtml, cTitle, 'TDlg_Msg', 'error' ) 				
}

//	------------------------------------------------------------

function UDialog( cId, cHtml, cTitle, cClass, cType ) {

	cId	= (typeof cId ) == 'string' ? cId : '_msg_' ;
	cTitle	= (typeof cTitle ) == 'string' ? cTitle : '' ;		
	cClass	= (typeof cClass ) == 'string' ? cClass : 'TDlg_Msg' ;		

	if ( $('#' + cId).length == 0 ) {
		var dlg_elem = document.createElement('div');					
		dlg_elem.id 	= cId ;	
		document.body.appendChild(dlg_elem);	
	} else {
		console.warn( 'Dialog exist id => ' + cId )
		return null
	}

	switch ( cType ) {
	
		case 'info': 	cTitle = ( cTitle === '' ) ? 'Information' : cTitle ; break;
		case 'error': 	cTitle = ( cTitle === '' ) ? 'Error System': cTitle ; break;
		default:
			cTitle = ( cTitle === '' ) ? 'Information' : cTitle ; 
	}
	
    var wWidth = $(window).width();
    var dWidth = wWidth * 0.8;		
    var wHeight = $(window).height();
    var dHeight = wHeight * 0.8;
	
//		.addClass("TDlg_Msg")

	switch ( cType ) {	
		case 'info'  : MsgSound( 'files/uhttpd2/sound/msg.mp3' 		 ); break;
		case 'error' : MsgSound( 'files/uhttpd2/sound/msg_error.mp3' ); break;
		default:
			MsgSound( 'files/uhttpd2/sound/msg.mp3' )
	}


	var oWnd = $( '#' + cId  )
		.html( cHtml )
		.dialog({
			width: 'auto',
			height: 'auto',
			maxWidth: dWidth,
			maxHeight: dHeight,
			minHeight: 'auto',
			title: cTitle,
			modal: true,
			resizable: false,
			dialogClass: cClass, 	//	"TDlg_Msg"	
			open: function(){
			},
			close: function () {
				$(this).dialog('destroy').remove();
			}			
		})
		

		
	return null
}

//	------------------------------------------------------------
//	UModal is for bootstrap framework...

function UModal( cHtml, cTitle, cType ) {


	cTitle	= (typeof cTitle ) == 'string' ? cTitle : '' ;	
	
	switch ( cType ) {
	
		case 'info': 	cTitle = ( cTitle === '' ) ? 'Information' : cTitle ; break;
		case 'error': 	cTitle = ( cTitle === '' ) ? 'Error System': cTitle ; break;
		default:
			cTitle = ( cTitle === '' ) ? 'Information' : cTitle ; 
	}	
	
	var cDialog = '<div class="modal fade">' +
				  '  <div class="modal-dialog">' +
				  '    <div class="modal-content">' 
				  
	if ( cTitle.length > 0 ) {
	
		cDialog +=  '      <div class="modal-header">' +
					'        <h4 class="modal-title">' + cTitle + '</h4>' +
					'        <button type="button" class="close" data-dismiss="modal">&times;</button>' +
					'      </div>' 
	}
	
	cDialog +=  '      <div class="modal-body" >' + cHtml + '</body>'
	
	
	
	/*
				  '      <div class="modal-footer">' +
				  '        <button type="button" class="btn btn-primary" data-dismiss="modal">Save</button>' +
				  '        <button type="button" class="btn btn-link" data-dismiss="modal">Cancel</button>' +
				  '      </div>' +
	*/
				  
	cDialog += 	  '    </div>' +
				  '  </div>' +
				  '</div>';

    
	$(cDialog).modal()	

}

//	----------------------------------------------------

var _dialogs = new Object();
var _dialogsId = 0;


function UBootbox( cHtml, cTitle, cId, oOption ) {

	cId = ( typeof cId == 'string' ) ?  cId : ( 'id-' + (++_dialogsId) ) ;
	
//		title: cIcon + '&nbsp;' + cTitle,
//		size: 'medium',

	var oConfig = new Object()
		oConfig[ 'size'] = ''
		oConfig[ 'backdrop'] = false 
		oConfig[ 'onEscape'] = true 
		oConfig[ 'draggable'] = true 
		// oConfig[ 'className'] = 'my-custom-class bounce animated'		// https://codepen.io/ghimawan/pen/vXYYOz		
		oConfig[ 'className'] = 'animated fadeIn'
		//oConfig[ 'animated_in'] = 'zoomIn'
		//oConfig[ 'animated_out'] = 'fadeOut'
		
	if ( $.type(oOption) == 'object' )	{
	
		for (const key in oOption ) {		
			oConfig[ key ] = oOption[ key]			
		}		
	}
	
	if ( typeof cTitle == 'string' )
		oConfig[ 'title'] = cTitle
			
	oConfig[ 'message'] = cHtml 
	
		var dialog = bootbox.dialog( oConfig )	
		

	//	Draggable system -----------------------------------

		dialog.bind('shown.bs.modal', function(){			

		
			var o = dialog.find('.modal-dialog')
		
			o.attr("id", cId )

			if ( oConfig[ 'draggable'] )
				dialog.find(".modal-content").draggable()
			
			//	No xuta...
			if ( 'focus' in oConfig ) {
				$("#" + oConfig[ 'focus' ]  ).focus();				
			}	

			//	There cannot be a duplicate id
			
			var ids = $('[id="' + cId + '"]');

			if ( ids.length > 1 ){
				console.warn( "Warning!, Dialog Form id duplicated => " + cId )
				UMsgError( '<b>Dialog Form ID duplicated: </b>' + cId, '<h3>System Error</h3>' )
				return null;
			}
			
		});		
		
	//	----------------------------------------------------
	

	
	/*
		var anim = oConfig[ 'animated_in' ] 		
		
		$(".modal .modal-dialog").attr("class", "modal-dialog " + anim + " animated");		
		
		dialog.on('hide.bs.modal', function (e) {
			var anim = oConfig[ 'animated_out' ] 										
			$(".modal .modal-dialog").attr("class", "modal-dialog " + anim + " animated");					
			
		});		
	*/
	
	if ( oConfig[ 'size' ].length > 0 ) {
		$(".modal").find(".modal-dialog").css( 'width', oConfig[ 'size' ] );
		$(".modal").find(".modal-dialog").css( 'max-width', 'none' );
	}
	
	_dialogs[ cId ] = dialog
	
}

//	----------------------------------------------------
var _IsTWeb = false

function SetTWeb() { _IsTWeb = true; }

function IsTWeb() { return _IsTWeb }

function IsBootstrap() {
	return ( typeof $().modal == 'function' )
}

function IsBootbox() {
	
	lLoaded = ( bootbox ) ? true : false; 
	return lLoaded
}

//	UDom management system... ----------------------------------------------------

function UDom() {

	this.Set = function( id, value, cargo ) {
	
		var type = UdomType( id )

		switch (type) {
		
			case 'hidden' :
			case 'month' :
			case 'color' :
			case 'password' :
			case 'time' :
			case 'email' :
			case 'tel' :
			case 'url' :
			case 'search' :
			case 'range' :
			case 'datetime-local' :
			case 'week' :			
			case 'number' :
			case 'date' :
			case 'textarea' :
			case 'text' :
			
				$('#'+id ).val( value )	
				break;
				
			case 'checkbox' :
			
				$('#'+id ).prop('checked', value );
				break;	
				
			case 'radio':

				if ( value != '' ) {
					$('input[name=' + id + '][ value="' + value + '"]' ).prop("checked", true);											
				} else  {								
					$('input[name=' + id + ']').prop("checked", false);												    
				}
					
				break;					

				
			case 'select-one' :
		
				if ( $.type( value ) == 'object' || $.type( value ) == 'array') {

					var type = $.type( value )
					
					$('#'+id ).empty()
					
					$.each(value, function(key, value) {					
					
						if ( type == 'object' ) {

							$('#'+id ).append($('<option>', { 
								value: key,
								text : value
							}));
						} else {
				
							$('#'+id ).append($('<option>', { 
								value: value,
								text : value
							}));
						}						
					});														
				
				} else {
					$('#'+id ).val( value )	
				}
				
				break;	

			case 'img' :							

				$('#'+id ).attr("src", value );
				$('#'+id ).parent().attr("href", value );
				
				break;
				
			case 'div' :							
			case 'span' :							
			
				$('#'+id ).html( value );
				
				break;	

			case 'progressbar' :													
			
				$('#'+id ).css({"width": value + '%' })
				
				if ( $('#'+id ).data( 'percentage' ) == 'yes' )
					$('#'+id ).html( value + '%' );
			
				if ( typeof cargo == 'string' )
					$('#'+id+'_label' ).html( cargo );
				
				
				break;
				
			default:		

				$('#'+id ).html( value )			
		}	
	}
	
	/*	
	
		if (!a.trim()) {
			// is empty or whitespace
		}	
	*/
	
	this.Get = function( id ) {	


		if ( typeof id == 'undefined' )
			return ''
		
			
		if ( id.length == 0 )
			return ''

		var value = ''
		
		
		
		
		
		

		var type = UdomType( id )


		switch (type) {
		
			case 'hidden' :
			case 'button' :
			case 'month' :
			case 'color' :
			case 'password' :
			case 'time' :
			case 'email' :
			case 'tel' :
			case 'url' :
			case 'search' :
			case 'range' :
			case 'datetime-local' :
			case 'week' :
			case 'number' :
			case 'date' :
			case 'textarea' :
			case 'text' :
			
				value = $('#'+id).val() 
				break;
				
			case 'checkbox' :
			
				value = $('#'+id).is(':checked')
				break;
				
				case 'select-one' :
			
				value = $('#'+id).val()
				break;	

			case 'radio' :
			
				value = $( 'input[name=' + id + ']:checked' ).val();		

				if ( typeof value === 'undefined' )
					value = 0;	
					
				break;	

			case 'img' :						
			
				value = $('#'+id ).attr("src" );							
				break;	
				
			case 'span' :						
			
				value = $('#'+id ).html();
					
				break;

			case 'file':

				var oFile 
				var F = $('#' + id )[0].files
				
					var aFiles = []
				
					for ( i=0; i < F.length; i++ ) {
						
						oFile = new Object()
							oFile[ 'name' ] = F[i].name
							oFile[ 'size' ] = F[i].size
							oFile[ 'type' ] = F[i].type
						
						aFiles.push( oFile )
					}		
				
				value = JSON.stringify( aFiles )				
				
				break;	
		
			
			default:
			
				var cClass = $('#'+id ).attr('class');	
		

				if ( typeof cClass == 'string' ) {									
				
					if ( cClass.indexOf("TGrid") >= 0 ) { 	//	OLD VERSION
					
						alert( 'Old version. Not working' )
						
								value[ 'selected' ] = {}													
								value[ 'updated' ] = {}											
								value[ 'data' ] = {}
							
								return value								

					} else if ( cClass.indexOf("tabulator") >= 0 ) {	

						var cAll = $('#'+id ).data( 'all' )
				
						if ( typeof cAll == 'string' )
							cAll = 'SUA'	
						else
							cAll = 'SU'	

						value = new Object()						
					
						var oTable = new UTabulator( id )
						
						//	Check if initialized...

							if ( typeof oTable.table == 'undefined' ) {
								value[ 'selected' ] = {}													
								value[ 'updated' ] = {}											
								value[ 'data' ] = {}
							
								return value
							}

						//	-------------------------d) 								
				
						if ( cAll.indexOf("S") >= 0 )  	//	[S]elect
							value[ 'selected' ] = oTable.Proc( 'getSelectedData' ) 
							
						if ( cAll.indexOf("U") >= 0 )	//	[U]pdate 
							value[ 'updated' ] = oTable.Proc( 'getDataChanged' ) 													
						
						if ( cAll.indexOf("A") >= 0 )  	//	[A]ll Rows
							value[ 'data' ] = oTable.Proc( 'getData' ) 													
					}				
					
				} else {
				
					value = $('#'+id ).html()							
				}								
		}
		
		return value
	}
	
	//	INTERESANT. Recuperar Valors 
	//	http://jsfiddle.net/PKB9j/1/ 
	//	https://stackoverflow.com/questions/9579721/convert-html-table-to-array-in-javascript
	
	this.Array2TBody = function( value ) {
	
		var cRows = ''
		
		if ( value.length > 0 ) {
		
			for ( i = 0; i < value.length; i++) {
			
				cRows += '<tr>'
				
				for ( j = 0; j < value[i].length; j++) {
				
					cRows += '<td>'
					
					cType = typeof value[i][j]
					
					
					
					switch ( cType ) {
					
						case 'boolean':
							cRows += '<input type="checkbox" id="vehicle1" name="vehicle1" value="">'
							break;
							
						default:
						
							cRows += value[i][j].toString()											
					}
					
					cRows += '</td>'
				}
				
				cRows += '</tr>'					
			}								
		}	
	
		return cRows
	}
	
	this.Active = function( id, value ) {

		var type = UdomType( id )
		//console.log( 'type ' + id + ' tipus:' + type, value )	
		
		switch (type) {
		
			case 'hidden' :
			case 'month' :
			case 'color' :
			case 'password' :
			case 'time' :
			case 'email' :
			case 'tel' :
			case 'url' :
			case 'search' :
			case 'range' :
			case 'datetime-local' :
			case 'week' :
			case 'number' :
			case 'date' :
			case 'textarea' :
			case 'text' :					
		
				$('#'+id ).prop( "disabled", ! value  );
				break;
				
			case 'checkbox' :		
				
				$('#'+id ).prop('disabled', ! value );
				
				break;		
				
			case 'textarea' :		
				
				$('#'+id ).prop('disabled', ! value );
				
				break;				

			case 'submit' :		
			case 'button' :		
				
				$('#'+id ).prop('disabled', ! value );
				
				break;

			case 'radio' :		
				$('input:radio[name=' + id + ']').prop( 'disabled', ! value ); 			
				break;
				
			case 'select-one' :		
				
				$('#'+id ).prop('disabled', ! value );
				
				break;				
				
			default:
				

				$('#'+id ).html( ! value )			
		}	
	}
	
	this.Class = function( id, value, action ) {
					
		switch (action){
		
			case 'toggle':
				$('#'+id).toggleClass( value );							
				break;
			case 'on':
				$('#'+id).addClass( value );							
				break;
			case 'off':
				$('#'+id).removeClass( value );							
				break;																									
		}	
	}
	
	this.Visibility = function( id, value ) {
	
		var type = UdomType( id )
		
		//console.log( 'type ' + id + ' ' + type, value )		
	
		switch (value){
	
			case 'toggle':
				$('#'+id).toggle();							
				break;
				
			case 'on':
			
				//if ( IsBootstrap() )  {
				if ( IsTWeb() )  {

					switch (type) {
					
						case 'hidden' :
						case 'month' :
						case 'color' :
						case 'password' :
						case 'time' :
						case 'email' :
						case 'tel' :
						case 'url' :
						case 'search' :
						case 'range' :
						case 'datetime-local' :
						case 'week' :
						case 'number' :
						case 'date' :
						case 'textarea' :
						case 'text' :
						case 'checkbox':
					
							var o = $('[data-group="' + id + '"]')
							if ( o.length == 1 ){
									$(o[0]).show()
							}
							break;

						case 'radio':
			
							var o = $('input:radio[name=' + id + ']')
							
							if ( o.length > 0 ) {
								o = $(o[0]).parents('[data-control]' )
							
								if ( o.length == 1 ){
									$(o[0]).show()
								}
							}	
							
							break;
							
						case 'select-one':												
						
							var o = $('[data-group="' + id + '"]')
						
								
							if ( o.length == 1 ){
								$(o[0]).show()
							}
							
							break;
							
						default: 
							$('#'+id).show();
					}		
					
				} else { 
					$('#'+id).show();
				}
				
				break;
				
			case 'off':
			
				//if ( IsBootstrap() ) {
				if ( IsTWeb() ) {
				
					switch (type) {
					
						case 'hidden' :
						case 'month' :
						case 'color' :
						case 'password' :
						case 'time' :
						case 'email' :
						case 'tel' :
						case 'url' :
						case 'search' :
						case 'range' :
						case 'datetime-local' :
						case 'week' :
						case 'number' :
						case 'date' :
						case 'textarea' :
						case 'text' :
						case 'checkbox':					
							
							var o = $('[data-group="' + id + '"]')
							if ( o.length == 1 ){
									$(o[0]).hide()
							}
							break;
							
						case  'radio':
			
							var o = $('input:radio[name=' + id + ']')
							
							if ( o.length > 0 ) {
								o = $(o[0]).parents('[data-control]' )
						
								if ( o.length == 1 ){
									$(o[0]).hide()
								}
							}	
							break;
							
						case 'select-one':	
						
							var o = $('[data-group="' + id + '"]')										
						
							if ( o.length == 1 ){
								$(o[0]).hide()
							}

							break;

						default:
							$('#'+id).hide();	
					}
					
				} else { 
					$('#'+id).hide();	
				}
				break;																									
		}
	}
	
	this.Focus = function( id ) {
		$('#'+id).focus() 
		$('#'+id).select() 
	}
	
}


//	----------------------------------------------------

function MsgSound( cFile ) {

	var audioElement = document.createElement('audio');
	audioElement.setAttribute('src', cFile );
	audioElement.setAttribute('autoplay', 'autoplay');
}

//	----------------------------------------------------

function UdomType( cId ) {

	var type =  $('#'+cId ).prop('type')	

	if (  type == null ) {		
	
		if ( $('input:radio[name=' + cId + ']').prop('type') == 'radio' )  {
	
			type = 'radio'
			
		} else if (  $('#'+cId ).is( "div" ) ) {
	
			var cRole = $('#'+cId ).attr( 'role')
			
			switch ( cRole ) {
				case 'progressbar':
					type = 'progressbar'
					
					break;
				default:
					type = 'div'
			}	
	
		} else if (  $('#'+cId ).is( "img" ) ) {
	
			type = 'img'
	
		} else if (  $('#'+cId ).is( "span" ) ) {
	
			type = 'span'
	
		}						
	}

	return type 
}


//	WEBSOCKETS --------------------------------------------------------------- //

/*	-------------------------- */
/*	USocket engine for UHttpd2 */
/*	-------------------------- */
/*	Beta prototype 			   */
/*	-------------------------- */

var _USocket 		= null 
var _USocket_Client = ''
var _UWS_Cfg		= null

function UWS_Define( cCfg ){
	
	try {
		_UWS_Cfg = jQuery.parseJSON( cCfg )		
		//if ( _UWS_Cfg[ 'console' ] )
			console.log( 'WS >> Initaliting...'  )
	}  catch(err) {	
		_UWS_Cfg = null
		if ( _UWS_Cfg[ 'console' ] )
			console.error( '>> WS Error config', err.message )
	}	
	
	//_UWS_Cfg[ 'uri' ] = '188.84.11.11:9443?m=basic&t=ABC-1234'
	//_UWS_Cfg[ 'uri' ] = 'wss://188.84.11.11:9443?m=basic&t=ABC-1234'	
	//console.log( _UWS_Cfg )
}

function UWS_Init() {


	if( _USocket )
		return null					
	
	if ( ! _UWS_Cfg )
		return null		

	_USocket = new WebSocket( _UWS_Cfg[ 'uri' ] );			
	
	_USocket.onopen = function( e ) {				
		
		//if ( _UWS_Cfg[ 'console' ] )
			console.log( 'WS >> Connected' )		
		
		var oPar = new Object()
		
		oPar[ 'msg' ] = 'UT Websocket Server'
		oPar[ 'scope' ] = _UWS_Cfg[ 'scope' ] 
		oPar[ 'token' ] = _UWS_Cfg[ 'token' ] 		
		
		var cPar = JSON.stringify( oPar )

		UWS_Send( cPar )	
	
		if ( typeof _UWS_Cfg[ 'onopen' ] == 'string' ) {

			try { 
				var fn =  window[ _UWS_Cfg[ 'onopen' ] ];
				
				if ( typeof fn == "function") {				
					fn.apply(null, [ e ] );
				}	
			}  catch(err) {	
				if ( _UWS_Cfg[ 'console' ] )
					console.error( 'WS error onopen >> ' + err.message )
			}		
		} 			
	};

	_USocket.onmessage = function( event ) {							
		
		try {

			data = jQuery.parseJSON( event.data )																
		
			switch ( data[ 'type' ] ) {
				case 'msg' : 
				
					if ( _UWS_Cfg[ 'console' ] )
						console.log( 'msg', data[ 'value' ])

					if ( typeof _UWS_Cfg[ 'onmessage' ] == 'string' ) {
				
						try { 
							var fn =  window[ _UWS_Cfg[ 'onmessage' ] ];
							
							if ( typeof fn == "function") {				
								fn.apply(null, [ data[ 'value' ] ] );
							}	
						}  catch(err) {							
							if ( _UWS_Cfg[ 'console' ] )
								console.error( '>> WS error onmessage >> ' + err.message )
						}		
					}												
				
					break;
				case 'js' : UWS_JS( data ); break;					
				case 'notify' : MsgNotify( data[ 'value' ] ); break;				
				case 'console' : console.log( data[ 'value' ] ); break;				
				case 'error_hb': 									
					
					var hError = jQuery.parseJSON( data[ 'value'] )	
					//if ( _UWS_Cfg[ 'console' ] )
						console.error( 'Harbour Error', hError )					
					break;
				case 'error': 									
					
					//if ( _UWS_Cfg[ 'console' ] )
						console.error( data[ 'value'] )					
						
					break;					
				
				case 'uws_token': 					
					_USocket_Client = data[ 'value' ];
					
					//if ( _UWS_Cfg[ 'console' ] )
						console.log( 'WS >> Ready !' )
						
					break; 
					
				default:
					//console.log( 'DEFAULT', data )
					
					if ( typeof _UWS_Cfg[ 'onmessage' ] == 'string' ) {
				
						try { 
							var fn =  window[ _UWS_Cfg[ 'onmessage' ] ];
							
							if ( typeof fn == "function") {				
								fn.apply(null, [ data ] );
							}	
						}  catch(err) {							
							console.error( '>> WS error onmessage >> ' + err.message )
						}		
					} 													
					
					break;									
			}			


			
		} catch (e) {	

			if ( typeof _UWS_Cfg[ 'onmessage' ] == 'string' ) {
		
				try { 
					var fn =  window[ _UWS_Cfg[ 'onmessage' ] ];
					
					if ( typeof fn == "function") {				
						fn.apply(null, [ event.data ] );
					}	
				}  catch(err) {							
					if ( _UWS_Cfg[ 'console' ] )
						console.error( '>> WS error onmessage >> ' + err.message )
				}		
			} 													

		}																												
	};

	_USocket.onclose = function( event ) {																												
		//if ( _UWS_Cfg[ 'console' ] )
			console.log( 'WS >> Connection closed...' )
	
		_USocket 		= null;
		_USocket_Client 	= ''	

		if ( typeof _UWS_Cfg[ 'onclose' ] == 'string' ) {
	
			try { 
				var fn =  window[ _UWS_Cfg[ 'onclose' ] ];
				
				if ( typeof fn == "function") {				
					fn.apply(null, [ event ] );
				}	
			}  catch(err) {							
				if ( _UWS_Cfg[ 'console' ] )
					console.error( '>>WS error onclose >> ' + err.message )
			}		
		} 		
	};

	_USocket.onerror = function(error) {
	
		//if ( _UWS_Cfg[ 'console' ] )
			console.log( 'WS >> Error', error );
			console.log( 'uri', _UWS_Cfg[ 'uri' ] );
		
		if ( typeof _UWS_Cfg[ 'onerror' ] == 'string' ) {
	
			try { 
				var fn =  window[ _UWS_Cfg[ 'onerror' ] ];
				
				if ( typeof fn == "function") {				
					fn.apply(null, [ error ] );
				}	
			}  catch(err) {							
				if ( _UWS_Cfg[ 'console' ] )
					console.error( '>> WS error onerror >> ' + err.message )
			}		
		} 		

	};			
}

function UWS_JS( oData ) {

	var fn =  window[ oData[ 'function' ] ]	
	
	if ( typeof fn == "function") {	
		fn.apply(null, [ oData[ 'value' ] ] );
	} else {
		console.log( ">> WS Error: function doesn't exist: " + oData[ 'function' ] )
	}		
	
	return null 
}

function UWS_Send( cMsg ) {

	if ( typeof cMsg != 'string' )
		return null

	if( _USocket == null ) 
		UWS_Init();	  

	/*	WebSocket.readyState --> Check https://stackoverflow.com/questions/13546424/how-to-wait-for-a-websockets-readystate-to-change 
	
		0	CONNECTING	Socket has been created. The connection is not yet open.
		1	OPEN	The connection is open and ready to communicate.
		2	CLOSING	The connection is in the process of closing.
		3	CLOSED	The connection is closed or couldn't be opened.												
	*/
	
	if (_USocket.readyState === WebSocket.OPEN) {	

		_USocket.send( cMsg );
		
	} else {													

		if ( _USocket.readyState == WebSocket.CONNECTING) {							
			_USocket.addEventListener('open', () => UWS_Send( cMsg ))						
		}
	}
}

function UWS_Close() { 

	 if( ! _USocket )
		return null 

	_USocket.send( 'exit' );
}	

//	END WEBSOCKETS ---------------------------------------- //

//	----------------------------------------------------------

/*	Funcion para hacer un submit i pasar los parametros via post

	var data = { LAST: cLast, TEST: 1234 }
	
	URedirect( 'my_file.php', data )
	
*/	
function URedirect( cUrl, oValues, cMethod ){

	var cType 
	var $form = $("<form />");

	var oPar = UValuesToParam( oValues )

	cMethod		= ( typeof cMethod == 'string' ? cMethod : 'get' )
	
//cUrl = cUrl + '?a=Pacuuu&b=123'	

	$form.attr( 'action', cUrl );
	$form.attr( 'method', cMethod );

	$form.append('<input id="_value" type="text" name="value" value="12345" />');

	
	$('body').append($form); 

	$form.submit();
	$form.remove();
}

function UValuesToParam( oValues ) {
	
	var cType 	= $.type( oValues )
	var oPar 	= new Object()
		
	switch ( cType ) {
	
		case 'object':
			oPar[ 'type' ] = 'H'
			oPar[ 'value' ] = JSON.stringify( oValues ) 	
			break;
			
		case 'string':
				
			oPar[ 'type' ] = 'C'
			oPar[ 'value' ] = oValues	
			break;	
			
		case 'boolean':
				
			oPar[ 'type' ] = 'L'
			oPar[ 'value' ] = oValues	
			break;	

		case 'number':
				
			oPar[ 'type' ] = 'N'
			oPar[ 'value' ] = oValues	
			break;			
			
		default:
		
			oPar[ 'type' ] = 'U'
			oPar[ 'value' ] = oValues;				
	}

	return oPar 
}

//----------------------------------------------------------------------------//


function TWebIntro( cId, fFunction ) {

	$("#" + cId ).on('keyup', function (e) {
		if (e.key === 'Enter' || e.keyCode === 13) {
			if ( typeof fFunction === "function") {					
				fFunction.apply(null);
			}		
		}
	});
}

function TWebIntroGetBtn( cId, cId_Btn ){

	$("#" + cId ).on('keyup', function (e) {
		if (e.key === 'Enter' || e.keyCode === 13) {			 			 			 			 
			const button = document.getElementById( cId_Btn );        
			const eventoClick = new Event('click');        
			button.dispatchEvent(eventoClick);	
		}
	});
}
