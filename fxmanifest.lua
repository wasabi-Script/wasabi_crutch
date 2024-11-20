-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Wasabi Crutch / Wheelchair System'
author 'wasabirobby#5110'
version '1.0.6'

files {
	'chair_data/vehicles.meta',
	'chair_data/carvariations.meta',
	'chair_data/handling.meta'
}

data_file 'DLC_ITYP_REQUEST' 'stream/crutch.ytyp'
data_file 'HANDLING_FILE'			'chair_data/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'chair_data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'chair_data/carvariations.meta'

shared_scripts {
  '@ox_lib/init.lua',
  'configuration/*.lua'
}

client_scripts {
  'bridge/**/client.lua',
  'client/*.lua'
}

server_scripts {
  'bridge/**/server.lua',
  'server/*.lua'
}

dependencies {
    'ox_lib'
}

