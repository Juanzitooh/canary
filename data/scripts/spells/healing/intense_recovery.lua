local combat = Combat()
local cooldown = 60000 -- milis

combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_REGENERATION)
condition:setParameter(CONDITION_PARAM_TICKS, cooldown)
condition:setParameter(CONDITION_PARAM_HEALTHGAIN, 40)
condition:setParameter(CONDITION_PARAM_HEALTHTICKS, 3000) -- 3sec
condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Resiliencia Elemental")
spell:words("sanviva magnus")
spell:group("healing")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de guerreiro da terra",
    "aprendiz de arqueiro da terra",
    "aprendiz de guerreiro do ar"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_INTENSE_RECOVERY)
spell:id(160)
spell:cooldown(cooldown)
spell:groupCooldown(1000)
spell:level(100)
spell:mana(165)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
