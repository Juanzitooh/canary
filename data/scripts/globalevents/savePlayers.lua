local function savePlayers()
    -- Mensagem apenas no terminal
    print("[Server Save] Salvando jogadores...")

    -- Salva os jogadores online
    if Game and Game.savePlayers then
        Game.savePlayers()
        print("[Server Save] Dados dos jogadores atualizados!")
    else
        print("[ERROR] Função Game.savePlayers() não encontrada!")
    end
end

local saveEvent = GlobalEvent("SavePlayersEvent")

function saveEvent.onTime(interval)
    savePlayers()
    return true
end

-- Define o intervalo de salvamento (600000 ms = 10 minutos)
saveEvent:interval(600000) -- 10 minutos
saveEvent:register()
