Config = {}

-- Canais fixos mostrados na UI
Config.PresetChannels = {
  { label = "111", channel = 111 },
  { label = "222", channel = 222 },
  { label = "333", channel = 333 },
}

-- Limites de canal
Config.MinChannel = 1
Config.MaxChannel = 9999

-- Volume padrão
Config.DefaultVolume = 0.50

-- Se true, só abre se tiver o item radio (extra segurança)
Config.RequireRadioItem = true

-- Nome do item no inventário
Config.RadioItemName = 'radio'
