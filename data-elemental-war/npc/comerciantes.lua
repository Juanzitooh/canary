local npcName = "Gerfan"
local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = "Gerfan, O Lider da Guild de Mercadores."

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 58,
	lookBody = 68,
	lookLegs = 38,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 60000,
	chance = 50,
	{ text = "Venham, Temos trabalhos para todas as racas, Ajudem na Recontrucao do reino elemental!" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

-- id das vocações de trabalho por raça
local RACE_PROFESSIONS = {
    [21] = { "pescador", "artesao", "cozinheiro" },      -- Humano
    [42] = { "ferreiro", "minerador", "coletor" },      -- Anão
    [43] = { "coletor", "alquimista", "cozinheiro" },   -- Elfo
    [44] = { "minerador", "alquimista", "joalheiro" },  -- Shatari
    [45] = { "joalheiro", "pescador", "ferreiro", "artesao" }, -- Animus
}

-- vocações de trabalho especializadas em algum elemento
local SPECIALIZED_VOCATIONS = {
    "ferreiro",       -- Ferreiro
    "artesao",        -- artesao
    "joalheiro",      -- Joalheiro
    "alquimista",     -- Alquimista
}

-- Tabela das vocações de acordo com os elementos
local ELEMENTAL_GROUPS = {
    fire = {9, 13, 17},  -- Guerreiro, Arqueiro, Mago do Fogo
    water = {10, 14, 18}, -- Guerreiro, Arqueiro, Mago da Água
    earth = {11, 15, 19}, -- Guerreiro, Arqueiro, Mago da Terra
    air = {12, 16, 20}    -- Guerreiro, Arqueiro, Mago do Ar
}

-- Id das vocações de trabalho
local JOB_VOCACOES = {
    coletor = 22,
    minerador = 23,
    pescador = 24,
    cozinheiro = 25,
    ferreiro = {fire = 26, water = 27, earth = 28, air = 29},
    artesao = {fire = 30, water = 31, earth = 32, air = 33},
    joalheiro = {fire = 34, water = 35, earth = 36, air = 37},
    alquimista = {fire = 38, water = 39, earth = 40, air = 41}
}

-- Variáveis nescessárias
-- Constantes de storage e tempo definidas fora da função
local STORAGE_VOCACAO = 2000000  -- ID do storage para a vocação do jogador
local STORAGE_TRABALHO_TEMPO = 2000003  -- ID do storage para o tempo de atribuição do trabalho
local STORAGE_RACE = 2000005      -- Race storage
local ONE_HOUR = 60 * 60


-- Função giveJob corrigida
local function giveJob(player, jobChoice)
    local currentVocationStorage = player:getStorageValue(STORAGE_VOCACAO)

    -- Obtém a vocação do trabalho (profissão)
    local jobVocation = JOB_VOCACOES[jobChoice]

    -- Se a profissão não existe
    if not jobVocation then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Essa profissão não existe!")
        return false
    end

    -- Se a profissão NÃO for especializada por elemento, apenas atribui a vocação e sai
    if type(jobVocation) ~= "table" then
        player:setVocation(jobVocation)
        player:setStorageValue(STORAGE_TRABALHO_TEMPO, os.time())
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Agora você é um " .. jobChoice .. "! Trabalhe bem e prospere!")
        return true
    end

    -- Se a profissão precisa de um elemento, verifica se o jogador tem afinidade elemental
    if currentVocationStorage == -1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você precisa de afinidade com algum elemento para exercer essa profissão. Fale com Askalor para aprender sobre os elementos!")
        return false
    end

    -- Identifica o elemento do jogador baseado na vocação armazenada
    local element = nil
    for elem, vocations in pairs(ELEMENTAL_GROUPS) do
        for _, vocationId in ipairs(vocations) do
            if vocationId == currentVocationStorage then
                element = elem
                break
            end
        end
        if element then break end
    end

    -- Se não encontrou um elemento válido, impede a profissão elementar
    if not element then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sua vocação não possui um elemento válido para profissão elemental!")
        return false
    end

    -- Atribui a vocação correta baseada no elemento do jogador
    jobVocation = jobVocation[element]
    if not jobVocation then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sua vocação não possui essa especialização!")
        return false
    end

    -- Define a vocação do jogador e armazena o tempo
    player:setVocation(jobVocation)
    player:setStorageValue(STORAGE_TRABALHO_TEMPO, os.time())

    -- Mensagem de sucesso (inclui elemento apenas se necessário)
    local message = "Agora você é um " .. jobChoice
    if element then
        message = message .. " " .. element
    end
    message = message .. "! Trabalhe bem e prospere!"

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
    return true
end




-- Função creatureSayCallback refatorada
local function creatureSayCallback(npc, creature, type, message)
    local player = Player(creature)
    local playerId = player:getId()

    -- Obtém as informações de vocação e raça do jogador
    local currentVocationStorage = player:getStorageValue(STORAGE_VOCATION)  -- Obtém a vocação do jogador
    local playerRace = player:getStorageValue(STORAGE_RACE)  -- Obtém a raça do jogador
    local validProfessions = RACE_PROFESSIONS[playerRace]  -- Profissões válidas para a raça do jogador

    -- Verifica se a interação é válida
    if not npcHandler:checkInteraction(npc, creature) then
        return false
    end

    -- Processa a escolha do jogador
    if npcHandler:getTopic(playerId) == 0 then
        local validChoice = false

        -- Verifica se a profissão escolhida é válida
        for _, validProfession in ipairs(validProfessions) do
            if MsgContains(message, validProfession) then
                validChoice = true
                break
            end
        end

        -- Se for uma profissão válida
        if validChoice then
            -- Se for uma profissão especializada, verifica se o jogador já escolheu uma forma elemental
            if table.contains(SPECIALIZED_VOCATIONS, message) then
                if currentVocationStorage == -1 then
                    npcHandler:say("Você precisa escolher uma forma elemental para exercer essa profissão especializada. Fale com Askalor para aprender sobre os elementos!", npc, creature, 10)
                    return false
                end
            end

            -- Chama a função giveJob para atribuir a vocação
            if giveJob(player, message) then
                npcHandler:say("Agora você tem uma nova profissão! Trabalhe duro e prospere!", npc, creature, 10)
            else
                npcHandler:say("Não foi possível definir sua profissão. Certifique-se de que já escolheu uma forma elemental!", npc, creature, 10)
            end
        else
            -- Se a profissão não for válida para a raça do jogador
            npcHandler:say("Essa profissão não é válida para sua raça. Aqui estão as profissões válidas para você: " .. table.concat(validProfessions, ", "), npc, creature, 10)
        end
    end
    return true
end

-- Função greetCallback refatorada
local function greetCallback(npc, creature)
    local player = Player(creature)
    local playerId = player:getId()
    
    -- Obtém as informações de vocação, raça e tempo do jogador
    local currentVocationStorage = player:getStorageValue(STORAGE_VOCATION)  -- Obtém a vocação do jogador
    local currentRaceStorage = player:getStorageValue(STORAGE_RACE)     -- Obtém a raça do jogador
    local trabalhoTime = player:getStorageValue(STORAGE_TEMPO_TRABALHO)  -- Obtém o tempo de trabalho do jogador
    local currentTime = os.time()  -- Obtém o tempo atual
    local hasElementalVocation = currentVocationStorage ~= -1  -- Verifica se o jogador tem vocação elemental

    -- Se a raça ainda não foi definida (-1), define como a vocação atual do jogador
    if currentRaceStorage == -1 then
        currentRaceStorage = player:getVocation():getId()
        player:setStorageValue(STORAGE_RACE, currentRaceStorage)
    end

    -- Se já passou mais de 1 hora desde a última troca de profissão, permite escolher uma nova
    if trabalhoTime == -1 or (trabalhoTime > 0 and (currentTime - trabalhoTime) >= ONE_HOUR) then
        local professionList = {}

        -- Se o jogador tem vocação elemental, oferece as vocações especializadas
        if hasElementalVocation then
            for _, vocation in ipairs(SPECIALIZED_VOCATIONS) do
                table.insert(professionList, vocation)
            end
        end

        -- Adiciona as profissões básicas da raça
        local raceProfessions = RACE_PROFESSIONS[currentRaceStorage] or {}
        for _, profession in ipairs(raceProfessions) do
            table.insert(professionList, profession)
        end

        -- Monta a mensagem com as profissões disponíveis
        local professionMessage = "Jovem, qual das profissoes deseja exercer? Escolha entre "
        for _, profession in ipairs(professionList) do
            professionMessage = professionMessage .. "{ " .. profession .. " }, "
        end
        professionMessage = professionMessage:sub(1, -3)  -- Remove a última vírgula e espaço

        npcHandler:setMessage(MESSAGE_GREET, professionMessage)
        return true
    end

    -- Se ainda não passou 1 hora, informa o tempo restante
    local remainingTime = ONE_HOUR - (currentTime - trabalhoTime)
    local minutes = math.floor(remainingTime / 60)
    npcHandler:setMessage(
        MESSAGE_GREET,
        string.format("Você ainda precisa esperar %d minutos antes de escolher uma nova profissão.", minutes)
    )
    return true
end



npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "thau, meu bom.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
