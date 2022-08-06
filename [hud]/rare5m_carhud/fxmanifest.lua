fx_version 'adamant'
game 'gta5'

description "SVRP Car Hud"

client_scripts {
	'client.lua',
	'@svrp-errorlog/client.lua',	
}

server_scripts {
	'server.lua',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/style.css',
	'html/scripts.js',
	'html/compass.png',	
	'html/debounce.min.js',	
	'html/harness_on.png',	
	'html/harness_off.png',	
	'html/sb_on.png',
	'html/sb_off.png',	
	'html/cruise_on.png',
	'html/cruise_off.png',	
}
lua54 'yes'