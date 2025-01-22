<!-- Template Splash -------------------------------

	Hash parameter:
	'file'	- Logo file
	'route' - Route when click logo
	'color' - Background color
-->


	<style>	
	
		body {
			background-color: #ddd !important;	
		}

		.logo {
			margin-top:15%;
		}

		@media only screen
		and (min-width: 320px)
		and (max-width: 736px)
		{			
			.logo {										
				margin-top: 50%;
			}
			
			.logo img {
				width: -moz-available;
				width: -webkit-fill-available;				
				margin:0					
			}				
		}

	</style>


<body style="background-color:{{ if( hb_HHasKey( pvalue(1), 'color' ), pvalue(1)[ 'color' ], 'white;' ) }}">

<div class="container-fluid">
	
	<div class="logo" align="center">
		<img id="logo" src="{{ pvalue(1)[ 'file' ] }}" >							
	</div>

	<?prg 
		local cHtml  := ''
		local cRoute := pvalue(1)[ 'route' ]
		
		if valtype( cRoute ) == 'C'
		
			cHtml := "<script>"
			cHtml += "  $( '#logo' ).on( 'click', function(){"
			cHtml += "     window.location.assign( '" + cRoute + "' );"
			cHtml += "	})"
			cHtml += "</script>"
			
		endif
		
		retu cHtml
	?>
	
</div>	
</body>