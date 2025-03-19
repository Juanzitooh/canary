local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STONES)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Criação da condição de defesa base (ativa quando em movimento)
local condition = Condition(CONDITION_ATTRIBUTES)
condition:setParameter(CONDITION_PARAM_SUBID, 8)
condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
condition:setParameter(CONDITION_PARAM_TICKS, 15 * 1000) -- Duração: 15 segundos
condition:setParameter(CONDITION_PARAM_DAMAGEMITIGATION, 5) -- Redução de 5% do dano
condition:setParameter(CONDITION_PARAM_SKILL_SHIELD, 5) -- Aumento de 5% em Shielding para absorção de projéteis

-- Condição aprimorada (ativa se o jogador estiver parado)
local strongCondition = Condition(CONDITION_ATTRIBUTES)
strongCondition:setParameter(CONDITION_PARAM_SUBID, 9)
strongCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
strongCondition:setParameter(CONDITION_PARAM_TICKS, 15 * 1000) -- Duração: 15 segundos
strongCondition:setParameter(CONDITION_PARAM_DAMAGEMITIGATION, 10) -- Redução de 10% do dano
strongCondition:setParameter(CONDITION_PARAM_SKILL_SHIELD, 10) -- Aumento de 10% em Shielding

local baseMana = 80 -- Custo base de mana

local spell = Spell("instant")

local function checkIfMoving(player, startPosition)
    if player and player:isPlayer() then
        if player:getPosition() == startPosition then
            -- O jogador está parado, aplica a versão forte da condição
            player:addCondition(strongCondition)
        else
            -- O jogador se moveu, aplica a condição padrão de 5%
            player:addCondition(condition)
        end
    end
end

function spell.onCastSpell(creature, var)
    local position = creature:getPosition()

    -- Aplicando a condição inicial (sempre começa com a versão fraca)
    if not combat:execute(creature, var) then
        creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
        position:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local mana = baseMana
    if creature:getMana() < mana then
        creature:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
        position:sendMagicEffect(CONST_ME_POFF)
        return false
    end

    creature:addMana(-mana, false)
    creature:addManaSpent(mana)

    -- Aplica a condição inicial
    creature:addCondition(condition)

    -- Verifica a cada segundo se o jogador está parado e troca a condição
    for i = 1, 15 do
        addEvent(checkIfMoving, i * 1000, creature, position)
    end

    return true
end

spell:name("Postura de Defesa Rochosa")
spell:words("munio petra aletus")
spell:group("support")
spell:vocation("aprendiz de arqueiro da terra")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_PROTECT_PARTY)
spell:id(157)
spell:cooldown(30 * 1000) -- Cooldown de 30 segundos
spell:groupCooldown(30 * 1000)
spell:level(35)
spell:mana(80)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
