# Milestones de Criacao de Monsters (Pet System)

## Objetivo
Organizar a criacao dos monsters de pet em fases executaveis, com 1 task por bicho.

## Diretriz atual de execucao
- foco do MVP: apenas `PET-001..PET-010`;
- cada pet MVP deve sair completo com:
  - `raceId` + `Bestiary`;
  - 3 magias unicas;
  - validacao de combate e reload;
- `PET-011..PET-235` ficam como backlog pos-MVP.

## Estrutura de IDs
- Milestones: `M1`, `M2`, `M3`, `M4`
- Tasks gerais: `T1.x`, `T2.x`, ...
- Task por bicho: `PET-<mountId>` (ex.: `PET-001`, `PET-235`)

## Milestones

### M1 - Base tecnica pronta
Criterio de saida:
- template/master de monster validado;
- referencia de enums pronta;
- indice de tasks por bicho gerado.

Tasks:
- `T1.1` consolidar template (`monster_lua_model_full_fields.md`)
- `T1.2` consolidar enums (`monster_enum_reference.md`)
- `T1.3` gerar backlog por mount (`monster_tasks_index.md`)

### M2 - Geracao inicial dos pets
Criterio de saida:
- 10 arquivos MVP `monster/pet/*.lua` gerados;
- todos com `raceId` unico + `Bestiary`;
- todos com 3 magias unicas.

Tasks:
- `T2.1` gerar lote MVP (10 pets)
- `T2.2` validar carga/reload
- `T2.3` adiar lote completo (11..235) para pos-MVP

### M3 - Balance e comportamento
Criterio de saida:
- cada pet com perfil de ataque definido;
- comandos de controle funcionando por slot.

Tasks:
- `T3.1` definir presets por arquetype (arcane/brute/ranged/guardian)
- `T3.2` aplicar escala por stats do master
- `T3.3` validar pve/pvp e cooldowns

### M4 - Integracao de mundo
Criterio de saida:
- spawns da area piloto migrados para ecossistema pet MVP;
- bestiary funcional ponta-a-ponta.

Tasks:
- `T4.1` migrar area piloto de spawn
- `T4.2` manter spawns restantes para fase pos-MVP
- `T4.3` auditoria final de bestiary/task/prey

## Backlog por bicho
Arquivo fonte do backlog por criatura:
- `docs/pet/monster_tasks_index.md`

Regra:
- cada linha `PET-xxx` representa um monster pet a criar/revisar.
