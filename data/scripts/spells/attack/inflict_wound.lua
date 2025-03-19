local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_TARGETCASTERORTOPMOST, 1)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_DRAWBLOOD)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_WEAPONTYPE)
combat:setParameter(COMBATPARAM_USECHARGES, 1)

local condition = Condition(CONDITION_BLEEDING)
condition:setParameter(CONDITION_PARAM_DELAYED, 10)
condition:addDamage(15, 2000, -50)
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:group("attack")
spell:id(141)
spell:name("Golpe Perfurante")
spell:words("incitare fragilis")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:impactSound(SOUND_EFFECT_TYPE_SPELL_INFLICT_WOUND)
spell:level(40)
spell:mana(30)
spell:isAggressive(true)
spell:range(1)
spell:needTarget(true)
spell:blockWalls(true)
spell:cooldown(30 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
-- 🔥 Lista de vocações que podem usar a magia
spell:vocation(
	"aprendiz de guerreiro do fogo",
	"aprendiz de guerreiro da agua",
	"aprendiz de guerreiro da terra",
	"aprendiz de guerreiro do ar"
)
spell:register()
