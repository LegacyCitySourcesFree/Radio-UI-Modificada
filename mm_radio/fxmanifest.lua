fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mm_radio'
author 'ChatGPT'
description 'Radio UI (NUI) estilo clean para MRI/Qbox (pma-voice)'
version '1.0.0'

dependency 'pma-voice'
dependency 'ox_inventory'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}

shared_script 'config.lua'

client_script 'client/client.lua'
server_script 'server/server.lua'
