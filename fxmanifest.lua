fx_version 'cerulean'
games {"gta5"}

lua54 'yes'

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/client.lua',
	'client/drugs.lua',
	'locales/pl.lua',
	'locales/en.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    '@es_extended/locale.lua',
	'config.lua',
	'server/server.lua',
	'locales/pl.lua',
	'locales/en.lua',
}
