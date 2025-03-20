--[[
Reserved player action storage key ranges (const.hpp)
	It is possible to place the storage in a quest door, so the player who has that storage will go through the door

	Reserved player action storage key ranges (const.hpp at the source)
	[10000000 - 20000000]
	[1000 - 1500]
	[2001 - 2011]

	Others reserved player action/storages
	[100] = unmovable/untrade/unusable items
	[101] = use pick floor
	[102] = well down action
	[103-120] = others keys action
	[103] = key 0010
	[303] = key 0303
	[1000] = level door. Here 1 must be used followed by the level.
	Example: 1010 = level 10,
	1100 = level 100]

	Questline = Storage through the Quest
]]

Storage = {
	Quest = {
		Key = {
			ID1000 = 103,
		},
		Item = {
			FerramentaInicial = 2000004,
		},
		ExampleQuest = {
			Example = 9000,
			Door = 9001,
		},
		Chamado = {
			Start = 2100000, -- Quest Inicial Principal
			ProfissaoComum = 2100001, -- Sub quest de profissões comuns
			FormaElemental = 2100002, -- Sub Quest de Combate
			ProfissaoEspecializada = 2100003, -- Sub Quest de Profissões especializadas
		},
		Caminho = {
			-- Quest de melhoria da Vocação e aprendizagem de magias.(a primeira missão deve ser criada antes de lançar o beta)
			CaminhoGuerreiroFogo = 2100099,
			CaminhoGuerreiroAgua = 2100100,
			CaminhoGuerreiroTerra = 2100101,
			CaminhoGuerreiroAr = 2100102,

			CaminhoArqueiroFogo = 2100103,
			CaminhoArqueiroAgua = 2100104,
			CaminhoArqueiroTerra = 2100105,
			CaminhoArqueiroAr = 2100106,

			CaminhoMagoFogo = 2100107,
			CaminhoMagoAgua = 2100108,
			CaminhoMagoTerra = 2100109,
			CaminhoMagoAr = 2100110,
		},
		Estudo = {
			-- Quests de estudo para aprofundamento nas profissões.
			Coleta = 2100199,
			Pesca = 2100200,
			Mineracao = 2100201,
			Culinaria = 2100202,
			Forja = 2100203,
			Artesanato = 2100204,
			Alquimia = 2100205,
			Joalheria = 2100206,

		},
		Heroi = {
			-- Quests de level alto(só serão criadas após o fim da missão elemental da arvore dos caminhos)
			MestreArtesClassicas = 2100299,
			CondutorElementosComuns = 2100300,
			OHeroi = 2100301,
		},
	},

	DelayLargeSeaShell = 30002,
	Imbuement = 30004,
}

GlobalStorage = {
	ExampleQuest = {
		Example = 60000,
	},
}
