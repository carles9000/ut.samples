#include 'lib/uhttpd2/uhttpd2.ch'
#include "../lib/tweb/tweb.ch"

#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY => ALWAYS

static sValue

FUNCTION api_refreshtest( odom )

   DO CASE
      CASE oDom:GetProc() == 'button-refresh' ; refreshdialog( oDom )
      CASE oDom:GetProc() == 'clickme'        ; DoButton( oDom )

      OTHERWISE
         oDom:SetError( "Proc don't defined => " + oDom:GetProc())
   ENDCASE

RETURN oDom:Send()

// --------------------------------------------------------- //

function DoButton( oDom )
   local cHtml
   local o := {=>}

   o[ 'backdrop' ] 	:= .f.		
   o[ 'onEscape' ] 	:= .f. 	
	
   sValue := time()

   cHtml := testrefresh()

   oDom:SetDialog( 'mydlg', cHtml, 'test', o )

return nil

func testrefresh()
   LOCAL o, oDlg

   DEFINE DIALOG oDlg

   DEFINE FORM o ID 'refreshtest'  API 'api_refreshtest' OF oDlg

   INIT FORM o

      ROWGROUP o
         SAY ID 'id-testvalue' VALUE sValue      GRID 6  ALIGN 'left' OF o
      ENDROW o

      ROWGROUP o
         GET ID 'my_time'  LABEL 'Time'  READONLY GRID 6 OF o
      ENDROW o

      ROWGROUP o
         BUTTON ID 'id-test'   LABEL 'Refresh'  ACTION 'button-refresh'  ALIGN 'left' WIDTH '100px' GRID 3 CLASS 'btn-primary' OF o
      ENDROW o

      // Botón de reconexión (inicialmente oculto)
      ROWGROUP o
         BUTTON ID 'reconnect-btn' LABEL 'Reconectar' ;
            ACTION 'reconnectServer()' ;
            ALIGN 'center' WIDTH '120px' GRID 12 ;
            CLASS 'btn-warning' STYLE 'display:none;' OF o
      ENDROW o



      // Indicador de estado de conexión
      ROWGROUP o
         SAY ID 'connection-status' VALUE '<span class="text-success">● Conectado</span>' ALIGN 'center' GRID 12 OF o
      ENDROW o

   ENDFORM o

   HTML o 
	<script>
		// Sistema de conexión usando AJAX puro
		var ConnectionManager = {
		    refreshInterval: null,
		    connectionLost: false,
		    consecutiveErrors: 0,
		    maxRetries: 3,
		    dialogId: 'refreshtest',
		    
		    init: function() {
		        console.log('ConnectionManager inicializado');
		        this.startAutoRefresh();
		    },
		    
		    startAutoRefresh: function() {
		        if (this.refreshInterval) {
		            clearInterval(this.refreshInterval);
		        }
		        
		        this.connectionLost = false;
		        this.consecutiveErrors = 0;
		        this.updateConnectionStatus('connected');
		        this.hideReconnectButton();
		        
		        var self = this;
		        this.refreshInterval = setInterval(function() {
		            if ($('#' + self.dialogId).length > 0 && !self.connectionLost) {
		                self.makeRefreshCall();
		            } else if ($('#' + self.dialogId).length === 0) {
		                console.log('Diálogo cerrado, deteniendo timer');
		                self.stopRefresh();
		            }
		        }, 5000);
		        
		        console.log('Auto-refresh iniciado cada 5 segundos');
		    },
		    
		    makeRefreshCall: function() {
		        var self = this;
		        
		        $.ajax({
		            url: 'refresh_timer',
		            type: 'POST',
		            timeout: 10000,
		            cache: false,
		            dataType: 'json',
		            success: function(response) {
		                self.handleJsonResponse(response, 'test_refresh');
		            },
		            error: function(xhr, status, error) {
		                self.handleError(xhr, status, error);
		            }
		        });
		    },
		    
		    handleJsonResponse: function(jsonResponse, action) {
		        try {
		            // defensa: si viene HTML de TWeb en lugar de JSON
		            if (jsonResponse && jsonResponse.html) {
		                console.warn('Respuesta de TWeb detectada (html en JSON), revisa URL.');
		                return;
		            }

		            console.log('Respuesta JSON recibida:', jsonResponse);
		            
		            if (jsonResponse.success) {
		                console.log('✓ ' + action + ': ' + jsonResponse.message);
		                
		                if (jsonResponse.time) {
		                    $('#' + this.dialogId + '-my_time').val(jsonResponse.time);
		                    console.log('Hora actualizada: ' + jsonResponse.time);
		                }
		                
		                this.consecutiveErrors = 0;
		                this.connectionLost = false;
		                this.updateConnectionStatus('connected');
		                
		            } else {
		                console.log('✗ Error en ' + action + ': ' + jsonResponse.message);
		            }
		            
		        } catch (error) {
		            console.log('Error procesando JSON:', error);
		            this.handleError(null, 'parse_error', error.message);
		        }
		    },
		    
		    handleError: function(xhr, status, error) {
		        this.consecutiveErrors++;
		        console.log('Error de conexión #' + this.consecutiveErrors + ':', {
		            status: status,
		            error: error,
		            httpStatus: xhr ? xhr.status : 'N/A'
		        });
		        
		        if (this.consecutiveErrors >= this.maxRetries) {
		            this.connectionLost = true;
		            this.stopRefresh();
		            this.updateConnectionStatus('disconnected');
		            this.showReconnectButton();
		            
		            if (typeof MsgInfo !== 'undefined') {
		                MsgInfo('Conexión perdida después de ' + this.maxRetries + ' intentos. Haz clic en "Reconectar" para reintentarlo.');
		            } else {
		                alert('Conexión perdida después de ' + this.maxRetries + ' intentos. Haz clic en "Reconectar" para reintentarlo.');
		            }
		        } else {
		            this.updateConnectionStatus('reconnecting', this.consecutiveErrors + '/' + this.maxRetries);
		        }
		    },
		    
		    stopRefresh: function() {
		        if (this.refreshInterval) {
		            clearInterval(this.refreshInterval);
		            this.refreshInterval = null;
		            console.log('Timer detenido');
		        }
		    },
		    
		    updateConnectionStatus: function(status, extra) {
		        var statusHtml = '';
		        switch(status) {
		            case 'connected':
		                statusHtml = '<span class="text-success">● Conectado</span>';
		                break;
		            case 'disconnected':
		                statusHtml = '<span class="text-danger">● Desconectado</span>';
		                break;
		            case 'reconnecting':
		                statusHtml = '<span class="text-warning">● Reconectando... (' + (extra || '') + ')</span>';
		                break;
		            case 'testing':
		                statusHtml = '<span class="text-info">● Probando conexión...</span>';
		                break;
		        }
		        
		        $('#' + this.dialogId + '-connection-status').html(statusHtml);
		    },
		    
		    showReconnectButton: function() {
		        $('#' + this.dialogId + '-reconnect-btn').show();
		    },
		    
		    hideReconnectButton: function() {
		        $('#' + this.dialogId + '-reconnect-btn').hide();
		    },
		    
		    reconnectServer: function() {
		        console.log('Iniciando reconexión...');
		        this.updateConnectionStatus('testing');
		        this.hideReconnectButton();
		        
		        var self = this;
		        
		        $.ajax({
		            url: 'ping_server',
		            type: 'POST',
		            timeout: 15000,
		            cache: false,
		            dataType: 'json',
		            success: function(response) {
		                self.handleJsonResponse(response, 'ping_connection');
		                
		                if (response.success) {
		                    console.log('Reconexión exitosa');
		                    
		                    if (typeof MsgInfo !== 'undefined') {
		                        MsgInfo('Conexión restablecida.');
		                    } else {
		                        alert('Conexión restablecida.');
		                    }
		                    
		                    self.startAutoRefresh();
		                }
		            },
		            error: function(xhr, status, error) {
		                console.log('Error en reconexión:', {
		                    status: status,
		                    error: error,
		                    httpStatus: xhr.status
		                });
		                
		                self.updateConnectionStatus('disconnected');
		                self.showReconnectButton();
		                
		                var errorMsg = 'No se pudo restablecer la conexión.';
		                if (xhr.status === 0) {
		                    errorMsg += ' Verifica que el servidor esté ejecutándose.';
		                } else if (xhr.status >= 500) {
		                    errorMsg += ' Error interno del servidor (Status: ' + xhr.status + ').';
		                } else if (xhr.status >= 400) {
		                    errorMsg += ' Error de solicitud (Status: ' + xhr.status + ').';
		                }
		                
		                if (typeof MsgInfo !== 'undefined') {
		                    MsgInfo(errorMsg);
		                } else {
		                    alert(errorMsg);
		                }
		            }
		        });
		    }
		};
		
		// Función global para el botón HTML
		window.reconnectServer = function() {
		    ConnectionManager.reconnectServer();
		};
		
		$(document).ready(function() {
		    console.log('Documento listo, inicializando ConnectionManager');
		    ConnectionManager.init();
		});
		
		window.buttonRefresh = function() {
		    ConnectionManager.makeRefreshCall();
		};
	</script>
	ENDTEXT
		
   INIT DIALOG oDlg RETURN

RETURN nil

FUNCTION refreshdialog( odom )
   sValue = time()
   oDom:Set( 'id-testvalue', svalue )
RETURN nil

// Función para el refresh automático (AJAX)
FUNCTION refresh_timer( oDom )
   LOCAL hResp := {=>}
   hResp['success'] := .T.
   hResp['message'] := 'Refresh automático ejecutado'
   hResp['time'] := time()
   hResp['debug_console'] := 'Backend: test_refresh JSON ejecutado a las: ' + time()
RETURN hb_jsonencode(hResp)

// Función para verificar conexión (AJAX)
FUNCTION ping_server( oDom )
   LOCAL hResp := {=>}
   hResp['success'] := .T.
   hResp['message'] := 'Ping de conexión exitoso'
   hResp['time'] := 'Reconectado: ' + time()
   hResp['debug_console'] := 'Backend: ping_connection JSON ejecutado a las: ' + time()
RETURN hb_jsonencode(hResp)