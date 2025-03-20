local teleportConfig = {
    itemId = 4396, -- ID do item que barra o teleport
    actionId = 30051, -- Action ID do item que barra o teleport
    questStorage = Storage.Quest.Chamado.Start, -- Storage da quest
    message = "Fale com o Guardiao Talian para estar habilitado a passar no portal para o reino elemental.", -- no caso de não poder passar no portal
    townId = 2 -- Cidade que será atribuída ao jogador se a quest estiver ativa
}

local teleportEvent = MoveEvent()
teleportEvent:type("stepin")

function teleportEvent.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player or not player:isPlayer() then
        return false
    end

    -- Verifica se o actionid do item é o correto
    if item.actionid ~= teleportConfig.actionId then
        return false
    end

    local questStorage = player:getStorageValue(teleportConfig.questStorage)

    if questStorage == -1 then
        -- Quest não iniciada, mostrar mensagem e teleportar de volta.
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, teleportConfig.message)
        player:teleportTo(Position(5950, 5950, 15))
        return false
    else
        -- Quest já iniciada, define a cidade e atualiza o storage
        player:setTown(Town(teleportConfig.townId))
        player:setStorageValue(teleportConfig.questStorage, 2)
    end

    return true
end

teleportEvent:id(teleportConfig.itemId) -- Registra apenas pelo ID do item
teleportEvent:register()
