local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, 0)

local condition = Condition(CONDITION_LIGHT)
condition:setParameter(CONDITION_PARAM_LIGHT_LEVEL, 8)
condition:setParameter(CONDITION_PARAM_LIGHT_COLOR, 215)
condition:setParameter(CONDITION_PARAM_TICKS, (60 * 33 + 10) * 1000)
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:name("Iluminacao das Chamas")
spell:words("videre ignis lumen")
spell:group("support")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de mago do fogo",
	"aprendiz de mago da agua",
	"aprendiz de mago da terra",
	"aprendiz de mago do ar"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_ULTIMATE_LIGHT)
spell:id(75)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(26)
spell:mana(140)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
