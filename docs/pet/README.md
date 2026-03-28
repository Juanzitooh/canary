# Pet Docs - Direcao Atual

## Objetivo atual
Construir uma feature isolada para unificar montaria e familiar no Canary, mantendo apenas as vocacoes padrao do jogo.

## Regras de produto (ativas)
- sem vocacao nova;
- sem alterar IDs de vocacao;
- mount e familiar operando via sistema de slots (`slot1` e `slot2`);
- maximo de 2 criaturas ativas por jogador;
- implementacao Lua-first.

## Ordem de leitura recomendada
1. `docs/pet/datapack_bootstrap_milestones.md` (fonte oficial de milestones)
2. `docs/pet/mounts_pet_system_briefing.md` (arquitetura e regras tecnicas)
3. `docs/pet/monster_creation_milestones.md` (subplano de criacao de monsters)
4. `docs/pet/monster_tasks_index.md` (backlog por mount)

## Documentos historicos (legado)
Os arquivos abaixo continuam uteis como referencia tecnica, mas nao sao a direcao oficial atual:
- `docs/pet/vocacao_conjurador_invocador.md`
- `docs/pet/kingdom_pets_canary_porting_llm.md`
- demais docs que assumem vocacao nova.

Em caso de conflito, prevalece:
- `docs/pet/datapack_bootstrap_milestones.md`
- `docs/pet/mounts_pet_system_briefing.md`
