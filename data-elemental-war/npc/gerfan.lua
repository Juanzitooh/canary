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


-- id das vocações de trabalho especializado por raça
local two_job = {
    [21] = "cozinheiro",        -- Humano
    [42] = "ferreiro",       -- Anão
    [43] = "alquimista",     -- Elfo
    [44] = "joalheiro",     -- Shatari
    [45] = "artesao",        -- Animus
}

-- id das vocações de trabalho por raça, com uma opção de profissão de extração por raça
local one_job = {
    [21] = "pescador",       -- Humano
    [42] = "minerador",      -- Anão
    [43] = "coletor",        -- Elfo
    [44] = "minerador",      -- Shatari
    [45] = "pescador",       -- Animus
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


-- Função giveJob simplificada
local function giveJob(player, jobChoice)
    -- Obtém a vocação do trabalho (profissão)
    local jobVocation = JOB_VOCACOES[jobChoice]
    
    -- Se a profissão não existe
    if not jobVocation then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Essa profissão não existe!")
        return false
    end

    -- Verifica se a profissão é especializada (elemento ou não)
    if type(jobVocation) ~= "table" then
        -- Profissão não especializada, atribui diretamente
        player:setVocation(jobVocation)
        player:setStorageValue(STORAGE_TRABALHO_TEMPO, os.time())
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Agora você é um " .. jobChoice .. "! Trabalhe bem e prospere!")
        return true
    end

    -- Profissão especializada, consulta o elemento
    local currentVocationStorage = player:getStorageValue(STORAGE_VOCACAO)
    
    -- Se o jogador não tem afinidade com um elemento, impede a profissão
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

    -- Atribui a vocação do jogador de acordo com o elemento
    jobVocation = jobVocation[element] or jobVocation["default"]
    if not jobVocation then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sua vocação não possui essa especialização!")
        return false
    end

    -- Define a vocação e armazena o tempo
    player:setVocation(jobVocation)
    player:setStorageValue(STORAGE_TRABALHO_TEMPO, os.time())

    -- Mensagem de sucesso
    local message = "Agora você é um " .. jobChoice
    if element then
        message = message .. " " .. element
    end
    message = message .. "! Trabalhe bem e prospere!"

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
    return true
end


-- Função para verificar e dar o job
local function creatureSayCallback(npc, creature, type, message)
    local player = Player(creature)
    local playerId = player:getId()

    -- Obtém o ID da raça do jogador
    local playerRace = player:getStorageValue(STORAGE_RACE)  -- Obtém a raça do jogador
    local questStorage = player:getStorageValue(Storage.Quest.Chamado.ProfissaoComum)  -- Obtém o storage da quest

    -- Verifica se a interação é válida
    if not npcHandler:checkInteraction(npc, creature) then
        return false
    end

    -- Processa a escolha do jogador
    if npcHandler:getTopic(playerId) == 0 then
        -- Verifica se a mensagem contém "trabalhar"
        if MsgContains(message, "trabalhar") then
            -- Se o jogador ainda não tiver o storage da quest
            if questStorage == -1 then
                -- Verifica a profissão de extração correspondente à raça do jogador
                local job = one_job[playerRace]
                
                -- Se existir uma profissão válida para a raça, dá o job
                if job then
                    -- Chama a função giveJob para atribuir a vocação
                    if giveJob(player, job) then
                        player:setStorageValue(Storage.Quest.Chamado.ProfissaoComum, 1)
                        npcHandler:say("Você agora tem o trabalho de " .. job .. ". Para completar a missão, veja as missões disponíveis.", npc, creature, 10)
                    else
                        npcHandler:say("Não foi possível atribuir o seu trabalho. Tente novamente mais tarde.", npc, creature, 10)
                    end
                else
                    npcHandler:say("Não há profissão disponível para a sua raça no momento.", npc, creature, 10)
                end
            elseif questStorage == 1 then
                -- Se o jogador já tem o trabalho atribuído
                npcHandler:say("Está aqui novamente? Eu não te dei um trabalho? O Tadeu está te esperando, viajante!", npc, creature, 10)
            end
        end
    end

    return true
end

-- Função greetCallback refatorada (sem troca de profissão)
local function greetCallback(npc, creature)
    local player = Player(creature)
    
    -- Mensagem inicial fixa
    npcHandler:setMessage(MESSAGE_GREET, "Bem-vindo a Ominis, estou a procura de trabalhadores para ajudarem a reconstruir esse reino. Deseja {trabalhar} ou escutar uma {historia}?")

    -- Obtém as informações de raça do jogador
    local currentRaceStorage = player:getStorageValue(STORAGE_RACE)  -- Obtém a raça do jogador

    -- Se a raça ainda não foi definida (-1), define como a vocação atual do jogador
    if currentRaceStorage == -1 then
        currentRaceStorage = player:getVocation():getId()
        player:setStorageValue(STORAGE_RACE, currentRaceStorage)
    end

    return true
end



npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "thau, meu bom.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
