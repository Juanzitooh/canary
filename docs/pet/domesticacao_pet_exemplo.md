# Exemplo - Domesticacao de Mount para Familiar

## Objetivo
Definir um exemplo pratico para transformar uma mount em familiar com:
- item unico de domesticacao;
- chance de sucesso;
- custo de mana;
- possibilidade de obter por store, quest ou drop.

## Exemplo escolhido
- Mount: `Widow Queen`
- `mountId`: `1`
- Familiar resultante: `Pet Widow Queen`
- Slot alvo: `slot 1` (familiar montavel)

## Fluxo funcional
1. Player encontra/gera a criatura `Pet Widow Queen` no mundo.
2. Player usa item unico de domesticacao no alvo.
3. Sistema valida requisitos (mana, cooldown, slot livre, alvo valido).
4. Rola chance de sucesso.
5. Se sucesso:
- criatura vira familiar do player;
- mount `1` e concedida (se ainda nao tiver);
- estado persistido em `kv`.
6. Se falha:
- item consumido (ou parcialmente consumido, regra de balance);
- aplica cooldown curto de nova tentativa.

## Item unico de domesticacao
Sugestao:
- nome: `Sigilo de Vinculo`
- id temporario: `ITEM_ID_PLACEHOLDER`
- uso: somente em criaturas com tag `petTameable = true`

Campos sugeridos do item:
- `targetType = monster`
- `consumeOnUse = true`
- `requiredMana = 120`
- `requiredLevel = 20`

## Regras de chance
Chance base sugerida:
- `baseChance = 20%`

Modificadores sugeridos:
- +`0.15%` por level do jogador acima do minimo
- +`2%` se player ja tiver titulo/achievement de domesticacao
- +`5%` se usar versao rara do item (futuro)
- cap maximo: `60%`

Formula:
`finalChance = min(60, baseChance + levelBonus + achievementBonus + itemBonus)`

## Regras de mana

### 1) No momento de domesticar
- custo instantaneo: `120 mana`

### 2) Familiar ativo (upkeep)
- custo por tick (2s): `8 mana`
- se montado no familiar: `+4 mana`

### 3) Skills do familiar
- skill 1: `20 mana`
- skill 2: `35 mana`
- skill 3: `55 mana`

Fallback sem mana:
- familiar entra em `passive` e bloqueia skills por `3s`.

## Persistencia sugerida (KV)
- `pet.slot1.mountId = 1`
- `pet.slot1.monsterName = "Pet Widow Queen"`
- `pet.slot1.state = active|mounted|passive`
- `pet.slot1.tamed = true`
- `pet.slot1.tamedAt = <timestamp>`

## Canais de obtencao do familiar

### A) Domesticacao por item (core gameplay)
- player usa item e tenta domesticar no mundo.

### B) Store direta
- compra mount concede familiar direto no slot 1.
- manter compativel com fluxo atual de store (`player:addMount`).

### C) Quest
- reward de quest concede:
  - item de domesticacao; ou
  - vinculo direto com chance 100% (boss/quest rara).

## Integracao com o sistema atual
Referencias existentes no projeto:
- tame por action/item: `data-otservbr-global/scripts/actions/mounts/mounts.lua`
- itens que concedem mount: `data/scripts/actions/items/usable_mount_items.lua`
- compra por store: `data/libs/gamestore/purchases.lua`
- comando admin: `data/scripts/talkactions/god/add_mount.lua`

## Pseudocodigo (Lua)
```lua
function tryTamePet(player, targetMonster, tameItem)
  if targetMonster:getName() ~= "Pet Widow Queen" then
    return false, "Alvo invalido."
  end

  if player:getMana() < 120 then
    return false, "Mana insuficiente."
  end

  if not isSlot1Free(player) then
    return false, "Slot 1 ocupado."
  end

  player:addMana(-120)
  tameItem:remove(1)

  local chance = calculateTameChance(player, tameItem)
  if math.random(100) <= chance then
    bindPetToPlayer(player, targetMonster, 1)
    if not player:hasMount(1) then
      player:addMount(1)
    end
    return true, "Voce domesticou a Pet Widow Queen."
  end

  applyTameCooldown(player, 10)
  return false, "A criatura resistiu ao vinculo."
end
```

## Variacoes prontas para escala
Mesmo modelo para qualquer mount:
- trocar `mountId`
- trocar `monsterName`
- ajustar `baseChance`
- ajustar custo de mana por tier da criatura

## Proximo passo recomendado
Criar a tabela central:
- `pet_taming_config.lua` com:
  - `mountId`
  - `monsterName`
  - `tameItemId`
  - `baseChance`
  - `manaCost`
  - `skillCosts`
