local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_POISON)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    return combat:execute(creature, variant)
end

spell:name("Cure Poison Friend")
spell:words("exura pox")
spell:group("healing")
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de mago da terra"
)
spell:castSound(SOUND_EFFECT_TYPE_SPELL_CURE_POISON)
spell:id(30)
spell:cooldown(6000)
spell:groupCooldown(1000)
spell:level(10)
spell:mana(50)
spell:needTarget(true)
spell:hasParams(true)
spell:hasPlayerNameParam(true)
spell:allowOnSelf(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)
spell:register()
