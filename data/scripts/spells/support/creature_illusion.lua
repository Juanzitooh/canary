local condition = Condition(CONDITION_OUTFIT)
condition:setTicks(180000)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local returnValue = RETURNVALUE_NOERROR
	local monsterType = MonsterType(variant:getString())
	if not monsterType then
		returnValue = RETURNVALUE_CREATUREDOESNOTEXIST
	elseif not creature:hasFlag(PlayerFlag_CanIllusionAll) and not monsterType:isIllusionable() then
		returnValue = RETURNVALUE_NOTPOSSIBLE
	end

	if returnValue ~= RETURNVALUE_NOERROR then
		creature:sendCancelMessage(returnValue)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	condition:setOutfit(monsterType:getOutfit())
	creature:addCondition(condition)
	creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	return true
end

spell:name("Ilusao")
spell:words("videre ventus adint")
spell:group("support")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de mago do ar"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CREATURE_ILLUSION)
spell:id(38)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(23)
spell:mana(100)
spell:hasParams(true)
spell:isAggressive(false)
spell:needLearn(false)
spell:register()
