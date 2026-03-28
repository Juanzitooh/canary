# Progressao de Familiares - Convencer, Domesticar, Conjurar/Invocar

## Objetivo
Definir uma progressao clara para obtencao e controle de pets no Kingdom of Pets, com foco em:
- aprendizado de manejo (player + pet);
- progressao por conhecimento da criatura (bestiary);
- separacao entre captura temporaria e desbloqueio permanente.

## Decisao de design (resumo)
- `Convencer` = captura temporaria de criatura viva.
- `Conjurar/Invocar` = chamada permanente de criatura ja dominada.
- bestiary e a base de progressao entre os dois estados.

## Diferenca entre os modos

### 1) Convencer (temporario)
- requer criatura alvo no mapa;
- consome mana no cast;
- consome item de vinculo;
- pode falhar (chance);
- se sucesso, cria vinculo temporario no slot;
- expira por tempo/condicao.

### 2) Conjurar/Invocar (permanente)
- nao requer criatura alvo no mapa;
- chama a criatura do catalogo do player;
- requer desbloqueio permanente da especie;
- consome mana de ativacao + upkeep;
- sem rolagem de chance no cast (gate ja cumprido).

## Gate por Bestiary (proposta)

### Fase A - Captura inicial
- bestiary baixo: pode `convencer`, com chance modesta e duracao curta.

### Fase B - Especializacao
- bestiary medio/alto: aumenta chance e duracao do `convencer`.

### Fase C - Dominio
- bestiary completo da criatura + requisito extra (quest/item/titulo):
  - libera `conjurar/invocar` dessa especie em definitivo.

## Regras de controle em combate
- player mantem magias proprias normalmente;
- pet controlado usa magias de pet;
- se skill do pet exigir target e nenhum parametro for enviado:
  - usa target atual do player;
- se skill nao exigir target:
  - executa sem alvo explicito;
- skills de area/direcionais:
  - origem no pet;
  - montado: mesma posicao do player.

## Regras de recurso (mana + item)
- `Convencer`:
  - custo de mana no uso;
  - item consumivel obrigatorio;
  - cooldown de tentativa.
- `Conjurar/Invocar`:
  - custo de mana de ativacao;
  - upkeep por tick enquanto ativo.

## Integracao com slots
- ate 2 criaturas ativas;
- 1 slot de controle principal (`control_slot`) para input de skill;
- troca rapida de controle entre slot 1 e slot 2.

## Milestones sugeridos (foco implementacao)

### M-C1 - Convencer base
- comando/acao de `convencer`;
- consumo de item + mana;
- chance + cooldown;
- persistencia temporaria em KV.

### M-C2 - Progressao por bestiary
- formula de bonus por faixa de bestiary;
- duracao temporaria escalada;
- auditoria de equilibrio inicial.

### M-C3 - Desbloqueio permanente
- regra de unlock por bestiary completo;
- requisito complementar (quest/item/titulo);
- cadastro da criatura no catalogo de invocacao.

### M-C4 - Conjurar/Invocar
- comando de invocacao sem alvo vivo;
- custo de ativacao + upkeep;
- uso do `control_slot` para skills do pet.

## Observacoes de escopo
- manter implementacao Lua-first;
- usar source somente se houver bloqueio tecnico sem workaround.
