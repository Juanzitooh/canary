local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Condição para regeneração de mana
local manaCondition = Condition(CONDITION_REGENERATION)
manaCondition:setParameter(CONDITION_PARAM_SUBID, 11)
manaCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
manaCondition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
manaCondition:setParameter(CONDITION_PARAM_MANAGAIN, 30) -- Regenera 30 mana por segundo
manaCondition:setParameter(CONDITION_PARAM_MANATICKS, 1000) -- Intervalo de 1 segundo

-- Condição para aumento temporário do Magic Level
local mlCondition = Condition(CONDITION_ATTRIBUTES)
mlCondition:setParameter(CONDITION_PARAM_SUBID, 12)
mlCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
mlCondition:setParameter(CONDITION_PARAM_TICKS, 10 * 1000) -- Duração: 10 segundos
mlCondition:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 1) -- Aumenta Magic Level em +1

local baseMana = 120 -- Custo base de mana

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	local position = creature:getPosition()
	local party = creature:getParty()

	if not party then
		creature:sendCancelMessage("Você precisa estar em uma party para usar essa magia.")
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local membersList = party:getMembers()
	membersList[#membersList + 1] = party:getLeader()
	if not membersList or type(membersList) ~= "table" or #membersList <= 1 then
		creature:sendCancelMessage("Nenhum membro da party está próximo.")
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local affectedList = {}
	for _, targetPlayer in ipairs(membersList) do
		if targetPlayer:getPosition():getDistance(position) <= 36 then
			affectedList[#affectedList + 1] = targetPlayer
		end
	end

	if #affectedList <= 1 then
		creature:sendCancelMessage("Nenhum membro da party está próximo.")
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local mana = math.ceil((0.9 ^ (#affectedList - 1) * baseMana) * #affectedList)
	if creature:getMana() < mana then
		creature:sendCancelMessage(RETURNVALUE_NOTENOUGHMANA)
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if not combat:execute(creature, var) then
		creature:sendCancelMessage(RETURNVALUE_NOTPOSSIBLE)
		position:sendMagicEffect(CONST_ME_POFF)
		return false
	end

	creature:addMana(-(mana - baseMana), false)
	creature:addManaSpent((mana - baseMana))

	-- Aplica os efeitos de regeneração de mana e aumento de ML a todos os membros da party
	for _, targetPlayer in ipairs(affectedList) do
		targetPlayer:addCondition(manaCondition) -- Regeneração de mana
		targetPlayer:addCondition(mlCondition) -- Aumento temporário de Magic Level
	end

	return true
end

spell:name("Chamas de Inspiracao")
spell:words("fortis ignis aletus communis")
spell:group("support")
spell:vocation("aprendiz de mago do fogo")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_TRAIN_PARTY)
spell:id(159)
spell:cooldown(60 * 1000) -- Cooldown de 1 minuto
spell:groupCooldown(60 * 1000)
spell:level(35)
spell:mana(120)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
