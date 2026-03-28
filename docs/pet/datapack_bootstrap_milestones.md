# Milestones - Pet Feature Isolada (Mount + Familiar)

## Status deste documento
Este roadmap substitui o planejamento anterior e reinicia a execucao a partir do zero.

Regra de precedencia:
- este arquivo e a fonte oficial de milestones do modulo pet;
- milestones antigas em outros arquivos de `docs/pet` passam a ser referencia historica;
- quando houver conflito, seguir este documento.

## Objetivo
Entregar uma feature isolada que unifica montaria e familiar no mesmo sistema de pets, sem criar nova vocacao e sem quebrar o fluxo padrao do jogo.

## Premissas obrigatorias
- manter apenas vocacoes padrao do jogo;
- nao criar `Conjurador/Invocador` nem alterar IDs de vocacao;
- priorizar implementacao em Lua/datapack (source apenas com bloqueio real);
- manter rollout reversivel por flag/storage e por area piloto.

## Escopo funcional (v2)
- `slot 1`: pet ligado a montaria ativa (`mountId -> petMonster`);
- `slot 2`: familiar/pet secundario com regras de desbloqueio;
- `control_slot`: define qual slot recebe comandos de skill;
- maximo de 2 criaturas ativas por jogador;
- bestiary obrigatorio para todos os pets gerados.

## Nao escopo (agora)
- nova vocacao ou rework de vocacoes;
- migracao global imediata de todos os spawns do mundo;
- balance economico final de loja/cosmeticos;
- refatoracao ampla de source C++ sem bloqueio tecnico.

## Milestones oficiais

### M0 - Reset de baseline e guardrails
Criterio de saida:
- direcao v2 documentada e aceita;
- regras de rollback e observabilidade definidas;
- ambiente pronto para validar sem downtime prolongado.

Tasks:
- `T0.1` consolidar docs de direcao em `docs/pet/README.md`.
- `T0.2` definir flag/storage global para ligar/desligar pet system.
- `T0.3` definir checklist de validacao rapida (login, summon, mount toggle, logout/login).

### M1 - Catalogo Pet + Bestiary
Criterio de saida:
- catalogo inicial de pets carregando sem erro;
- `raceId` unico por pet na faixa reservada;
- bestiary funcional para os pets do lote inicial.

Tasks:
- `T1.1` consolidar template de monster pet e naming canonico.
- `T1.2` manter index `mountId -> monsterName/raceId/lookType`.
- `T1.3` validar lote inicial MVP (`PET-001..PET-010`) com reload limpo.

### M2 - Orquestrador isolado de slots
Criterio de saida:
- modulo Lua de pet isolado do restante do jogo;
- estado persistido por player para `slot1/slot2/control_slot`;
- regras de limite e ownership aplicadas.

Tasks:
- `T2.1` criar `pet_system` em libs com API minima (`summon`, `despawn`, `setControlSlot`, `setMode`).
- `T2.2` persistir estado em KV/storage com recuperacao em relog.
- `T2.3` validar regras: max 2 criaturas e 1 mount-link por vez.

### M3 - Integracao Mount -> Pet (slot 1)
Criterio de saida:
- montar/desmontar sincroniza estado do slot 1;
- mount visual e pet vinculado operam como uma unidade logica;
- comportamento montado nao duplica summon nem quebra follow.

Tasks:
- `T3.1` implementar sincronismo de estado montado (`MOUNTED_LINKED`/`UNMOUNTED_ACTIVE`).
- `T3.2` definir fallback Lua-first para detectar toggle de mount.
- `T3.3` validar edge cases (relog montado, death, teleport, dispell).

### M4 - Integracao Familiar (slot 2) e comandos
Criterio de saida:
- familiar atual opera no mesmo orquestrador do pet;
- comando de controle unificado funcionando por slot;
- troca de `control_slot` estavel em combate.

Tasks:
- `T4.1` adaptar fluxo de familiar para usar `slot 2`.
- `T4.2` padronizar comando `pet <slot> <skillId> [target]`.
- `T4.3` manter alvo padrao no target atual do player quando aplicavel.

### M5 - Combate, mana e balance inicial
Criterio de saida:
- custo por upkeep/cast funcional e auditavel;
- skills por pet com cooldown e anti-spam;
- balance inicial aceitavel para PvE sem quebrar PvP.

Tasks:
- `T5.1` implementar upkeep de mana por criatura ativa.
- `T5.2` implementar custo por skill com escala por tier.
- `T5.3` aplicar fallback sem mana (passive ou bloqueio de skill).

### M6 - Rollout controlado e migracao por lotes
Criterio de saida:
- area piloto pet-first validada ponta a ponta;
- plano de expansao para `PET-011..PET-235` definido;
- operacao com rollback simples documentado.

Tasks:
- `T6.1` migrar apenas area piloto para spawns pet.
- `T6.2` executar bateria de testes (load/reload/bestiary/combat).
- `T6.3` publicar runbook de rollout e rollback.

## Ordem de execucao oficial
`M0 -> M1 -> M2 -> M3 -> M4 -> M5 -> M6`

## Relacao com outros arquivos
- backlog por criatura: `docs/pet/monster_tasks_index.md`.
- milestones de geracao de monsters: `docs/pet/monster_creation_milestones.md` (subplano tecnico).
- briefing tecnico de arquitetura: `docs/pet/mounts_pet_system_briefing.md`.

## Proxima task recomendada
`T0.2` definir feature flag/storage global e registrar comportamento de rollback.
