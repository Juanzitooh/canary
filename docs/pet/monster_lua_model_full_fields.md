# Modelo Monster Lua (Campos Completos)

## Fonte escolhida (exemplo real, sem bloco final de action/event custom)
Arquivo base recomendado:
- `data-otservbr-global/monster/magicals/marid.lua`

Motivo da escolha:
- tem `Bestiary`, `faction`, `enemyFactions`, `summon`, `loot`, `attacks`, `defenses`, `elements`, `immunities`;
- termina somente com `mType:register(monster)`;
- nao depende de `mType.onThink/onSpawn/...` no final do arquivo.

## Exemplo real (Marid)

```lua
local mType = Game.createMonsterType("Marid")
local monster = {}

monster.description = "a marid"
monster.experience = 410
monster.outfit = {
	lookType = 104,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.raceId = 104
monster.Bestiary = {
	class = "Magical",
	race = BESTY_RACE_MAGICAL,
	toKill = 1000,
	FirstUnlock = 50,
	SecondUnlock = 500,
	CharmsPoints = 25,
	Stars = 3,
	Occurrence = 0,
	Locations = "Kha'zeel, Magician Quarter, Djinn battle island through the Haunted Tomb.",
}

monster.health = 550
monster.maxHealth = 550
monster.race = "blood"
monster.corpse = 6033
monster.speed = 117
monster.manaCost = 0

monster.faction = FACTION_MARID
monster.enemyFactions = { FACTION_PLAYER, FACTION_EFREET }

monster.changeTarget = {
	interval = 4000,
	chance = 10,
}

monster.strategiesTarget = {
	nearest = 100,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = false,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.summon = {
	maxSummons = 2,
	summons = {
		{ name = "blue djinn", chance = 10, interval = 2000, count = 2 },
	},
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "Wishes can come true.", yell = false },
	{ text = "Feel the power of my magic, tiny mortal!", yell = false },
}

monster.loot = {
	{ id = 2659, chance = 2560 },
	{ name = "gold coin", chance = 60000, maxCount = 70 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -90 },
	{ name = "combat", interval = 2000, chance = 10, type = COMBAT_ENERGYDAMAGE, minDamage = -100, maxDamage = -250, range = 7, shootEffect = CONST_ANI_ENERGYBALL, target = false },
	{ name = "speed", interval = 2000, chance = 15, speedChange = -650, range = 7, effect = CONST_ME_MAGIC_RED, target = false, duration = 1500 },
}

monster.defenses = {
	defense = 20,
	armor = 24,
	mitigation = 0.91,
	{ name = "combat", interval = 2000, chance = 15, type = COMBAT_HEALING, minDamage = 50, maxDamage = 80, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 60 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "invisible", condition = true },
}

mType:register(monster)
```

## Template completo (todos os grupos de campo suportados)

