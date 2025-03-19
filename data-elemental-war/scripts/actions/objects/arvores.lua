local plants = {
    [3699] = { newId = 3700, decay = true, reward = {id = 3588, count = 3} }, -- Blueberry Bush
    [5156] = { newId = 5155, decay = true, reward = {id = 5096, count = 3} }, -- Árvore de mangas
    [3742] = { newId = 3744, decay = true, reward = {id = 3586, count = 3} }  -- Árvore de Laranjas
}

local REQUIRED_TOOL = 3308 -- ID da Machete

local plantAction = Action()

function plantAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local plant = plants[item:getId()]
    if not plant then return false end

    -- Verifica se o jogador está segurando a Machete
    local weapon = player:getSlotItem(CONST_SLOT_LEFT)
    if not weapon or weapon:getId() ~= REQUIRED_TOOL then
        player:sendCancelMessage("Você precisa de uma Machete para colher esta planta.")
        return true
    end

    -- Transforma a planta (se aplicável)
    if plant.newId then
        item:transform(plant.newId)
    end

    -- Aplica o decay (se aplicável)
    if plant.decay then
        item:decay()
    end

    -- Cria o item no chão
    Game.createItem(plant.reward.id, plant.reward.count, fromPosition)

    return true
end

-- Registra todas as plantas automaticamente
for plantId, _ in pairs(plants) do
    plantAction:id(plantId)
end

plantAction:register()