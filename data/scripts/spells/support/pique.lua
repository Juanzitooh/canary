local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_GREEN) -- Efeito visual da magia
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

-- Condição de Aumento de Velocidade
local condition = Condition(CONDITION_HASTE)
condition:setParameter(CONDITION_PARAM_TICKS, 30000) -- Duração: 30 segundos
condition:setFormula(1.15, 20, 1.15, 20) -- Aumento de velocidade reduzido comparado ao Haste
combat:addCondition(condition)

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local summons = creature:getSummons()
	if summons and type(summons) == "table" and #summons > 0 then
		for i = 1, #summons do
			local summon = summons[i]
			local summon_t = summon:getType()
			if summon_t and summon_t:familiar() then
				local deltaSpeed = math.max(creature:getBaseSpeed() - summon:getBaseSpeed(), 0)
				local FamiliarSpeed = ((summon:getBaseSpeed() + deltaSpeed) * 0.25) - 10 -- Menor que Haste
				local FamiliarHaste = Condition(CONDITION_HASTE)
				FamiliarHaste:setParameter(CONDITION_PARAM_TICKS, 33000)
				FamiliarHaste:setParameter(CONDITION_PARAM_SPEED, FamiliarSpeed)
				summon:addCondition(FamiliarHaste)
			end
		end
	end
	return combat:execute(creature, variant)
end

spell:name("Pes Ligeiros")
spell:words("celeris modicus") -- Palavras mágicas para ativação
spell:group("support")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_HASTE)
spell:id(7)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(1)
spell:mana(10) -- Custo reduzido de mana
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:needLearn(false)

-- 🔥 Vocações permitidas (Removendo os aprendizes)
spell:vocation(
	"aprendiz de arqueiro do ar",
	"aprendiz de guerreiro do ar",
	"aprendiz de mago do ar",
	"ferreiro do ar",
	"artesao do ar",
	"joalheiro do ar",
	"alquimista do ar"
)

spell:register()
