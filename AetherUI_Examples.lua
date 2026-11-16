--[[
	AetherUI_Examples.lua
	Exemplos praticos baseados exclusivamente na API real da AetherUI (v2.7.0).
	Inclui exemplos com a API padronizada (Create* / estilo Rayfield), API classica (Add*),
	RadioGroup, Save Configuration (JSON + sistema de arquivos), biblioteca expandida
	de icones (65+ vetoriais e imagens personalizadas) e comportamento do Floating Dock.
]]

----------------------------------------------------------------
-- 1. Carregamento da biblioteca
----------------------------------------------------------------
-- Opcao A: via ModuleScript no Roblox Studio (LocalScript)
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local AetherUI = require(ReplicatedStorage:WaitForChild("AetherUI"))

-- Opcao B: via HttpGet + loadstring em executores (link RAW terminado em /AetherUI.lua)
-- Substitua USUARIO/REPOSITORIO pelo seu repositorio GitHub PUBLICO:
local AetherUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/tierryandrade60-lgtm/AetherUI.lua./main/AetherUI.lua"))()

----------------------------------------------------------------
-- 2. Configuracoes globais e registro de icones personalizados
----------------------------------------------------------------
AetherUI.SetAccent(Color3.fromRGB(124, 92, 255))
AetherUI.SetLowPerformance(false)

