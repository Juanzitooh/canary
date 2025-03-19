-- Função para determinar a temporada atual
local function getCurrentSeason()
    local month = os.date("*t").month

    local season = { "fixed" } -- Sempre carrega os spawns fixos

    if month == 12 or month == 1 or month == 2 then
        table.insert(season, "winter")
    elseif month == 6 or month == 7 or month == 8 then
        table.insert(season, "summer")
    elseif month == 10 then
        table.insert(season, "halloween")
    elseif month == 12 then
        table.insert(season, "christmas")
    end

    return season -- Retorna todas as temporadas ativas (fixos + sazonal, se houver)
end

-- função que dá load nos respawns
local function loadMonsterSpawns()
    local seasons = getCurrentSeason()
    local seasonQuery = "'" .. table.concat(seasons, "', '") .. "'"

    logger.info("[SPAWN] Carregando spawns para as temporadas: {}", table.concat(seasons, ", "))

    local query = "SELECT * FROM monster_spawns WHERE season IN (" .. seasonQuery .. ")"
    local resultId = db.storeQuery(query)

    if resultId then
        repeat
            -- Aqui está a correção: usando Result.getNumber() e Result.getString()
            local monsterName = Result.getString(resultId, "monster_name")
            local posx = Result.getNumber(resultId, "posx")
            local posy = Result.getNumber(resultId, "posy")
            local posz = Result.getNumber(resultId, "posz")
            local count = Result.getNumber(resultId, "count")
            local radius = Result.getNumber(resultId, "radius")
            local respawnTime = Result.getNumber(resultId, "respawn_time")

            for i = 1, count do
                local spawnPosition = {x = posx + math.random(-radius, radius), y = posy + math.random(-radius, radius), z = posz}
                Game.createMonster(monsterName, spawnPosition)
            end

            logger.info("[SPAWN] {}x {} spawnados em {}, {}, {}", count, monsterName, posx, posy, posz)

        until not Result.next(resultId)
        
        Result.free(resultId)
    else
        logger.warn("[SPAWN] Nenhum spawn encontrado para esta temporada.")
    end
end




-- Registrar o evento global para rodar automaticamente no startup
local spawnInitialization = GlobalEvent("Spawn Initialization")

function spawnInitialization.onStartup()
    loadMonsterSpawns()
end

spawnInitialization:register()
