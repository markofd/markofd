fx_version 'cerulean'
game 'gta5'

client_script {
	'client.lua'
}

server_script {
	'server.lua',
	'@mysql-async/lib/MySQL.lua'
}

ui_page('html/index.html')

files({
	"html/script.js",
	"html/jquery.min.js",
	"html/jquery-ui.min.js",
	"html/js-fluid-meter.js",
	"html/styles.css",
	"html/img/*.svg",
	"html/*.png",
	"html/index.html",
})