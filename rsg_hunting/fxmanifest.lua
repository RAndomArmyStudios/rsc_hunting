game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Ryuu'
description 'Hunting script for RSG Core'
version 'alpha'

client_script {
    'config.lua',
    'client/main.lua',
    'client/skinning.lua'
}

server_script {
    'config.lua',
    'server/main.lua'  ,
    'server/skinning.lua'
}

exports {
	'DataViewNativeGetEventData'
}
