local STORAGE_VOCACAO_ESCOLHIDA = 2000001 -- Storage que guarda a vocação elemental
local STORAGE_ITENS_INICIAIS = 2000004 -- Storage que controla se o jogador já recebeu os itens iniciais
local STORAGE_TEMPO_ELEMENTAL = 2000002 -- Storage para o tempo da transformação elemental
local STORAGE_RACA = 2000000 -- Storage para a raça do jogador (se tiver)

local scriptConfig = {
    itemId = 3613, -- ID do item (a árvore) colocada no mapa
}

-- Listas de vocações
local warriorVocations = {9, 10, 11, 12}  
local archerVocations = {13, 14, 15, 16}  
local mageVocations = {17, 18, 19, 20}    

-- Equipamento inicial comum a todas as vocações
local commonItems = {
    {itemId = 3355},   -- Capacete
    {itemId = 3561},   -- Armadura
    {itemId = 3559},   -- Perneiras
    {itemId = 3552},   -- Botas
    {itemId = 3412}    -- Escudo
}

-- Arma para as vocações
local weapons = {
    warrior = {itemId = 12673},  -- Arma do guerreiro
    archer = {itemId = 1781, count = 1},    -- Arma do arqueiro
    mage = {itemId = 12673}      -- A mesma arma do guerreiro para o mago
}

-- Função para determinar a classe da vocação
local function getVocationClass(vocationId)
    for _, id in ipairs(warriorVocations) do
        if vocationId == id then return "warrior" end
    end
    for _, id in ipairs(archerVocations) do
        if vocationId == id then return "archer" end
    end
    for _, id in ipairs(mageVocations) do
        if vocationId == id then return "mage" end
    end
    return nil
end

-- Função para dar os itens iniciais apenas na primeira vez
local function giveStarterItems(player)
    if not player then return false end

    -- Verifica se o jogador já recebeu os itens
    if player:getStorageValue(STORAGE_ITENS_INICIAIS) == 1 then
        -- Apenas retorna true, sem mensagens, caso o jogador já tenha recebido os itens
        return true
    end

    -- Verifica se o jogador tem uma vocação escolhida
    local vocationId = player:getStorageValue(STORAGE_VOCACAO_ESCOLHIDA)
    if vocationId == -1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você precisa escolher uma vocação antes de receber os itens iniciais.")
        return false
    end

    -- Determina a classe da vocação
    local vocationClass = getVocationClass(vocationId)
    if not vocationClass then
        return false
    end

    -- Calcula o peso total dos itens
    local totalWeight = 0
    local itemsToAdd = {}

    -- Adiciona os itens comuns
    for _, itemData in ipairs(commonItems) do
        table.insert(itemsToAdd, {itemData.itemId, 1})
        totalWeight = totalWeight + (ItemType(itemData.itemId):getWeight() * 1)
    end

    -- Adiciona a arma específica da vocação
    local weapon = weapons[vocationClass]
    table.insert(itemsToAdd, {weapon.itemId, weapon.count or 1})
    totalWeight = totalWeight + (ItemType(weapon.itemId):getWeight() * (weapon.count or 1))

    -- Verifica se o jogador tem capacidade suficiente para carregar os itens
    if player:getFreeCapacity() < totalWeight then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você não tem capacidade suficiente para carregar os itens iniciais. Eles pesam " .. (totalWeight / 100) .. " oz.")
        return false
    end

    -- Verifica se o jogador tem espaço suficiente na mochila para os itens
    if player:getFreeBackpackSlots() < #itemsToAdd then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você não tem espaço suficiente na mochila para os itens iniciais.")
        return false
    end

    -- Entrega os itens diretamente para a mochila
    for _, itemData in ipairs(itemsToAdd) do
        local newItem = player:addItem(itemData[1], itemData[2])
        if not newItem then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Erro ao tentar adicionar o item " .. itemData[1] .. ".")
            return false
        end
    end

    -- Marca que o jogador já recebeu os itens
    player:setStorageValue(STORAGE_ITENS_INICIAIS, 1)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você recebeu seus equipamentos iniciais!")

    return true
end

-- Função para realizar a transformação de vocação
local function transformToElemental(player)
    local currentTime = os.time()
    local oneDay = 4 * 60 * 60
    local elementalTime = player:getStorageValue(STORAGE_TEMPO_ELEMENTAL)
    local vocationId = player:getStorageValue(STORAGE_VOCACAO_ESCOLHIDA)
    local playerVocation = player:getVocation():getId()
    local playerRace = player:getStorageValue(STORAGE_RACA)

    if vocationId == -1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você ainda não pode se transformar, fale com Asfalor!")
        return false
    end

    if playerVocation == vocationId then
        if elementalTime > 0 and (currentTime - elementalTime) < oneDay then
            local remainingTime = oneDay - (currentTime - elementalTime)
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Você está instável, faltam %d horas e %d minutos para voltar à sua forma original.", hours, minutes))
            return false
        else
            if playerRace > 0 then
                player:setVocation(playerRace)
            else
                player:setVocation(21)
            end
            player:setStorageValue(STORAGE_TEMPO_ELEMENTAL, currentTime)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você retornou à sua forma original.")
        end
    else
        if elementalTime > 0 and (currentTime - elementalTime) < oneDay then
            local remainingTime = oneDay - (currentTime - elementalTime)
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Você está exausto, ainda não consegue se transformar em elemental, precisa esperar %d horas e %d minutos.", hours, minutes))
            return false
        else
            player:setVocation(vocationId)
            player:setStorageValue(STORAGE_TEMPO_ELEMENTAL, currentTime)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você se transformou na sua forma elemental!")
        end
    end

    return true
end

-- Action para a árvore de itens iniciais e vocação
local arvoreItensIniciais = Action()

function arvoreItensIniciais.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Verifica se o item usado é o correto
    if item:getId() ~= scriptConfig.itemId then
        return false
    end

    -- Executa a função para dar os itens iniciais (apenas uma vez)
    if giveStarterItems(player) then
        -- Após dar os itens iniciais, realiza a transformação (sem repetir a entrega de itens)
        return transformToElemental(player)
    end

    return false
end

-- Registra a ação para o item com o ID configurado
arvoreItensIniciais:id(scriptConfig.itemId)
arvoreItensIniciais:register()