```lua
local mType = Game.createMonsterType("Monster Name")
local monster = {}

-- Basico
monster.name = "Monster Name" -- opcional, normalmente o createMonsterType ja define
monster.description = "a monster name"
monster.variant = "optional_variant"
monster.experience = 0
monster.skull = SKULL_NONE -- opcional

-- Outfit
monster.outfit = {
	lookType = 0,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

-- Vida/atributos
monster.health = 100
monster.maxHealth = 100
monster.race = "blood" -- blood/venom/undead/fire/energy...
monster.corpse = 0
monster.speed = 100
monster.manaCost = 0

-- Bestiary / Bosstiary
monster.raceId = 30001
monster.Bestiary = {
	class = "Pet",
	race = BESTY_RACE_MAGICAL,
	toKill = 250,
	FirstUnlock = 25,
	SecondUnlock = 100,
	CharmsPoints = 5,
	Stars = 2,
	Occurrence = 0,
	Locations = "Kingdom of Pets",
}

monster.bosstiary = {
	bossRace = RARITY_ARCHFOE,
	bossRaceId = 50001,
}

-- Faccao
monster.faction = FACTION_DEFAULT
monster.enemyFactions = { FACTION_PLAYER }
monster.targetPreferPlayer = true
monster.targetPreferMaster = false

-- Flags
monster.flags = {
	attackable = true,
	convinceable = false,
	summonable = false,
	isPreyable = true,
	isPreyExclusive = false,
	illusionable = false,
	hostile = true,
	healthHidden = false,
	pushable = false,
	canPushItems = false,
	canPushCreatures = false,
	rewardBoss = false,
	familiar = false,
	critChance = 0,
	targetDistance = 1,
	runHealth = 0,
	staticAttackChance = 90,
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = false,
	isBlockable = false,
	isForgeCreature = false,
}

-- Luz
monster.light = {
	level = 0,
	color = 0,
}

-- Troca de alvo e estrategia
monster.changeTarget = {
	interval = 4000,
	chance = 10,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
}

-- Respawn (opcional)
monster.respawnType = {
	period = 0,
	underground = false,
}

-- Sons (opcional)
monster.sounds = {
	death = SOUND_EFFECT_TYPE_MONSTER_DEATH,
	ticks = 5000,
	chance = 20,
	ids = { SOUND_EFFECT_TYPE_MONSTER_BARK },
}

-- Falas
monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "...", yell = false },
}

-- Summons
monster.summon = {
	maxSummons = 2,
	summons = {
		{ name = "Summon Name", chance = 10, interval = 2000, count = 1 },
	},
}

-- Creature events vinculados
monster.events = {
	"EventName1",
	"EventName2",
}

-- Loot
monster.loot = {
	{ name = "gold coin", chance = 50000, minCount = 1, maxCount = 100 },
	{ id = 1234, chance = 1000, actionId = 0, text = "", unique = false },
	{
		name = "backpack",
		chance = 500,
		child = {
			{ name = "small ruby", chance = 2000 },
		},
	},
}

-- Resistencias
monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
	{ type = COMBAT_EARTHDAMAGE, percent = 0 },
	{ type = COMBAT_FIREDAMAGE, percent = 0 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 },
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.reflects = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
}

monster.heals = {
	{ type = COMBAT_HEALING, percent = 0 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
	{ type = COMBAT_FIREDAMAGE, combat = true },
}

-- Ataques
monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -50 },
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -50, maxDamage = -120, range = 7, radius = 3, target = true, effect = CONST_ME_FIREAREA, shootEffect = CONST_ANI_FIRE },
	{ name = "speed", interval = 2000, chance = 10, speedChange = -500, duration = 4000, range = 7, target = true, effect = CONST_ME_MAGIC_RED },
	{ name = "drunk", interval = 2000, chance = 10, duration = 6000, range = 7, target = true },
	{ name = "outfit", interval = 2000, chance = 5, duration = 3000, outfitMonster = "rat", target = true },
	{ name = "condition", interval = 2000, chance = 10, type = CONDITION_POISON, minDamage = -10, maxDamage = -20 },
	{
		script = "spells/monster/custom_pet_spell",
		interval = 2000,
		chance = 10,
		target = true,
		minDamage = -20,
		maxDamage = -60,
	},
}

-- Defesas
monster.defenses = {
	defense = 15,
	armor = 10,
	mitigation = 0.50,
	{ name = "combat", interval = 2000, chance = 10, type = COMBAT_HEALING, minDamage = 20, maxDamage = 50, effect = CONST_ME_MAGIC_BLUE, target = false },
}

mType:register(monster)
```

## Campos de spell (ataques/defesas) suportados pelo parser
Fonte: `data/scripts/lib/register_monster_type.lua` funcao `readSpell(...)`.

Campos aceitos em cada spell table:
- `name`, `script`
- `attack`, `skill`
- `interval`, `chance`, `range`, `target`
- `type`
- `minDamage`, `maxDamage`, `startDamage`
- `duration`, `speedChange`
- `radius`, `length`, `spread`
- `effect`, `shootEffect` (ou `shooteffect`)
- `outfitMonster`, `outfitItem`
- `condition = { type, duration, interval, totalDamage }`
- `soundCast`, `impactCast`

## Observacao para gerador
Para gerar monsters consistentes em massa:
- sempre preencher `raceId` unico;
- sempre preencher bloco `Bestiary`;
- manter estrutura padrao acima e variar apenas `outfit`, `hp`, `exp`, `attacks`.
