------------------------------CREDITS------------------------------
--------        Script made by Bluse and Invrokaaah        --------
------   Copyright 2021 BluseStudios. All rights reserved   -------
-------------------------------------------------------------------

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

author 'Bluse Studios'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
}

ui_page {
	'html/index.html'
}

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/listener.js'
}