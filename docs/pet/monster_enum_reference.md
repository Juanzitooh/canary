# Referencia de Enums para Monster Lua

## Como os enums chegam no Lua
Os enums usados nos arquivos de monster sao expostos ao Lua em:
- `src/lua/functions/core/game/lua_enums.cpp`

Se um valor existe em C++ mas nao foi `registerEnum(...)` nesse arquivo, ele nao estara disponivel direto no Lua.

## Mapa rapido: campo -> enum esperado
| Campo no monster | Tipo esperado |
|---|---|
| `attacks[].type` | `COMBAT_*` ou `CONDITION_*` (quando spell de condition) |
| `elements[].type` | `COMBAT_*` |
| `reflects[].type` | `COMBAT_*` |
| `heals[].type` | `COMBAT_*` |
| `Bestiary.race` | `BESTY_RACE_*` |
| `faction` / `enemyFactions[]` | `FACTION_*` |
| `bosstiary.bossRace` | `RARITY_*` |
| `attacks[].effect` | `CONST_ME_*` |
| `attacks[].shootEffect` | `CONST_ANI_*` |
| `race` | string mapeada para `RaceType_t` |

## Enums principais usados em monsters

### 1) Combat (`COMBAT_*`)
Uso tipico:
- `monster.attacks[].type`
- `monster.elements[].type`
- `monster.reflects[].type`
- `monster.heals[].type`

Onde encontrar:
- definicao C++: `src/creatures/creatures_definitions.hpp` (`enum CombatType_t`)
- exposicao Lua: `src/lua/functions/core/game/lua_enums.cpp` (`registerEnum(L, COMBAT_...)`)

Exemplos:
- `COMBAT_PHYSICALDAMAGE`
- `COMBAT_FIREDAMAGE`
- `COMBAT_ENERGYDAMAGE`
- `COMBAT_EARTHDAMAGE`
- `COMBAT_ICEDAMAGE`
- `COMBAT_HOLYDAMAGE`
- `COMBAT_DEATHDAMAGE`
- `COMBAT_LIFEDRAIN`
- `COMBAT_MANADRAIN`
- `COMBAT_DROWNDAMAGE`

### 2) Condition (`CONDITION_*`)
Uso tipico:
- `monster.attacks[].type` quando `name = "condition"`
- `monster.immunities[]` (campo `condition = true`)

Onde encontrar:
- definicao C++: `src/creatures/creatures_definitions.hpp` (`enum ConditionType_t`)
- parser de monster spell: `data/scripts/lib/register_monster_type.lua` (`readSpell`)

Exemplos:
- `CONDITION_POISON`
- `CONDITION_PARALYZE`
- `CONDITION_DRUNK`
- `CONDITION_INVISIBLE`

### 3) Race visual do sangue (`monster.race`)
Uso tipico:
- `monster.race = "blood"`

Onde encontrar:
- enum base C++: `src/creatures/creatures_definitions.hpp` (`enum RaceType_t`)
- mapeamento string -> enum: `src/lua/functions/creatures/monster/monster_type_functions.cpp`

Strings comuns aceitas:
- `"venom"`, `"blood"`, `"undead"`, `"fire"`, `"energy"`, `"ink"`, `"chocolate"`, `"candy"`

### 4) Bestiary race (`BESTY_RACE_*`)
Uso tipico:
- `monster.Bestiary.race`

Onde encontrar:
- definicao C++: `src/creatures/creatures_definitions.hpp` (`enum BestiaryType_t`)
- exposicao Lua: `src/lua/functions/core/game/lua_enums.cpp` (`initBestiaryEnums`)

Exemplos:
- `BESTY_RACE_MAGICAL`
- `BESTY_RACE_HUMANOID`
- `BESTY_RACE_DRAGON`
- `BESTY_RACE_UNDEAD`

### 5) Factions (`FACTION_*`)
Uso tipico:
- `monster.faction`
- `monster.enemyFactions`

Onde encontrar:
- definicao C++: `src/game/game_definitions.hpp` (`enum Faction_t`)
- exposicao Lua: `src/lua/functions/core/game/lua_enums.cpp` (`registerEnum(L, FACTION_...)`)

Exemplos:
- `FACTION_DEFAULT`
- `FACTION_PLAYER`
- `FACTION_MARID`
- `FACTION_EFREET`

### 6) Bosstiary rarity (`RARITY_*`)
Uso tipico:
- `monster.bosstiary.bossRace`

Onde encontrar:
- definicao C++: `src/io/io_bosstiary.hpp` (`enum class BosstiaryRarity_t`)
- uso no parser Lua: `data/scripts/lib/register_monster_type.lua`

Exemplos:
- `RARITY_BANE`
- `RARITY_ARCHFOE`
- `RARITY_NEMESIS`

### 7) Efeitos visuais (`CONST_ME_*`, `CONST_ANI_*`)
Uso tipico:
- `monster.attacks[].effect` -> `CONST_ME_*`
- `monster.attacks[].shootEffect` -> `CONST_ANI_*`

Onde encontrar:
- definicoes base: `src/utils/utils_definitions.hpp`
- exposicao Lua: `src/lua/functions/core/game/lua_enums.cpp`

Exemplos:
- `CONST_ME_FIREAREA`
- `CONST_ME_ENERGYHIT`
- `CONST_ANI_FIRE`
- `CONST_ANI_ENERGYBALL`

## Como listar enums rapidamente (comandos)
```bash
rg -n "registerEnum\(L, (COMBAT_|CONDITION_|BESTY_RACE_|FACTION_|RARITY_|CONST_ME_|CONST_ANI_)" src/lua/functions/core/game/lua_enums.cpp
rg -n "enum (CombatType_t|ConditionType_t|BestiaryType_t|RaceType_t)" src/creatures/creatures_definitions.hpp
rg -n "enum Faction_t" src/game/game_definitions.hpp
rg -n "enum class BosstiaryRarity_t" src/io/io_bosstiary.hpp
```

## O que pode ser em cada bloco do monster
Referencia do parser:
- `data/scripts/lib/register_monster_type.lua`

Blocos principais suportados:
- `Bestiary`, `bosstiary`
- `flags`, `light`, `changeTarget`, `strategiesTarget`, `respawnType`
- `sounds`, `voices`, `summon`, `events`, `loot`
- `elements`, `reflects`, `heals`, `immunities`
- `attacks`, `defenses`

## Regra pratica para geracao em massa
Antes de gerar um novo bicho, validar:
1. `raceId` unico e nao-zero.
2. `Bestiary.race` com `BESTY_RACE_*` valido.
3. `type` dos ataques com `COMBAT_*`/`CONDITION_*` valido.
4. `effect`/`shootEffect` usando `CONST_ME_*`/`CONST_ANI_*` existentes.