-- Registrar icone personalizado por imagem (rbxassetid://) ou formas vetoriais
AetherUI.RegisterIcon("meu_emblema", "rbxassetid://113083945240866")

-- Listar todos os nomes de icones disponiveis na biblioteca (65+ embutidos + custom)
local listaIcones = AetherUI.GetIcons()
print("[Icones] Disponiveis:", #listaIcones)

----------------------------------------------------------------
-- 3. Criacao da Janela (CreateWindow + ConfigurationSaving)
----------------------------------------------------------------
local Window = AetherUI.CreateWindow({
	Name = "AetherUI Studio Hub",      -- tambem define o titulo exibido caso Title nao seja passado
	Title = "AetherUI Studio Hub",     -- titulo opcional (sobrescreve Name na barra superior)
	Accent = Color3.fromRGB(124, 92, 255),
	Compact = false,                   -- true para layout compacto
	SidebarCollapsed = false,          -- true para iniciar com a barra lateral recolhida (apenas icones)
	CloseButton = true,                -- exibe o botao X com modal de confirmacao
	FavoritesTab = true,               -- exibe a aba exclusiva "Favoritos"
	FavoriteButton = true,             -- exibe o botao de estrela ao lado de minimizar
	ShowFavoriteStars = false,         -- inicia com as estrelas visiveis ou ocultas
	Settings = true,                   -- exibe a aba embutida "Interface"
	Dock = true,                       -- dock flutuante (aparece SOMENTE quando o painel esta minimizado)
	ConfigurationSaving = {
		Enabled = true,                -- carrega automaticamente a config salva se writefile/readfile existir
		FolderName = "AetherUIHub",
		FileName = "PerfilPrincipal",
	},
	Favorites = {},                    -- lista de chaves salvas (ex.: {"T::Principal"})
	OnFavoritesChanged = function(favoritos)
		-- Chamado sempre que um item e marcado ou desmarcado nos favoritos
		print("[Favoritos] Total:", #favoritos)
	end,
	OnClose = function()
		print("[AetherUI] Janela encerrada.")
	end,
})

----------------------------------------------------------------
-- 4. Aba Principal (API padronizada Create* + Icones + Flags)
----------------------------------------------------------------
local TabPrincipal = Window:CreateTab("Principal", "home")

-- Secao com texto e icone personalizado (tamanho e cor)
local SecaoGeral = TabPrincipal:CreateSection({
	Text = "Controles Gerais",
	Icon = { Name = "rocket", Size = 16, Color = Color3.fromRGB(124, 92, 255) },
})

-- Label informativo com icone embutido
local StatusLabel = TabPrincipal:CreateLabel({
	Text = "Status: pronto para uso",
	Icon = "sparkles",
})

-- Botao com icone personalizado em cor e tamanho
local BtnNotificar = TabPrincipal:CreateButton({
	Name = "Enviar notificacao",
	Icon = "bell",
	IconSize = 18,
	IconColor = Color3.fromRGB(72, 199, 128),
	Flag = "BotaoNotificar",
	Callback = function()
		AetherUI.Notify({
			Title = "AetherUI",
			Content = "Notificacao disparada pelo botao.",
			Type = "success",
			Duration = 3,
		})
	end,
})

-- Botao usando icone registrado via RegisterIcon
TabPrincipal:CreateButton({
	Name = "Testar icone personalizado",
	Icon = { Name = "meu_emblema", Size = 20, CornerRadius = 6 },
	Callback = function()
		local previewFrame = Instance.new("Frame")
		local iconeAvulso = AetherUI.CreateIcon("crown", previewFrame, 18, Color3.fromRGB(245, 176, 65))
		if iconeAvulso then
			print("[CreateIcon] Tipo criado:", iconeAvulso.Kind)
		end
		previewFrame:Destroy()
	end,
})

-- Toggle com Flag e leitura/atualizacao via CurrentValue ou Get/Set
local ToggleFarm = TabPrincipal:CreateToggle({
	Name = "Ativar modo automatico",
	Icon = "bolt",
	CurrentValue = false,
	Flag = "AutoMode",
	Callback = function(ativo)
		print("[AutoMode] Estado:", ativo)
		StatusLabel:SetText(ativo and "Status: modo automatico ativo" or "Status: parado")
	end,
})

-- Slider com Range, Increment, Suffix e Flag
local SliderVelocidade = TabPrincipal:CreateSlider({
	Name = "Velocidade",
	Icon = "gauge",
	Range = { 16, 200 },
	Increment = 2,
	Suffix = " studs/s",
	CurrentValue = 32,
	Flag = "Velocidade",
	Callback = function(valor)
		print("[Velocidade] Novo valor:", valor)
	end,
})

----------------------------------------------------------------
-- 5. Aba Combate (RadioGroup, Dropdown, MultiDropdown, ColorPicker)
----------------------------------------------------------------
local TabCombate = Window:CreateTab("Combate", "sword")

TabCombate:CreateSection({ Text = "Prioridade de Alvo", Icon = "crosshair" })

-- RadioGroup (v2.7.0) com Get, Set, Clear, Refresh e Flag
local RadioPrioridade = TabCombate:CreateRadioGroup({
	Name = "Modo de Prioridade",
	Icon = "crosshair",
	Options = { "Mais Proximo", "Menor Vida", "Maior Ameaça", "Aleatorio" },
	CurrentOption = "Mais Proximo",
	Flag = "PrioridadeAlvo",
	Callback = function(selecionado)
		print("[RadioGroup] Selecionado:", tostring(selecionado))
	end,
})

TabCombate:CreateSection({ Text = "Equipamento", Icon = "target" })

-- Dropdown de selecao unica (CreateDropdown passa uma tabela para o Callback)
local DropdownArma = TabCombate:CreateDropdown({
	Name = "Arma principal",
	Icon = "sword",
	Options = { "Espada", "Arco", "Cajado", "Adaga" },
	CurrentOption = { "Espada" },
	Flag = "ArmaPrincipal",
	Callback = function(opcoes)
		local escolhida = opcoes[1]
		print("[Arma] Selecionada:", tostring(escolhida))
	end,
})

-- MultiDropdown (tambem pode usar CreateDropdown com MultipleOptions = true)
local MultiModulos = TabCombate:CreateMultiDropdown({
	Name = "Modulos ativos",
	Icon = "layers",
	Options = { "ESP", "Radar", "Tracers", "Mira Assistida", "Anti-AFK" },
	CurrentOption = { "ESP", "Radar" },
	Flag = "ModulosAtivos",
	Callback = function(lista)
		print("[Modulos] Ativos:", table.concat(lista, ", "))
	end,
})

-- Equivalente usando CreateDropdown com MultipleOptions = true:
local MultiAlternativo = TabCombate:CreateDropdown({
	Name = "Filtros de alvo",
	Icon = "filter",
	Options = { "Jogadores", "NPCs", "Bosses" },
	CurrentOption = { "Jogadores" },
	MultipleOptions = true,
	Flag = "FiltrosAlvo",
	Callback = function(lista)
		print("[Filtros] Selecionados:", #lista)
	end,
})

TabCombate:CreateSection("Aparencia")

-- ColorPicker (seletor SV + barra Hue otimizados para toque no Mobile + HEX + presets)
local PickerTema = TabCombate:CreateColorPicker({
	Name = "Cor de destaque",
	Icon = "palette",
	Color = Color3.fromRGB(124, 92, 255),
	Colors = {
		Color3.fromRGB(124, 92, 255),
		Color3.fromRGB(59, 130, 246),
		Color3.fromRGB(52, 211, 153),
		Color3.fromRGB(245, 176, 65),
		Color3.fromRGB(239, 68, 68),
	},
	Flag = "CorDestaque",
	Callback = function(cor)
		AetherUI.SetAccent(cor)
	end,
})

----------------------------------------------------------------
-- 6. Aba usando a API Classica (Add*)
----------------------------------------------------------------
local TabClassica = Window:AddTab("Classica", "grid")

TabClassica:AddSection("Componentes Add*")
local lblClassico = TabClassica:AddLabel("Exemplo utilizando os metodos Add* originais.")

local toggleClassico = TabClassica:AddToggle({
	Name = "Modo silencioso",
	Default = true,
	Callback = function(estado)
		print("[AddToggle] Estado:", estado)
	end,
})

local sliderClassico = TabClassica:AddSlider({
	Name = "Alcance",
	Min = 10,
	Max = 100,
	Step = 5,
	Suffix = "m",
	Default = 50,
	Callback = function(v)
		print("[AddSlider] Alcance:", v)
	end,
})

local radioClassico = TabClassica:AddRadioGroup({
	Name = "Regiao",
	Icon = "globe",
	Options = { "Brasil", "EUA", "Europa" },
	Default = "Brasil",
	Callback = function(regiao)
		print("[AddRadioGroup] Regiao:", tostring(regiao))
	end,
})

-- No AddDropdown, o Callback recebe diretamente o valor (string), nao uma tabela
local ddClassico = TabClassica:AddDropdown({
	Name = "Qualidade",
	Options = { "Baixa", "Media", "Alta" },
	Default = "Media",
	Callback = function(valor)
		print("[AddDropdown] Qualidade:", tostring(valor))
	end,
})

local mdClassico = TabClassica:AddMultiDropdown({
	Name = "Efeitos",
	Options = { "Sombras", "Brilho", "Particulas" },
	Default = { "Sombras" },
	Callback = function(lista)
		print("[AddMultiDropdown] Total:", #lista)
	end,
})

local cpClassico = TabClassica:AddColorPicker({
	Name = "Cor secundaria",
	Default = Color3.fromRGB(59, 130, 246),
	Callback = function(cor)
		print("[AddColorPicker] RGB:", cor.R, cor.G, cor.B)
	end,
})

----------------------------------------------------------------
-- 7. Get, Set, Modo Silencioso, Flags e Save Configuration
----------------------------------------------------------------
local TabFerramentas = Window:CreateTab("Ferramentas", "wrench")
TabFerramentas:CreateSection("Manipulacao via Codigo")

TabFerramentas:CreateButton({
	Name = "Ler valores atuais (Get e Flags)",
	Icon = "terminal",
	Callback = function()
		print("--- Leitura via objetos ---")
		print("AutoMode:", ToggleFarm:Get())
		print("Velocidade:", SliderVelocidade:Get())
		print("Prioridade:", RadioPrioridade:Get())
		print("Arma:", DropdownArma:Get())
		print("Modulos:", table.concat(MultiModulos:Get(), ", "))
		print("Cor:", PickerTema:Get())

		print("--- Leitura via AetherUI.Flags ---")
		print("Flag AutoMode.CurrentValue:", AetherUI.Flags.AutoMode.CurrentValue)
		print("Flag Velocidade.CurrentValue:", Window.Flags.Velocidade.CurrentValue)
		print("Flag PrioridadeAlvo.CurrentValue:", AetherUI.Flags.PrioridadeAlvo.CurrentValue)
		print("Flag ArmaPrincipal.CurrentOption[1]:", AetherUI.Flags.ArmaPrincipal.CurrentOption[1])
		print("Flag CorDestaque.Color:", AetherUI.Flags.CorDestaque.Color)
	end,
})

TabFerramentas:CreateButton({
	Name = "Aplicar valores silenciosamente (Set + silent)",
	Icon = "sliders",
	Callback = function()
		-- O segundo argumento `true` atualiza a UI sem disparar o Callback
		ToggleFarm:Set(true, true)
		SliderVelocidade:Set(120, true)
		RadioPrioridade:Set("Menor Vida", true)
		DropdownArma:Set("Arco", true)
		MultiModulos:Set({ "ESP", "Anti-AFK" }, true)
		PickerTema:Set(Color3.fromRGB(52, 211, 153), true)
		lblClassico:SetText("Valores aplicados com silent = true.")
	end,
})

TabFerramentas:CreateButton({
	Name = "Atualizar opcoes (Refresh)",
	Icon = "refresh",
	Callback = function()
		RadioPrioridade:Refresh({ "Mais Proximo", "Maior Vida", "Boss" })
		RadioPrioridade:Set("Boss")
		DropdownArma:Refresh({ "Katana", "Lanca", "Machado" })
		DropdownArma:Set("Katana")
		DropdownArma:Open() -- abre o dropdown programaticamente
	end,
})

TabFerramentas:CreateButton({
	Name = "Limpar selecoes (Clear)",
	Icon = "trash",
	Callback = function()
		RadioPrioridade:Clear(true)
		DropdownArma:Clear(true)
		MultiModulos:Clear(true)
		ddClassico:Clear()
	end,
})

TabFerramentas:CreateSection({ Text = "Save Configuration", Icon = "save" })

TabFerramentas:CreateButton({
	Name = "Salvar configuracao em arquivo (SaveConfig)",
	Icon = "save",
	Callback = function()
		local ok, detalhe = Window:SaveConfig("PerfilPrincipal")
		if ok then
			AetherUI.Notify({ Title = "Config Salva", Content = tostring(detalhe), Type = "success", Duration = 3 })
		else
			-- Se o ambiente nao tiver writefile (ex.: Roblox Studio puro), exporta em JSON:
			local json = Window:ExportConfig(false)
			print("[ExportConfig JSON]", json)
			AetherUI.Notify({ Title = "Exportado em JSON", Content = tostring(detalhe), Type = "warning", Duration = 5 })
		end
	end,
})

TabFerramentas:CreateButton({
	Name = "Carregar configuracao (LoadConfig)",
	Icon = "upload",
	Callback = function()
		local ok, detalhe = Window:LoadConfig("PerfilPrincipal")
		if ok then
			AetherUI.Notify({ Title = "Config Carregada", Content = tostring(detalhe), Type = "success", Duration = 3 })
		else
			AetherUI.Notify({ Title = "Aviso", Content = tostring(detalhe), Type = "warning", Duration = 4 })
		end
	end,
})

TabFerramentas:CreateButton({
	Name = "Testar ExportConfig / ImportConfig em JSON",
	Icon = "copy",
	Callback = function()
		local jsonSalvo = Window:ExportConfig(false)
		print("[ExportConfig]", jsonSalvo)
		local ok, aplicadas = Window:ImportConfig(jsonSalvo, true)
		print("[ImportConfig] OK:", ok, "Flags aplicadas:", aplicadas)
		local arquivos = Window:ListConfigs()
		print("[ListConfigs] Perfis encontrados:", table.concat(arquivos, ", "))
	end,
})

----------------------------------------------------------------
-- 8. Notificacoes (tipos e fechamento programatico)
----------------------------------------------------------------
TabFerramentas:CreateSection("Notificacoes")

TabFerramentas:CreateButton({
	Name = "Testar tipos de notificacao",
	Icon = "bell",
	Callback = function()
		Window:Notify({ Title = "Info", Content = "Mensagem informativa padrao.", Type = "info", Duration = 3 })
		AetherUI.Notify({ Title = "Sucesso", Content = "Operacao concluida.", Type = "success", Duration = 3 })
		AetherUI.Notify({ Title = "Aviso", Content = "Verifique os parametros.", Type = "warning", Duration = 4 })
		local notifErro = AetherUI.Notify({
			Title = "Erro",
			Content = "Clique aqui para executar o callback.",
			Type = "error",
			Duration = 6,
			Callback = function()
				print("Notificacao clicada!")
			end,
		})
		-- Exemplo para fechar manualmente antes do tempo:
		-- task.delay(2, function() notifErro.Dismiss() end)
		local _ = notifErro
	end,
})

----------------------------------------------------------------
-- 9. Controle da Janela, Floating Dock e Favoritos
----------------------------------------------------------------
TabFerramentas:CreateSection("Janela e Favoritos")

TabFerramentas:CreateButton({
	Name = "Minimizar (exibe o Floating Dock)",
	Icon = "minus",
	Callback = function()
		Window:Minimize()
	end,
})

TabFerramentas:CreateButton({
	Name = "Alternar modo compacto",
	Icon = "maximize",
	Callback = function()
		Window:SetCompact(not Window:GetCompact())
	end,
})

TabFerramentas:CreateButton({
	Name = "Recolher / Expandir barra lateral",
	Icon = "menu",
	Callback = function()
		Window:ToggleSidebar()
	end,
})

TabFerramentas:CreateButton({
	Name = "Mostrar / Ocultar estrelas de favoritos",
	Icon = "star",
	Callback = function()
		Window:ToggleFavoritesMode()
	end,
})

TabFerramentas:CreateButton({
	Name = "Salvar lista de favoritos no console",
	Icon = "bookmark",
	Callback = function()
		local salvos = Window:GetFavorites()
		print("Chaves favoritas:", table.concat(salvos, " | "))
	end,
})

-- Outros metodos disponiveis na instancia Window:
-- Window:SelectTab("Principal")
-- Window:SetTitle("Novo Titulo")
-- Window:Minimize() -- minimiza o painel e exibe o Floating Dock
-- Window:Restore()  -- abre o painel e oculta o Floating Dock
-- Window:SaveConfiguration("PerfilPrincipal")
-- Window:LoadConfiguration("PerfilPrincipal")
-- Window:DeleteConfig("PerfilPrincipal")
-- Window:DeleteConfiguration("PerfilPrincipal")
-- Window:ListConfigurations()
-- Window:Close(true) -- true ignora o modal de confirmacao
-- Window:Destroy()
