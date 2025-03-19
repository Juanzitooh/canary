if not Quests then
	Quests = {
		[1] = {
			name = "Example",
			startStorageId = Storage.Quest.ExampleQuest.Example,
			startStorageValue = 1,
			missions = {
				[1] = {
					name = "The Hidden Seal",
					storageId = Storage.Quest.ExampleQuest.Example,
					missionId = 1,
					startValue = 1,
					endValue = 1,
					description = "You broke the first seal.",
				},
			},
		},
		[2] = {
			name = "O chamado",
			startStorageId = Storage.Quest.Chamado.Start,
			startStorageValue = 1,
			missions = {
				[1] = {
					name = "Aceitando o chamado",
					storageId = Storage.Quest.Chamado.Start,
					missionId = 1,
					startValue = 1,
					endValue = 2,
					description = "Use o que você tem na mochila para chegar ate o portal dourado e aceitar ir para o Reino Elemental.",
				},
				[2] = {
					name = "Profissoes Comuns da Raça",
					storageId = Storage.Quest.Chamado.Start,
					missionId = 2,
					startValue = 2,
					endValue = 3,
					description = "Fale com Gerfan, Ele pode te ensinar sobre as profissoes que sao a base da economia no Reino Elemental e ainda te conceder uma licenca de Extracao de Recursos.",
				},
				[3] = {
					name = "Aprendendo Sobre os elementos",
					storageId = Storage.Quest.Chamado.Start,
					missionId = 3,
					startValue = 3,
					endValue = 4,
					description = "Fale com asfalor para escolher uma vocacao de combate e melhorar sua afinidade com as artes e os elementos.",
				},
				[4] = {
					name = "Aprendendo sobre profissoes especializadas.",
					storageId = Storage.Quest.Chamado.Start,
					missionId = 4,
					startValue = 4,
					endValue = 5,
					description = "Fale novamente com Gerfan para pegar uma profissão especializada e Conquistar sua licenca de Produtor",
				},
				[5] = {
					name = "Aprofundamento do Estudo dos Elementos.",
					storageId = Storage.Quest.Chamado.Start,
					missionId = 5,
					startValue = 5,
					endValue = 6,
					description = "Como ja deve ter notado, todo o mundo é regido pelo dominio dos elementos, e so tem como ter avanco nesse reino aprendendo sobre eles, para prosseguir sua jornada e explorar o mundo pergunte ao askalor sobre as Academias.",
				},
			}
		},
		[3] = {
			name = "A Base da Economia",
			startStorageId = Storage.Quest.Chamado.ProfissaoComum,
			startStorageValue = 1,
			missions = {
				[1] = {
					name = "Extraindo Recursos",
					storageId = Storage.Quest.Chamado.ProfissaoComum,
					missionId = 1,
					startValue = 1,
					endValue = 2,
					description = "ao norte, no pier, tem um comerciante chamado tadeu. Fale com ele e pegue suas ferramentas iniciais para conseguir exercer a sua profissao.",
				},
				[2] = {
					name = "Registro de Comerciante",
					storageId = Storage.Quest.Chamado.ProfissaoComum,
					missionId = 2,
					startValue = 2,
					endValue = 3,
					description = "Isso mesmo assim que se extrai recursos, leve alguns deles para o Gerfan e consiga sua licenca de Extracao valida em todo o reino.",
				},
				[3] = {
					name = "Vendendo Recursos a Guilda de Comerciantes",
					storageId = Storage.Quest.Chamado.ProfissaoComum,
					missionId = 3,
					startValue = 3,
					endValue = 4,
					description = "Agora que ganhou sua licensa negocie com Tadeu, Ao falar 'oi' e depois 'negociar' para qualquer comerciante ele ira te mostrar as ofertas.",
				},
			}
		},
		[4] = {
			name = "Introducao ao combate",
			startStorageId = Storage.Quest.Chamado.FormaElemental,
			startStorageValue = 1,
			missions = {
				[1] = {
					name = "Transformacao Elemental",
					storageId = Storage.Quest.Chamado.FormaElemental,
					missionId = 1,
					startValue = 1,
					endValue = 2,
					description = "Agora que escolheu uma arte de combate e uma afinidade elemental, pode se transformar na sua forma de combate, va em uma arvore magica que emana eter e a use.",
				},
				[2] = {
					name = "Preparacao",
					storageId = Storage.Quest.Chamado.FormaElemental,
					missionId = 2,
					startValue = 2,
					endValue = 3,
					description = "Somente na forma elemental consegue evoluir seu nivel, mas e importante ter bons equipamentos, procure um bau no segundo andar da casa de askalor, e o use para ganhar o set inicial da sua vocacao de combate.",
				},
				[3] = {
					name = "A Primeira Batalha",
					storageId = Storage.Quest.Chamado.FormaElemental,
					missionId = 3,
					startValue = 3,
					endValue = 4,
					description = "Mostre que e habil tambem no combate, encontre ratos e lobos para testar suas novas habilidades e equipamentos, lute ate alcancar o nivel 10 e reporte a askalor sobre a aventura.",
				},
			}
		},
		[5] = {
			name = "Produzindo Itens",
			startStorageId = Storage.Quest.Chamado.ProfissaoEspecializada,
			startStorageValue = 1,
			missions = {
				[1] = {
					name = "Utilizando recursos",
					storageId = Storage.Quest.Chamado.ProfissaoEspecializada,
					missionId = 1,
					startValue = 1,
					endValue = 2,
					description = "Utilize itens ja extraidos ou compre com tadeu para criar receitas para exercer sua nova profissao.",
				},
				[2] = {
					name = "Aumentando o Capital",
					storageId = Storage.Quest.Chamado.ProfissaoEspecializada,
					missionId = 2,
					startValue = 2,
					endValue = 3,
					description = "Ganhe 1000 moedas de ouro vendendo os itens que tadeu está procurando, fale com ele para saber quais voce pode vender a ele.",
				},
				[3] = {
					name = "Melhorando a licenca de comercio",
					storageId = Storage.Quest.Chamado.ProfissaoEspecializada,
					missionId = 3,
					startValue = 3,
					endValue = 4,
					description = "Parabens agora que sabe o basico da economia pode ir ate o gerfan e pedir para melhorar sua licenca de comercio para Produtor.",
				},
			}
		},
	}
end
