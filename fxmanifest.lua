author "The Wrench"
description "Wrench Prod."
version "1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_script {
    '@ox_lib/init.lua',
    "config.lua"
}

server_scripts {"server.lua", '@oxmysql/lib/MySQL.lua'}
client_scripts {
    "client.lua",
}

dependencies {
    "ox_lib"
}
