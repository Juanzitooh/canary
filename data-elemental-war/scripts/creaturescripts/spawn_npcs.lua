local function spawnAskalorNpc()
    local npcName = "Askalor"
    local npcPosition = Position(3086, 3074, 7) -- Coordenadas exatas no mapa

    -- Criar o NPC no mapa ao iniciar o servidor
    if not Game.createNpc(npcName, npcPosition, false) then
        print("[ERRO] Não foi possível criar o NPC: " .. npcName)
    else
        print("[SUCESSO] NPC " .. npcName .. " criado em " .. npcPosition.x .. ", " .. npcPosition.y .. ", " .. npcPosition.z)
    end
end

function onStartup()
    spawnAskalorNpc()
end
