local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_CARNIPHILA)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local baseMana = 90 -- Custo base de mana
local duration = 20 * 1000 -- 20 segundos de duração
local tickInterval = 2000 -- A cada 2 segundos, reduz debuffs

local spell = Spell("instant")

local function removeDebuffs(target)
    if target and target:isPlayer() then
        -- Remove debuffs específicos (veneno, sangramento, stun)
        target:removeCondition(CONDITION_POISON)
        target:removeCondition(CONDITION_BLEEDING)
        target:removeCondition(CONDITION_PARALYZE)
        target:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    end
end

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

	-- Agendando a remoção de debuffs durante a duração da magia
	for _, targetPlayer in ipairs(affectedList) do
		for i = 0, duration, tickInterval do
			addEvent(removeDebuffs, i, targetPlayer)
		end
	end

	return true
end

spell:name("Raizes Protetoras")
spell:words("expelis toxis aletus")
spell:group("support")
spell:vocation("aprendiz de guerreiro da terra")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_TRAIN_PARTY)
spell:id(152)
spell:cooldown(30 * 1000) -- Cooldown de 30 segundos
spell:groupCooldown(30 * 1000)
spell:level(35)
spell:mana(90)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
