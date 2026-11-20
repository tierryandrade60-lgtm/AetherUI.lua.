--[[
	AetherUI v2.9.0 - arquivo unico (Parte 1/3 + 2/3 + 3/3 ja unidas)
	Inclui: cabecalho, tema, estado, utilitarios, biblioteca expandida de icones,
	        notificacoes (DisplayOrder 990, abaixo da UI),
	        Section, Label, Button, Toggle, Slider, Dropdown, MultiDropdown,
	        RadioGroup, ColorPicker, Search global, Save Configuration,
	        aba Menu (FPS, Ping, Uptime, Grafico de FPS, Smart Performance Anti-Lag)
	        e animacoes nativas padronizadas.
	Cole TODO este arquivo em um unico ModuleScript ou carregue via loadstring.

	v2.9.0 (Aba Menu + Smart Performance Anti-Lag Avancado + Animacoes Padronizadas):
	  - Nova aba Menu: FPS em tempo real, Ping em tempo real, Uptime da biblioteca,
	    Grafico de desempenho com historico de FPS e Smart Performance configuravel.
	  - Smart Performance (Anti-Lag adaptativo por distancia, visibilidade e contexto):
	    * Frustum/Visibility Culling (LocalTransparencyModifier, Decals, Textures,
	      imagens 3D, luzes e efeitos fora da visao ou muito distantes).
	    * Sistema de Protecao de Combate: prioriza habilidades, poderes, projeteis,
	      explosoes, auras, ferramentas e personagens em combate.
	    * Reducao gradual de qualidade/taxa em particulas, luzes, Trails, Beams e
	      personagens distantes + hibernacao segura de efeitos temporarios finalizados.
	    * Escalonamento continuo por FPS/sobrecarga sem oscilacoes e restauracao 1:1.
	  - Animacoes nativas padronizadas internamente (janela, hover, abas, sidebar,
	    bolinha e notificacoes) sem menus de personalizacao.

	v2.7.0 (Mobile + Bolinha + ColorPicker + RadioGroup + Save Config + Icones):
	  - Floating Ball (Bolinha): aparece SOMENTE quando o painel principal esta
	    minimizado; pode ser arrastada livremente por toda a tela dentro das bordas
	    e reabre o painel ao tocar sem disparar durante o arraste.
	  - Mobile & Toque: deteccao aprimorada, viewport responsivo retrato/paisagem,
	    clamping seguro abaixo do topbar e alvos de toque confortaveis.
	  - ColorPicker: calibragem inteligente de coordenadas (Mouse/Touch/GuiInset/
	    Topbar v2) e hitboxes Active=true, eliminando deslocamentos do dedo.
	  - RadioGroup: Tab:AddRadioGroup / Tab:CreateRadioGroup com Get, Set, Clear,
	    SetOptions/Refresh, Flag, Busca global e Favoritos.
	  - Save Configuration: ExportConfig/ImportConfig (JSON universal) e
	    SaveConfig/LoadConfig/DeleteConfig/ListConfigs (+ aliases *Configuration,
	    ConfigurationSaving em CreateWindow e secao na aba Interface).
	  - Biblioteca de Icones expandida (65+ icones vetoriais + aliases), suporte a
	    IconSize/IconColor/tabela/imagens personalizadas e AetherUI.RegisterIcon,
	    AetherUI.CreateIcon, AetherUI.GetIcons e AetherUI.Icons.

	v2.6.0 (otimizacao profunda + correcao da bolinha):
	  - Animador central, maquina de estados por tokens/timers, Heartbeats sob
	    demanda, listeners de arraste sob demanda e shadows coalescidas.

	v2.5.0:
	  - API padronizada estilo Rayfield (CreateWindow/CreateTab/Create*) +
	    AetherUI.Flags / Window.Flags + Set(valor, silent) + Refresh.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LibraryStartClock = os.clock()

local AetherUI = {}
AetherUI.Version = "2.9.0"

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

local Theme = {
	Background = Color3.fromRGB(14, 14, 18),
	BackgroundDeep = Color3.fromRGB(10, 10, 13),
	Sidebar = Color3.fromRGB(17, 17, 22),
	Surface = Color3.fromRGB(22, 22, 28),
	SurfaceHigh = Color3.fromRGB(27, 27, 34),
	Element = Color3.fromRGB(24, 24, 31),
	ElementHigh = Color3.fromRGB(30, 30, 39),
	ElementHover = Color3.fromRGB(33, 33, 43),
	ElementPressed = Color3.fromRGB(39, 39, 50),
	Off = Color3.fromRGB(54, 54, 67),
	OffDeep = Color3.fromRGB(32, 32, 41),
	Stroke = Color3.fromRGB(44, 44, 56),
	StrokeSoft = Color3.fromRGB(34, 34, 44),
	StrokeStrong = Color3.fromRGB(58, 58, 72),
	Divider = Color3.fromRGB(30, 30, 38),
	Text = Color3.fromRGB(244, 244, 248),
	SubText = Color3.fromRGB(162, 164, 178),
	Muted = Color3.fromRGB(106, 108, 124),
	Danger = Color3.fromRGB(229, 72, 77),
	DangerSoft = Color3.fromRGB(148, 52, 56),
	Success = Color3.fromRGB(62, 188, 120),
	Warning = Color3.fromRGB(235, 173, 58),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Shadow = Color3.fromRGB(0, 0, 0),
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	FontBlack = Enum.Font.GothamBlack,
}

local Radius = {
	Window = 12,
	Popup = 10,
	Card = 8,
	Control = 6,
	Small = 4,
}

local Anim = {
	Micro = 0.08, Fast = 0.14, Normal = 0.22,
	Smooth = 0.26, Slow = 0.32, Spring = 0.28,
}

-- Superficies 100% solidas e opacas (Premium Dark sem glassmorphism)
local Glass = {
	Window = 0, Bar = 0, Side = 0, Element = 0,
	Panel = 0, Popup = 0, Card = 0, Ball = 0,
}

local State = {
	Accent = Color3.fromRGB(124, 92, 255),
	LowPerformance = false,
}

local Windows = {}

local DefaultSwatches = {
	Color3.fromRGB(124, 92, 255), Color3.fromRGB(59, 130, 246),
	Color3.fromRGB(34, 211, 238), Color3.fromRGB(52, 211, 153),
	Color3.fromRGB(245, 176, 65), Color3.fromRGB(249, 115, 22),
	Color3.fromRGB(239, 68, 68), Color3.fromRGB(236, 72, 153),
}

local Assets = {
	Logo = "rbxassetid://113083945240866",
	Moon = "rbxassetid://123147524256851",
}

local function accent() return State.Accent end
local function accentDeep() return State.Accent:Lerp(Theme.Black, 0.38) end
local function accentLight() return State.Accent:Lerp(Theme.White, 0.24) end
local function accentSoft(amount) return Theme.Element:Lerp(State.Accent, amount or 0.12) end
local function accentSurface(amount) return Theme.Surface:Lerp(State.Accent, amount or 0.12) end
local function accentBorder(amount) return Theme.Stroke:Lerp(State.Accent, amount or 0.45) end
local function accentGlow() return State.Accent:Lerp(Theme.White, 0.12) end

local function create(className, props, children)
	local instance = Instance.new(className)
	if instance:IsA("GuiObject") then instance.BorderSizePixel = 0 end
	local parent = nil
	for key, value in pairs(props or {}) do
		if key == "Parent" then parent = value else instance[key] = value end
	end
	for _, child in ipairs(children or {}) do child.Parent = instance end
	if parent then instance.Parent = parent end
	return instance
end

-- ===================================================================
-- Animador central (padroes internos fixos, sem opcoes extras)
--  * TweenInfo em cache (sem alocar a cada chamada)
--  * no maximo 1 tween ativo por propriedade de cada objeto; tweens
--	concorrentes sao mesclados (as propriedades nao sobrescritas terminam
--	normalmente, nada fica pela metade)
--  * pedido identico ao que ja esta rodando / ja no valor final = no-op
--  * objeto invisivel (ou LowPerformance) = atribuicao direta, sem tween
-- Nenhuma logica critica deve depender de Tween.Completed.
-- ===================================================================
local STUB_TWEEN = {}
STUB_TWEEN.Completed = { Connect = function(_, callback)
	task.defer(callback, Enum.PlaybackState.Completed)
	return { Disconnect = function() end }
end }
function STUB_TWEEN:Cancel() end
function STUB_TWEEN:Play() end
local function instantTween() return STUB_TWEEN end

local InfoCache = {}
local function getTweenInfo(duration, style, direction)
	style = style or Enum.EasingStyle.Quint
	direction = direction or Enum.EasingDirection.Out
	local byStyle = InfoCache[style]
	if not byStyle then byStyle = {}; InfoCache[style] = byStyle end
	local byDirection = byStyle[direction]
	if not byDirection then byDirection = {}; byStyle[direction] = byDirection end
	local info = byDirection[duration]
	if not info then
		info = TweenInfo.new(duration, style, direction)
		byDirection[duration] = info
	end
	return info
end

local GuiClassCache = {}
local function isGuiClass(instance)
	local className = instance.ClassName
	local cached = GuiClassCache[className]
	if cached == nil then
		cached = instance:IsA("GuiObject")
		GuiClassCache[className] = cached
	end
	return cached
end

-- Esta sendo desenhado de fato? (todo ancestral GuiObject visivel + ScreenGui ligada)
local function isRendered(instance)
	local node = instance
	if not isGuiClass(node) then node = node.Parent end
	while node do
		if isGuiClass(node) then
			if not node.Visible then return false end
		elseif node:IsA("LayerCollector") then
			return node.Enabled
		end
		node = node.Parent
	end
	return true
end

local ActiveTweens = setmetatable({}, { __mode = "k" })

local function isRunning(record)
	local state = record.Tween.PlaybackState
	return state ~= Enum.PlaybackState.Completed and state ~= Enum.PlaybackState.Cancelled
end

-- Cancela tweens que disputam as propriedades pedidas e devolve as
-- propriedades "orfas" (do tween cancelado) para o novo tween terminar.
local function takeConflicts(object, properties)
	local records = ActiveTweens[object]
	if not records then return nil, nil end
	local leftovers
	for property in pairs(properties) do
		local record = records[property]
		if record then
			records[property] = nil
			if isRunning(record) then
				record.Tween:Cancel()
				for other, goal in pairs(record.Goals) do
					if records[other] == record then records[other] = nil end
					if properties[other] == nil then
						leftovers = leftovers or {}
						leftovers[other] = goal
					end
				end
			end
		end
	end
	return leftovers, records
end

local function sameValue(a, b)
	if a == b then return true end
	if type(a) == "number" and type(b) == "number" then return math.abs(a - b) < 1e-4 end
	return false
end

local function cancelTweensUnder(root)
	for object, records in pairs(ActiveTweens) do
		if object == root or object:IsDescendantOf(root) then
			for _, record in pairs(records) do
				if isRunning(record) then record.Tween:Cancel() end
			end
			ActiveTweens[object] = nil
		end
	end
end

local function tween(object, duration, properties, style, direction)
	if State.LowPerformance or not duration or duration <= 0 or not isRendered(object) then
		local leftovers = takeConflicts(object, properties)
		if leftovers then for key, value in pairs(leftovers) do object[key] = value end end
		for key, value in pairs(properties) do object[key] = value end
		return STUB_TWEEN
	end

	style = style or Enum.EasingStyle.Quint
	direction = direction or Enum.EasingDirection.Out

	-- Pedido redundante: ja esta indo / ja esta no valor final.
	local records = ActiveTweens[object]
	local same, running = true, nil
	for key, goal in pairs(properties) do
		local record = records and records[key]
		if record and isRunning(record) then
			if not sameValue(record.Goals[key], goal) then same = false; break end
			running = running or record
		elseif not sameValue(object[key], goal) then
			same = false; break
		end
	end
	if same then return running and running.Tween or STUB_TWEEN end

	local leftovers
	leftovers, records = takeConflicts(object, properties)
	local goals = properties
	if leftovers then
		goals = table.clone(properties)
		for key, value in pairs(leftovers) do goals[key] = value end
	end
	local t = TweenService:Create(object, getTweenInfo(duration, style, direction), goals)
	local record = { Tween = t, Goals = goals }
	if not records then records = {}; ActiveTweens[object] = records end
	for key in pairs(goals) do records[key] = record end
	t:Play()
	return t
end

local function setProps(object, properties, animate, duration, style, direction)
	if animate and not State.LowPerformance then
		tween(object, duration or Anim.Fast, properties, style, direction)
	else
		local leftovers = takeConflicts(object, properties)
		if leftovers then for key, value in pairs(leftovers) do object[key] = value end end
		for key, value in pairs(properties) do object[key] = value end
	end
end

-- ===================================================================
-- Telemetria (FPS, Ping, Uptime, Historico) & Smart Performance (Anti-Lag)
-- ===================================================================
local Notifications = { Gui = nil, Holder = nil, Layout = nil, Active = {}, Counter = 0 }

local PerfMonitor = {
	Interval = 0.35,
	HistoryMax = 32,
	History = {},
	Stats = {
		FPS = 60,
		MinFPS = 60,
		MaxFPS = 60,
		AvgFPS = 60,
		FrameTimeMs = 16.7,
		PingMs = -1,
		Uptime = 0,
		ActiveElements = 0,
		GuiObjects = 0,
		ActiveTweens = 0,
		Connections = 0,
		MemoryMB = 0,
		Windows = 0,
	},
	Subscribers = {},
	Conn = nil,
}

local function formatDurationClock(seconds)
	local s = math.max(0, math.floor(tonumber(seconds) or 0))
	local h = math.floor(s / 3600)
	local m = math.floor((s % 3600) / 60)
	local sec = s % 60
	if h > 0 then
		return string.format("%02d:%02d:%02d", h, m, sec)
	end
	return string.format("%02d:%02d", m, sec)
end

local function readMemoryMb()
	local okStats, statsService = pcall(function() return game:GetService("Stats") end)
	if okStats and statsService then
		local okMem, totalMb = pcall(function() return statsService:GetTotalMemoryUsageMb() end)
		if okMem and typeof(totalMb) == "number" and totalMb > 0 then
			return math.floor(totalMb * 10 + 0.5) / 10
		end
	end
	local okGc, kb = pcall(function() return gcinfo() end)
	if okGc and typeof(kb) == "number" then
		return math.floor((kb / 1024) * 10 + 0.5) / 10
	end
	return 0
end

local function readPingMs()
	local okStats, statsService = pcall(function() return game:GetService("Stats") end)
	if okStats and statsService then
		local okNet, rawVal = pcall(function()
			local net = statsService:FindFirstChild("Network")
			local serverItems = net and net:FindFirstChild("ServerStatsItem")
			local dataPing = serverItems and serverItems:FindFirstChild("Data Ping")
			if dataPing then return dataPing:GetValue() end
			return nil
		end)
		if okNet and typeof(rawVal) == "number" and rawVal >= 0 then
			return math.max(0, math.floor(rawVal + 0.5))
		end
	end
	local player = Players.LocalPlayer
	if player then
		local okPing, netPing = pcall(function() return player:GetNetworkPing() end)
		if okPing and typeof(netPing) == "number" and netPing >= 0 then
			return math.max(0, math.floor(netPing * 1000 + 0.5))
		end
	end
	return -1
end

local function pushFpsHistory(fps)
	local hist = PerfMonitor.History
	table.insert(hist, fps)
	while #hist > PerfMonitor.HistoryMax do
		table.remove(hist, 1)
	end
	local minV, maxV, sumV = fps, fps, 0
	for _, v in ipairs(hist) do
		if v < minV then minV = v end
		if v > maxV then maxV = v end
		sumV = sumV + v
	end
	PerfMonitor.Stats.MinFPS = minV
	PerfMonitor.Stats.MaxFPS = maxV
	PerfMonitor.Stats.AvgFPS = math.floor((sumV / math.max(#hist, 1)) + 0.5)
end

-- ===================================================================
-- Smart Performance v3 (Anti-Lag Real por Modos, Oclusao, Frustum & Contexto)
--   * 5 modos distintos (Leve, Equilibrado, Agressivo, Ultra, Automatico)
--     com distancias, culling, efeitos, luzes, objetos e frequencia proprios.
--   * Culling por Frustum + Raycast Occlusion em lotes com orcamento de CPU.
--   * Protecao estrutural/comportamental de combate (nao so por nomes).
--   * Rastreamento Orig + Applied para restauracao 1:1 sem sobrescrever
--     alteracoes legitimas feitas pelo jogo.
-- ===================================================================
local SmartPerf = {
	Enabled = false,
	Config = {
		Mode = "Automatico", -- Automatico | Leve | Equilibrado | Agressivo | Ultra
		Intensity = 100, -- 20..100 (%) escala aplicada sobre o modo selecionado
		FrustumCulling = true,
		CombatProtection = true,
		EffectOptimization = true,
		LightOptimization = true,
		ObjectOptimization = true,
		CharacterOptimization = true,
		EffectCleanup = true,
		TargetFPS = 55,
	},
	Cache = {},
	EntryMap = {},
	Modified = {},
	CharacterModels = {},
	AnimOrig = setmetatable({}, { __mode = "k" }),
	Cursor = 1,
	RestoreCursor = 1,
	RestoreList = {},
	ScanQueue = nil,
	ScanIndex = 1,
	ScanDone = true,
	Conns = {},
	HeartbeatConn = nil,
	StepAccum = 0,
	RestoreAccum = 0,
	ContextAccum = 0,
	LastPlayerPos = nil,
	LastCamPos = nil,
	LastCamLook = nil,
	SmoothFps = 60,
	LastFrameMs = 16.7,
	SpikeScore = 0,
	LastOverloadAt = 0,
	LocalCombatUntil = 0,
	LastLocalHp = nil,
	Stress = 0,
	Intensity = 0.25,
	ActiveProfileName = "Leve",
	ActiveProfile = nil,
	ConfigEpoch = 1,
	OcclusionChecks = 0,
	RaycastParams = nil,
	RayIgnoreList = {},
	NearRadius = 155,
	FarRadius = 330,
	CullRadius = 560,
	Stats = {
		Enabled = false,
		Mode = "Automatico",
		Profile = "Inativo",
		IntensityPct = 0,
		FPS = 60,
		NearCount = 0,
		MidCount = 0,
		FarCount = 0,
		CulledCount = 0,
		OccludedCount = 0,
		ProtectedCount = 0,
		CleanedCount = 0,
		OptimizedCount = 0,
		CachedCount = 0,
		NearRadius = 155,
		FarRadius = 330,
		CullRadius = 560,
		StepIntervalMs = 180,
	},
}

local SmartModeProfiles = {
	Leve = {
		Name = "Leve",
		NearRadius = 155,
		FarRadius = 330,
		CullRadius = 560,
		BaseIntensity = 0.24,
		MinIntensity = 0.14,
		MaxIntensity = 0.40,
		StepInterval = 0.24,
		RestoreInterval = 0.14,
		BatchSize = 140,
		StepBudget = 0.0010,
		RestoreBudget = 0.0005,
		OcclusionEnabled = false,
		OcclusionBudget = 0,
		OcclusionRevalidate = 0.60,
		ShadowOffTier = 2,
		MaterialSimplifyTier = 3,
		DecalHideTier = 3,
		PartCullTier = 0, -- Nao oculta pecas solidas no modo Leve (apenas acessorios pequenos)
		MaxPartCullRadius = 10,
		CullParticles = false,
		CullLights = false,
		ParticleScaleMin = 0.48,
		ParticlePrimaryScaleMin = 0.85,
		LightRangeMin = 0.72,
		LightBrightMin = 0.76,
		CharAnimSpeedFar = 0.75,
		CharAnimSpeedCull = 0.50,
		OffCameraCombatGrace = 3.2,
	},
	Equilibrado = {
		Name = "Equilibrado",
		NearRadius = 115,
		FarRadius = 260,
		CullRadius = 430,
		BaseIntensity = 0.52,
		MinIntensity = 0.36,
		MaxIntensity = 0.72,
		StepInterval = 0.18,
		RestoreInterval = 0.11,
		BatchSize = 200,
		StepBudget = 0.0014,
		RestoreBudget = 0.0007,
		OcclusionEnabled = true,
		OcclusionBudget = 12,
		OcclusionRevalidate = 0.45,
		ShadowOffTier = 2,
		MaterialSimplifyTier = 2,
		DecalHideTier = 3,
		PartCullTier = 3,
		MaxPartCullRadius = 28,
		CullParticles = true,
		CullLights = true,
		ParticleScaleMin = 0.26,
		ParticlePrimaryScaleMin = 0.74,
		LightRangeMin = 0.55,
		LightBrightMin = 0.58,
		CharAnimSpeedFar = 0.55,
		CharAnimSpeedCull = 0.30,
		OffCameraCombatGrace = 2.6,
	},
	Agressivo = {
		Name = "Agressivo",
		NearRadius = 82,
		FarRadius = 195,
		CullRadius = 335,
		BaseIntensity = 0.78,
		MinIntensity = 0.62,
		MaxIntensity = 0.92,
		StepInterval = 0.13,
		RestoreInterval = 0.08,
		BatchSize = 260,
		StepBudget = 0.0018,
		RestoreBudget = 0.0009,
		OcclusionEnabled = true,
		OcclusionBudget = 20,
		OcclusionRevalidate = 0.32,
		ShadowOffTier = 1,
		MaterialSimplifyTier = 2,
		DecalHideTier = 2,
		PartCullTier = 3,
		MaxPartCullRadius = 54,
		CullParticles = true,
		CullLights = true,
		ParticleScaleMin = 0.14,
		ParticlePrimaryScaleMin = 0.64,
		LightRangeMin = 0.38,
		LightBrightMin = 0.42,
		CharAnimSpeedFar = 0.38,
		CharAnimSpeedCull = 0.18,
		OffCameraCombatGrace = 2.2,
	},
	Ultra = {
		Name = "Ultra",
		NearRadius = 56,
		FarRadius = 145,
		CullRadius = 250,
		BaseIntensity = 0.95,
		MinIntensity = 0.84,
		MaxIntensity = 1.0,
		StepInterval = 0.10,
		RestoreInterval = 0.07,
		BatchSize = 320,
		StepBudget = 0.0022,
		RestoreBudget = 0.0011,
		OcclusionEnabled = true,
		OcclusionBudget = 26,
		OcclusionRevalidate = 0.25,
		ShadowOffTier = 1,
		MaterialSimplifyTier = 1,
		DecalHideTier = 2,
		PartCullTier = 3,
		MaxPartCullRadius = 92,
		CullParticles = true,
		CullLights = true,
		ParticleScaleMin = 0.06,
		ParticlePrimaryScaleMin = 0.54,
		LightRangeMin = 0.26,
		LightBrightMin = 0.28,
		CharAnimSpeedFar = 0.25,
		CharAnimSpeedCull = 0.12,
		OffCameraCombatGrace = 1.8,
	},
}
SmartPerf.ActiveProfile = SmartModeProfiles.Leve

local SMART_HYSTERESIS = 16
local SMART_MIN_DWELL = 1.15

local SmartCombatKeywords = {
	"attack", "skill", "ability", "spell", "magic", "power", "aura",
	"slash", "dash", "combo", "hit", "beam", "laser", "blast", "proj",
	"bullet", "missile", "rocket", "fireball", "meteor", "explo",
	"shockwave", "parry", "block", "shield", "dodge", "ult", "domain",
	"boss", "combat", "weapon", "sword", "gun", "katana", "clash",
	"burst", "thunder", "lightning", "heal", "buff", "hitbox", "hurtbox",
}

local SmartTempContainerKeywords = {
	"debris", "effect", "vfx", "fx", "temp", "particles", "splatter", "smoke",
}

local SmartProceduralMaterials = {
	[Enum.Material.Brick] = true,
	[Enum.Material.Cobblestone] = true,
	[Enum.Material.Concrete] = true,
	[Enum.Material.CorrodedMetal] = true,
	[Enum.Material.DiamondPlate] = true,
	[Enum.Material.Fabric] = true,
	[Enum.Material.Foil] = true,
	[Enum.Material.Granite] = true,
	[Enum.Material.Grass] = true,
	[Enum.Material.Ice] = true,
	[Enum.Material.Marble] = true,
	[Enum.Material.Metal] = true,
	[Enum.Material.Pebble] = true,
	[Enum.Material.Sand] = true,
	[Enum.Material.Slate] = true,
	[Enum.Material.Wood] = true,
	[Enum.Material.WoodPlanks] = true,
}
pcall(function()
	for _, name in ipairs({
		"Asphalt", "Basalt", "Carpet", "CrackedLava", "Glacier", "Ground",
		"LeafyGrass", "Limestone", "Mud", "Pavement", "Plaster",
		"Rock", "RoofShingles", "Salt", "Sandstone", "Snow",
	}) do
		local mat = Enum.Material[name]
		if mat then SmartProceduralMaterials[mat] = true end
	end
end)

local function nameMatchesList(nameStr, list)
	if not nameStr or nameStr == "" then return false end
	local lower = string.lower(nameStr)
	for _, kw in ipairs(list) do
		if string.find(lower, kw, 1, true) then
			return true
		end
	end
	return false
end

local function hasImportantAttributesOrLinks(inst)
	if inst:IsA("Explosion") then return true end
	local node = inst
	local depth = 0
	while node and node ~= workspace and depth < 4 do
		local okAttrs, attrs = pcall(function() return node:GetAttributes() end)
		if okAttrs and typeof(attrs) == "table" then
			for k, v in pairs(attrs) do
				if v ~= nil and v ~= false then
					local lk = string.lower(tostring(k))
					if lk == "combat" or lk == "skill" or lk == "ability" or lk == "important"
						or lk == "critical" or lk == "boss" or lk == "projectile" or lk == "hitbox"
						or lk == "owner" or lk == "caster" or lk == "userid" then
						return true
					end
				end
			end
		end
		for _, child in ipairs(node:GetChildren()) do
			if child:IsA("ObjectValue") then
				local lc = string.lower(child.Name)
				if lc == "creator" or lc == "owner" or lc == "caster" or lc == "target" then
					return true
				end
			end
		end
		if nameMatchesList(node.Name, SmartCombatKeywords) then
			return true
		end
		node = node.Parent
		depth = depth + 1
	end
	return false
end

local function isInTempContainer(inst)
	local node = inst.Parent
	local depth = 0
	while node and node ~= workspace and depth < 3 do
		if nameMatchesList(node.Name, SmartTempContainerKeywords) then
			return true
		end
		node = node.Parent
		depth = depth + 1
	end
	return false
end

local function findCharacterAncestor(inst)
	local node = inst
	while node and node ~= workspace do
		if node:IsA("Model") then
			if node:FindFirstChildOfClass("Humanoid") or node:FindFirstChildOfClass("AnimationController") then
				return node
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character == node then return node end
			end
		end
		node = node.Parent
	end
	return nil
end

local function isToolOrAccessory(inst)
	local node = inst
	while node and node ~= workspace do
		if node:IsA("Tool") or node:IsA("HopperBin") then
			return "Tool"
		elseif node:IsA("Accessory") then
			return "Accessory"
		end
		node = node.Parent
	end
	return nil
end

local function hasInteractiveOrSurfaceChild(inst)
	for _, child in ipairs(inst:GetChildren()) do
		if child:IsA("ProximityPrompt")
			or child:IsA("ClickDetector")
			or child:IsA("DragDetector")
			or child:IsA("TouchTransmitter")
			or child:IsA("Dialog")
			or child:IsA("Seat")
			or child:IsA("VehicleSeat") then
			return "Interactive"
		end
	end
	return nil
end

local function hasSurfaceTextures(inst)
	for _, child in ipairs(inst:GetChildren()) do
		if child:IsA("SurfaceAppearance") or child:IsA("Texture") or child:IsA("Decal") then
			return true
		end
	end
	return false
end

local function hasInteractiveDescendant(inst)
	for _, desc in ipairs(inst:GetDescendants()) do
		if desc:IsA("ProximityPrompt")
			or desc:IsA("ClickDetector")
			or desc:IsA("DragDetector")
			or desc:IsA("TouchTransmitter")
			or desc:IsA("Seat")
			or desc:IsA("VehicleSeat") then
			return true
		end
	end
	return false
end

local function hasMoverOrPhysicsForce(part)
	if not part or not part:IsA("BasePart") then return false end
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("BodyVelocity")
			or child:IsA("LinearVelocity")
			or child:IsA("VectorForce")
			or child:IsA("BodyForce")
			or child:IsA("AlignPosition")
			or child:IsA("RocketPropulsion")
			or child:IsA("LineForce")
			or child:IsA("TouchTransmitter") then
			return true
		end
	end
	return false
end

local function isPrimaryVisualEffect(inst, anchor, charModel, combatTagged)
	if combatTagged or charModel then return true end
	if inst:IsA("Explosion") then return true end
	if anchor and anchor:IsA("BasePart") and not anchor.Anchored then
		if hasMoverOrPhysicsForce(anchor) then return true end
		local okV, vel = pcall(function() return anchor.AssemblyLinearVelocity.Magnitude end)
		if okV and vel >= 10 then return true end
	end
	if inst:IsA("Beam") or inst:IsA("Trail") then
		local primary = false
		pcall(function()
			if inst:IsA("Beam") then
				primary = inst.Width0 >= 1.2 or inst.Width1 >= 1.2 or inst.LightEmission >= 0.35
			else
				primary = inst.Lifetime >= 0.45 or inst.LightEmission >= 0.35
			end
		end)
		return primary
	end
	if inst:IsA("ParticleEmitter") then
		local primary = false
		pcall(function()
			primary = inst.LightEmission >= 0.4 or inst.Rate >= 30 or inst.Lifetime.Max >= 1.8
		end)
		return primary
	end
	return false
end

local function getPartPositionSafe(inst)
	if not inst or not inst.Parent then return nil end
	if inst:IsA("BasePart") then return inst.Position end
	if inst:IsA("Attachment") then
		local ok, wp = pcall(function() return inst.WorldPosition end)
		if ok then return wp end
	end
	if inst:IsA("Model") then
		local pp = inst.PrimaryPart
		if pp and pp.Parent then return pp.Position end
		local okBox, cf = pcall(function() return inst:GetBoundingBox() end)
		if okBox and typeof(cf) == "CFrame" then return cf.Position end
	end
	return nil
end

local function resolveAnchorPos(inst)
	local node = inst
	while node and node ~= workspace do
		local pos = getPartPositionSafe(node)
		if pos then return node, pos end
		node = node.Parent
	end
	return nil, nil
end

local function classifySmartTarget(inst)
	if not inst or not inst.Parent then return nil end
	if SmartPerf.EntryMap[inst] then return nil end
	if inst:IsA("Terrain") or inst:IsA("Camera") then return nil end

	local charModel = findCharacterAncestor(inst)
	local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
	local isLocalChar = charModel ~= nil and charModel == localChar
	local attachKind = isToolOrAccessory(inst)
	if isLocalChar or attachKind == "Tool" then
		-- Jogador local e ferramentas nunca sao otimizados/ocultos
		return nil
	end

	local combatTagged = hasImportantAttributesOrLinks(inst)
	local now = os.clock()

	-- Personagem remoto / NPC (somente raiz Model para gerenciar animacao + partes)
	if inst:IsA("Model") and (inst:FindFirstChildOfClass("Humanoid") or inst:FindFirstChildOfClass("AnimationController")) then
		local okBox, cf, sz = pcall(function() return inst:GetBoundingBox() end)
		if not okBox or typeof(cf) ~= "CFrame" then return nil end
		local hum = inst:FindFirstChildOfClass("Humanoid")
		local animCtrl = hum or inst:FindFirstChildOfClass("AnimationController")
		local animator = animCtrl and animCtrl:FindFirstChildOfClass("Animator") or nil
		local meta = {
			Model = inst,
			Humanoid = hum,
			Animator = animator,
			LastHp = hum and hum.Health or nil,
			CombatUntil = 0,
			InCombat = false,
		}
		SmartPerf.CharacterModels[inst] = meta
		return {
			Inst = inst, Kind = "Character", CharModel = inst, Priority = "High",
			Pos = cf.Position, Radius = math.min(sz.Magnitude * 0.5, 24),
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- Particulas, Trails, Beams, Fire, Smoke, Sparkles, Explosions
	if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
		or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") or inst:IsA("Explosion") then
		local anchor, pos = resolveAnchorPos(inst.Parent)
		if not anchor or not pos then return nil end
		local radius = anchor:IsA("BasePart") and math.min(anchor.Size.Magnitude * 0.5, 60) or 12
		local kind = inst:IsA("ParticleEmitter") and "Particle"
			or (inst:IsA("Beam") and "Beam")
			or (inst:IsA("Trail") and "Trail")
			or (inst:IsA("Explosion") and "Explosion")
			or "TempFx"
		local isPrimary = isPrimaryVisualEffect(inst, anchor, charModel, combatTagged)
		local prio = (combatTagged or kind == "Explosion" or isPrimary) and "Critical" or (charModel and "High" or "Normal")
		return {
			Inst = inst, Kind = kind, Anchor = anchor, CharModel = charModel,
			Priority = prio, IsPrimaryEffect = isPrimary,
			CombatProtected = combatTagged or kind == "Explosion",
			IsTemp = isInTempContainer(inst) or kind == "Explosion",
			DisabledSince = nil, Pos = pos, Radius = radius,
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- Luzes dinamicas
	if inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
		local anchor, pos = resolveAnchorPos(inst.Parent)
		if not anchor or not pos then return nil end
		local rangeVal = 16
		pcall(function() rangeVal = inst.Range end)
		local mover = anchor:IsA("BasePart") and not anchor.Anchored and hasMoverOrPhysicsForce(anchor)
		local important = combatTagged or mover
		local prio = important and "Critical" or (charModel and "High" or "Normal")
		return {
			Inst = inst, Kind = "Light", Anchor = anchor, CharModel = charModel,
			Priority = prio, CombatProtected = important,
			Pos = pos, Radius = math.min(rangeVal, 75),
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- Decals & Textures
	if inst:IsA("Decal") or inst:IsA("Texture") then
		local parent = inst.Parent
		if not parent or not parent:IsA("BasePart") then return nil end
		local prio = combatTagged and "High" or "Low"
		return {
			Inst = inst, Kind = "Decal", Anchor = parent, CharModel = charModel,
			Priority = prio, CombatProtected = combatTagged,
			Pos = parent.Position, Radius = math.min(parent.Size.Magnitude * 0.5, 70),
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- Imagens em 3D UI (SurfaceGui / BillboardGui)
	if (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and (inst:FindFirstAncestorOfClass("SurfaceGui") or inst:FindFirstAncestorOfClass("BillboardGui")) then
		local gui3d = inst:FindFirstAncestorOfClass("SurfaceGui") or inst:FindFirstAncestorOfClass("BillboardGui")
		local anchor = gui3d and ((gui3d.Adornee and gui3d.Adornee:IsA("BasePart") and gui3d.Adornee) or (gui3d.Parent and gui3d.Parent:IsA("BasePart") and gui3d.Parent))
		if not anchor then return nil end
		local prio = (combatTagged or charModel) and "High" or "Low"
		return {
			Inst = inst, Kind = "GuiImage", Anchor = anchor, CharModel = charModel,
			Priority = prio, CombatProtected = combatTagged,
			Pos = anchor.Position, Radius = math.min(anchor.Size.Magnitude * 0.5, 45),
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- SurfaceGui / BillboardGui
	if inst:IsA("SurfaceGui") or inst:IsA("BillboardGui") then
		local parent = inst.Adornee or inst.Parent
		if not parent or not parent:IsA("BasePart") then return nil end
		local isBb = inst:IsA("BillboardGui")
		local prio = (combatTagged or charModel) and "High" or "Normal"
		return {
			Inst = inst, Kind = isBb and "BillboardGui" or "SurfaceGui", Anchor = parent, CharModel = charModel,
			Priority = prio, CombatProtected = combatTagged,
			Pos = parent.Position, Radius = math.min(parent.Size.Magnitude * 0.5, 70),
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- Models (nao personagens)
	if inst:IsA("Model") then
		if hasInteractiveDescendant(inst) then return nil end
		local okBox, cf, sz = pcall(function() return inst:GetBoundingBox() end)
		if not okBox or typeof(cf) ~= "CFrame" then return nil end
		local radius = math.min(sz.Magnitude * 0.5, 160)
		local prio = combatTagged and "Critical" or (radius >= 45 and "High" or "Normal")
		return {
			Inst = inst, Kind = "Model", CharModel = nil,
			Priority = prio, CombatProtected = combatTagged,
			Pos = cf.Position, Radius = radius,
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	-- BasePart / MeshPart
	if inst:IsA("BasePart") then
		if inst:IsA("Seat") or inst:IsA("VehicleSeat") or inst:IsA("SkateboardPlatform") then return nil end
		if hasInteractiveOrSurfaceChild(inst) then return nil end
		local hasTex = hasSurfaceTextures(inst)
		local isProjectile = not inst.Anchored and hasMoverOrPhysicsForce(inst)
		local radius = math.min(inst.Size.Magnitude * 0.5, 120)
		local prio = (combatTagged or isProjectile) and "Critical"
			or ((charModel or radius >= 42) and "High")
			or ((inst.Size.Magnitude < 6 and not inst.CanCollide) and "Low" or "Normal")
		local kind = inst:IsA("MeshPart") and "Mesh" or "Part"
		return {
			Inst = inst, Kind = kind, Anchor = inst, CharModel = charModel,
			Priority = prio, CombatProtected = combatTagged or isProjectile,
			HasTex = hasTex, IsAccessory = attachKind == "Accessory",
			IsMovingProjectile = isProjectile,
			Pos = inst.Position, Radius = radius,
			Tier = 0, LastSwitch = 0, LastInViewAt = now, CreatedAt = now,
			Orig = {}, Applied = {}, Occluded = false, LastOcclusionAt = 0,
		}
	end

	return nil
end

local function propsAlmostEqual(a, b)
	if a == b then return true end
	if typeof(a) == "number" and typeof(b) == "number" then
		return math.abs(a - b) <= 0.025
	end
	return false
end

-- Escreve propriedade mantendo historico exato e respeitando mudancas legitimas feitas pelo jogo
local function writeSmartProp(entry, inst, prop, targetVal)
	local orig = entry.Orig
	local applied = entry.Applied
	local okRead, current = pcall(function() return inst[prop] end)
	if not okRead then return false end

	if orig[prop] == nil then
		orig[prop] = current
	elseif applied[prop] ~= nil and not propsAlmostEqual(current, applied[prop]) then
		-- O jogo alterou legitimamente esta propriedade enquanto otimizada: atualiza baseline e respeita!
		orig[prop] = current
		applied[prop] = nil
		if prop == "Enabled" and current == false then
			return false
		end
		if prop == "Visible" and current == false then
			return false
		end
	elseif applied[prop] == nil then
		orig[prop] = current
	end

	if propsAlmostEqual(current, targetVal) then
		if applied[prop] ~= nil then
			applied[prop] = current
		end
		return false
	end

	local okSet = pcall(function() inst[prop] = targetVal end)
	if okSet then
		local okAfter, afterVal = pcall(function() return inst[prop] end)
		applied[prop] = okAfter and afterVal or targetVal
		return true
	end
	return false
end

-- Restaura propriedade somente se SmartPerf a modificou e o jogo nao a sobrescreveu depois
local function restoreSmartProp(entry, inst, prop)
	local orig = entry.Orig
	local applied = entry.Applied
	if not orig or not applied then return false end
	local appVal = applied[prop]
	local origVal = orig[prop]
	if appVal == nil then return false end
	applied[prop] = nil
	if origVal == nil then return false end

	local okRead, current = pcall(function() return inst[prop] end)
	if not okRead then return false end
	if not propsAlmostEqual(current, appVal) then
		-- Jogo alterou legitimamente depois da nossa escrita: nao sobrescreve
		orig[prop] = current
		return false
	end
	if not propsAlmostEqual(current, origVal) then
		pcall(function() inst[prop] = origVal end)
		return true
	end
	return false
end

local function hasAnyAppliedProp(entry)
	if not entry.Applied then return false end
	for _ in pairs(entry.Applied) do
		return true
	end
	return false
end

local function restoreAnimatorTracks(meta)
	if not meta or not meta.Animator then return end
	local ok, tracks = pcall(function() return meta.Animator:GetPlayingAnimationTracks() end)
	if not ok or typeof(tracks) ~= "table" then return end
	for _, track in ipairs(tracks) do
		local origSpeed = SmartPerf.AnimOrig[track]
		if origSpeed ~= nil then
			pcall(function() track:AdjustSpeed(origSpeed) end)
			SmartPerf.AnimOrig[track] = nil
		end
	end
end

local function applyAnimatorThrottle(meta, factor)
	if not meta or not meta.Animator then return false end
	local ok, tracks = pcall(function() return meta.Animator:GetPlayingAnimationTracks() end)
	if not ok or typeof(tracks) ~= "table" then return false end
	local any = false
	for _, track in ipairs(tracks) do
		if track.IsPlaying then
			local p = track.Priority
			if p == Enum.AnimationPriority.Core or p == Enum.AnimationPriority.Idle then
				if SmartPerf.AnimOrig[track] == nil then
					SmartPerf.AnimOrig[track] = track.Speed
				end
				local target = math.max(0.10, SmartPerf.AnimOrig[track] * factor)
				if math.abs(track.Speed - target) > 0.04 then
					pcall(function() track:AdjustSpeed(target) end)
				end
				any = true
			end
		end
	end
	return any
end

local function restoreSmartEntry(entry)
	local inst = entry.Inst
	if not inst or not inst.Parent then
		SmartPerf.Modified[inst] = nil
		entry.Tier = 0
		return
	end
	if entry.Kind == "Character" then
		local meta = SmartPerf.CharacterModels[inst]
		if meta then restoreAnimatorTracks(meta) end
		SmartPerf.Modified[inst] = nil
		entry.Tier = 0
		return
	end
	if entry.Applied then
		local props = {}
		for prop in pairs(entry.Applied) do
			table.insert(props, prop)
		end
		for _, prop in ipairs(props) do
			restoreSmartProp(entry, inst, prop)
		end
	end
	SmartPerf.Modified[inst] = nil
	entry.Tier = 0
end

local function applySmartTier(entry, newTier, intensity, prof)
	-- Tiers:
	--   0 = Near / Preserved
	--   1 = Mid LOD
	--   2 = Far Aggressive LOD
	--   3 = Culled (Off-screen, Ocluso ou > CullRadius)
	--   4 = Hibernated (efeito temporario finalizado)
	if newTier == 0 then
		if SmartPerf.Modified[entry.Inst] or hasAnyAppliedProp(entry) then
			restoreSmartEntry(entry)
		else
			entry.Tier = 0
		end
		return
	end

	local inst = entry.Inst
	if not inst or not inst.Parent then return end
	local cfg = SmartPerf.Config
	local kind = entry.Kind
	local sev = math.clamp(intensity or 0.5, 0.1, 1.0)
	prof = prof or SmartPerf.ActiveProfile or SmartModeProfiles.Equilibrado

	if kind == "Character" then
		local meta = SmartPerf.CharacterModels[inst]
		if meta and cfg.CharacterOptimization and not meta.InCombat and newTier >= 2 then
			local spd = newTier >= 3 and prof.CharAnimSpeedCull or prof.CharAnimSpeedFar
			if applyAnimatorThrottle(meta, spd) then
				SmartPerf.Modified[inst] = entry
			end
		elseif meta then
			restoreAnimatorTracks(meta)
			SmartPerf.Modified[inst] = nil
		end
		entry.Tier = newTier
		return
	end

	-- Personagem remoto: protecao ou toggle desligado
	if entry.CharModel then
		local meta = SmartPerf.CharacterModels[entry.CharModel]
		if (meta and meta.InCombat) or (not cfg.CharacterOptimization and (kind == "Part" or kind == "Mesh")) then
			restoreSmartEntry(entry)
			return
		end
	end

	if kind == "Mesh" or kind == "Part" then
		if not cfg.ObjectOptimization and not (entry.CharModel and cfg.CharacterOptimization) then
			restoreSmartEntry(entry)
			return
		end

		local canCullPart = cfg.FrustumCulling and newTier >= 3 and not entry.CombatProtected
		if entry.CharModel then
			canCullPart = canCullPart and cfg.CharacterOptimization and entry.IsAccessory == true
		else
			canCullPart = canCullPart and (
				entry.IsAccessory
				or (prof.PartCullTier >= 3 and entry.Radius <= prof.MaxPartCullRadius)
			)
		end

		if canCullPart then
			writeSmartProp(entry, inst, "LocalTransparencyModifier", 1)
		else
			restoreSmartProp(entry, inst, "LocalTransparencyModifier")
		end

		if newTier >= prof.ShadowOffTier or entry.IsAccessory or sev >= 0.72 then
			writeSmartProp(entry, inst, "CastShadow", false)
		else
			restoreSmartProp(entry, inst, "CastShadow")
		end

		if not entry.CharModel then
			local baseRefl = entry.Orig.Reflectance
			if baseRefl == nil then
				pcall(function() baseRefl = inst.Reflectance end)
			end
			if baseRefl and baseRefl > 0.05 then
				local targetReflect = (newTier == 1 and prof.Name == "Leve") and (baseRefl * 0.45) or 0
				writeSmartProp(entry, inst, "Reflectance", targetReflect)
			end

			if not entry.HasTex and newTier >= prof.MaterialSimplifyTier then
				local baseMat = entry.Orig.Material
				if baseMat == nil then pcall(function() baseMat = inst.Material end) end
				if baseMat == Enum.Material.Glass or (baseMat and SmartProceduralMaterials[baseMat]) then
					writeSmartProp(entry, inst, "Material", Enum.Material.SmoothPlastic)
				end
			else
				restoreSmartProp(entry, inst, "Material")
			end

			if kind == "Mesh" then
				if newTier >= 2 or prof.Name == "Ultra" then
					writeSmartProp(entry, inst, "RenderFidelity", Enum.RenderFidelity.Performance)
				else
					restoreSmartProp(entry, inst, "RenderFidelity")
				end
			end
		end
	elseif kind == "Model" then
		if not cfg.ObjectOptimization then
			restoreSmartEntry(entry)
			return
		end
		if newTier >= 2 then
			local okSm, sm = pcall(function() return Enum.ModelLevelOfDetail.StreamingMesh end)
			if okSm and sm then writeSmartProp(entry, inst, "LevelOfDetail", sm) end
		else
			restoreSmartProp(entry, inst, "LevelOfDetail")
		end
	elseif kind == "Decal" then
		if not cfg.ObjectOptimization then
			restoreSmartEntry(entry)
			return
		end
		local hideDecal = (newTier >= prof.DecalHideTier) and not entry.CombatProtected
		if hideDecal then
			writeSmartProp(entry, inst, "Transparency", 1)
		else
			restoreSmartProp(entry, inst, "Transparency")
		end
	elseif kind == "GuiImage" then
		if not cfg.ObjectOptimization then
			restoreSmartEntry(entry)
			return
		end
		if newTier >= 3 and not entry.CombatProtected then
			writeSmartProp(entry, inst, "ImageTransparency", 1)
		else
			restoreSmartProp(entry, inst, "ImageTransparency")
		end
	elseif kind == "SurfaceGui" or kind == "BillboardGui" then
		if not cfg.ObjectOptimization then
			restoreSmartEntry(entry)
			return
		end
		if newTier >= 3 and not entry.CombatProtected then
			writeSmartProp(entry, inst, "Enabled", false)
		else
			restoreSmartProp(entry, inst, "Enabled")
			if kind == "SurfaceGui" then
				local okMode, mode = pcall(function() return inst.SizingMode end)
				if okMode and mode == Enum.SurfaceGuiSizingMode.PixelsPerStud then
					local origPps = entry.Orig.PixelsPerStud
					if origPps == nil then pcall(function() origPps = inst.PixelsPerStud end) end
					local cap = (newTier >= 2) and (prof.Name == "Ultra" and 8 or 11) or 18
					if origPps and origPps > cap then
						writeSmartProp(entry, inst, "PixelsPerStud", cap)
					else
						restoreSmartProp(entry, inst, "PixelsPerStud")
					end
				end
			end
		end
	elseif kind == "Particle" then
		local isPrimary = entry.IsPrimaryEffect or entry.CombatProtected
		local shouldHibernate = (newTier == 4 and cfg.EffectCleanup and not isPrimary)
		local shouldCull = (newTier == 3 and cfg.FrustumCulling and prof.CullParticles and not isPrimary)

		if shouldHibernate or shouldCull then
			writeSmartProp(entry, inst, "Enabled", false)
		else
			restoreSmartProp(entry, inst, "Enabled")
			if cfg.EffectOptimization then
				local origRate = entry.Orig.Rate
				if origRate == nil then pcall(function() origRate = inst.Rate end) end
				if origRate and origRate > 0 then
					local minKeep = isPrimary and prof.ParticlePrimaryScaleMin or prof.ParticleScaleMin
					local drop = isPrimary and (sev * 0.35) or ((newTier == 1) and (sev * 0.55) or (sev * 0.88))
					local factor = math.max(minKeep, 1 - drop)
					local targetRate = math.max(1, math.floor(origRate * factor + 0.5))
					writeSmartProp(entry, inst, "Rate", targetRate)
				end
				if not isPrimary then
					local origLe = entry.Orig.LightEmission
					if origLe == nil then pcall(function() origLe = inst.LightEmission end) end
					if origLe and origLe > 0.05 then
						writeSmartProp(entry, inst, "LightEmission", origLe * ((newTier >= 2) and 0.4 or 0.72))
					end
				else
					restoreSmartProp(entry, inst, "LightEmission")
				end
			else
				restoreSmartProp(entry, inst, "Rate")
				restoreSmartProp(entry, inst, "LightEmission")
			end
		end
	elseif kind == "Beam" or kind == "Trail" then
		local isPrimary = entry.IsPrimaryEffect or entry.CombatProtected
		local shouldCull = (newTier == 4 and cfg.EffectCleanup and not isPrimary)
			or (newTier == 3 and cfg.FrustumCulling and prof.CullParticles and not isPrimary)

		if shouldCull then
			writeSmartProp(entry, inst, "Enabled", false)
		else
			restoreSmartProp(entry, inst, "Enabled")
			if cfg.EffectOptimization then
				local scaleFloor = isPrimary and 0.65 or 0.32
				local factor = math.max(scaleFloor, (newTier >= 2) and (1 - sev * 0.62) or (1 - sev * 0.28))
				if kind == "Beam" then
					local origSeg = entry.Orig.Segments
					if origSeg == nil then pcall(function() origSeg = inst.Segments end) end
					if origSeg and origSeg > 2 then
						writeSmartProp(entry, inst, "Segments", math.max(isPrimary and 3 or 1, math.floor(origSeg * factor + 0.5)))
					end
				else
					local origLen = entry.Orig.MaxLength
					if origLen == nil then pcall(function() origLen = inst.MaxLength end) end
					if origLen and origLen > 1 then
						writeSmartProp(entry, inst, "MaxLength", math.max(1, origLen * factor))
					end
				end
			else
				restoreSmartProp(entry, inst, "Segments")
				restoreSmartProp(entry, inst, "MaxLength")
			end
		end
	elseif kind == "TempFx" then
		local shouldHibernate = (newTier == 4 and cfg.EffectCleanup)
		local shouldCull = (newTier == 3 and cfg.FrustumCulling and prof.CullParticles and not entry.CombatProtected)
		if shouldHibernate or shouldCull then
			writeSmartProp(entry, inst, "Enabled", false)
		else
			restoreSmartProp(entry, inst, "Enabled")
			if cfg.EffectOptimization then
				local factor = math.max(0.35, (newTier >= 2) and (1 - sev * 0.60) or (1 - sev * 0.28))
				if inst:IsA("Smoke") then
					local origOp = entry.Orig.Opacity
					if origOp == nil then pcall(function() origOp = inst.Opacity end) end
					if origOp then writeSmartProp(entry, inst, "Opacity", origOp * factor) end
				end
				if inst:IsA("Fire") or inst:IsA("Smoke") then
					local origSz = entry.Orig.Size
					if origSz == nil then pcall(function() origSz = inst.Size end) end
					if origSz then writeSmartProp(entry, inst, "Size", math.max(1, origSz * factor)) end
				end
			else
				restoreSmartProp(entry, inst, "Opacity")
				restoreSmartProp(entry, inst, "Size")
			end
		end
	elseif kind == "Explosion" then
		if newTier == 4 and cfg.EffectCleanup then
			writeSmartProp(entry, inst, "Visible", false)
		else
			restoreSmartProp(entry, inst, "Visible")
		end
	elseif kind == "Light" then
		if not cfg.LightOptimization then
			restoreSmartEntry(entry)
			return
		end
		local shouldCull = (newTier >= 3 and cfg.FrustumCulling and prof.CullLights and not entry.CombatProtected)
		if shouldCull then
			writeSmartProp(entry, inst, "Enabled", false)
		else
			restoreSmartProp(entry, inst, "Enabled")
			if not entry.CombatProtected and (newTier >= prof.ShadowOffTier or sev >= 0.45) then
				writeSmartProp(entry, inst, "Shadows", false)
			else
				restoreSmartProp(entry, inst, "Shadows")
			end
			local origRange = entry.Orig.Range
			if origRange == nil then pcall(function() origRange = inst.Range end) end
			if origRange and origRange > 2 then
				local rFactor = math.max(prof.LightRangeMin, 1 - sev * ((newTier >= 2) and 0.55 or 0.28))
				writeSmartProp(entry, inst, "Range", origRange * rFactor)
			end
			if newTier >= 2 and not entry.CombatProtected then
				local origBr = entry.Orig.Brightness
				if origBr == nil then pcall(function() origBr = inst.Brightness end) end
				if origBr and origBr > 0.1 then
					local bFactor = math.max(prof.LightBrightMin, 1 - sev * 0.50)
					writeSmartProp(entry, inst, "Brightness", origBr * bFactor)
				end
			else
				restoreSmartProp(entry, inst, "Brightness")
			end
		end
	end

	entry.Tier = newTier
	if hasAnyAppliedProp(entry) then
		SmartPerf.Modified[inst] = entry
	else
		SmartPerf.Modified[inst] = nil
	end
end

local function refreshSmartCacheEntry(inst)
	local entry = classifySmartTarget(inst)
	if entry then
		SmartPerf.EntryMap[inst] = entry
		table.insert(SmartPerf.Cache, entry)
	end
end

local function removeSmartEntry(inst)
	if SmartPerf.CharacterModels[inst] then
		restoreAnimatorTracks(SmartPerf.CharacterModels[inst])
		SmartPerf.CharacterModels[inst] = nil
	end
	local entry = SmartPerf.EntryMap[inst]
	if not entry then return end
	SmartPerf.EntryMap[inst] = nil
	SmartPerf.Modified[inst] = nil
	entry.Dead = true
end

local function getReferenceContext()
	local player = Players.LocalPlayer
	local playerPos = nil
	local char = player and player.Character
	if char then
		local rootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
		if rootPart and rootPart:IsA("BasePart") then
			playerPos = rootPart.Position
		end
	end
	local cam = workspace.CurrentCamera
	local camPos = cam and cam.CFrame.Position or nil
	local camLook = cam and cam.CFrame.LookVector or nil
	local viewSize = cam and cam.ViewportSize or Vector2.new(1280, 720)
	return playerPos, cam, camPos, camLook, viewSize
end

local function refreshCombatContext(now, playerPos)
	local cfg = SmartPerf.Config
	if not cfg.CombatProtection then
		SmartPerf.LocalCombatUntil = 0
		for _, meta in pairs(SmartPerf.CharacterModels) do
			meta.InCombat = false
		end
		return
	end

	local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
	if localChar and localChar.Parent then
		if localChar:FindFirstChildOfClass("Tool") then
			SmartPerf.LocalCombatUntil = math.max(SmartPerf.LocalCombatUntil, now + 4.5)
		end
		local hum = localChar:FindFirstChildOfClass("Humanoid")
		if hum then
			if SmartPerf.LastLocalHp and hum.Health < SmartPerf.LastLocalHp - 0.5 then
				SmartPerf.LocalCombatUntil = math.max(SmartPerf.LocalCombatUntil, now + 6.0)
			end
			SmartPerf.LastLocalHp = hum.Health
		end
		local root = localChar:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") and root.AssemblyLinearVelocity.Magnitude > 26 then
			SmartPerf.LocalCombatUntil = math.max(SmartPerf.LocalCombatUntil, now + 2.5)
		end
	end

	local localInCombat = now < SmartPerf.LocalCombatUntil
	for model, meta in pairs(SmartPerf.CharacterModels) do
		if not model or not model.Parent then
			SmartPerf.CharacterModels[model] = nil
		else
			if model:FindFirstChildOfClass("Tool") then
				meta.CombatUntil = math.max(meta.CombatUntil, now + 4.5)
			end
			if meta.Humanoid and meta.Humanoid.Parent then
				local hp = meta.Humanoid.Health
				if meta.LastHp and hp < meta.LastHp - 0.5 then
					meta.CombatUntil = math.max(meta.CombatUntil, now + 5.5)
				end
				meta.LastHp = hp
			end
			local pos = getPartPositionSafe(model)
			if localInCombat and playerPos and pos and (pos - playerPos).Magnitude <= 130 then
				meta.CombatUntil = math.max(meta.CombatUntil, now + 3.5)
			end
			meta.InCombat = now < meta.CombatUntil
		end
	end
end

local function isEntryInCombat(entry, now)
	if not SmartPerf.Config.CombatProtection then return false end
	if entry.CombatProtected then return true end
	if entry.CharModel then
		local meta = SmartPerf.CharacterModels[entry.CharModel]
		if meta and meta.InCombat then return true end
	end
	-- Efeitos recem-criados ou projeteis fisicos sem nome de combate
	if (entry.Kind == "Part" or entry.Kind == "Mesh") and entry.Inst and not entry.Inst.Anchored then
		if entry.IsMovingProjectile then return true end
		local okVel, vel = pcall(function() return entry.Inst.AssemblyLinearVelocity.Magnitude end)
		if okVel and vel >= 12 then return true end
	end
	if entry.IsPrimaryEffect and (now - (entry.CreatedAt or now)) < 3.0 then
		return true
	end
	return false
end

local function checkLineOfSightOcclusion(entry, camPos, prof)
	if not camPos or not prof.OcclusionEnabled then return false end
	if SmartPerf.OcclusionChecks >= prof.OcclusionBudget then
		return entry.Occluded == true
	end
	local vec = entry.Pos - camPos
	local dist = vec.Magnitude
	if dist <= math.max(entry.Radius + 14, 24) then return false end

	if not SmartPerf.RaycastParams then
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Exclude
		rp.IgnoreWater = true
		SmartPerf.RaycastParams = rp
	end

	local ignore = SmartPerf.RayIgnoreList
	table.clear(ignore)
	local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
	if localChar then table.insert(ignore, localChar) end
	if entry.CharModel then
		table.insert(ignore, entry.CharModel)
	elseif entry.Anchor then
		table.insert(ignore, entry.Anchor)
	elseif entry.Inst then
		table.insert(ignore, entry.Inst)
	end

	SmartPerf.RaycastParams.FilterDescendantsInstances = ignore
	SmartPerf.OcclusionChecks = SmartPerf.OcclusionChecks + 1

	local dir = vec.Unit * math.max(1, dist - math.max(entry.Radius * 0.85, 2))
	local okHit, res = pcall(function()
		return workspace:Raycast(camPos, dir, SmartPerf.RaycastParams)
	end)
	if okHit and res and res.Instance then
		local hitPart = res.Instance
		if hitPart:IsA("BasePart") and hitPart.CanCollide ~= false and hitPart.Transparency < 0.45 then
			return true
		end
	end
	return false
end

local function computeEntryVisibility(entry, now, cam, camPos, rawCamDist, effDist, nearR, viewW, viewH, prof, moved)
	if not cam or not camPos then
		entry.Occluded = false
		return true, false
	end
	if rawCamDist <= math.max(entry.Radius + 18, 24) then
		entry.Occluded = false
		return true, false
	end

	local okVp, vp = pcall(function() return cam:WorldToViewportPoint(entry.Pos) end)
	if not okVp or typeof(vp) ~= "Vector3" then
		return true, false
	end
	local marginPx = math.clamp((entry.Radius / math.max(rawCamDist, 1)) * viewH * 1.2 + 42, 42, viewH * 0.95)
	if vp.Z < -entry.Radius then
		return false, false
	end
	local inFrustum = vp.X >= -marginPx and vp.X <= (viewW + marginPx)
		and vp.Y >= -marginPx and vp.Y <= (viewH + marginPx)
	if not inFrustum then
		return false, false
	end

	if prof.OcclusionEnabled
		and effDist >= nearR * 0.9
		and entry.Radius < 38
		and not entry.CombatProtected
		and not entry.InCombatNow
		and entry.Kind ~= "Explosion" then
		local reval = moved and (prof.OcclusionRevalidate * 0.5) or prof.OcclusionRevalidate
		if (now - (entry.LastOcclusionAt or 0)) >= reval then
			entry.Occluded = checkLineOfSightOcclusion(entry, camPos, prof)
			entry.LastOcclusionAt = now
		end
		if entry.Occluded then
			return false, true
		end
	else
		entry.Occluded = false
	end

	return true, false
end

local function isFinishedTempEffect(entry, now)
	if not SmartPerf.Config.EffectCleanup then return false end
	if entry.Kind == "Explosion" then
		return (now - (entry.CreatedAt or now)) >= 1.6
	end
	if entry.IsTemp and (entry.Kind == "Particle" or entry.Kind == "TempFx") then
		local inst = entry.Inst
		if inst and inst.Parent then
			if inst.Enabled == false and not (entry.Applied and entry.Applied.Enabled == false) then
				if not entry.DisabledSince then entry.DisabledSince = now end
				if (now - entry.DisabledSince) >= 2.2 then return true end
			elseif inst.Enabled == true then
				entry.DisabledSince = nil
			end
		end
	end
	return false
end

local function evaluateSmartEntry(entry, now, playerPos, cam, camPos, viewW, viewH, moved, forceApply)
	local prof = SmartPerf.ActiveProfile or SmartModeProfiles.Equilibrado
	local anchor = entry.Anchor or entry.Inst
	if entry.Kind == "Character" then
		local p = getPartPositionSafe(entry.Inst)
		if p then entry.Pos = p end
	elseif entry.Kind ~= "Model" and anchor and anchor.Parent then
		local p = getPartPositionSafe(anchor)
		if p then entry.Pos = p end
	end

	local pos = entry.Pos
	local dPlayer = playerPos and (pos - playerPos).Magnitude or math.huge
	local dCam = camPos and (pos - camPos).Magnitude or math.huge
	local rawDist = math.min(dPlayer, dCam)
	local effDist = math.max(0, rawDist - entry.Radius)

	local inCombat = isEntryInCombat(entry, now)
	entry.InCombatNow = inCombat

	-- Limpeza segura (hibernacao reversivel) de efeitos temporarios ja finalizados
	if isFinishedTempEffect(entry, now) then
		if entry.Tier ~= 4 or forceApply then
			applySmartTier(entry, 4, SmartPerf.Intensity, prof)
			entry.LastSwitch = now
		end
		return
	end

	local nearR, farR, cullR = SmartPerf.NearRadius, SmartPerf.FarRadius, SmartPerf.CullRadius
	local inView, isOccluded = true, false
	if SmartPerf.Config.FrustumCulling and effDist > nearR * 0.75 then
		inView, isOccluded = computeEntryVisibility(entry, now, cam, camPos, dCam, effDist, nearR, viewW, viewH, prof, moved)
	else
		entry.Occluded = false
	end
	if inView then
		entry.LastInViewAt = now
	end

	-- Protecao absoluta de combate & janela de tolerancia se girar a camera rapidamente
	if inCombat then
		if effDist <= farR or (now - (entry.LastInViewAt or now)) < prof.OffCameraCombatGrace then
			if entry.Tier ~= 0 or forceApply then
				applySmartTier(entry, 0, SmartPerf.Intensity, prof)
				entry.LastSwitch = now
			end
			return
		end
		if entry.Tier ~= 1 or forceApply then
			applySmartTier(entry, 1, SmartPerf.Intensity * 0.40, prof)
			entry.LastSwitch = now
		end
		return
	end

	local curTier = entry.Tier or 0
	local targetTier = curTier

	local offCamTooLong = (now - (entry.LastInViewAt or now)) >= (entry.CharModel and 1.2 or 0.25)
	if SmartPerf.Config.FrustumCulling and (effDist > cullR or (not inView and effDist > nearR and (isOccluded or offCamTooLong))) then
		if entry.Priority ~= "Critical" then
			targetTier = 3
		else
			targetTier = 2
		end
	else
		-- Se voltou a ficar visivel e estava culled/hibernado, reavalia pela distancia imediatamente!
		local evalTier = (curTier >= 3) and 2 or curTier
		if evalTier == 0 then
			if effDist > farR + SMART_HYSTERESIS then
				targetTier = 2
			elseif effDist > nearR + SMART_HYSTERESIS then
				targetTier = 1
			else
				targetTier = 0
			end
		elseif evalTier == 1 then
			if effDist < nearR - SMART_HYSTERESIS then
				targetTier = 0
			elseif effDist > farR + SMART_HYSTERESIS then
				targetTier = 2
			else
				targetTier = 1
			end
		else
			if effDist < nearR - SMART_HYSTERESIS then
				targetTier = 0
			elseif effDist < farR - SMART_HYSTERESIS then
				targetTier = 1
			else
				targetTier = 2
			end
		end
	end

	local restoringVisual = targetTier < curTier
	if forceApply or (targetTier ~= curTier and (restoringVisual or (now - (entry.LastSwitch or 0) >= SMART_MIN_DWELL))) then
		applySmartTier(entry, targetTier, SmartPerf.Intensity, prof)
		entry.LastSwitch = now
		entry.AppliedEpoch = SmartPerf.ConfigEpoch
	elseif targetTier > 0 and entry.AppliedEpoch ~= SmartPerf.ConfigEpoch then
		applySmartTier(entry, targetTier, SmartPerf.Intensity, prof)
		entry.AppliedEpoch = SmartPerf.ConfigEpoch
	end
end

local function updateAdaptiveIntensity(dt, now)
	if dt > 0 and dt < 0.5 then
		local instFps = 1 / math.max(dt, 0.001)
		SmartPerf.SmoothFps = SmartPerf.SmoothFps * 0.90 + instFps * 0.10
		SmartPerf.LastFrameMs = SmartPerf.LastFrameMs * 0.90 + (dt * 1000) * 0.10
		local isSpike = dt > 0.034 and 1 or 0
		SmartPerf.SpikeScore = SmartPerf.SpikeScore * 0.92 + isSpike * 0.08
	end

	local cfg = SmartPerf.Config
	local targetFps = math.clamp(tonumber(cfg.TargetFPS) or 55, 30, 120)
	local rawStress = math.clamp((targetFps - SmartPerf.SmoothFps) / math.max(targetFps * 0.45, 14), 0, 1)
	rawStress = math.clamp(rawStress + SmartPerf.SpikeScore * 0.50, 0, 1)

	if rawStress > 0.20 or SmartPerf.SpikeScore > 0.12 then
		SmartPerf.LastOverloadAt = now
	end

	local mode = cfg.Mode or "Automatico"
	local userScale = math.clamp((tonumber(cfg.Intensity) or 100) / 100, 0.20, 1.0)
	local prof = SmartModeProfiles[mode]
	local desired

	if prof then
		desired = math.clamp(prof.MinIntensity + (prof.MaxIntensity - prof.MinIntensity) * rawStress, prof.MinIntensity, prof.MaxIntensity)
		desired = desired * userScale
		SmartPerf.ActiveProfile = prof
		SmartPerf.ActiveProfileName = prof.Name
	else
		-- Modo Automatico seleciona dinamicamente o perfil real conforme FPS + carga
		desired = math.clamp(0.16 + rawStress * 0.84, 0.16, 1.0) * userScale
		local intenCheck = SmartPerf.Intensity
		local autoProfName = "Leve"
		if intenCheck >= 0.80 then
			autoProfName = "Ultra"
		elseif intenCheck >= 0.56 then
			autoProfName = "Agressivo"
		elseif intenCheck >= 0.33 then
			autoProfName = "Equilibrado"
		end
		prof = SmartModeProfiles[autoProfName]
		SmartPerf.ActiveProfile = prof
		SmartPerf.ActiveProfileName = autoProfName
	end

	-- Escalonamento assimetrico: sobe rapido na queda de FPS, recupera devagar apos estabilizar
	if desired > SmartPerf.Intensity then
		SmartPerf.Intensity = SmartPerf.Intensity * 0.76 + desired * 0.24
	elseif (now - SmartPerf.LastOverloadAt) >= 2.0 and SmartPerf.SmoothFps >= (targetFps - 3) then
		SmartPerf.Intensity = SmartPerf.Intensity * 0.94 + desired * 0.06
	elseif mode ~= "Automatico" and math.abs(desired - SmartPerf.Intensity) > 0.12 then
		SmartPerf.Intensity = SmartPerf.Intensity * 0.82 + desired * 0.18
	end

	SmartPerf.Stress = SmartPerf.Intensity
	local inten = SmartPerf.Intensity
	-- Raios ancorados no perfil do modo selecionado, modulados pela intensidade manual/adaptativa
	local scaleAdj = 1.0 - (inten - prof.BaseIntensity) * 0.35
	SmartPerf.NearRadius = math.max(35, math.floor(prof.NearRadius * scaleAdj + 0.5))
	SmartPerf.FarRadius = math.max(SmartPerf.NearRadius + 40, math.floor(prof.FarRadius * scaleAdj + 0.5))
	SmartPerf.CullRadius = math.max(SmartPerf.FarRadius + 60, math.floor(prof.CullRadius * scaleAdj + 0.5))

	SmartPerf.Stats.Mode = mode
	SmartPerf.Stats.Profile = SmartPerf.ActiveProfileName
	SmartPerf.Stats.IntensityPct = math.floor(inten * 100 + 0.5)
	SmartPerf.Stats.FPS = math.floor(SmartPerf.SmoothFps + 0.5)
	SmartPerf.Stats.NearRadius = SmartPerf.NearRadius
	SmartPerf.Stats.FarRadius = SmartPerf.FarRadius
	SmartPerf.Stats.CullRadius = SmartPerf.CullRadius
	SmartPerf.Stats.StepIntervalMs = math.floor(prof.StepInterval * 1000 + 0.5)
end

local function reconcileSmartConfig()
	SmartPerf.ConfigEpoch = SmartPerf.ConfigEpoch + 1
	SmartPerf.StepAccum = 1
	SmartPerf.RestoreAccum = 1
	if not SmartPerf.Enabled then
		updateAdaptiveIntensity(0, os.clock())
		return
	end
	local now = os.clock()
	updateAdaptiveIntensity(0, now)
	local playerPos, cam, camPos, _, viewSize = getReferenceContext()
	local viewW = math.max(viewSize.X, 1)
	local viewH = math.max(viewSize.Y, 1)
	local list = {}
	for _, entry in pairs(SmartPerf.Modified) do
		if not entry.Dead and entry.Inst and entry.Inst.Parent then
			entry.LastOcclusionAt = 0
			table.insert(list, entry)
		end
	end
	local budgetStart = os.clock()
	for i, entry in ipairs(list) do
		evaluateSmartEntry(entry, now, playerPos, cam, camPos, viewW, viewH, true, true)
		if i % 30 == 0 and (os.clock() - budgetStart) > 0.0025 then
			break
		end
	end
end

local function stepSmartPerformance(dt)
	if not SmartPerf.Enabled then return end
	local now = os.clock()
	local startClock = now
	SmartPerf.OcclusionChecks = 0

	updateAdaptiveIntensity(dt, now)
	local prof = SmartPerf.ActiveProfile or SmartModeProfiles.Equilibrado

	-- Indexacao inicial incremental em lotes pequenos para nao gerar stutter
	if not SmartPerf.ScanDone and SmartPerf.ScanQueue then
		local queue = SmartPerf.ScanQueue
		local total = #queue
		local idx = SmartPerf.ScanIndex
		local processed = 0
		while idx <= total and processed < prof.BatchSize do
			refreshSmartCacheEntry(queue[idx])
			idx = idx + 1
			processed = processed + 1
			if processed % 40 == 0 and (os.clock() - startClock) > prof.StepBudget then
				break
			end
		end
		SmartPerf.ScanIndex = idx
		if idx > total then
			SmartPerf.ScanDone = true
			SmartPerf.ScanQueue = nil
		end
	end

	local playerPos, cam, camPos, camLook, viewSize = getReferenceContext()
	if not playerPos and not camPos then return end
	local viewW, viewH = math.max(viewSize.X, 1), math.max(viewSize.Y, 1)

	SmartPerf.ContextAccum = SmartPerf.ContextAccum + dt
	if SmartPerf.ContextAccum >= 0.2 then
		SmartPerf.ContextAccum = 0
		refreshCombatContext(now, playerPos)
	end

	local moved = false
	if playerPos and (not SmartPerf.LastPlayerPos or (playerPos - SmartPerf.LastPlayerPos).Magnitude >= 3) then
		moved = true; SmartPerf.LastPlayerPos = playerPos
	end
	if camPos and (not SmartPerf.LastCamPos or (camPos - SmartPerf.LastCamPos).Magnitude >= 3) then
		moved = true; SmartPerf.LastCamPos = camPos
	end
	if camLook and (not SmartPerf.LastCamLook or camLook:Dot(SmartPerf.LastCamLook) < 0.985) then
		moved = true; SmartPerf.LastCamLook = camLook
	end

	-- Passo rapido de restauracao visual para objetos culled/oclusos ao virar a camera
	SmartPerf.RestoreAccum = SmartPerf.RestoreAccum + dt
	local restoreInterval = moved and (prof.RestoreInterval * 0.75) or prof.RestoreInterval
	if SmartPerf.RestoreAccum >= restoreInterval then
		SmartPerf.RestoreAccum = 0
		local rList = SmartPerf.RestoreList
		table.clear(rList)
		for _, entry in pairs(SmartPerf.Modified) do
			if not entry.Dead and entry.Inst and entry.Inst.Parent then
				table.insert(rList, entry)
			end
		end
		local rCount = #rList
		if rCount > 0 then
			local rCursor = SmartPerf.RestoreCursor
			if rCursor > rCount then rCursor = 1 end
			local rBatch = math.min(rCount, math.floor(prof.BatchSize * 0.65))
			for _ = 1, rBatch do
				if rCursor > rCount then rCursor = 1 end
				local entry = rList[rCursor]
				if entry and not entry.Dead and entry.Inst and entry.Inst.Parent then
					evaluateSmartEntry(entry, now, playerPos, cam, camPos, viewW, viewH, moved, false)
				end
				rCursor = rCursor + 1
				if (os.clock() - startClock) > prof.RestoreBudget then break end
			end
			SmartPerf.RestoreCursor = rCursor
		end
	end

	SmartPerf.StepAccum = SmartPerf.StepAccum + dt
	local stepInterval = moved and math.max(0.08, prof.StepInterval * 0.78) or prof.StepInterval
	if SmartPerf.StepAccum < stepInterval then return end
	SmartPerf.StepAccum = 0

	local cache = SmartPerf.Cache
	local count = #cache
	if count == 0 then
		SmartPerf.Stats.CachedCount = 0
		SmartPerf.Stats.NearCount = 0
		SmartPerf.Stats.MidCount = 0
		SmartPerf.Stats.FarCount = 0
		SmartPerf.Stats.CulledCount = 0
		SmartPerf.Stats.OccludedCount = 0
		SmartPerf.Stats.ProtectedCount = 0
		SmartPerf.Stats.CleanedCount = 0
		SmartPerf.Stats.OptimizedCount = 0
		return
	end

	local batchLimit = math.min(count, prof.BatchSize)
	local cursor = SmartPerf.Cursor
	if cursor > count then cursor = 1 end

	local checks = 0
	while checks < batchLimit and #cache > 0 do
		if cursor > #cache then cursor = 1 end
		local entry = cache[cursor]
		if not entry or entry.Dead or not entry.Inst or not entry.Inst.Parent then
			if entry and entry.Inst then
				SmartPerf.EntryMap[entry.Inst] = nil
				SmartPerf.Modified[entry.Inst] = nil
			end
			cache[cursor] = cache[#cache]
			table.remove(cache)
		else
			evaluateSmartEntry(entry, now, playerPos, cam, camPos, viewW, viewH, moved, false)
			cursor = cursor + 1
		end
		checks = checks + 1
		if checks % 25 == 0 and (os.clock() - startClock) > prof.StepBudget then
			break
		end
	end
	SmartPerf.Cursor = cursor

	local nearC, midC, farC, cullC, occC, protC, cleanC, optC = 0, 0, 0, 0, 0, 0, 0, 0
	for _, entry in ipairs(cache) do
		if not entry.Dead then
			if entry.InCombatNow or entry.CombatProtected then protC = protC + 1 end
			if entry.Occluded then occC = occC + 1 end
			local t = entry.Tier or 0
			if t == 0 then nearC = nearC + 1
			elseif t == 1 then midC = midC + 1
			elseif t == 2 then farC = farC + 1
			elseif t == 3 then cullC = cullC + 1
			else cleanC = cleanC + 1 end
		end
	end
	for _ in pairs(SmartPerf.Modified) do optC = optC + 1 end

	SmartPerf.Stats.CachedCount = #cache
	SmartPerf.Stats.NearCount = nearC
	SmartPerf.Stats.MidCount = midC
	SmartPerf.Stats.FarCount = farC
	SmartPerf.Stats.CulledCount = cullC
	SmartPerf.Stats.OccludedCount = occC
	SmartPerf.Stats.ProtectedCount = protC
	SmartPerf.Stats.CleanedCount = cleanC
	SmartPerf.Stats.OptimizedCount = optC
end

local function enableSmartPerf()
	if SmartPerf.Enabled then return end
	SmartPerf.Enabled = true
	SmartPerf.Stats.Enabled = true
	SmartPerf.StepAccum = 0.3
	SmartPerf.RestoreAccum = 0.2
	SmartPerf.ContextAccum = 0.2
	SmartPerf.LastPlayerPos = nil
	SmartPerf.LastCamPos = nil
	SmartPerf.LastCamLook = nil
	updateAdaptiveIntensity(0, os.clock())
	local okDesc, desc = pcall(function() return workspace:GetDescendants() end)
	if okDesc and typeof(desc) == "table" then
		SmartPerf.ScanQueue = desc
		SmartPerf.ScanIndex = 1
		SmartPerf.ScanDone = #desc == 0
	else
		SmartPerf.ScanQueue = nil
		SmartPerf.ScanDone = true
	end
	table.insert(SmartPerf.Conns, workspace.DescendantAdded:Connect(function(inst)
		if not SmartPerf.Enabled then return end
		local parent = inst.Parent
		if parent and SmartPerf.EntryMap[parent] then
			if inst:IsA("ProximityPrompt") or inst:IsA("ClickDetector") or inst:IsA("DragDetector")
				or inst:IsA("TouchTransmitter") or inst:IsA("Humanoid") or inst:IsA("AnimationController") then
				restoreSmartEntry(SmartPerf.EntryMap[parent])
				removeSmartEntry(parent)
			elseif inst:IsA("SurfaceAppearance") or inst:IsA("Texture") or inst:IsA("Decal") then
				local pEntry = SmartPerf.EntryMap[parent]
				pEntry.HasTex = true
				restoreSmartProp(pEntry, pEntry.Inst, "Material")
			end
		end
		refreshSmartCacheEntry(inst)
	end))
	table.insert(SmartPerf.Conns, workspace.DescendantRemoving:Connect(function(inst)
		removeSmartEntry(inst)
	end))
	SmartPerf.HeartbeatConn = RunService.Heartbeat:Connect(stepSmartPerformance)
end

local function disableSmartPerf()
	if not SmartPerf.Enabled then return end
	SmartPerf.Enabled = false
	if SmartPerf.HeartbeatConn then
		SmartPerf.HeartbeatConn:Disconnect()
		SmartPerf.HeartbeatConn = nil
	end
	for _, conn in ipairs(SmartPerf.Conns) do
		conn:Disconnect()
	end
	table.clear(SmartPerf.Conns)

	local toRestore = {}
	for _, entry in pairs(SmartPerf.Modified) do
		table.insert(toRestore, entry)
	end
	for _, entry in ipairs(toRestore) do
		restoreSmartEntry(entry)
	end
	for _, meta in pairs(SmartPerf.CharacterModels) do
		restoreAnimatorTracks(meta)
	end
	table.clear(SmartPerf.Cache)
	table.clear(SmartPerf.EntryMap)
	table.clear(SmartPerf.Modified)
	table.clear(SmartPerf.CharacterModels)
	table.clear(SmartPerf.RestoreList)
	SmartPerf.ScanQueue = nil
	SmartPerf.ScanIndex = 1
	SmartPerf.ScanDone = true
	SmartPerf.Cursor = 1
	SmartPerf.RestoreCursor = 1
	SmartPerf.Stats.Enabled = false
	SmartPerf.Stats.Profile = "Inativo"
	SmartPerf.Stats.IntensityPct = 0
	SmartPerf.Stats.NearCount = 0
	SmartPerf.Stats.MidCount = 0
	SmartPerf.Stats.FarCount = 0
	SmartPerf.Stats.CulledCount = 0
	SmartPerf.Stats.OccludedCount = 0
	SmartPerf.Stats.ProtectedCount = 0
	SmartPerf.Stats.CleanedCount = 0
	SmartPerf.Stats.OptimizedCount = 0
	SmartPerf.Stats.CachedCount = 0
end

local function samplePerfSnapshot(fps, frameMs, pushHistory)
	local st = PerfMonitor.Stats
	if fps then
		st.FPS = fps
		if pushHistory then pushFpsHistory(fps) end
	end
	if frameMs then st.FrameTimeMs = frameMs end
	st.Uptime = os.clock() - LibraryStartClock
	st.PingMs = readPingMs()

	local elemCount, connCount, guiCount, winCount = 0, 0, 0, 0
	for _, win in ipairs(Windows) do
		if win._state ~= "Destroyed" then
			winCount = winCount + 1
			connCount = connCount + #(win._connections or {})
			for _, tab in ipairs(win._tabs or {}) do
				elemCount = elemCount + #(tab._entries or {})
			end
			if win._gui and win._gui.Parent then
				guiCount = guiCount + #win._gui:GetDescendants()
			end
		end
	end
	elemCount = elemCount + #(Notifications.Active or {})
	if Notifications.Gui and Notifications.Gui.Parent then
		guiCount = guiCount + #Notifications.Gui:GetDescendants()
	end

	local tweenCount = 0
	for _, records in pairs(ActiveTweens) do
		for _, rec in pairs(records) do
			if isRunning(rec) then
				tweenCount = tweenCount + 1
				break
			end
		end
	end

	st.ActiveElements = elemCount
	st.GuiObjects = guiCount
	st.ActiveTweens = tweenCount
	st.Connections = connCount
	st.Windows = winCount
	st.MemoryMB = readMemoryMb()
	return st
end

local function refreshPerfSubscription()
	local anyNeed = false
	for win in pairs(PerfMonitor.Subscribers) do
		if win._state ~= "Destroyed" and win:_needsPerfUpdates() then
			anyNeed = true
			break
		end
	end
	if anyNeed then
		if PerfMonitor.Conn then return end
		local frames, accum, emaFps = 0, 0, 60
		samplePerfSnapshot(nil, nil, false)
		for win in pairs(PerfMonitor.Subscribers) do
			if win._state ~= "Destroyed" and win:_needsPerfUpdates() then win:_updatePerfViews() end
		end
		PerfMonitor.Conn = RunService.Heartbeat:Connect(function(dt)
			frames = frames + 1
			accum = accum + dt
			local interval = math.clamp(tonumber(PerfMonitor.Interval) or 0.35, 0.15, 2)
			if accum < interval then return end
			local rawFps = frames / math.max(accum, 0.001)
			emaFps = emaFps * 0.35 + rawFps * 0.65
			local fps = math.clamp(math.floor(emaFps + 0.5), 1, 999)
			local frameMs = math.floor((accum / math.max(frames, 1)) * 10000 + 0.5) / 10
			frames = 0
			accum = 0
			samplePerfSnapshot(fps, frameMs, true)
			for win in pairs(PerfMonitor.Subscribers) do
				if win._state == "Destroyed" then
					PerfMonitor.Subscribers[win] = nil
				elseif win:_needsPerfUpdates() then
					win:_updatePerfViews()
				end
			end
		end)
	elseif PerfMonitor.Conn then
		PerfMonitor.Conn:Disconnect()
		PerfMonitor.Conn = nil
	end
end

local function addCorner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end
local function addCornerScale(parent, scale)
	return create("UICorner", { CornerRadius = UDim.new(scale, 0), Parent = parent })
end
local function addPadding(parent, l, t, r, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b), Parent = parent,
	})
end
local function addStroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or Theme.Stroke, Transparency = transparency or 0,
		Thickness = thickness or 1, Parent = parent,
	})
end
local function addGradient(parent, sequence, rotation)
	return create("UIGradient", { Transparency = sequence, Rotation = rotation or 0, Parent = parent })
end

local ShadowLayers = {
	{ Grow = 1, Alpha = 0.78 }, { Grow = 5, Alpha = 0.88 }, { Grow = 12, Alpha = 0.94 },
}

local function attachShadow(target, parent, corner, scaleObject, connections)
	local container = create("Frame", {
		Name = "Shadow", AnchorPoint = target.AnchorPoint,
		BackgroundTransparency = 1, ZIndex = 0, Parent = parent,
	})
	local containerScale = nil
	if scaleObject then containerScale = create("UIScale", { Parent = container }) end
	local layers = {}
	for _, spec in ipairs(ShadowLayers) do
		local layer = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, spec.Grow * 2, 1, spec.Grow * 2),
			BackgroundColor3 = Theme.Shadow, BackgroundTransparency = spec.Alpha,
			Parent = container,
		})
		addCorner(layer, corner + spec.Grow)
		table.insert(layers, { Frame = layer, Alpha = spec.Alpha })
	end
	local lastGroup = nil
	local function sync()
		local visible = target.Visible and not State.LowPerformance
		if container.Visible ~= visible then container.Visible = visible end
		if not visible then return end
		local position = target.Position
		container.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 4)
		container.Size = target.Size
		if containerScale then containerScale.Scale = scaleObject.Scale end
		local groupTransparency = target.GroupTransparency
		if groupTransparency ~= lastGroup then
			lastGroup = groupTransparency
			for _, layer in ipairs(layers) do
				layer.Frame.BackgroundTransparency = 1 - (1 - layer.Alpha) * (1 - groupTransparency)
			end
		end
	end
	-- Posicao/tamanho/transparencia/escala mudam juntos num tween: coalesce
	-- em uma unica atualizacao por frame.
	local pending = false
	local function schedule()
		if pending then return end
		pending = true
		task.defer(function()
			pending = false
			sync()
		end)
	end
	local function watch(instance, property)
		local c = instance:GetPropertyChangedSignal(property):Connect(schedule)
		if connections then table.insert(connections, c) end
	end
	watch(target, "Position"); watch(target, "Size")
	watch(target, "Visible"); watch(target, "GroupTransparency")
	if scaleObject then watch(scaleObject, "Scale") end
	sync()
	return { Instance = container, Sync = sync }
end

local function safeCall(callback, ...)
	if typeof(callback) ~= "function" then return end
	local ok, err = pcall(callback, ...)
	if not ok then warn("[AetherUI] Erro em callback: " .. tostring(err)) end
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function getGuiInset()
	local ok, topLeft = pcall(function() return GuiService:GetGuiInset() end)
	if ok and typeof(topLeft) == "Vector2" then return topLeft end
	return Vector2.zero
end

local function isMouseInput(input)
	local t = input.UserInputType
	return t == Enum.UserInputType.MouseButton1
		or t == Enum.UserInputType.MouseButton2
		or t == Enum.UserInputType.MouseMovement
end

local function pointInGuiBounds(point, gui)
	if not gui then return false end
	local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X
		and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

-- Calibra o deslocamento entre InputObject.Position e GuiObject.AbsolutePosition
-- (evita desvios causados por GuiInset / Topbar v2 / telas com notch no Mobile).
local CalibratedTouchOffset = nil

local function detectPointerOffset(input, refGui)
	local raw = Vector2.new(input.Position.X, input.Position.Y)
	local inset = getGuiInset()
	if inset.Magnitude < 1 then
		if input.UserInputType == Enum.UserInputType.Touch then
			CalibratedTouchOffset = Vector2.zero
		end
		return Vector2.zero
	end
	local okMl, ml = pcall(function() return UserInputService:GetMouseLocation() end)
	if okMl and typeof(ml) == "Vector2" and ml.Magnitude > 0 then
		if (ml - raw).Magnitude <= 6 then
			if input.UserInputType == Enum.UserInputType.Touch then CalibratedTouchOffset = Vector2.zero end
			return Vector2.zero
		end
		if (ml - (raw + inset)).Magnitude <= 6 then
			if input.UserInputType == Enum.UserInputType.Touch then CalibratedTouchOffset = inset end
			return inset
		end
	end
	if refGui then
		local rawIn = pointInGuiBounds(raw, refGui)
		local insetIn = pointInGuiBounds(raw + inset, refGui)
		if rawIn and not insetIn then
			if input.UserInputType == Enum.UserInputType.Touch then CalibratedTouchOffset = Vector2.zero end
			return Vector2.zero
		end
		if insetIn and not rawIn then
			if input.UserInputType == Enum.UserInputType.Touch then CalibratedTouchOffset = inset end
			return inset
		end
	end
	if CalibratedTouchOffset ~= nil then
		return CalibratedTouchOffset
	end
	return inset
end

-- Posicao do ponteiro exatamente no mesmo espaco de AbsolutePosition (IgnoreGuiInset = true).
local function pointerPosition(input, forcedOffset)
	local raw = Vector2.new(input.Position.X, input.Position.Y)
	if forcedOffset ~= nil then
		return raw + forcedOffset
	end
	if isMouseInput(input) then
		local okMl, ml = pcall(function() return UserInputService:GetMouseLocation() end)
		if okMl and typeof(ml) == "Vector2" and ml.Magnitude > 0 then return ml end
	end
	return raw + detectPointerOffset(input, nil)
end

-- Normaliza texto para busca: minusculas e sem acentos.
local AccentMap = {}
do
	local groups = {
		a = "\u{E0}\u{E1}\u{E2}\u{E3}\u{E4}\u{C0}\u{C1}\u{C2}\u{C3}\u{C4}",
		e = "\u{E8}\u{E9}\u{EA}\u{EB}\u{C8}\u{C9}\u{CA}\u{CB}",
		i = "\u{EC}\u{ED}\u{EE}\u{EF}\u{CC}\u{CD}\u{CE}\u{CF}",
		o = "\u{F2}\u{F3}\u{F4}\u{F5}\u{F6}\u{D2}\u{D3}\u{D4}\u{D5}\u{D6}",
		u = "\u{F9}\u{FA}\u{FB}\u{FC}\u{D9}\u{DA}\u{DB}\u{DC}",
		c = "\u{E7}\u{C7}",
		n = "\u{F1}\u{D1}",
	}
	for base, chars in pairs(groups) do
		for _, code in utf8.codes(chars) do AccentMap[utf8.char(code)] = base end
	end
end
local function normalizeText(text)
	text = tostring(text == nil and "" or text)
	local ok, result = pcall(string.gsub, text, utf8.charpattern, function(ch) return AccentMap[ch] end)
	if ok then text = result end
	return string.lower(text)
end

local function colorsEqual(a, b)
	return math.abs(a.R - b.R) < 0.004 and math.abs(a.G - b.G) < 0.004 and math.abs(a.B - b.B) < 0.004
end

local function getViewport()
	local camera = workspace.CurrentCamera
	if camera then return camera.ViewportSize end
	return Vector2.new(1280, 720)
end

local function isMobile()
	if not UserInputService.TouchEnabled then return false end
	if not UserInputService.KeyboardEnabled then return true end
	return getViewport().X <= 760
end

local function computeMetrics(compact)
	local mobile = isMobile()
	local c = compact == true
	local m = {}
	m.Mobile = mobile
	m.Compact = c
	m.Row = c and (mobile and 40 or 34) or (mobile and 48 or 40)
	m.Title = c and (mobile and 42 or 36) or (mobile and 50 or 44)
	m.Text = c and (mobile and 13 or 12) or (mobile and 15 or 14)
	m.Ball = c and (mobile and 48 or 42) or (mobile and 58 or 50)
	m.TitleButton = c and (mobile and 32 or 26) or (mobile and 36 or 30)
	m.Icon = c and 13 or (mobile and 17 or 16)
	m.SideRow = c and (mobile and 40 or 34) or (mobile and 46 or 40)
	m.SideWidth = c and (mobile and 116 or 118) or (mobile and 136 or 152)
	m.SidePad = 8
	m.SideGap = c and 3 or 4
	m.Pad = c and 10 or 12
	m.Gap = c and 7 or 9
	m.Header = c and 26 or 30
	m.SwitchW = c and (mobile and 42 or 38) or (mobile and 48 or 44)
	m.SwitchH = c and (mobile and 24 or 22) or (mobile and 28 or 26)
	m.Swatch = c and 24 or (mobile and 28 or 26)
	return m
end

local function getWindowSize(m)
	local viewport = getViewport()
	local inset = getGuiInset()
	local width, height
	if m.Mobile then
		local portrait = viewport.X < viewport.Y
		if portrait then
			width = math.clamp(math.floor(viewport.X * 0.92), 290, 440)
			height = math.clamp(math.floor(viewport.Y * (m.Compact and 0.56 or 0.64)), 280, 520)
		else
			if m.Compact then
				width = math.clamp(math.floor(viewport.X * 0.58), 300, 420)
				height = math.clamp(math.floor(viewport.Y * 0.76), 220, 320)
			else
				width = math.clamp(math.floor(viewport.X * 0.68), 340, 500)
				height = math.clamp(math.floor(viewport.Y * 0.82), 240, 360)
			end
		end
	else
		if m.Compact then
			width = math.clamp(math.floor(viewport.X * 0.36), 380, 460)
			height = math.clamp(math.floor(viewport.Y * 0.5), 260, 340)
		else
			width = math.clamp(math.floor(viewport.X * 0.46), 480, 620)
			height = math.clamp(math.floor(viewport.Y * 0.62), 340, 460)
		end
	end
	width = math.min(width, math.max(math.floor(viewport.X) - 12, 200))
	height = math.min(height, math.max(math.floor(viewport.Y - inset.Y) - 12, 180))
	return UDim2.fromOffset(width, height)
end

local function bindCanvas(scroll, layout, axis, extra)
	local function update()
		local content = layout.AbsoluteContentSize
		if axis == "X" then scroll.CanvasSize = UDim2.fromOffset(content.X + extra, 0)
		else scroll.CanvasSize = UDim2.fromOffset(0, content.Y + extra) end
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
	return update
end

local function resolveParent()
	local ok, hidden = pcall(function() return gethui() end)
	if ok and typeof(hidden) == "Instance" then return hidden end
	local player = Players.LocalPlayer
	assert(player, "[AetherUI] CreateWindow deve ser chamado a partir de um LocalScript.")
	return player:WaitForChild("PlayerGui")
end

local function clampWindowPosition(position, size)
	local viewport = getViewport()
	local insetTop = getGuiInset().Y
	local halfW = size.X.Offset / 2
	local halfH = size.Y.Offset / 2
	local minY = math.min(halfH + insetTop + 4, viewport.Y / 2)
	local maxY = math.max(viewport.Y - halfH - 4, minY)
	local cx = position.X.Scale * viewport.X + position.X.Offset
	local cy = position.Y.Scale * viewport.Y + position.Y.Offset
	local nx = math.clamp(cx, math.min(halfW, viewport.X / 2), math.max(viewport.X - halfW, viewport.X / 2))
	local ny = math.clamp(cy, minY, maxY)
	return UDim2.new(position.X.Scale, position.X.Offset + (nx - cx),
		position.Y.Scale, position.Y.Offset + (ny - cy))
end

local function clampBallPosition(position, diameter)
	local viewport = getViewport()
	local r = diameter / 2 + 4
	local cx = position.X.Scale * viewport.X + position.X.Offset
	local cy = position.Y.Scale * viewport.Y + position.Y.Offset
	return UDim2.fromOffset(
		math.clamp(cx, r, math.max(viewport.X - r, r)),
		math.clamp(cy, r, math.max(viewport.Y - r, r))
	)
end

local function makeDraggable(handle, target, connections, options)
	options = options or {}
	local dragging, moved, activeInput = false, false, nil
	local startPointer = Vector2.zero
	local lastPointer = Vector2.zero
	local startPosition = target.Position
	local didMoveThreshold = options.Threshold or (isMobile() and 7 or 5)
	local moveConn, endConn

	-- InputChanged/InputEnded globais so existem durante o gesto.
	local function release()
		if moveConn then moveConn:Disconnect(); moveConn = nil end
		if endConn then endConn:Disconnect(); endConn = nil end
		dragging = false; activeInput = nil
	end

	local function onMove(input)
		if not dragging then return end
		local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
			or (input.UserInputType == Enum.UserInputType.Touch and input == activeInput)
		if not isMove then return end
		local currentPos = Vector2.new(input.Position.X, input.Position.Y)
		local newPosition
		if not moved then
			local delta = currentPos - startPointer
			if delta.Magnitude < didMoveThreshold then return end
			moved = true
			lastPointer = currentPos
			newPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		else
			local step = currentPos - lastPointer
			lastPointer = currentPos
			local cur = target.Position
			newPosition = UDim2.new(cur.X.Scale, cur.X.Offset + step.X,
				cur.Y.Scale, cur.Y.Offset + step.Y)
		end
		if options.Clamp then newPosition = options.Clamp(newPosition) end
		target.Position = newPosition
	end

	local function onEnd(input)
		if not dragging or not activeInput then return end
		local same = input == activeInput
			or (input.UserInputType == Enum.UserInputType.MouseButton1
				and activeInput.UserInputType == Enum.UserInputType.MouseButton1)
			or (input.UserInputType == Enum.UserInputType.Touch
				and activeInput.UserInputState == Enum.UserInputState.End)
		if not same then return end
		local wasMoved = moved
		release()
		if wasMoved then
			if options.OnDragEnd then options.OnDragEnd() end
		elseif options.OnClick then options.OnClick() end
	end

	table.insert(connections, handle.InputBegan:Connect(function(input)
		if not isPointer(input) then return end
		if dragging then
			-- gesto anterior perdido (elemento ocultado no meio do toque): libera
			if activeInput and activeInput.UserInputState ~= Enum.UserInputState.End then return end
			release()
		end
		dragging = true; moved = false; activeInput = input
		startPointer = Vector2.new(input.Position.X, input.Position.Y)
		lastPointer = startPointer
		startPosition = target.Position
		moveConn = UserInputService.InputChanged:Connect(onMove)
		endConn = UserInputService.InputEnded:Connect(onEnd)
	end))
	table.insert(connections, { Disconnect = release })
end

-- Icones (inalterado)
local ICON_STROKE = 1.7
local function shapeLine(x1, y1, x2, y2) return { "l", x1, y1, x2, y2 } end
local function shapeBox(x, y, w, h, c) return { "b", x, y, w, h, c or 0 } end
local function shapeDot(cx, cy, d) return { "d", cx, cy, d } end
local function shapePoly(points, closed)
	local shapes = {}
	for i = 1, #points - 1 do
		table.insert(shapes, shapeLine(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2]))
	end
	if closed and #points > 2 then
		table.insert(shapes, shapeLine(points[#points][1], points[#points][2], points[1][1], points[1][2]))
	end
	return shapes
end
local function mergeShapes(...)
	local result = {}
	for _, list in ipairs({ ... }) do
		for _, shape in ipairs(list) do table.insert(result, shape) end
	end
	return result
end
local function buildStar()
	local points = {}
	for i = 0, 9 do
		local radius = (i % 2 == 0) and 6.8 or 3
		local angle = -math.pi / 2 + i * math.pi / 5
		table.insert(points, { 8 + radius * math.cos(angle), 8.4 + radius * math.sin(angle) })
	end
	return shapePoly(points, true)
end

local function buildStarFilled()
	local shapes = {}
	for _, k in ipairs({ 1, 0.8, 0.6, 0.4, 0.2 }) do
		local points = {}
		for i = 0, 9 do
			local radius = ((i % 2 == 0) and 6.8 or 3) * k
			local angle = -math.pi / 2 + i * math.pi / 5
			table.insert(points, { 8 + radius * math.cos(angle), 8.4 + radius * math.sin(angle) })
		end
		for _, shape in ipairs(shapePoly(points, true)) do table.insert(shapes, shape) end
	end
	return shapes
end

local IconShapes = {
	home = mergeShapes({
		shapeLine(2, 8, 8, 2.5), shapeLine(8, 2.5, 14, 8),
		shapeLine(3.8, 7, 3.8, 13.5), shapeLine(12.2, 7, 12.2, 13.5),
		shapeLine(3.8, 13.5, 12.2, 13.5), shapeLine(6.5, 13.5, 6.5, 10),
		shapeLine(9.5, 13.5, 9.5, 10), shapeLine(6.5, 10, 9.5, 10),
	}),
	settings = {
		shapeLine(2, 4, 14, 4), shapeLine(2, 8, 14, 8), shapeLine(2, 12, 14, 12),
		shapeDot(10, 4, 3.8), shapeDot(5.5, 8, 3.8), shapeDot(10.5, 12, 3.8),
	},
	user = { shapeBox(5.2, 2, 5.6, 5.6, 2.8), shapeBox(3, 9.5, 10, 5, 2.5) },
	eye = { shapeBox(1, 4.2, 14, 7.6, 3.8), shapeDot(8, 8, 3.6) },
	bolt = shapePoly({ { 9.5, 1.5 }, { 3.5, 9 }, { 8, 9 }, { 6.5, 14.5 }, { 12.5, 7 }, { 8, 7 } }, true),
	shield = shapePoly({ { 8, 1.8 }, { 13, 3.5 }, { 13, 8 }, { 8, 14.2 }, { 3, 8 }, { 3, 3.5 } }, true),
	sword = {
		shapeLine(13, 3, 6.5, 9.5), shapeLine(4.5, 6.5, 9.5, 11.5),
		shapeLine(6.5, 9.5, 3.2, 12.8), shapeDot(2.8, 13.2, 2.4),
	},
	grid = {
		shapeBox(2, 2, 5, 5, 1.2), shapeBox(9, 2, 5, 5, 1.2),
		shapeBox(2, 9, 5, 5, 1.2), shapeBox(9, 9, 5, 5, 1.2),
	},
	bell = {
		shapeBox(3.5, 2.5, 9, 8.5, 4.5), shapeLine(2.5, 12, 13.5, 12), shapeDot(8, 14.2, 2.4),
	},
	info = { shapeBox(1.5, 1.5, 13, 13, 6.5), shapeDot(8, 4.8, 1.9), shapeLine(8, 7.2, 8, 11.6) },
	check = { shapeLine(3, 8.5, 6.5, 12), shapeLine(6.5, 12, 13, 4.5) },
	close = { shapeLine(3.5, 3.5, 12.5, 12.5), shapeLine(12.5, 3.5, 3.5, 12.5) },
	minus = { shapeLine(3, 8, 13, 8) },
	menu = { shapeLine(2.5, 4, 13.5, 4), shapeLine(2.5, 8, 13.5, 8), shapeLine(2.5, 12, 13.5, 12) },
	warning = mergeShapes(
		shapePoly({ { 8, 2 }, { 14.5, 13.5 }, { 1.5, 13.5 } }, true),
		{ shapeLine(8, 6.2, 8, 9.6), shapeDot(8, 11.7, 1.7) }
	),
	star = buildStar(),
	star_fill = buildStarFilled(),
	gauge = { shapeBox(2, 2, 12, 12, 6), shapeLine(8, 8, 11, 5), shapeDot(8, 8, 2.6) },
	palette = {
		shapeBox(2, 2, 12, 12, 6), shapeDot(5.5, 6.2, 2.2), shapeDot(8.5, 4.8, 2.2),
		shapeDot(11, 7.4, 2.2), shapeDot(6.2, 10.2, 2.2),
	},
	target = { shapeBox(2, 2, 12, 12, 6), shapeBox(5, 5, 6, 6, 3), shapeDot(8, 8, 1.8) },
	list = {
		shapeDot(3, 4, 2), shapeLine(6, 4, 14, 4),
		shapeDot(3, 8, 2), shapeLine(6, 8, 14, 8),
		shapeDot(3, 12, 2), shapeLine(6, 12, 14, 12),
	},
	maximize = { shapeBox(3, 3, 10, 10, 2) },
	search = { shapeBox(1.8, 1.8, 9, 9, 4.5), shapeLine(9.4, 9.4, 14, 14) },
	dropdown = { shapeLine(3, 6, 8, 11), shapeLine(8, 11, 13, 6) },
	confirm = {
		shapeBox(1.5, 1.5, 13, 13, 6.5),
		shapeLine(4.5, 8.5, 7, 11), shapeLine(7, 11, 11.5, 5.5),
	},
}

IconShapes["chevron-right"] = { shapeLine(6, 3, 11, 8), shapeLine(11, 8, 6, 13) }
IconShapes["chevron-left"] = { shapeLine(10, 3, 5, 8), shapeLine(5, 8, 10, 13) }
IconShapes["chevron-down"] = { shapeLine(3, 6, 8, 11), shapeLine(8, 11, 13, 6) }
IconShapes["chevron-up"] = { shapeLine(3, 10, 8, 5), shapeLine(8, 5, 13, 10) }

-- Biblioteca expandida de icones vetoriais (v2.7.0)
IconShapes["arrow-right"] = { shapeLine(2.5, 8, 13, 8), shapeLine(9, 4, 13.5, 8), shapeLine(13.5, 8, 9, 12) }
IconShapes["arrow-left"] = { shapeLine(13.5, 8, 3, 8), shapeLine(7, 4, 2.5, 8), shapeLine(2.5, 8, 7, 12) }
IconShapes["arrow-up"] = { shapeLine(8, 13.5, 8, 3), shapeLine(4, 7, 8, 2.5), shapeLine(8, 2.5, 12, 7) }
IconShapes["arrow-down"] = { shapeLine(8, 2.5, 8, 13), shapeLine(4, 9, 8, 13.5), shapeLine(8, 13.5, 12, 9) }
IconShapes.plus = { shapeLine(8, 3, 8, 13), shapeLine(3, 8, 13, 8) }
IconShapes.circle = { shapeBox(2, 2, 12, 12, 6) }
IconShapes.dot = { shapeDot(8, 8, 6) }
IconShapes.radio = { shapeBox(2, 2, 12, 12, 6), shapeDot(8, 8, 5) }
IconShapes.save = {
	shapeBox(2, 2, 12, 12, 2), shapeBox(4.5, 2, 6, 4.5, 0.8), shapeBox(4, 9, 8, 5, 1),
}
IconShapes.folder = {
	shapeBox(1.8, 3.5, 12.4, 10, 1.8), shapeLine(2.2, 3.5, 6.8, 3.5), shapeLine(6.8, 3.5, 8, 5.2),
}
IconShapes.file = {
	shapeBox(3, 1.8, 10, 12.4, 1.6), shapeLine(5.5, 6, 10.5, 6), shapeLine(5.5, 9, 10.5, 9), shapeLine(5.5, 12, 8.5, 12),
}
IconShapes.download = {
	shapeLine(8, 2, 8, 10.5), shapeLine(4.8, 7.5, 8, 10.8), shapeLine(8, 10.8, 11.2, 7.5),
	shapeLine(2.5, 13.5, 13.5, 13.5),
}
IconShapes.upload = {
	shapeLine(8, 10.8, 8, 2.5), shapeLine(4.8, 5.8, 8, 2.5), shapeLine(8, 2.5, 11.2, 5.8),
	shapeLine(2.5, 13.5, 13.5, 13.5),
}
IconShapes.trash = {
	shapeLine(2.5, 4, 13.5, 4), shapeLine(6, 2.2, 10, 2.2),
	shapeBox(3.8, 4, 8.4, 10, 1.4), shapeLine(6.5, 6.5, 6.5, 11.5), shapeLine(9.5, 6.5, 9.5, 11.5),
}
IconShapes.edit = {
	shapeLine(3, 13, 11.5, 4.5), shapeLine(9.8, 2.8, 13.2, 6.2), shapeLine(2.5, 13.5, 5.2, 13.5),
}
IconShapes.copy = { shapeBox(5.5, 5.5, 8.5, 8.5, 1.8), shapeBox(2, 2, 8.5, 8.5, 1.8) }
IconShapes.refresh = {
	shapeBox(2.5, 2.5, 11, 11, 5.5), shapeLine(11, 2.5, 13.5, 5), shapeLine(13.5, 2.5, 13.5, 5.5),
}
IconShapes.play = shapePoly({ { 4.5, 2.5 }, { 13, 8 }, { 4.5, 13.5 } }, true)
IconShapes.pause = { shapeLine(5.5, 3, 5.5, 13), shapeLine(10.5, 3, 10.5, 13) }
IconShapes.stop = { shapeBox(3, 3, 10, 10, 1.6) }
IconShapes.lock = { shapeBox(3, 7, 10, 7, 1.8), shapeBox(5, 2.2, 6, 5, 3), shapeDot(8, 10.5, 2) }
IconShapes.unlock = { shapeBox(3, 7, 10, 7, 1.8), shapeLine(5, 7, 5, 4), shapeLine(5, 4, 8, 2.5), shapeDot(8, 10.5, 2) }
IconShapes.key = { shapeBox(2, 5, 6, 6, 3), shapeLine(8, 8, 14, 8), shapeLine(11.5, 8, 11.5, 11), shapeLine(14, 8, 14, 11) }
IconShapes.globe = {
	shapeBox(2, 2, 12, 12, 6), shapeLine(2, 8, 14, 8), shapeLine(8, 2, 8, 14),
}
IconShapes.compass = {
	shapeBox(2, 2, 12, 12, 6), shapePoly({ { 10.5, 5.5 }, { 9, 9 }, { 5.5, 10.5 }, { 7, 7 } }, true),
}
IconShapes.map = shapePoly({ { 2, 3.5 }, { 6, 2 }, { 10, 4 }, { 14, 2.5 }, { 14, 12.5 }, { 10, 14 }, { 6, 12 }, { 2, 13.5 } }, true)
IconShapes.pin = { shapeBox(4, 2, 8, 8, 4), shapeDot(8, 6, 2.4), shapeLine(8, 10, 8, 14.5) }
IconShapes.crosshair = {
	shapeBox(2.5, 2.5, 11, 11, 5.5),
	shapeLine(8, 1, 8, 4.5), shapeLine(8, 11.5, 8, 15),
	shapeLine(1, 8, 4.5, 8), shapeLine(11.5, 8, 15, 8),
	shapeDot(8, 8, 2),
}
IconShapes.flame = shapePoly({ { 8, 1.8 }, { 12.5, 7 }, { 11.5, 12.2 }, { 8, 14.2 }, { 4.5, 12.2 }, { 3.5, 7 } }, true)
IconShapes.sparkles = {
	shapeLine(8, 2, 8, 10), shapeLine(4, 6, 12, 6),
	shapeLine(12.5, 10, 12.5, 14), shapeLine(10.5, 12, 14.5, 12),
	shapeDot(3.5, 12, 2),
}
IconShapes.crown = shapePoly({ { 2, 12 }, { 2, 5 }, { 5.5, 8.5 }, { 8, 3.5 }, { 10.5, 8.5 }, { 14, 5 }, { 14, 12 } }, true)
IconShapes.gem = shapePoly({ { 5, 2.5 }, { 11, 2.5 }, { 14, 6.5 }, { 8, 14 }, { 2, 6.5 } }, true)
IconShapes.trophy = {
	shapeBox(4, 2.5, 8, 6.5, 2), shapeLine(8, 9, 8, 13), shapeLine(5, 13.5, 11, 13.5),
	shapeLine(2.2, 4, 4, 4), shapeLine(12, 4, 13.8, 4),
}
IconShapes.heart = shapePoly({ { 8, 13.8 }, { 2.4, 8 }, { 2.4, 4.8 }, { 5.2, 3 }, { 8, 5.5 }, { 10.8, 3 }, { 13.6, 4.8 }, { 13.6, 8 } }, true)
IconShapes.moon = shapePoly({ { 11.5, 2.5 }, { 7.5, 4.5 }, { 7, 8 }, { 8.5, 11.5 }, { 12.5, 13 }, { 7, 14 }, { 3.5, 10.5 }, { 3.5, 5.5 }, { 7, 2.2 } }, true)
IconShapes.sun = {
	shapeBox(4.8, 4.8, 6.4, 6.4, 3.2),
	shapeLine(8, 1.5, 8, 3.2), shapeLine(8, 12.8, 8, 14.5),
	shapeLine(1.5, 8, 3.2, 8), shapeLine(12.8, 8, 14.5, 8),
	shapeLine(3.4, 3.4, 4.6, 4.6), shapeLine(11.4, 11.4, 12.6, 12.6),
}
IconShapes.cloud = { shapeBox(2, 6, 12, 7.5, 3.7), shapeBox(5, 3.2, 6.5, 5.5, 2.7) }
IconShapes.wifi = {
	shapeDot(8, 12.8, 2.4), shapeLine(5.5, 10, 10.5, 10),
	shapeLine(3.5, 7, 12.5, 7), shapeLine(1.8, 4, 14.2, 4),
}
IconShapes.cpu = {
	shapeBox(4, 4, 8, 8, 1.6), shapeBox(6.4, 6.4, 3.2, 3.2, 0.8),
	shapeLine(6, 1.8, 6, 4), shapeLine(10, 1.8, 10, 4),
	shapeLine(6, 12, 6, 14.2), shapeLine(10, 12, 10, 14.2),
	shapeLine(1.8, 6, 4, 6), shapeLine(12, 6, 14.2, 6),
}
IconShapes.terminal = {
	shapeBox(1.8, 2.5, 12.4, 11, 2),
	shapeLine(4.5, 6, 7.5, 8), shapeLine(7.5, 8, 4.5, 10), shapeLine(8.5, 10.5, 11.5, 10.5),
}
IconShapes.code = {
	shapeLine(5.5, 4.5, 2, 8), shapeLine(2, 8, 5.5, 11.5),
	shapeLine(10.5, 4.5, 14, 8), shapeLine(14, 8, 10.5, 11.5),
	shapeLine(9, 3, 7, 13),
}
IconShapes.layers = {
	shapeLine(8, 2.2, 14, 5.5), shapeLine(14, 5.5, 8, 8.8), shapeLine(8, 8.8, 2, 5.5), shapeLine(2, 5.5, 8, 2.2),
	shapeLine(2.5, 8.8, 8, 11.8), shapeLine(8, 11.8, 13.5, 8.8),
	shapeLine(2.5, 11.5, 8, 14.2), shapeLine(8, 14.2, 13.5, 11.5),
}
IconShapes.sliders = IconShapes.settings
IconShapes.filter = shapePoly({ { 2, 3 }, { 14, 3 }, { 9.5, 8.5 }, { 9.5, 13.5 }, { 6.5, 12 }, { 6.5, 8.5 } }, true)
IconShapes.bookmark = shapePoly({ { 4, 2 }, { 12, 2 }, { 12, 14 }, { 8, 10.8 }, { 4, 14 } }, true)
IconShapes.tag = mergeShapes(
	shapePoly({ { 2, 8 }, { 2, 2 }, { 8, 2 }, { 14, 8 }, { 8, 14 } }, true),
	{ shapeDot(5.4, 5.4, 2) }
)
IconShapes.clock = { shapeBox(2, 2, 12, 12, 6), shapeLine(8, 4.5, 8, 8), shapeLine(8, 8, 11, 9.8) }
IconShapes.calendar = {
	shapeBox(2, 3.2, 12, 10.8, 1.8), shapeLine(2, 6.8, 14, 6.8),
	shapeLine(5.5, 1.8, 5.5, 4), shapeLine(10.5, 1.8, 10.5, 4),
}
IconShapes.camera = { shapeBox(1.8, 4.2, 12.4, 9.2, 2), shapeBox(5.5, 6.2, 5, 5, 2.5), shapeLine(5.5, 2.6, 10.5, 2.6) }
IconShapes.image = {
	shapeBox(2, 2.5, 12, 11, 2), shapeDot(5.4, 5.6, 2.2),
	shapeLine(3, 12, 7.5, 8), shapeLine(7.5, 8, 10, 10.2), shapeLine(10, 10.2, 13, 7),
}
IconShapes.music = { shapeLine(6, 11.5, 6, 3.2), shapeLine(6, 3.2, 13, 2.2), shapeLine(13, 2.2, 13, 10.5), shapeDot(4.5, 12, 3.2), shapeDot(11.5, 11, 3.2) }
IconShapes.volume = {
	shapePoly({ { 2.5, 6 }, { 5.5, 6 }, { 9, 3 }, { 9, 13 }, { 5.5, 10 }, { 2.5, 10 } }, true),
	shapeLine(11.5, 5.8, 12.8, 8), shapeLine(12.8, 8, 11.5, 10.2),
}
IconShapes.mic = { shapeBox(5.5, 2, 5, 8, 2.5), shapeLine(4, 9.5, 12, 9.5), shapeLine(8, 11.5, 8, 14.2), shapeLine(5.5, 14.2, 10.5, 14.2) }
IconShapes.message = { shapeBox(2, 2.5, 12, 9, 2.2), shapeLine(4.5, 11.5, 4, 14.2), shapeLine(4, 14.2, 7.5, 11.5) }
IconShapes.send = shapePoly({ { 2, 8 }, { 14, 2.5 }, { 10.5, 14 }, { 7.8, 9.5 } }, true)
IconShapes.link = { shapeBox(2, 5, 7, 5, 2.5), shapeBox(7, 6, 7, 5, 2.5) }
IconShapes.external = {
	shapeBox(2.5, 4.5, 9, 9, 1.8), shapeLine(8, 8, 13.5, 2.5), shapeLine(9.5, 2.5, 13.5, 2.5), shapeLine(13.5, 2.5, 13.5, 6.5),
}
IconShapes.power = { shapeBox(2.8, 3.5, 10.4, 10.4, 5.2), shapeLine(8, 1.8, 8, 7.5) }
IconShapes.rocket = {
	shapePoly({ { 8, 1.8 }, { 11.5, 6 }, { 11.5, 11 }, { 4.5, 11 }, { 4.5, 6 } }, true),
	shapeDot(8, 6.8, 2.2), shapeLine(6, 13.8, 6, 11.5), shapeLine(10, 13.8, 10, 11.5),
}
IconShapes.car = {
	shapeBox(2, 6.5, 12, 5.5, 1.8), shapeLine(3.8, 6.5, 5.2, 3.5), shapeLine(5.2, 3.5, 10.8, 3.5), shapeLine(10.8, 3.5, 12.2, 6.5),
	shapeDot(4.8, 12.2, 2.8), shapeDot(11.2, 12.2, 2.8),
}
IconShapes.skull = {
	shapeBox(3, 2, 10, 8.5, 4.2), shapeBox(5.2, 10.2, 5.6, 3.8, 1.2),
	shapeDot(6, 6.2, 2.2), shapeDot(10, 6.2, 2.2),
}
IconShapes.bug = {
	shapeBox(4.5, 4.5, 7, 9, 3.5), shapeLine(2, 6.5, 4.5, 7.2), shapeLine(14, 6.5, 11.5, 7.2),
	shapeLine(2, 11, 4.5, 10.2), shapeLine(14, 11, 11.5, 10.2), shapeLine(6, 2.2, 7, 4.5), shapeLine(10, 2.2, 9, 4.5),
}
IconShapes.wrench = { shapeLine(3.5, 12.5, 10.5, 5.5), shapeBox(9.2, 2, 4.8, 4.8, 2.4), shapeDot(3.2, 12.8, 2.6) }
IconShapes.coins = { shapeBox(2.5, 4, 8, 8, 4), shapeBox(5.5, 6, 8, 8, 4) }
IconShapes.package = {
	shapeBox(2.2, 3.2, 11.6, 10, 1.8), shapeLine(2.2, 6.8, 13.8, 6.8), shapeLine(8, 3.2, 8, 6.8),
}
IconShapes["eye-off"] = mergeShapes(IconShapes.eye, { shapeLine(2.5, 2.5, 13.5, 13.5) })

-- Aliases praticos
IconShapes.activity = {
	shapeLine(1.5, 8.5, 4.5, 8.5), shapeLine(4.5, 8.5, 6.5, 3.5),
	shapeLine(6.5, 3.5, 9.5, 12.5), shapeLine(9.5, 12.5, 11.5, 8.5), shapeLine(11.5, 8.5, 14.5, 8.5),
}
IconShapes.monitor = {
	shapeBox(1.8, 2.5, 12.4, 8.5, 1.5), shapeLine(8, 11, 8, 13.8), shapeLine(5, 13.8, 11, 13.8),
}
IconShapes.minimize = { shapeBox(3, 3, 10, 10, 2), shapeLine(5.5, 8, 10.5, 8) }
IconShapes.chart = IconShapes.activity
IconShapes.eyeoff = IconShapes["eye-off"]
IconShapes.cog = IconShapes.settings
IconShapes.gear = IconShapes.settings
IconShapes.config = IconShapes.settings
IconShapes.flash = IconShapes.bolt
IconShapes.lightning = IconShapes.bolt
IconShapes.alert = IconShapes.warning
IconShapes.delete = IconShapes.trash
IconShapes.reload = IconShapes.refresh
IconShapes.sync = IconShapes.refresh
IconShapes.aim = IconShapes.crosshair
IconShapes.floppy = IconShapes.save
IconShapes.disk = IconShapes.save
IconShapes.hub = IconShapes.layers
IconShapes.player = IconShapes.user
IconShapes.profile = IconShapes.user
IconShapes.x = IconShapes.close

local CustomIcons = {}
AetherUI.Icons = IconShapes

local TabIconHints = {
	{ "home", { "principal", "main", "home", "inicio", "geral", "general" } },
	{ "settings", { "config", "setting", "ajuste", "opcoes", "options", "preferenc" } },
	{ "sword", { "combat", "combate", "aim", "attack", "ataque", "pvp", "fight" } },
	{ "eye", { "visual", "esp", "view", "render" } },
	{ "user", { "player", "jogador", "user", "perfil", "profile", "conta", "account" } },
	{ "target", { "teleport", "alvo", "target", "mapa", "map" } },
	{ "bolt", { "farm", "auto", "speed", "velocidade", "exploit", "script" } },
	{ "shield", { "prote", "defes", "segur", "secur", "anti" } },
	{ "bell", { "notif", "aviso", "alert" } },
	{ "info", { "info", "sobre", "about", "credit", "ajuda", "help" } },
	{ "palette", { "tema", "theme", "color", "aparenc" } },
	{ "save", { "save", "salvar", "preset", "arquivo", "file" } },
	{ "sparkles", { "extra", "misc", "fun", "efeito", "effect" } },
}

local function guessIcon(name)
	local lower = string.lower(tostring(name))
	for _, entry in ipairs(TabIconHints) do
		for _, hint in ipairs(entry[2]) do
			if string.find(lower, hint, 1, true) then return entry[1] end
		end
	end
	return "grid"
end

local function createVectorIcon(shapes, parent, size, color)
	local container = create("Frame", {
		Name = "Icon", BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size), Parent = parent,
	})
	local parts, strokes = {}, {}
	for _, shape in ipairs(shapes) do
		local kind = shape[1]
		if kind == "l" then
			local x1, y1, x2, y2 = shape[2], shape[3], shape[4], shape[5]
			local dx, dy = x2 - x1, y2 - y1
			local length = math.sqrt(dx * dx + dy * dy) + ICON_STROKE * 0.7
			local part = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale((x1 + x2) / 32, (y1 + y2) / 32),
				Size = UDim2.fromScale(length / 16, ICON_STROKE / 16),
				Rotation = math.deg(math.atan2(dy, dx)),
				BackgroundColor3 = color, Parent = container,
			})
			addCornerScale(part, 0.5)
			table.insert(parts, part)
		elseif kind == "b" then
			local x, y, w, h, c = shape[2], shape[3], shape[4], shape[5], shape[6]
			local part = create("Frame", {
				Position = UDim2.fromScale(x / 16, y / 16),
				Size = UDim2.fromScale(w / 16, h / 16),
				BackgroundTransparency = 1, Parent = container,
			})
			if c > 0 then addCornerScale(part, math.min(0.5, c / math.min(w, h))) end
			local stroke = create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = color, Thickness = math.max(1, ICON_STROKE / 16 * size), Parent = part,
			})
			table.insert(strokes, stroke)
		elseif kind == "d" then
			local cx, cy, d = shape[2], shape[3], shape[4]
			local part = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(cx / 16, cy / 16),
				Size = UDim2.fromScale(d / 16, d / 16),
				BackgroundColor3 = color, Parent = container,
			})
			addCornerScale(part, 0.5)
			table.insert(parts, part)
		end
	end
	local icon = { Instance = container, Kind = "Vector" }
	function icon:SetColor(newColor)
		for _, part in ipairs(parts) do part.BackgroundColor3 = newColor end
		for _, stroke in ipairs(strokes) do stroke.Color = newColor end
	end
	function icon:Tween(newColor, duration)
		for _, part in ipairs(parts) do tween(part, duration or Anim.Fast, { BackgroundColor3 = newColor }) end
		for _, stroke in ipairs(strokes) do tween(stroke, duration or Anim.Fast, { Color = newColor }) end
	end
	function icon:SetSize(px)
		container.Size = UDim2.fromOffset(px, px)
		for _, stroke in ipairs(strokes) do stroke.Thickness = math.max(1, ICON_STROKE / 16 * px) end
	end
	return icon
end

local function normalizeAssetString(value)
	if typeof(value) == "number" then
		return "rbxassetid://" .. tostring(math.floor(value))
	end
	if typeof(value) == "string" then
		if tonumber(value) then return "rbxassetid://" .. value end
		return value
	end
	return nil
end

local function createIcon(spec, parent, size, color, opts)
	if spec == nil or spec == "" or spec == false then return nil end

	local customSize = opts and typeof(opts.Size) == "number" and opts.Size or nil
	local customColor = opts and typeof(opts.Color) == "Color3" and opts.Color or nil
	local customTransp = opts and tonumber(opts.Transparency) or nil
	local customScaleType = opts and opts.ScaleType or nil
	local customCorner = opts and tonumber(opts.CornerRadius) or nil

	if typeof(spec) == "table" then
		if typeof(spec.Size) == "number" then customSize = spec.Size end
		if typeof(spec.Color) == "Color3" then customColor = spec.Color end
		if spec.Transparency ~= nil then customTransp = tonumber(spec.Transparency) end
		if spec.ScaleType ~= nil then customScaleType = spec.ScaleType end
		if spec.CornerRadius ~= nil then customCorner = tonumber(spec.CornerRadius) end
		local inner = spec.Name or spec.Icon or spec.Image or spec.Asset
		if inner == nil or inner == "" or inner == false then return nil end
		spec = inner
	end

	local finalSize = customSize or size or 16
	local finalColor = customColor or color or Theme.SubText

	if typeof(spec) == "number" then spec = "rbxassetid://" .. tostring(math.floor(spec)) end
	if typeof(spec) ~= "string" then return nil end
	if tonumber(spec) then spec = "rbxassetid://" .. spec end

	local key = string.lower(spec)
	local registered = CustomIcons[key]
	if registered ~= nil then
		if typeof(registered) == "table" and registered.Name == nil and registered.Image == nil and registered.Icon == nil and typeof(registered[1]) == "table" then
			local icon = createVectorIcon(registered, parent, finalSize, finalColor)
			icon.CustomSize = customSize
			icon.CustomColor = customColor ~= nil
			return icon
		end
		return createIcon(registered, parent, finalSize, finalColor, {
			Size = customSize, Color = customColor, Transparency = customTransp,
			ScaleType = customScaleType, CornerRadius = customCorner,
		})
	end

	local shapes = IconShapes[key]
	if shapes then
		local icon = createVectorIcon(shapes, parent, finalSize, finalColor)
		icon.CustomSize = customSize
		icon.CustomColor = customColor ~= nil
		return icon
	end

	if string.find(spec, "rbxasset", 1, true) or string.find(spec, "http", 1, true) then
		local image = create("ImageLabel", {
			Name = "Icon", BackgroundTransparency = 1,
			Size = UDim2.fromOffset(finalSize, finalSize),
			Image = spec, ImageColor3 = customColor or color or Theme.White,
			ImageTransparency = customTransp or 0,
			ScaleType = customScaleType or Enum.ScaleType.Fit,
			Parent = parent,
		})
		if customCorner and customCorner > 0 then
			if customCorner <= 1 then addCornerScale(image, customCorner) else addCorner(image, customCorner) end
		end
		local hasTint = customColor ~= nil or (color ~= nil and color ~= Theme.White)
		local icon = {
			Instance = image, Kind = "Image",
			CustomSize = customSize, CustomColor = customColor ~= nil,
		}
		function icon:SetColor(c)
			if typeof(c) == "Color3" then image.ImageColor3 = c end
		end
		function icon:Tween(c, d)
			if typeof(c) == "Color3" and hasTint then tween(image, d or Anim.Fast, { ImageColor3 = c }) end
		end
		function icon:SetSize(px) image.Size = UDim2.fromOffset(px, px) end
		function icon:SetImage(newAsset)
			local norm = normalizeAssetString(newAsset)
			if norm then image.Image = norm end
		end
		function icon:SetTransparency(alpha)
			image.ImageTransparency = tonumber(alpha) or 0
		end
		return icon
	end

	local glyph = create("TextLabel", {
		Name = "Icon", BackgroundTransparency = 1,
		Size = UDim2.fromOffset(finalSize, finalSize), Text = spec,
		Font = Theme.FontBold, TextSize = finalSize, TextColor3 = finalColor,
		TextTransparency = customTransp or 0, Parent = parent,
	})
	local icon = {
		Instance = glyph, Kind = "Glyph",
		CustomSize = customSize, CustomColor = customColor ~= nil,
	}
	function icon:SetColor(c) glyph.TextColor3 = c end
	function icon:Tween(c, d) tween(glyph, d or Anim.Fast, { TextColor3 = c }) end
	function icon:SetSize(px)
		glyph.Size = UDim2.fromOffset(px, px); glyph.TextSize = px
	end
	function icon:SetTransparency(alpha) glyph.TextTransparency = tonumber(alpha) or 0 end
	return icon
end

local function iconSizeOf(icon, fallback)
	if icon and icon.CustomSize then return icon.CustomSize end
	return fallback
end

function AetherUI.RegisterIcon(first, second, third)
	local name, spec = first, second
	if first == AetherUI then name, spec = second, third end
	if typeof(name) ~= "string" or name == "" then return false end
	local key = string.lower(name)
	if typeof(spec) == "number" then
		CustomIcons[key] = "rbxassetid://" .. tostring(math.floor(spec))
	else
		CustomIcons[key] = spec
	end
	return true
end

function AetherUI.CreateIcon(first, second, third, fourth, fifth)
	local spec, parent, size, color = first, second, third, fourth
	if first == AetherUI then spec, parent, size, color = second, third, fourth, fifth end
	return createIcon(spec, parent, size or 16, color or Theme.SubText)
end

function AetherUI.GetIcons()
	local seen, names = {}, {}
	for k in pairs(IconShapes) do
		if not seen[k] then seen[k] = true; table.insert(names, k) end
	end
	for k in pairs(CustomIcons) do
		if not seen[k] then seen[k] = true; table.insert(names, k) end
	end
	table.sort(names)
	return names
end

-- "Pop" suave quando o texto de um rotulo de valor muda (slider/dropdown).
local function attachValuePop(label, strength, throttle)
	local scale = create("UIScale", { Parent = label })
	local last = 0
	label:GetPropertyChangedSignal("Text"):Connect(function()
		if State.LowPerformance then return end
		local now = os.clock()
		if now - last < (throttle or 0) then return end
		last = now
		scale.Scale = strength or 1.1
		tween(scale, Anim.Normal, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
end

----------------------------------------------------------------
-- Notificacoes (DisplayOrder 990 -> sempre abaixo da UI Library)
----------------------------------------------------------------
-- (Notifications inicializada acima junto ao PerfMonitor)

local NotifyTypes = {
	info = { Icon = "info", Color = nil },
	success = { Icon = "check", Color = Theme.Success },
	warning = { Icon = "warning", Color = Theme.Warning },
	error = { Icon = "close", Color = Theme.Danger },
}

local function notifyMetrics()
	local mobile = isMobile()
	local viewport = getViewport()
	local width = mobile and math.clamp(math.floor(viewport.X * 0.46), 210, 270) or 300
	width = math.min(width, math.max(math.floor(viewport.X) - 24, 160))
	return mobile, width
end

local function ensureNotifyHost()
	local gui = Notifications.Gui
	if gui and gui.Parent then return end
	gui = create("ScreenGui", {
		Name = "AetherUI_Notifications",
		ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = 990,  -- v2.3.0: abaixo da janela (1000)
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = resolveParent(),
	})
	local holder = create("Frame", { Name = "Holder", BackgroundTransparency = 1, Parent = gui })
	local layout = create("UIListLayout", {
		Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = holder,
	})
	Notifications.Gui = gui; Notifications.Holder = holder
	Notifications.Layout = layout; Notifications.Active = {}
end

local function layoutNotifyHost()
	local mobile, width = notifyMetrics()
	local holder, layout = Notifications.Holder, Notifications.Layout
	if mobile then
		holder.AnchorPoint = Vector2.new(1, 0)
		holder.Position = UDim2.new(1, -10, 0, 10)
		holder.Size = UDim2.new(0, width, 1, -20)
		layout.VerticalAlignment = Enum.VerticalAlignment.Top
	else
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Position = UDim2.new(1, -16, 1, -16)
		holder.Size = UDim2.new(0, width, 1, -32)
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	end
end

function AetherUI.Notify(first, second)
	local config = first
	if first == AetherUI then config = second end
	if typeof(config) == "string" then config = { Title = config } end
	if typeof(config) ~= "table" then config = {} end
	ensureNotifyHost(); layoutNotifyHost()

	local mobile, width = notifyMetrics()
	local textSize = mobile and 13 or 14
	local title = tostring(config.Title or "AetherUI")
	local content = ""
	if config.Content ~= nil then content = tostring(config.Content) end
	local duration = tonumber(config.Duration)
	if duration == nil then duration = 4 end
	local persistent = duration <= 0 or duration >= 1000000
	local kind = string.lower(tostring(config.Type or "info"))
	local style = NotifyTypes[kind] or NotifyTypes.info
	local color = State.Accent
	if typeof(config.Color) == "Color3" then color = config.Color
	elseif style.Color then color = style.Color end
	local iconSpec = config.Icon
	if iconSpec == nil then iconSpec = style.Icon end

	local iconColumn, rightMargin = 48, 28
	local textWidth = width - iconColumn - rightMargin
	local titleHeight = textSize + 4
	local contentHeight = 0
	if content ~= "" then
		local ok, bounds = pcall(function()
			return TextService:GetTextSize(content, textSize - 1, Theme.Font, Vector2.new(textWidth, 2000))
		end)
		if ok and bounds then contentHeight = math.ceil(bounds.Y)
		else contentHeight = textSize + 2 end
	end
	local height = 14 + titleHeight + (contentHeight > 0 and (contentHeight + 4) or 0) + 14
	height = math.max(height, 54)

	Notifications.Counter = Notifications.Counter + 1
	local animated = not State.LowPerformance
	local slot = create("Frame", {
		Name = "Notification", LayoutOrder = Notifications.Counter,
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, animated and 0 or height),
		Parent = Notifications.Holder,
	})
	local card = create("CanvasGroup", {
		Name = "Card", BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		Position = UDim2.fromOffset(animated and 28 or 0, 0),
		Size = UDim2.new(1, 0, 0, height),
		GroupTransparency = animated and 1 or 0, Parent = slot,
	})
	local cardScale = create("UIScale", { Scale = animated and 0.96 or 1, Parent = card })
	addCorner(card, Radius.Popup)
	addStroke(card, Theme.Stroke, 0, 1)
	attachShadow(card, slot, Radius.Popup, cardScale)

	if iconSpec ~= nil and iconSpec ~= "" and iconSpec ~= false then
		local badge = create("Frame", {
			Name = "Badge", Position = UDim2.fromOffset(12, 13),
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = Theme.Surface:Lerp(color, 0.14), Parent = card,
		})
		addCorner(badge, Radius.Control)
		addStroke(badge, Theme.Stroke:Lerp(color, 0.42), 0, 1)
		local icon = createIcon(iconSpec, badge, 14, color, { Size = config.IconSize, Color = config.IconColor })
		if icon then
			icon.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Instance.Position = UDim2.fromScale(0.5, 0.5)
		else badge:Destroy() end
	end

	create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(iconColumn, 12),
		Size = UDim2.new(1, -(iconColumn + rightMargin), 0, titleHeight),
		Text = title, Font = Theme.FontBold, TextSize = textSize,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	if contentHeight > 0 then
		create("TextLabel", {
			Name = "Content", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(iconColumn, 12 + titleHeight + 2),
			Size = UDim2.new(1, -(iconColumn + rightMargin), 0, contentHeight),
			Text = content, Font = Theme.Font, TextSize = textSize - 1,
			TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = card,
		})
	end

	local closeIcon = createIcon("close", card, 10, Theme.Muted)
	if closeIcon then
		closeIcon.Instance.AnchorPoint = Vector2.new(1, 0)
		closeIcon.Instance.Position = UDim2.new(1, -12, 0, 14)
	end

	local progress = nil
	if not persistent and not State.LowPerformance then
		progress = create("Frame", {
			Name = "Progress", AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = color, BackgroundTransparency = 0.2, Parent = card,
		})
	end

	local overlay = create("TextButton", {
		Name = "Overlay", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false,
		ZIndex = 5, Parent = card,
	})

	local dead = false
	local entry = {}
	local function dismiss()
		if dead then return end
		dead = true
		for index, other in ipairs(Notifications.Active) do
			if other == entry then table.remove(Notifications.Active, index); break end
		end
		if State.LowPerformance then
			slot:Destroy()
			return
		end
		local out = tween(card, Anim.Normal, {
			Position = UDim2.fromOffset(28, 0),
			GroupTransparency = 1,
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(cardScale, Anim.Normal, { Scale = 0.96 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		out.Completed:Connect(function()
			local shrink = tween(slot, Anim.Fast, { Size = UDim2.new(1, 0, 0, 0) })
			shrink.Completed:Connect(function() slot:Destroy() end)
		end)
	end
	entry.Dismiss = dismiss
	table.insert(Notifications.Active, entry)
	while #Notifications.Active > 5 do
		local oldest = Notifications.Active[1]
		oldest.Dismiss()
		if Notifications.Active[1] == oldest then table.remove(Notifications.Active, 1) end
	end
	overlay.Activated:Connect(function()
		safeCall(config.Callback); dismiss()
	end)
	if closeIcon then
		overlay.MouseEnter:Connect(function() closeIcon:Tween(Theme.Text, Anim.Fast) end)
		overlay.MouseLeave:Connect(function() closeIcon:Tween(Theme.Muted, Anim.Fast) end)
	end
	tween(slot, Anim.Normal, { Size = UDim2.new(1, 0, 0, height) })
	tween(card, Anim.Normal, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
	tween(cardScale, Anim.Normal, { Scale = 1 })
	if progress then
		tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	end
	if not persistent then task.delay(duration, dismiss) end
	return { Dismiss = dismiss, Instance = slot }
end

----------------------------------------------------------------
-- Componentes: Section e Label
----------------------------------------------------------------
function Tab:_nextOrder()
	self._order = self._order + 1
	return self._order
end

function Tab:_refresh()
	if self._updateCanvas then self._updateCanvas() end
end

-- Registra o componente no indice da busca global.
function Tab:_register(kind, instance, getName, extra)
	local entry = {
		Kind = kind, Instance = instance, GetName = getName, Tab = self,
		SectionEntry = (kind ~= "Section") and self._currentSection or nil,
		Order = instance.LayoutOrder,
	}
	if extra then
		for key, value in pairs(extra) do entry[key] = value end
	end
	table.insert(self._entries, entry)
	instance.Destroying:Connect(function()
		local index = table.find(self._entries, entry)
		if index then table.remove(self._entries, index) end
	end)
	return entry
end

-- Posicao Y (no canvas da pagina) de um filho, calculada pelo layout.
function Tab:_offsetOf(instance)
	local items = {}
	for _, child in ipairs(self._page:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then table.insert(items, child) end
	end
	table.sort(items, function(a, b)
		if a.LayoutOrder ~= b.LayoutOrder then return a.LayoutOrder < b.LayoutOrder end
		return a.Name < b.Name
	end)
	local y = self._metrics.Pad
	for _, child in ipairs(items) do
		if child == instance then return y end
		local height = child.Size.Y.Offset
		if child.Size.Y.Scale ~= 0 then height = child.AbsoluteSize.Y end
		y = y + height + self._metrics.Gap
	end
	return y
end

-- Rola a pagina so o necessario para o item (com altura final) ficar visivel.
function Tab:_scrollIntoView(instance, finalHeight)
	local page = self._page
	if not instance.Parent or page.AbsoluteSize.Y <= 0 then return end
	local scale = self._window._scale and self._window._scale.Scale or 1
	if scale <= 0 then scale = 1 end
	local top = self:_offsetOf(instance)
	local viewH = page.AbsoluteSize.Y / scale
	local current = page.CanvasPosition.Y
	local bottom = top + (finalHeight or instance.Size.Y.Offset)
	local target = current
	if bottom + 12 > current + viewH then target = bottom + 12 - viewH end
	if top - 6 < target then target = math.max(top - 6, 0) end
	if math.abs(target - current) < 1 then return end
	tween(page, Anim.Smooth, { CanvasPosition = Vector2.new(0, target) })
end

function Tab:AddSection(config)
	local text = config
	local iconSpec, iconSize, iconColor = nil, nil, nil
	if typeof(config) == "table" then
		text = config.Text or config.Name
		iconSpec = config.Icon
		iconSize = config.IconSize
		iconColor = config.IconColor
	end
	local win = self._window
	local m = self._metrics
	local holder = create("Frame", {
		Name = "Section", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = self._page,
	})
	local icon = createIcon(iconSpec, holder, m.Icon - 3, Theme.Muted, { Size = iconSize, Color = iconColor })
	if icon then
		icon.Instance.AnchorPoint = Vector2.new(0, 0.5)
		icon.Instance.Position = UDim2.new(0, 2, 0.5, 0)
	end
	local rawText = tostring(text or "Section")
	local label = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Text = string.upper(rawText),
		Font = Theme.FontBold, TextSize = math.max(10, m.Text - 3),
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
	})
	local hline = create("Frame", {
		Name = "Line", AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Divider, Size = UDim2.new(1, 0, 0, 1),
		Parent = holder,
	})
	local function layout()
		holder.Size = UDim2.new(1, 0, 0, m.Compact and 22 or 26)
		local ts = math.max(10, m.Text - 3)
		label.TextSize = ts
		local offsetX = 2
		if icon then
			local sz = iconSizeOf(icon, m.Icon - 3)
			icon:SetSize(sz)
			offsetX = 2 + sz + 7
		end
		label.Position = UDim2.fromOffset(offsetX, 0)
		label.Size = UDim2.new(1, -offsetX, 1, 0)
		local textW = 64
		local ok, bounds = pcall(function()
			return TextService:GetTextSize(label.Text, ts, Theme.FontBold, Vector2.new(1000, 32))
		end)
		if ok and bounds then textW = math.ceil(bounds.X) end
		local lineX = offsetX + textW + 10
		hline.Position = UDim2.new(0, lineX, 0.5, 0)
		hline.Size = UDim2.new(1, -lineX, 0, 1)
	end
	win:_onLayout(layout)
	local object = { Instance = holder }
	local entry = self:_register("Section", holder, function() return rawText end)
	self._currentSection = entry
	function object:SetText(newText)
		rawText = tostring(newText)
		label.Text = string.upper(rawText)
		layout()
	end
	function object:Set(newText) object:SetText(newText) end
	function object:Get() return rawText end
	return object
end

function Tab:AddLabel(config)
	if typeof(config) == "string" then config = { Text = config } end
	config = config or {}
	local win = self._window
	local m = self._metrics
	local label = create("TextLabel", {
		Name = "Label", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row - 4),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		Text = tostring(config.Text or config.Name or "Label"),
		Font = Theme.Font, TextSize = m.Text,
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = self._page,
	})
	addCorner(label, Radius.Card)
	local padding = addPadding(label, 12, 0, 12, 0)
	addStroke(label, Theme.StrokeSoft, 0, 1)
	local iconSpec = config.Icon
	if iconSpec == nil then iconSpec = "info" end
	local icon = createIcon(iconSpec, label, m.Icon - 2, Theme.Muted, { Size = config.IconSize, Color = config.IconColor })
	if icon then icon.Instance.AnchorPoint = Vector2.new(0, 0.5) end
	win:_onLayout(function()
		label.Size = UDim2.new(1, 0, 0, m.Row - 4)
		label.TextSize = m.Text
		local extra = 0
		if icon then
			local sz = iconSizeOf(icon, m.Icon - 2)
			icon:SetSize(sz)
			extra = sz + 8
			icon.Instance.Position = UDim2.new(0, -extra, 0.5, 0)
		end
		padding.PaddingLeft = UDim.new(0, 12 + extra)
	end)
	local object = { Instance = label }
	function object:SetText(newText) label.Text = tostring(newText) end
	function object:Set(newText) object:SetText(newText) end
	function object:Get() return label.Text end
	self:_register("Label", label, function() return label.Text end)
	return object
end
-- ============================================================
-- AetherUI v2.9.0 - Parte 2/3
-- Button, Toggle, Slider, Dropdown, MultiDropdown, ColorPicker
-- ============================================================

----------------------------------------------------------------
-- Button (Premium Dark: solido, limpo e preciso)
----------------------------------------------------------------
function Tab:AddButton(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local button = create("TextButton", {
		Name = "Button", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0, AutoButtonColor = false,
		Text = config.Name or "Button", Font = Theme.Font,
		TextSize = m.Text, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ClipsDescendants = true, Parent = self._page,
	})
	addCorner(button, Radius.Card)
	local stroke = addStroke(button, Theme.StrokeSoft, 0, 1)
	local scale = create("UIScale", { Parent = button })
	local padding = addPadding(button, 14, 0, 14, 0)
	local lead = createIcon(config.Icon, button, m.Icon, Theme.SubText, { Size = config.IconSize, Color = config.IconColor })
	if lead then lead.Instance.AnchorPoint = Vector2.new(0, 0.5) end
	local chevron = createIcon("chevron-right", button, m.Icon - 2, Theme.Muted)
	chevron.Instance.AnchorPoint = Vector2.new(1, 0.5)

	win:_onLayout(function()
		button.Size = UDim2.new(1, 0, 0, m.Row)
		button.TextSize = m.Text
		local leadExtra = 0
		if lead then
			local sz = iconSizeOf(lead, m.Icon)
			lead:SetSize(sz); leadExtra = sz + 10
			lead.Instance.Position = UDim2.new(0, -leadExtra, 0.5, 0)
		end
		chevron:SetSize(m.Icon - 2)
		local chevronExtra = (m.Icon - 2) + 8
		chevron.Instance.Position = UDim2.new(1, chevronExtra, 0.5, 0)
		padding.PaddingLeft = UDim.new(0, 14 + leadExtra)
		padding.PaddingRight = UDim.new(0, 14 + chevronExtra)
	end)

	local hovering = false
	button.MouseEnter:Connect(function()
		hovering = true
		tween(button, Anim.Fast, { BackgroundColor3 = Theme.ElementHover })
		tween(stroke, Anim.Fast, { Color = accentBorder(0.35) })
		chevron:Tween(Theme.Text, Anim.Fast)
		tween(chevron.Instance, Anim.Fast, { Position = UDim2.new(1, (m.Icon - 2) + 11, 0.5, 0) })
		if lead and not lead.CustomColor then lead:Tween(Theme.Text, Anim.Fast) end
	end)
	button.MouseLeave:Connect(function()
		hovering = false
		tween(button, Anim.Fast, { BackgroundColor3 = Theme.Element })
		tween(stroke, Anim.Fast, { Color = Theme.StrokeSoft })
		tween(scale, Anim.Fast, { Scale = 1 })
		tween(chevron.Instance, Anim.Fast, { Position = UDim2.new(1, (m.Icon - 2) + 8, 0.5, 0) })
		chevron:Tween(Theme.Muted, Anim.Fast)
		if lead and not lead.CustomColor then lead:Tween(Theme.SubText, Anim.Fast) end
	end)
	button.MouseButton1Down:Connect(function()
		tween(button, Anim.Micro, { BackgroundColor3 = Theme.ElementPressed })
		tween(scale, Anim.Micro, { Scale = 0.988 })
	end)
	button.MouseButton1Up:Connect(function()
		tween(button, Anim.Fast, { BackgroundColor3 = hovering and Theme.ElementHover or Theme.Element })
		tween(scale, Anim.Fast, { Scale = 1 })
	end)
	button.Activated:Connect(function()
		local flash = tween(stroke, Anim.Micro, { Color = accentBorder(0.75) })
		flash.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Completed then return end
			tween(stroke, Anim.Normal, { Color = hovering and accentBorder(0.35) or Theme.StrokeSoft })
		end)
		safeCall(config.Callback)
	end)
	button.InputBegan:Connect(function(input)
		if isPointer(input) then detectPointerOffset(input, button) end
	end)
	local object = { Instance = button }
	function object:SetText(newText) button.Text = tostring(newText) end
	function object:Set(newText) object:SetText(newText) end
	function object:Get() return button.Text end
	self:_register("Button", button, function() return button.Text end)
	return object
end

----------------------------------------------------------------
-- Toggle (Premium Dark: switch solido sem glow/halo)
----------------------------------------------------------------
function Tab:AddToggle(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local state = config.Default == true
	local row = create("TextButton", {
		Name = "Toggle", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0, AutoButtonColor = false,
		Text = "", ClipsDescendants = true, Parent = self._page,
	})
	addCorner(row, Radius.Card)
	local stroke = addStroke(row, state and accentBorder(0.35) or Theme.StrokeSoft, 0, 1)
	local rowScale = create("UIScale", { Parent = row })
	local lead = createIcon(config.Icon, row, m.Icon, state and accentLight() or Theme.SubText, { Size = config.IconSize, Color = config.IconColor })
	if lead then
		lead.Instance.AnchorPoint = Vector2.new(0, 0.5)
		lead.Instance.Position = UDim2.new(0, 14, 0.5, 0)
	end
	local label = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -70, 1, 0),
		Text = config.Name or "Toggle", Font = Theme.Font,
		TextSize = m.Text, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local switch = create("Frame", {
		Name = "Switch", AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(m.SwitchW, m.SwitchH),
		BackgroundColor3 = state and accent() or Theme.BackgroundDeep,
		ClipsDescendants = false, Parent = row,
	})
	addCornerScale(switch, 0.5)
	local switchStroke = create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = state and accentBorder(0.75) or Theme.Stroke, Thickness = 1,
		Transparency = 0, Parent = switch,
	})

	local knobSize = m.SwitchH - 8
	local knob = create("Frame", {
		Name = "Knob", AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -(knobSize + 4), 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(knobSize, knobSize),
		BackgroundColor3 = state and Theme.White or Theme.SubText, ZIndex = 2, Parent = switch,
	})
	addCornerScale(knob, 0.5)

	local function knobPosition()
		if state then return UDim2.new(1, -(knobSize + 4), 0.5, 0) end
		return UDim2.new(0, 4, 0.5, 0)
	end
	local function render(animate)
		local on = state
		setProps(switch, { BackgroundColor3 = on and accent() or Theme.BackgroundDeep }, animate, Anim.Normal)
		setProps(switchStroke, { Color = on and accentBorder(0.75) or Theme.Stroke }, animate, Anim.Normal)
		setProps(knob, { BackgroundColor3 = on and Theme.White or Theme.SubText }, animate, Anim.Fast)
		if animate then tween(knob, Anim.Spring, { Position = knobPosition() }, Enum.EasingStyle.Back)
		else knob.Position = knobPosition() end
		setProps(stroke, { Color = on and accentBorder(0.35) or Theme.StrokeSoft }, animate, Anim.Normal)
		if lead and not lead.CustomColor then
			if animate then lead:Tween(on and accentLight() or Theme.SubText, Anim.Normal)
			else lead:SetColor(on and accentLight() or Theme.SubText) end
		end
	end

	win:_onLayout(function()
		row.Size = UDim2.new(1, 0, 0, m.Row)
		label.TextSize = m.Text
		local leftX = 14
		if lead then
			local sz = iconSizeOf(lead, m.Icon)
			lead:SetSize(sz); leftX = 14 + sz + 10
		end
		label.Position = UDim2.fromOffset(leftX, 0)
		label.Size = UDim2.new(1, -(leftX + m.SwitchW + 28), 1, 0)
		switch.Size = UDim2.fromOffset(m.SwitchW, m.SwitchH)
		local ks = m.SwitchH - 8
		knobSize = ks
		knob.Size = UDim2.fromOffset(ks, ks)
		knob.Position = knobPosition()
	end)
	win:_onAccent(function(animate)
		if state then
			setProps(switch, { BackgroundColor3 = accent() }, animate, Anim.Normal)
			setProps(switchStroke, { Color = accentBorder(0.75) }, animate, Anim.Normal)
		end
		if lead and not lead.CustomColor then lead:SetColor(state and accentLight() or Theme.SubText) end
		setProps(stroke, { Color = state and accentBorder(0.35) or Theme.StrokeSoft }, animate, Anim.Normal)
	end)

	local object = { Instance = row }
	function object:Set(value, silent)
		value = value == true
		if value == state then return end
		state = value; render(true)
		if not silent then safeCall(config.Callback, state) end
	end
	function object:Get() return state end
	function object:SetText(newText) label.Text = tostring(newText) end
	self:_register("Toggle", row, function() return label.Text end)
	row.MouseEnter:Connect(function()
		tween(row, Anim.Fast, { BackgroundColor3 = Theme.ElementHover })
	end)
	row.MouseLeave:Connect(function()
		tween(row, Anim.Fast, { BackgroundColor3 = Theme.Element })
		tween(rowScale, Anim.Fast, { Scale = 1 })
	end)
	local function knobRest()
		local ks = m.SwitchH - 8
		tween(knob, Anim.Fast, { Size = UDim2.fromOffset(ks, ks) })
	end
	row.MouseButton1Down:Connect(function()
		tween(rowScale, Anim.Micro, { Scale = 0.99 })
		local ks = m.SwitchH - 8
		tween(knob, Anim.Micro, {
			Size = UDim2.fromOffset(ks + 3, ks),
			Position = state and UDim2.new(1, -(ks + 7), 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
		})
	end)
	row.MouseButton1Up:Connect(function()
		tween(rowScale, Anim.Fast, { Scale = 1 })
		local ks = m.SwitchH - 8
		tween(knob, Anim.Spring, { Size = UDim2.fromOffset(ks, ks), Position = knobPosition() }, Enum.EasingStyle.Back)
	end)
	row.MouseLeave:Connect(knobRest)
	row.InputBegan:Connect(function(input)
		if isPointer(input) then detectPointerOffset(input, row) end
	end)
	row.Activated:Connect(function() object:Set(not state) end)
	return object
end

----------------------------------------------------------------
-- Slider (Premium Dark: trilha solida + badge de valor)
----------------------------------------------------------------
function Tab:AddSlider(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local min = config.Min or 0
	local max = config.Max or 100
	if max < min then min, max = max, min end
	local step = config.Step or 1
	local suffix = config.Suffix or ""
	local function snap(v)
		v = math.clamp(v, min, max)
		if step > 0 then v = min + math.floor((v - min) / step + 0.5) * step end
		v = math.clamp(v, min, max)
		return math.floor(v * 10000 + 0.5) / 10000
	end
	local value = snap(config.Default or min)
	local holder = create("Frame", {
		Name = "Slider", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row + 14),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0, Parent = self._page,
	})
	addCorner(holder, Radius.Card)
	local holderStroke = addStroke(holder, Theme.StrokeSoft, 0, 1)
	local lead = createIcon(config.Icon, holder, m.Icon, Theme.SubText, { Size = config.IconSize, Color = config.IconColor })
	if lead then
		lead.Instance.AnchorPoint = Vector2.new(0, 0.5)
		lead.Instance.Position = UDim2.new(0, 14, 0, 18)
	end
	local nameLabel = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -102, 0, 20),
		Text = config.Name or "Slider", Font = Theme.Font,
		TextSize = m.Text, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = holder,
	})
	local valueBox = create("Frame", {
		Name = "ValueBox", AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 7),
		Size = UDim2.fromOffset(66, 20),
		BackgroundColor3 = Theme.BackgroundDeep, Parent = holder,
	})
	addCorner(valueBox, Radius.Small)
	local valueBoxStroke = addStroke(valueBox, Theme.StrokeSoft, 0, 1)
	local valueLabel = create("TextLabel", {
		Name = "Value", BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), Text = "",
		Font = Theme.FontBold, TextSize = math.max(10, m.Text - 2),
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Center, Parent = valueBox,
	})
	attachValuePop(valueLabel, 1.06, 0.12)
	local track = create("Frame", {
		Name = "Track", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.new(1, -28, 0, m.Mobile and 6 or 5),
		BackgroundColor3 = Theme.BackgroundDeep, Parent = holder,
	})
	addCornerScale(track, 0.5)
	addStroke(track, Theme.StrokeSoft, 0, 1)
	local fill = create("Frame", {
		Name = "Fill", Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = accent(), Parent = track,
	})
	addCornerScale(fill, 0.5)
	local function knobBase() return m.Compact and (m.Mobile and 15 or 13) or (m.Mobile and 18 or 14) end
	local knob = create("Frame", {
		Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(knobBase(), knobBase()),
		BackgroundColor3 = Theme.White, ZIndex = 2, Parent = track,
	})
	addCornerScale(knob, 0.5)
	local knobRingStroke = create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = accent(), Thickness = 2, Transparency = 0, Parent = knob,
	})
	local hit = create("TextButton", {
		Name = "Hit", AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, m.Mobile and 42 or 34), Text = "",
		AutoButtonColor = false, Active = true, ZIndex = 3, Parent = holder,
	})
	local dragging, activeInput, lockedOffset, lastRawPos, lastMoveOffset = false, nil, nil, nil, nil
	local function render(animate)
		local alpha = 0
		if max > min then alpha = (value - min) / (max - min) end
		local text = tostring(value) .. suffix
		if valueLabel.Text ~= text then valueLabel.Text = text end
		if animate and not dragging then
			tween(fill, Anim.Micro, { Size = UDim2.new(alpha, 0, 1, 0) }, Enum.EasingStyle.Linear)
			tween(knob, Anim.Micro, { Position = UDim2.new(alpha, 0, 0.5, 0) }, Enum.EasingStyle.Linear)
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
	end
	win:_onLayout(function()
		holder.Size = UDim2.new(1, 0, 0, m.Row + 14)
		nameLabel.TextSize = m.Text
		valueLabel.TextSize = math.max(10, m.Text - 2)
		local leftX = 14
		if lead then
			local sz = iconSizeOf(lead, m.Icon)
			lead:SetSize(sz); leftX = 14 + sz + 10
		end
		nameLabel.Position = UDim2.fromOffset(leftX, 8)
		nameLabel.Size = UDim2.new(1, -(leftX + 90), 0, 20)
		hit.Size = UDim2.new(1, 0, 0, m.Mobile and 42 or 34)
		local size = dragging and (knobBase() + 3) or knobBase()
		knob.Size = UDim2.fromOffset(size, size)
		render(false)
	end)
	win:_onAccent(function(animate)
		setProps(fill, { BackgroundColor3 = accent() }, animate, Anim.Normal)
		setProps(knobRingStroke, { Color = accent() }, animate, Anim.Normal)
	end)
	local object = { Instance = holder }
	function object:Set(newValue, silent)
		if typeof(newValue) ~= "number" then return end
		newValue = snap(newValue)
		if newValue == value then return end
		value = newValue; render(true)
		if not silent then safeCall(config.Callback, value) end
	end
	function object:Get() return value end
	self:_register("Slider", holder, function() return nameLabel.Text end)
	local function updateFromInput(input)
		local width = track.AbsoluteSize.X
		if width <= 0 then return end
		local px = pointerPosition(input, lockedOffset).X
		local alpha = math.clamp((px - track.AbsolutePosition.X) / width, 0, 1)
		object:Set(min + (max - min) * alpha)
	end
	local function startDragging(input)
		if dragging then return end
		dragging = true; activeInput = input
		lockedOffset = detectPointerOffset(input, hit)
		lastRawPos = nil; lastMoveOffset = nil
		self._page.ScrollingEnabled = false
		tween(knob, Anim.Fast, { Size = UDim2.fromOffset(knobBase() + 3, knobBase() + 3) })
		tween(holderStroke, Anim.Fast, { Color = accentBorder(0.45) })
		tween(valueBoxStroke, Anim.Fast, { Color = accentBorder(0.45) })
		tween(valueLabel, Anim.Fast, { TextColor3 = accentLight() })
	end
	local function stopDragging()
		if not dragging then return end
		dragging = false; activeInput = nil; lockedOffset = nil; lastRawPos = nil; lastMoveOffset = nil
		self._page.ScrollingEnabled = true
		tween(knob, Anim.Fast, { Size = UDim2.fromOffset(knobBase(), knobBase()) })
		tween(holderStroke, Anim.Fast, { Color = Theme.StrokeSoft })
		tween(valueBoxStroke, Anim.Fast, { Color = Theme.StrokeSoft })
		tween(valueLabel, Anim.Fast, { TextColor3 = Theme.SubText })
	end
	local moveConn, hitMoveConn, endConn
	local function untrack()
		if moveConn then moveConn:Disconnect(); moveConn = nil end
		if hitMoveConn then hitMoveConn:Disconnect(); hitMoveConn = nil end
		if endConn then endConn:Disconnect(); endConn = nil end
	end
	table.insert(self._connections, { Disconnect = function() untrack(); stopDragging() end })
	local function handleMove(changed)
		if not dragging then return end
		if changed.UserInputType == Enum.UserInputType.MouseMovement
			or (changed.UserInputType == Enum.UserInputType.Touch and (activeInput == nil or changed == activeInput)) then
			local raw = Vector2.new(changed.Position.X, changed.Position.Y)
			if changed.UserInputType == Enum.UserInputType.Touch then
				local okMl, ml = pcall(function() return UserInputService:GetMouseLocation() end)
				if okMl and typeof(ml) == "Vector2" and ml.Magnitude > 0 then
					local inset = getGuiInset()
					if (ml - raw).Magnitude <= 5 then
						lockedOffset = Vector2.zero; CalibratedTouchOffset = Vector2.zero
					elseif inset.Magnitude > 0 and (ml - (raw + inset)).Magnitude <= 5 then
						lockedOffset = inset; CalibratedTouchOffset = inset
					end
				end
			end
			if lastRawPos == raw and lastMoveOffset == lockedOffset then return end
			lastRawPos = raw; lastMoveOffset = lockedOffset
			updateFromInput(changed)
		end
	end
	hit.InputBegan:Connect(function(input)
		if not isPointer(input) then return end
		if dragging then return end
		startDragging(input); updateFromInput(input)
		untrack()
		hitMoveConn = hit.InputChanged:Connect(handleMove)
		moveConn = UserInputService.InputChanged:Connect(handleMove)
		endConn = UserInputService.InputEnded:Connect(function(ended)
			if not dragging then return end
			local same = ended == activeInput
				or (activeInput and ended.UserInputType == Enum.UserInputType.MouseButton1
					and activeInput.UserInputType == Enum.UserInputType.MouseButton1)
				or (activeInput and ended.UserInputType == Enum.UserInputType.Touch
					and activeInput.UserInputState == Enum.UserInputState.End)
			if same or (not activeInput and isPointer(ended)) then
				untrack()
				stopDragging()
			end
		end)
	end)
	return object
end

----------------------------------------------------------------
-- Dropdown / MultiDropdown - base compartilhada (v2.3.0)
-- Abrir/fechar, clique fora, apenas um aberto por vez, mobile e PC.
----------------------------------------------------------------
local function dropdownRowHeight(m)
	if m.Mobile then return m.Compact and 32 or 38 end
	return m.Compact and 28 or 32
end

local function buildDropdownShell(tab, config, className)
	local win = tab._window
	local m = tab._metrics
	local shell = { Options = {}, Rows = {}, Expanded = false }
	for i, value in ipairs(config.Options or {}) do shell.Options[i] = value end
	win._openDropdowns = win._openDropdowns or {}

	local root = create("Frame", {
		Name = className, LayoutOrder = tab:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0, ClipsDescendants = true, Parent = tab._page,
	})
	addCorner(root, Radius.Card)
	local rootStroke = addStroke(root, Theme.StrokeSoft, 0, 1)

	local header = create("TextButton", {
		Name = "Header", Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundTransparency = 1, Text = "",
		AutoButtonColor = false, Parent = root,
	})
	local lead = createIcon(config.Icon, header, m.Icon, Theme.SubText, { Size = config.IconSize, Color = config.IconColor })
	if lead then
		lead.Instance.AnchorPoint = Vector2.new(0, 0.5)
		lead.Instance.Position = UDim2.new(0, 14, 0.5, 0)
	end
	local label = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, -14, 1, 0),
		Text = config.Name or "Selecionar", Font = Theme.Font,
		TextSize = m.Text, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})
	local valueLabel = create("TextLabel", {
		Name = "Value", AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -38, 0.5, 0), Size = UDim2.new(0.5, -38, 1, 0),
		BackgroundTransparency = 1, Text = "",
		Font = Theme.Font, TextSize = m.Text - 1,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})
	local chevron = createIcon("chevron-down", header, m.Icon - 2, Theme.Muted)
	chevron.Instance.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Instance.Position = UDim2.new(1, -14, 0.5, 0)
	attachValuePop(valueLabel, 1.05, 0)

	local panel = create("CanvasGroup", {
		Name = "Panel", Visible = false,
		Position = UDim2.fromOffset(0, m.Row),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		GroupTransparency = 0, ClipsDescendants = true, Parent = root,
	})
	local panelScale = create("UIScale", { Scale = 1, Parent = panel })
	create("Frame", {
		Name = "TopDivider", BackgroundColor3 = Theme.Divider,
		Size = UDim2.new(1, 0, 0, 1), ZIndex = 4, Parent = panel,
	})
	local scroll = create("ScrollingFrame", {
		Name = "Scroll", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 5),
		Size = UDim2.new(1, -8, 1, -9),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 2, ScrollBarImageColor3 = accent(),
		ScrollBarImageTransparency = 0.25, Parent = panel,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll,
	})

	shell.Root, shell.Header, shell.Label, shell.ValueLabel = root, header, label, valueLabel
	shell.Chevron, shell.Panel, shell.Scroll, shell.RootStroke = chevron, panel, scroll, rootStroke

	local token = {}
	token.Close = function() shell.setExpanded(false, true) end

	local function heights()
		local rowH = dropdownRowHeight(m)
		local content = #shell.Options * (rowH + 2) + 9
		return math.min(content, 220), content, rowH
	end

	local headerHover = false
	local function paintHeader(animate)
		local active = shell.Expanded or headerHover
		local props = {
			Color = shell.Expanded and accentBorder(0.6) or (headerHover and Theme.StrokeStrong or Theme.StrokeSoft),
			Transparency = 0,
		}
		if animate then
			tween(rootStroke, Anim.Fast, props)
			tween(root, Anim.Fast, { BackgroundColor3 = headerHover and Theme.ElementHover or Theme.Element })
			chevron:Tween(active and accentLight() or Theme.Muted, Anim.Fast)
		else
			rootStroke.Color = props.Color; rootStroke.Transparency = props.Transparency
			root.BackgroundColor3 = headerHover and Theme.ElementHover or Theme.Element
			chevron:SetColor(active and accentLight() or Theme.Muted)
		end
	end
	header.MouseEnter:Connect(function() headerHover = true; paintHeader(true) end)
	header.MouseLeave:Connect(function() headerHover = false; paintHeader(true) end)

	function shell.setExpanded(value, animate, noScroll)
		value = value == true
		if shell.Expanded == value then return end
		shell.Expanded = value
		paintHeader(animate)
		local panelH, content = heights()
		scroll.ScrollingEnabled = content > panelH
		local doAnim = animate and not State.LowPerformance
		if value then
			win:_closeDropdowns(token)
			win._openDropdowns[token] = true
			panel.Visible = true
			if doAnim then
				panel.GroupTransparency = 1
				panelScale.Scale = 0.98
				panel.Position = UDim2.fromOffset(0, m.Row - 4)
				tween(panel, Anim.Fast, {
					Size = UDim2.new(1, 0, 0, panelH),
					Position = UDim2.fromOffset(0, m.Row),
					GroupTransparency = 0,
				})
				tween(panelScale, Anim.Fast, { Scale = 1 })
				tween(root, Anim.Fast, { Size = UDim2.new(1, 0, 0, m.Row + panelH) })
				tween(chevron.Instance, Anim.Fast, { Rotation = 180 })
			else
				panel.GroupTransparency = 0
				panelScale.Scale = 1
				panel.Position = UDim2.fromOffset(0, m.Row)
				panel.Size = UDim2.new(1, 0, 0, panelH)
				root.Size = UDim2.new(1, 0, 0, m.Row + panelH)
				chevron.Instance.Rotation = 180
			end
			if not noScroll then
				task.delay(0.1, function()
					if shell.Expanded and root.Parent then
						tab:_scrollIntoView(root, m.Row + panelH)
					end
				end)
			end
		else
			win._openDropdowns[token] = nil
			if doAnim then
				tween(panel, Anim.Fast, { Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1 })
				tween(panelScale, Anim.Fast, { Scale = 0.98 })
				tween(root, Anim.Fast, { Size = UDim2.new(1, 0, 0, m.Row) })
				tween(chevron.Instance, Anim.Fast, { Rotation = 0 })
				task.delay(Anim.Fast + 0.03, function()
					if not shell.Expanded then
						panel.Visible = false
						panelScale.Scale = 1
						panel.GroupTransparency = 0
					end
				end)
			else
				panel.Size = UDim2.new(1, 0, 0, 0)
				root.Size = UDim2.new(1, 0, 0, m.Row)
				chevron.Instance.Rotation = 0
				panel.Visible = false
				panelScale.Scale = 1
				panel.GroupTransparency = 0
			end
		end
	end

	-- (Re)constroi as linhas de opcao. buildRow(opt, i, rowH) devolve
	-- { Button = ..., Relayout = function(rowH) ... end (opcional), ... }
	function shell.rebuild(buildRow)
		for _, row in ipairs(shell.Rows) do row.Button:Destroy() end
		shell.Rows = {}
		local panelH, content, rowH = heights()
		for i, opt in ipairs(shell.Options) do
			shell.Rows[i] = buildRow(opt, i, rowH)
		end
		scroll.CanvasSize = UDim2.fromOffset(0, #shell.Options * (rowH + 2))
		scroll.ScrollingEnabled = content > panelH
		if shell.Expanded then
			setProps(panel, { Size = UDim2.new(1, 0, 0, panelH) }, true, Anim.Fast)
			setProps(root, { Size = UDim2.new(1, 0, 0, m.Row + panelH) }, true, Anim.Fast)
		end
	end

	function shell.scrollToRow(index)
		local rowH = dropdownRowHeight(m)
		local y = (index - 1) * (rowH + 2)
		scroll.CanvasPosition = Vector2.new(0, y)
	end

	function shell.relayout()
		local panelH, content, rowH = heights()
		root.Size = UDim2.new(1, 0, 0, shell.Expanded and (m.Row + panelH) or m.Row)
		header.Size = UDim2.new(1, 0, 0, m.Row)
		panel.Position = UDim2.fromOffset(0, m.Row)
		panel.Size = UDim2.new(1, 0, 0, shell.Expanded and panelH or 0)
		scroll.CanvasSize = UDim2.fromOffset(0, #shell.Options * (rowH + 2))
		scroll.ScrollingEnabled = content > panelH
		for _, row in ipairs(shell.Rows) do
			row.Button.Size = UDim2.new(1, 0, 0, rowH)
			if row.Relayout then row.Relayout(rowH) end
		end
		label.TextSize = m.Text
		valueLabel.TextSize = m.Text - 1
		local leftX = 14
		if lead then
			local sz = iconSizeOf(lead, m.Icon)
			lead:SetSize(sz); leftX = 14 + sz + 10
		end
		label.Position = UDim2.fromOffset(leftX, 0)
		label.Size = UDim2.new(0.5, -leftX, 1, 0)
		valueLabel.Position = UDim2.new(1, -38, 0.5, 0)
		valueLabel.Size = UDim2.new(0.5, -38, 1, 0)
		chevron:SetSize(m.Icon - 2)
		chevron.Instance.Position = UDim2.new(1, -14, 0.5, 0)
	end

	header.Activated:Connect(function() shell.setExpanded(not shell.Expanded, true) end)

	-- Clique/toque fora do controle fecha o painel.
	-- Testa as duas interpretacoes de coordenada (com e sem GuiInset) para
	-- nunca fechar por engano ao tocar dentro do proprio dropdown.
	table.insert(tab._connections, UserInputService.InputBegan:Connect(function(input)
		if not shell.Expanded or not isPointer(input) then return end
		local raw = Vector2.new(input.Position.X, input.Position.Y)
		local inset = GuiService:GetGuiInset()
		local pos, size = root.AbsolutePosition, root.AbsoluteSize
		local function inside(p)
			return p.X >= pos.X and p.X <= pos.X + size.X and p.Y >= pos.Y and p.Y <= pos.Y + size.Y
		end
		if not inside(raw) and not inside(raw + inset) then
			shell.setExpanded(false, true)
		end
	end))

	win:_onLayout(shell.relayout)
	return shell
end

----------------------------------------------------------------
-- Dropdown - selecao unica
----------------------------------------------------------------
function Tab:AddDropdown(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local shell = buildDropdownShell(self, config, "Dropdown")
	local options = shell.Options
	local selected = config.Default
	if selected ~= nil and not table.find(options, selected) then selected = nil end
	local object = { Instance = shell.Root }

	local function paint()
		for i, row in ipairs(shell.Rows) do
			local isSel = selected ~= nil and options[i] == selected
			setProps(row.Button, {
				BackgroundColor3 = isSel and accentSurface(0.14) or Theme.Surface,
				BackgroundTransparency = 0,
			}, true, Anim.Fast)
			setProps(row.Label, { TextColor3 = isSel and Theme.Text or Theme.SubText }, true, Anim.Fast)
			row.Check.Visible = isSel
		end
		shell.ValueLabel.Text = selected ~= nil and tostring(selected) or "Nenhum"
		shell.ValueLabel.TextColor3 = selected ~= nil and accentLight() or Theme.Muted
	end

	local function buildRow(opt, i, rowH)
		local isSel = selected ~= nil and opt == selected
		local btn = create("TextButton", {
			Name = "Option" .. i, LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, rowH),
			BackgroundColor3 = isSel and accentSurface(0.14) or Theme.Surface, BackgroundTransparency = 0,
			AutoButtonColor = false, Text = "", Parent = shell.Scroll,
		})
		addCorner(btn, Radius.Control)
		local btnLabel = create("TextLabel", {
			Name = "L", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -40, 1, 0),
			Text = tostring(opt), Font = Theme.Font,
			TextSize = m.Text - 1,
			TextColor3 = isSel and Theme.Text or Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		})
		local check = createIcon("check", btn, m.Icon - 4, accentLight())
		check.Instance.AnchorPoint = Vector2.new(1, 0.5)
		check.Instance.Position = UDim2.new(1, -10, 0.5, 0)
		check.Instance.Visible = isSel
		btn.MouseEnter:Connect(function()
			local curSel = selected ~= nil and opt == selected
			tween(btn, Anim.Fast, { BackgroundColor3 = curSel and accentSurface(0.18) or Theme.ElementHover, BackgroundTransparency = 0 })
			btnLabel.TextColor3 = Theme.Text
		end)
		btn.MouseLeave:Connect(function()
			local curSel = selected ~= nil and opt == selected
			tween(btn, Anim.Fast, { BackgroundColor3 = curSel and accentSurface(0.14) or Theme.Surface, BackgroundTransparency = 0 })
			btnLabel.TextColor3 = curSel and Theme.Text or Theme.SubText
		end)
		btn.Activated:Connect(function()
			object:Set(opt)
			shell.setExpanded(false, true)
		end)
		return {
			Button = btn, Label = btnLabel, Check = check.Instance,
			Relayout = function()
				btnLabel.TextSize = m.Text - 1
				check:SetSize(m.Icon - 4)
				check.Instance.Position = UDim2.new(1, -10, 0.5, 0)
			end,
		}
	end

	function object:Set(value, silent)
		if not table.find(options, value) then return end
		selected = value
		paint()
		if not silent then safeCall(config.Callback, selected) end
	end
	function object:Get() return selected end
	function object:Clear(silent)
		selected = nil; paint()
		if not silent then safeCall(config.Callback, nil) end
	end
	function object:SetOptions(newOptions, silent)
		if typeof(newOptions) ~= "table" then return end
		table.clear(options)
		for i, value in ipairs(newOptions) do options[i] = value end
		local changed = false
		if selected ~= nil and not table.find(options, selected) then
			selected = nil; changed = true
		end
		shell.rebuild(buildRow)
		paint()
		if changed and not silent then safeCall(config.Callback, selected) end
	end
	object.Refresh = object.SetOptions
	function object:Open() shell.setExpanded(true, true) end
	function object:Close() shell.setExpanded(false, true) end
	function object:Toggle() shell.setExpanded(not shell.Expanded, true) end
	function object:IsOpen() return shell.Expanded end
	function object:SetText(newText) shell.Label.Text = tostring(newText) end

	shell.rebuild(buildRow)
	win:_onAccent(function(animate)
		shell.Scroll.ScrollBarImageColor3 = accent()
		paint()
	end)
	paint()
	self:_register("Dropdown", shell.Root, function() return shell.Label.Text end, {
		Options = options, FlashTarget = shell.Header,
		Open = function() shell.setExpanded(true, true, true) end,
		RowFor = function(i) return shell.Rows[i] and shell.Rows[i].Button or nil end,
		ScrollToRow = shell.scrollToRow,
	})
	return object
end

----------------------------------------------------------------
-- MultiDropdown - multipla selecao
----------------------------------------------------------------
function Tab:AddMultiDropdown(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local shell = buildDropdownShell(self, config, "MultiDropdown")
	local options = shell.Options
	local selected = {}
	if typeof(config.Default) == "table" then
		for _, v in ipairs(config.Default) do
			if table.find(options, v) then selected[v] = true end
		end
	end
	local object = { Instance = shell.Root }

	local function countSelected()
		local n = 0
		for _, opt in ipairs(options) do
			if selected[opt] then n = n + 1 end
		end
		return n
	end
	local function listSelected()
		local out = {}
		for _, opt in ipairs(options) do
			if selected[opt] then table.insert(out, opt) end
		end
		return out
	end
	local function paint()
		for i, row in ipairs(shell.Rows) do
			local on = selected[options[i]] == true
			row.Check.Visible = on
			setProps(row.Button, { BackgroundColor3 = on and accentSurface(0.12) or Theme.Surface, BackgroundTransparency = 0 }, true, Anim.Fast)
			setProps(row.Box, { BackgroundColor3 = on and accent() or Theme.BackgroundDeep }, true, Anim.Fast)
			if row.BoxStroke then
				setProps(row.BoxStroke, { Color = on and accent() or Theme.Stroke, Transparency = 0 }, true, Anim.Fast)
			end
			setProps(row.Label, { TextColor3 = on and Theme.Text or Theme.SubText }, true, Anim.Fast)
		end
		local n = countSelected()
		shell.ValueLabel.Text = n == 0 and "0" or (n .. " selecionado" .. (n > 1 and "s" or ""))
		shell.ValueLabel.TextColor3 = n > 0 and accentLight() or Theme.Muted
	end

	local function buildRow(opt, i, rowH)
		local on = selected[opt] == true
		local btn = create("TextButton", {
			Name = "Option" .. i, LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, rowH),
			BackgroundColor3 = on and accentSurface(0.12) or Theme.Surface, BackgroundTransparency = 0,
			AutoButtonColor = false, Text = "", Parent = shell.Scroll,
		})
		addCorner(btn, Radius.Control)
		local box = create("Frame", {
			Name = "Box", Position = UDim2.fromOffset(8, (rowH - 16) / 2),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = on and accent() or Theme.BackgroundDeep, Parent = btn,
		})
		addCorner(box, Radius.Small)
		local boxStroke = addStroke(box, on and accent() or Theme.Stroke, 0, 1)
		local btnLabel = create("TextLabel", {
			Name = "L", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0),
			Text = tostring(opt), Font = Theme.Font,
			TextSize = m.Text - 1, TextColor3 = on and Theme.Text or Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		})
		local check = createIcon("check", box, 10, Theme.White)
		check.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
		check.Instance.Position = UDim2.fromScale(0.5, 0.5)
		check.Instance.Visible = on
		btn.MouseEnter:Connect(function()
			local curOn = selected[opt] == true
			tween(btn, Anim.Fast, { BackgroundColor3 = curOn and accentSurface(0.16) or Theme.ElementHover, BackgroundTransparency = 0 })
		end)
		btn.MouseLeave:Connect(function()
			local curOn = selected[opt] == true
			tween(btn, Anim.Fast, { BackgroundColor3 = curOn and accentSurface(0.12) or Theme.Surface, BackgroundTransparency = 0 })
		end)
		btn.Activated:Connect(function() object:Toggle(opt) end)
		return {
			Button = btn, Label = btnLabel, Check = check.Instance, Box = box, BoxStroke = boxStroke,
			Relayout = function(newRowH)
				box.Position = UDim2.fromOffset(8, (newRowH - 16) / 2)
				btnLabel.TextSize = m.Text - 1
			end,
		}
	end

	function object:Set(values, silent)
		if typeof(values) ~= "table" then return end
		selected = {}
		for _, v in ipairs(values) do
			if table.find(options, v) then selected[v] = true end
		end
		paint()
		if not silent then safeCall(config.Callback, listSelected()) end
	end
	function object:Get() return listSelected() end
	function object:Toggle(opt)
		if not table.find(options, opt) then return end
		selected[opt] = not selected[opt]
		paint()
		safeCall(config.Callback, listSelected())
	end
	function object:Clear(silent)
		selected = {}; paint()
		if not silent then safeCall(config.Callback, {}) end
	end
	function object:SetOptions(newOptions, silent)
		if typeof(newOptions) ~= "table" then return end
		table.clear(options)
		for i, value in ipairs(newOptions) do options[i] = value end
		local changed = false
		for opt in pairs(selected) do
			if not table.find(options, opt) then selected[opt] = nil; changed = true end
		end
		shell.rebuild(buildRow)
		paint()
		if changed and not silent then safeCall(config.Callback, listSelected()) end
	end
	object.Refresh = object.SetOptions
	function object:Open() shell.setExpanded(true, true) end
	function object:Close() shell.setExpanded(false, true) end
	function object:IsOpen() return shell.Expanded end
	function object:SetText(newText) shell.Label.Text = tostring(newText) end

	shell.rebuild(buildRow)
	win:_onAccent(function(animate)
		shell.Scroll.ScrollBarImageColor3 = accent()
		paint()
	end)
	paint()
	self:_register("MultiDropdown", shell.Root, function() return shell.Label.Text end, {
		Options = options, FlashTarget = shell.Header,
		Open = function() shell.setExpanded(true, true, true) end,
		RowFor = function(i) return shell.Rows[i] and shell.Rows[i].Button or nil end,
		ScrollToRow = shell.scrollToRow,
	})
	return object
end

----------------------------------------------------------------
-- RadioGroup - grupo de selecao exclusiva inline (v2.7.0)
----------------------------------------------------------------
function Tab:AddRadioGroup(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local options = {}
	for i, value in ipairs(config.Options or {}) do options[i] = value end
	local selected = config.Default
	if selected ~= nil and not table.find(options, selected) then selected = nil end

	local root = create("Frame", {
		Name = "RadioGroup", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0,
		ClipsDescendants = true, Parent = self._page,
	})
	addCorner(root, Radius.Card)
	addStroke(root, Theme.StrokeSoft, 0, 1)

	local header = create("Frame", {
		Name = "Header", Size = UDim2.new(1, 0, 0, m.Compact and 32 or 38),
		BackgroundTransparency = 1, Parent = root,
	})
	local lead = createIcon(config.Icon or "radio", header, m.Icon, Theme.SubText, { Size = config.IconSize, Color = config.IconColor })
	if lead then
		lead.Instance.AnchorPoint = Vector2.new(0, 0.5)
		lead.Instance.Position = UDim2.new(0, 14, 0.5, 0)
	end
	local titleLabel = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.55, -14, 1, 0),
		Text = tostring(config.Name or "Radio Group"), Font = Theme.Font,
		TextSize = m.Text, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})
	local valueLabel = create("TextLabel", {
		Name = "Value", AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0.45, -14, 1, 0),
		BackgroundTransparency = 1, Text = "",
		Font = Theme.FontBold, TextSize = m.Text - 1,
		TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})
	attachValuePop(valueLabel, 1.06, 0)

	local listHolder = create("Frame", {
		Name = "Options", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, m.Compact and 32 or 38),
		Size = UDim2.new(1, -16, 0, 0), Parent = root,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = listHolder,
	})

	local rows = {}
	local object = { Instance = root }

	local function optionHeight()
		if m.Mobile then return m.Compact and 36 or 42 end
		return m.Compact and 28 or 34
	end
	local function headerHeight()
		return m.Compact and 32 or 38
	end
	local function updateSize()
		local hh = headerHeight()
		local oh = optionHeight()
		local listH = (#options > 0) and (#options * oh + math.max(#options - 1, 0) * 4) or 0
		local total = hh + listH + ((#options > 0) and 8 or 2)
		header.Size = UDim2.new(1, 0, 0, hh)
		listHolder.Position = UDim2.fromOffset(8, hh)
		listHolder.Size = UDim2.new(1, -16, 0, listH)
		root.Size = UDim2.new(1, 0, 0, total)
		self:_refresh()
	end

	local function paint(animate)
		for i, row in ipairs(rows) do
			local isSel = selected ~= nil and options[i] == selected
			setProps(row.Button, {
				BackgroundColor3 = isSel and accentSurface(0.14) or Theme.Surface,
				BackgroundTransparency = 0,
			}, animate, Anim.Fast)
			setProps(row.RowStroke, {
				Color = isSel and accentBorder(0.55) or Theme.StrokeSoft,
				Transparency = 0,
			}, animate, Anim.Fast)
			setProps(row.RingStroke, {
				Color = isSel and accent() or Theme.StrokeStrong,
				Transparency = 0,
			}, animate, Anim.Fast)
			setProps(row.Dot, { BackgroundColor3 = accentLight() }, animate, Anim.Fast)
			setProps(row.DotScale, { Scale = isSel and 1 or 0 }, animate, Anim.Normal, Enum.EasingStyle.Quint)
			setProps(row.Label, { TextColor3 = isSel and Theme.Text or Theme.SubText }, animate, Anim.Fast)
		end
		valueLabel.Text = selected ~= nil and tostring(selected) or "Nenhum"
		valueLabel.TextColor3 = selected ~= nil and accentLight() or Theme.Muted
	end

	local function rebuild()
		for _, row in ipairs(rows) do row.Button:Destroy() end
		rows = {}
		local oh = optionHeight()
		for i, opt in ipairs(options) do
			local isSel = selected ~= nil and opt == selected
			local btn = create("TextButton", {
				Name = "Radio" .. i, LayoutOrder = i,
				Size = UDim2.new(1, 0, 0, oh),
				BackgroundColor3 = isSel and accentSurface(0.14) or Theme.Surface,
				BackgroundTransparency = 0,
				AutoButtonColor = false, Active = true, Text = "", Parent = listHolder,
			})
			addCorner(btn, Radius.Control)
			local rowStroke = addStroke(btn, isSel and accentBorder(0.55) or Theme.StrokeSoft, 0, 1)
			local ringSize = m.Mobile and 18 or 16
			local ring = create("Frame", {
				Name = "Ring", AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.fromOffset(ringSize, ringSize),
				BackgroundColor3 = Theme.BackgroundDeep, BackgroundTransparency = 0, Parent = btn,
			})
			addCornerScale(ring, 0.5)
			local ringStroke = create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = isSel and accent() or Theme.StrokeStrong,
				Thickness = 1.6, Transparency = 0, Parent = ring,
			})
			local dot = create("Frame", {
				Name = "Dot", AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(math.floor(ringSize * 0.5), math.floor(ringSize * 0.5)),
				BackgroundColor3 = accentLight(), Parent = ring,
			})
			addCornerScale(dot, 0.5)
			local dotScale = create("UIScale", { Scale = isSel and 1 or 0, Parent = dot })
			local optLabel = create("TextLabel", {
				Name = "L", BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10 + ringSize + 10, 0),
				Size = UDim2.new(1, -(20 + ringSize + 10), 1, 0),
				Text = tostring(opt), Font = Theme.Font,
				TextSize = m.Text - 1,
				TextColor3 = isSel and Theme.Text or Theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
			})
			btn.MouseEnter:Connect(function()
				if options[i] ~= selected then
					tween(btn, Anim.Fast, { BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0 })
				end
			end)
			btn.MouseLeave:Connect(function()
				local cur = options[i] == selected
				tween(btn, Anim.Fast, {
					BackgroundColor3 = cur and accentSurface(0.14) or Theme.Surface,
					BackgroundTransparency = 0,
				})
			end)
			btn.Activated:Connect(function() object:Set(opt) end)
			rows[i] = {
				Button = btn, Label = optLabel, RowStroke = rowStroke,
				Ring = ring, RingStroke = ringStroke, Dot = dot, DotScale = dotScale,
			}
		end
		updateSize()
		paint(false)
	end

	function object:Set(value, silent)
		if value == nil then
			object:Clear(silent)
			return
		end
		if not table.find(options, value) then return end
		if value == selected then return end
		selected = value
		paint(true)
		if not silent then safeCall(config.Callback, selected) end
	end
	function object:Get() return selected end
	function object:Clear(silent)
		if selected == nil then return end
		selected = nil
		paint(true)
		if not silent then safeCall(config.Callback, nil) end
	end
	function object:SetOptions(newOptions, silent)
		if typeof(newOptions) ~= "table" then return end
		table.clear(options)
		for i, value in ipairs(newOptions) do options[i] = value end
		local changed = false
		if selected ~= nil and not table.find(options, selected) then
			selected = nil; changed = true
		end
		rebuild()
		if changed and not silent then safeCall(config.Callback, selected) end
	end
	object.Refresh = object.SetOptions
	function object:SetText(newText) titleLabel.Text = tostring(newText) end

	win:_onLayout(function()
		titleLabel.TextSize = m.Text
		valueLabel.TextSize = m.Text - 1
		local leftX = 14
		if lead then
			local sz = iconSizeOf(lead, m.Icon)
			lead:SetSize(sz); leftX = 14 + sz + 10
		end
		titleLabel.Position = UDim2.fromOffset(leftX, 0)
		titleLabel.Size = UDim2.new(0.55, -leftX, 1, 0)
		local oh = optionHeight()
		local ringSize = m.Mobile and 18 or 16
		for _, row in ipairs(rows) do
			row.Button.Size = UDim2.new(1, 0, 0, oh)
			row.Ring.Size = UDim2.fromOffset(ringSize, ringSize)
			row.Dot.Size = UDim2.fromOffset(math.floor(ringSize * 0.5), math.floor(ringSize * 0.5))
			row.Label.TextSize = m.Text - 1
			row.Label.Position = UDim2.fromOffset(10 + ringSize + 10, 0)
			row.Label.Size = UDim2.new(1, -(20 + ringSize + 10), 1, 0)
		end
		updateSize()
	end)
	win:_onAccent(function(animate) paint(animate) end)

	rebuild()
	self:_register("RadioGroup", root, function() return titleLabel.Text end, {
		Options = options, FlashTarget = header,
		RowFor = function(i) return rows[i] and rows[i].Button or nil end,
	})
	return object
end

----------------------------------------------------------------
-- ColorPicker (v2.3.0)
-- Seletor circular (quadrado SV) + painel de tonalidades (hue) ao lado,
-- tons, presets e campo HEX. Sem faixas RGB.
----------------------------------------------------------------
local function toHex(c)
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5))
end

local function parseHex(text)
	local hex = string.match(tostring(text or ""), "^%s*#?(%x+)%s*$")
	if not hex then return nil end
	if #hex == 3 then
		hex = string.sub(hex, 1, 1):rep(2) .. string.sub(hex, 2, 2):rep(2) .. string.sub(hex, 3, 3):rep(2)
	end
	if #hex ~= 6 then return nil end
	local r = tonumber(string.sub(hex, 1, 2), 16)
	local g = tonumber(string.sub(hex, 3, 4), 16)
	local b = tonumber(string.sub(hex, 5, 6), 16)
	if not (r and g and b) then return nil end
	return Color3.fromRGB(r, g, b)
end

local ToneColors = {
	Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220),
	Color3.fromRGB(160, 160, 160), Color3.fromRGB(100, 100, 100),
	Color3.fromRGB(50, 50, 50), Color3.fromRGB(0, 0, 0),
}

function Tab:AddColorPicker(config)
	config = config or {}
	local win = self._window
	local m = self._metrics
	local presets = config.Colors or DefaultSwatches
	local initial = typeof(config.Default) == "Color3" and config.Default or nil
	local current = initial or Color3.fromRGB(255, 255, 255)
	local h, s, v = current:ToHSV()
	local expanded = false
	win._openDropdowns = win._openDropdowns or {}

	local object = {}
	local token = {}
	token.Close = function() object:Close() end

	local root = create("Frame", {
		Name = "ColorPicker", LayoutOrder = self:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0, ClipsDescendants = true, Parent = self._page,
	})
	object.Instance = root
	addCorner(root, Radius.Card)
	local rootStroke = addStroke(root, Theme.StrokeSoft, 0, 1)

	local header = create("TextButton", {
		Name = "Header", Size = UDim2.new(1, 0, 0, m.Row),
		BackgroundTransparency = 1, Text = "",
		AutoButtonColor = false, Parent = root,
	})
	local lead = createIcon(config.Icon or "palette", header, m.Icon, Theme.SubText, { Size = config.IconSize, Color = config.IconColor })
	if lead then
		lead.Instance.AnchorPoint = Vector2.new(0, 0.5)
		lead.Instance.Position = UDim2.new(0, 14, 0.5, 0)
	end
	local nameLabel = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -80, 1, 0),
		Text = config.Name or "Cor", Font = Theme.Font,
		TextSize = m.Text, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})
	local previewBadge = create("Frame", {
		Name = "Preview", AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -38, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = current, Parent = header,
	})
	addCorner(previewBadge, Radius.Control)
	addStroke(previewBadge, Theme.StrokeStrong, 0, 1)
	local chevron = createIcon("chevron-down", header, m.Icon - 2, Theme.Muted)
	chevron.Instance.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Instance.Position = UDim2.new(1, -14, 0.5, 0)

	-- Painel: lista vertical com altura calculada automaticamente
	local panel = create("CanvasGroup", {
		Name = "Panel", Visible = false,
		Position = UDim2.fromOffset(0, m.Row),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		GroupTransparency = 0, ClipsDescendants = true, Parent = root,
	})
	local panelScale = create("UIScale", { Scale = 1, Parent = panel })
	addPadding(panel, 10, 10, 10, 10)
	local panelLayout = create("UIListLayout", {
		Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel,
	})

	-- Linha 1: quadrado SV (seletor circular) + faixa de tonalidades ao lado
	local pickH = m.Mobile and 140 or 112
	local hueW = m.Mobile and 26 or 18
	local pickRow = create("Frame", {
		Name = "Pick", LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, pickH), BackgroundTransparency = 1, Parent = panel,
	})
	local svSquare = create("Frame", {
		Name = "SV", Size = UDim2.new(1, -(hueW + 10), 1, 0),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1), Parent = pickRow,
	})
	addCorner(svSquare, 8)
	local satOverlay = create("Frame", {
		Name = "Sat", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.White, Active = false, Parent = svSquare,
	})
	addCorner(satOverlay, 8)
	create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 0, Parent = satOverlay,
	})
	local valOverlay = create("Frame", {
		Name = "Val", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Black, Active = false, Parent = svSquare,
	})
	addCorner(valOverlay, 8)
	create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
		}),
		Rotation = 90, Parent = valOverlay,
	})
	local selectorSize = m.Mobile and 20 or 16
	local svSelector = create("Frame", {
		Name = "Selector", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(s, 1 - v),
		Size = UDim2.fromOffset(selectorSize, selectorSize), BackgroundColor3 = current,
		Active = false, ZIndex = 5, Parent = svSquare,
	})
	addCornerScale(svSelector, 0.5)
	create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Theme.White, Thickness = 2, Parent = svSelector,
	})
	local svHit = create("TextButton", {
		Name = "Hit", BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), Text = "",
		AutoButtonColor = false, Active = true, ZIndex = 6, Parent = svSquare,
	})

	local hueBar = create("Frame", {
		Name = "Hue", AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, hueW, 1, 0),
		BackgroundColor3 = Theme.White, Parent = pickRow,
	})
	addCorner(hueBar, 8)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.000, Color3.fromHSV(0.000, 1, 1)),
			ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
			ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
			ColorSequenceKeypoint.new(0.500, Color3.fromHSV(0.500, 1, 1)),
			ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
			ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
			ColorSequenceKeypoint.new(1.000, Color3.fromHSV(0.000, 1, 1)),
		}),
		Rotation = 90, Parent = hueBar,
	})
	local hueSelector = create("Frame", {
		Name = "Selector", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, h, 0),
		Size = UDim2.fromOffset(hueW + 2, hueW + 2),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Active = false, ZIndex = 5, Parent = hueBar,
	})
	addCornerScale(hueSelector, 0.5)
	create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Theme.White, Thickness = 2, Parent = hueSelector,
	})
	local huePad = m.Mobile and 10 or 6
	local hueHit = create("TextButton", {
		Name = "Hit", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(-huePad, -huePad), Size = UDim2.new(1, huePad * 2, 1, huePad * 2),
		Text = "", AutoButtonColor = false, Active = true, ZIndex = 6, Parent = hueBar,
	})

	-- Linha 2: preview + campo HEX (editavel)
	local infoRow = create("Frame", {
		Name = "Info", LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = panel,
	})
	local bigPreview = create("Frame", {
		Name = "BigPreview", Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = current, Parent = infoRow,
	})
	addCorner(bigPreview, Radius.Control)
	addStroke(bigPreview, Theme.StrokeStrong, 0, 1)
	local hexBox = create("TextBox", {
		Name = "Hex", BackgroundColor3 = Theme.BackgroundDeep, BackgroundTransparency = 0,
		Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -36, 1, 0),
		Text = toHex(current), PlaceholderText = "#RRGGBB", Font = Theme.FontBold,
		TextSize = m.Text, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, Parent = infoRow,
	})
	addCorner(hexBox, Radius.Control)
	addPadding(hexBox, 8, 0, 8, 0)
	local hexStroke = addStroke(hexBox, Theme.StrokeSoft, 0, 1)

	-- Tons e presets (grade que quebra linha sozinha)
	local cell = m.Mobile and 28 or 24
	local toneButtons, presetButtons = {}, {}
	local function makeGrid(order, title, colors, circular, store, onPick)
		create("TextLabel", {
			Name = title .. "Label", LayoutOrder = order, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14), Text = title, Font = Theme.FontBold,
			TextSize = m.Text - 3, TextColor3 = Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = panel,
		})
		local row = create("Frame", {
			Name = title, LayoutOrder = order + 1, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, cell), AutomaticSize = Enum.AutomaticSize.Y, Parent = panel,
		})
		create("UIGridLayout", {
			CellSize = UDim2.fromOffset(cell, cell), CellPadding = UDim2.fromOffset(6, 6),
			SortOrder = Enum.SortOrder.LayoutOrder, Parent = row,
		})
		for i, color in ipairs(colors) do
			local b = create("TextButton", {
				Name = title .. i, LayoutOrder = i,
				BackgroundColor3 = color, AutoButtonColor = false, Text = "", Parent = row,
			})
			if circular then addCornerScale(b, 0.5) else addCorner(b, Radius.Control) end
			local stroke = addStroke(b, Theme.StrokeSoft, 0, 1)
			b.Activated:Connect(function() onPick(color) end)
			store[i] = {
				Button = b, Color = color, Stroke = stroke,
				Base = 0,
				BaseColor = Theme.StrokeSoft,
			}
		end
	end
	makeGrid(3, "TONS", ToneColors, false, toneButtons, function(c) object:Set(c) end)
	makeGrid(5, "PRESETS", presets, true, presetButtons, function(c) object:Set(c) end)

	-- Altura do painel acompanha o conteudo
	local function contentHeight()
		return math.max(panelLayout.AbsoluteContentSize.Y + 20, pickH + 20)
	end
	local function applyHeights(animate)
		if not expanded then return end
		local ph = contentHeight()
		setProps(panel, { Size = UDim2.new(1, 0, 0, ph) }, animate, Anim.Fast)
		setProps(root, { Size = UDim2.new(1, 0, 0, m.Row + ph) }, animate, Anim.Fast)
	end
	panelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		applyHeights(false)
	end)

	local function paintUI()
		current = Color3.fromHSV(h, s, v)
		local pure = Color3.fromHSV(h, 1, 1)
		if not hexBox:IsFocused() then hexBox.Text = toHex(current) end
		bigPreview.BackgroundColor3 = current
		previewBadge.BackgroundColor3 = current
		svSquare.BackgroundColor3 = pure
		svSelector.BackgroundColor3 = current
		svSelector.Position = UDim2.fromScale(s, 1 - v)
		hueSelector.BackgroundColor3 = pure
		hueSelector.Position = UDim2.new(0.5, 0, h, 0)
		for _, group in ipairs({ presetButtons, toneButtons }) do
			for _, item in ipairs(group) do
				local sel = colorsEqual(item.Color, current)
				item.Stroke.Transparency = sel and 0 or item.Base
				item.Stroke.Thickness = sel and 2 or 1
				item.Stroke.Color = sel and Theme.White or item.BaseColor
			end
		end
	end

	function object:Set(color, silent)
		if typeof(color) ~= "Color3" then return end
		if silent and colorsEqual(color, current) then return end
		local nh, ns, nv = color:ToHSV()
		if ns > 0.001 and nv > 0.001 then h = nh end -- cinza/preto/branco preservam o matiz
		s, v = ns, nv
		paintUI()
		current = color
		if not silent then safeCall(config.Callback, current) end
	end
	function object:Get() return current end
	function object:SetText(newText) nameLabel.Text = tostring(newText) end

	-- Interacao por arraste com calibracao exata do espaco de tela (mouse e toque mobile)
	local dragging, activeInput, dragOffset, lastDragRaw, lastDragOffset = nil, nil, nil, nil, nil
	local function localPoint(input, gui)
		local p = pointerPosition(input, dragOffset)
		local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
		if size.X <= 0 or size.Y <= 0 then return nil, nil end
		return math.clamp((p.X - pos.X) / size.X, 0, 1), math.clamp((p.Y - pos.Y) / size.Y, 0, 1)
	end
	local function updateDrag(input)
		if dragging == "sv" then
			local x, y = localPoint(input, svSquare)
			if not x then return end
			s = x; v = 1 - y
		elseif dragging == "hue" then
			local _, y = localPoint(input, hueBar)
			if not y then return end
			h = y
		else
			return
		end
		paintUI()
		safeCall(config.Callback, current)
	end
	local dragMoveConn, hitMoveConn, dragEndConn
	local function untrackDrag()
		if dragMoveConn then dragMoveConn:Disconnect(); dragMoveConn = nil end
		if hitMoveConn then hitMoveConn:Disconnect(); hitMoveConn = nil end
		if dragEndConn then dragEndConn:Disconnect(); dragEndConn = nil end
	end
	local endDrag
	local function handleDragMove(changed)
		if not dragging then return end
		if changed.UserInputType == Enum.UserInputType.MouseMovement
			or (changed.UserInputType == Enum.UserInputType.Touch and (activeInput == nil or changed == activeInput)) then
			local raw = Vector2.new(changed.Position.X, changed.Position.Y)
			if changed.UserInputType == Enum.UserInputType.Touch then
				local okMl, ml = pcall(function() return UserInputService:GetMouseLocation() end)
				if okMl and typeof(ml) == "Vector2" and ml.Magnitude > 0 then
					local inset = getGuiInset()
					if (ml - raw).Magnitude <= 5 then
						dragOffset = Vector2.zero; CalibratedTouchOffset = Vector2.zero
					elseif inset.Magnitude > 0 and (ml - (raw + inset)).Magnitude <= 5 then
						dragOffset = inset; CalibratedTouchOffset = inset
					end
				end
			end
			if lastDragRaw == raw and lastDragOffset == dragOffset then return end
			lastDragRaw = raw; lastDragOffset = dragOffset
			updateDrag(changed)
		end
	end
	local function beginDrag(kind, input, refGui, hitBtn)
		if dragging then return end
		dragging = kind; activeInput = input
		dragOffset = detectPointerOffset(input, refGui)
		lastDragRaw = nil; lastDragOffset = nil
		self._page.ScrollingEnabled = false
		updateDrag(input)
		untrackDrag()
		if hitBtn then
			hitMoveConn = hitBtn.InputChanged:Connect(handleDragMove)
		end
		dragMoveConn = UserInputService.InputChanged:Connect(handleDragMove)
		dragEndConn = UserInputService.InputEnded:Connect(function(ended)
			if not dragging or not activeInput then return end
			local same = ended == activeInput
				or (ended.UserInputType == Enum.UserInputType.MouseButton1
					and activeInput.UserInputType == Enum.UserInputType.MouseButton1)
				or (ended.UserInputType == Enum.UserInputType.Touch
					and activeInput.UserInputState == Enum.UserInputState.End)
			if same then endDrag() end
		end)
	end
	function endDrag()
		untrackDrag()
		if not dragging then return end
		dragging = nil; activeInput = nil; dragOffset = nil; lastDragRaw = nil; lastDragOffset = nil
		self._page.ScrollingEnabled = true
	end
	svHit.InputBegan:Connect(function(input)
		if isPointer(input) then beginDrag("sv", input, svSquare, svHit) end
	end)
	hueHit.InputBegan:Connect(function(input)
		if isPointer(input) then beginDrag("hue", input, hueBar, hueHit) end
	end)
	header.InputBegan:Connect(function(input)
		if isPointer(input) then detectPointerOffset(input, header) end
	end)
	table.insert(self._connections, { Disconnect = function() untrackDrag(); endDrag() end })

	-- Campo HEX
	hexBox.Focused:Connect(function()
		tween(hexStroke, Anim.Fast, { Color = accent(), Transparency = 0 })
	end)
	hexBox.FocusLost:Connect(function()
		tween(hexStroke, Anim.Fast, { Color = Theme.StrokeSoft, Transparency = 0 })
		local parsed = parseHex(hexBox.Text)
		if parsed then object:Set(parsed) else hexBox.Text = toHex(current) end
	end)

	-- Abrir / fechar
	local function setExpanded(value, animate, noScroll)
		value = value == true
		if value == expanded then return end
		expanded = value
		tween(rootStroke, Anim.Fast, { Color = expanded and accentBorder(0.6) or Theme.StrokeSoft, Transparency = 0 })
		local doAnim = animate and not State.LowPerformance
		if value then
			win:_closeDropdowns(token)
			win._openDropdowns[token] = true
			panel.Visible = true
			local ph = contentHeight()
			if doAnim then
				panel.GroupTransparency = 1
				panelScale.Scale = 0.98
				panel.Position = UDim2.fromOffset(0, m.Row - 4)
				tween(panel, Anim.Fast, {
					Size = UDim2.new(1, 0, 0, ph),
					Position = UDim2.fromOffset(0, m.Row),
					GroupTransparency = 0,
				})
				tween(panelScale, Anim.Fast, { Scale = 1 })
				tween(root, Anim.Fast, { Size = UDim2.new(1, 0, 0, m.Row + ph) })
				tween(chevron.Instance, Anim.Fast, { Rotation = 180 })
			else
				panel.GroupTransparency = 0
				panelScale.Scale = 1
				panel.Position = UDim2.fromOffset(0, m.Row)
				panel.Size = UDim2.new(1, 0, 0, ph)
				root.Size = UDim2.new(1, 0, 0, m.Row + ph)
				chevron.Instance.Rotation = 180
			end
			if not noScroll then
				task.delay(0.12, function()
					if expanded and root.Parent then
						self:_scrollIntoView(root, m.Row + contentHeight())
					end
				end)
			end
		else
			endDrag()
			win._openDropdowns[token] = nil
			if doAnim then
				tween(panel, Anim.Fast, { Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1 })
				tween(panelScale, Anim.Fast, { Scale = 0.98 })
				tween(root, Anim.Fast, { Size = UDim2.new(1, 0, 0, m.Row) })
				tween(chevron.Instance, Anim.Fast, { Rotation = 0 })
				task.delay(Anim.Fast + 0.03, function()
					if not expanded then
						panel.Visible = false
						panelScale.Scale = 1
						panel.GroupTransparency = 0
					end
				end)
			else
				panel.Size = UDim2.new(1, 0, 0, 0)
				root.Size = UDim2.new(1, 0, 0, m.Row)
				chevron.Instance.Rotation = 0
				panel.Visible = false
				panelScale.Scale = 1
				panel.GroupTransparency = 0
			end
		end
	end
	function object:Open() setExpanded(true, true) end
	function object:Close() setExpanded(false, true) end
	function object:Toggle() setExpanded(not expanded, true) end
	function object:IsOpen() return expanded end

	header.Activated:Connect(function() setExpanded(not expanded, true) end)
	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input)
		if not expanded or not isPointer(input) then return end
		local raw = Vector2.new(input.Position.X, input.Position.Y)
		local inset = getGuiInset()
		if not pointInGuiBounds(raw, root) and not pointInGuiBounds(raw + inset, root) then
			setExpanded(false, true)
		end
	end))

	win:_onLayout(function()
		root.Size = UDim2.new(1, 0, 0, expanded and (m.Row + contentHeight()) or m.Row)
		header.Size = UDim2.new(1, 0, 0, m.Row)
		panel.Position = UDim2.fromOffset(0, m.Row)
		nameLabel.TextSize = m.Text
		hexBox.TextSize = m.Text
		local leftX = 14
		if lead then
			local sz = iconSizeOf(lead, m.Icon)
			lead:SetSize(sz); leftX = 14 + sz + 10
		end
		nameLabel.Position = UDim2.fromOffset(leftX, 0)
		nameLabel.Size = UDim2.new(1, -leftX - 80, 1, 0)
		chevron:SetSize(m.Icon - 2)
		chevron.Instance.Position = UDim2.new(1, -14, 0.5, 0)
		previewBadge.Position = UDim2.new(1, -38, 0.5, 0)
	end)
	win:_onAccent(function(animate)
		paintUI()
	end)
	paintUI()
	self:_register("ColorPicker", root, function() return nameLabel.Text end, { FlashTarget = header })
	return object
end
-- ============================================================
-- AetherUI v2.3.0 - Parte 3/3
-- Tab internals, Window (open animation + close confirmation + search),
-- Settings, API publica
-- ============================================================

----------------------------------------------------------------
-- Metodos internos de Tab
----------------------------------------------------------------
function Tab:_applyMetrics()
	local m = self._metrics
	self._label.TextSize = m.Text
	self._label.Position = UDim2.fromOffset(m.SideRow, 0)
	self._label.Size = UDim2.new(1, -m.SideRow, 1, 0)
	if self._icon then
		local iconPx = iconSizeOf(self._icon, m.Icon)
		self._icon:SetSize(iconPx)
		self._icon.Instance.Position = UDim2.new(0, math.floor((m.SideRow - iconPx) / 2), 0.5, 0)
	end
	self._pagePadding.PaddingLeft = UDim.new(0, m.Pad)
	self._pagePadding.PaddingTop = UDim.new(0, m.Pad)
	self._pagePadding.PaddingRight = UDim.new(0, m.Pad)
	self._pagePadding.PaddingBottom = UDim.new(0, m.Pad)
	self._pageLayout.Padding = UDim.new(0, m.Gap)
	self:_refresh()
end

function Tab:_restScale()
	return 1
end

function Tab:_paint(animate)
	local selected = self._window._selectedTab == self
	local hovering = self._hover == true and not selected
	local textColor = (selected or hovering) and Theme.Text or Theme.SubText
	local iconColor = selected and accentLight() or (hovering and Theme.Text or Theme.SubText)
	local backgroundTransparency = hovering and 0 or 1
	if animate then
		tween(self._button, Anim.Fast, { BackgroundTransparency = backgroundTransparency })
		tween(self._label, Anim.Fast, { TextColor3 = textColor })
		if self._icon and not self._icon.CustomColor then self._icon:Tween(iconColor, Anim.Fast) end
		if self._scaleObj and not self._pressed then
			tween(self._scaleObj, Anim.Fast, { Scale = 1 })
		end
	else
		self._button.BackgroundTransparency = backgroundTransparency
		self._label.TextColor3 = textColor
		if self._icon and not self._icon.CustomColor then self._icon:SetColor(iconColor) end
		if self._scaleObj then self._scaleObj.Scale = 1 end
	end
end

function Tab:_applyCollapse(collapsed, animate)
	local label = self._label
	local m = self._metrics
	self._collapsed = collapsed
	local doAnim = animate and not State.LowPerformance
	if collapsed then
		if doAnim then
			local t = tween(label, Anim.Fast, {
				TextTransparency = 1,
				Position = UDim2.fromOffset(m.SideRow - 8, 0),
			})
			t.Completed:Connect(function()
				if self._collapsed then
					label.Visible = false
					label.Position = UDim2.fromOffset(m.SideRow, 0)
				end
			end)
		else
			label.TextTransparency = 1
			label.Position = UDim2.fromOffset(m.SideRow, 0)
			label.Visible = false
		end
	else
		label.Visible = true
		if doAnim then
			label.TextTransparency = 1
			label.Position = UDim2.fromOffset(m.SideRow - 8, 0)
			tween(label, Anim.Normal, {
				TextTransparency = 0,
				Position = UDim2.fromOffset(m.SideRow, 0),
			})
		else
			label.TextTransparency = 0
			label.Position = UDim2.fromOffset(m.SideRow, 0)
		end
	end
end

----------------------------------------------------------------
-- Janela - helpers de layout e estados
----------------------------------------------------------------
function Window:_onLayout(callback)
	table.insert(self._layoutUpdaters, callback)
	callback()
end
function Window:_onAccent(callback)
	table.insert(self._accentUpdaters, callback)
	callback(false)
end
function Window:_getSize() return getWindowSize(self._metrics) end
function Window:_isCollapsed()
	if self._collapsedManual ~= nil then return self._collapsedManual end
	return self:_getSize().X.Offset < 360
end
function Window:_ordered()
	local list = {}
	for _, tab in ipairs(self._tabs) do
		if not tab._isSettings and not tab._isMenu then table.insert(list, tab) end
	end
	if self._menuTab then table.insert(list, self._menuTab) end
	if self._settingsTab then table.insert(list, self._settingsTab) end
	return list
end

function Window:_layoutSidebar()
	local m = self._metrics
	local y = 0
	local separated = false
	for _, tab in ipairs(self:_ordered()) do
		if (tab._isMenu or tab._isSettings) and not separated then
			separated = true
			y = y + 4
			self._separator.Position = UDim2.new(0, 4, 0, y)
			self._separator.Size = UDim2.new(1, -8, 0, 1)
			y = y + 9
		end
		tab._y = y
		tab._button.Position = UDim2.fromOffset(0, y)
		tab._button.Size = UDim2.new(1, 0, 0, m.SideRow)
		y = y + m.SideRow + m.SideGap
	end
	self._separator.Visible = self._menuTab ~= nil or self._settingsTab ~= nil
	self._list.CanvasSize = UDim2.fromOffset(0, y + 4)
end

function Window:_moveIndicator(animate)
	local tab = self._selectedTab
	local m = self._metrics
	if not tab or tab._y == nil then
		self._highlight.Visible = false
		self._indicator.Visible = false
		return
	end
	local indicatorHeight = math.max(12, math.floor(m.SideRow * 0.5))
	local y = tab._y
	local indicatorY = y + math.floor((m.SideRow - indicatorHeight) / 2)
	local highlightProps = { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, m.SideRow) }
	local indicatorProps = { Position = UDim2.fromOffset(4, indicatorY), Size = UDim2.fromOffset(3, indicatorHeight) }
	local firstShow = not self._highlight.Visible
	self._highlight.Visible = true
	self._indicator.Visible = true
	if animate and not firstShow and not State.LowPerformance then
		tween(self._highlight, Anim.Fast, highlightProps)
		tween(self._indicator, Anim.Fast, indicatorProps)
	else
		for k, v in pairs(highlightProps) do self._highlight[k] = v end
		for k, v in pairs(indicatorProps) do self._indicator[k] = v end
	end
end

function Window:_applyLayout(animate)
	if self._state == "Destroyed" then return end
	local m = self._metrics
	local collapsed = self:_isCollapsed()
	local changed = self._collapsed ~= collapsed
	self._collapsed = collapsed
	local sidebarWidth = collapsed and (m.SideRow + m.SidePad * 2) or m.SideWidth

	self._titleBar.Size = UDim2.new(1, 0, 0, m.Title)
	local tb = m.TitleButton
	local buttonsWidth = 8 + tb * 2 + 6 + 8
	self._menuButton.Size = UDim2.fromOffset(tb, tb)
	self._menuButton.Position = UDim2.new(0, 6, 0.5, 0)
	self._menuIcon:SetSize(m.Icon - 2)
	self._minimizeButton.Size = UDim2.fromOffset(tb, tb)
	self._minimizeButton.Position = UDim2.new(1, -(8 + tb + 6), 0.5, 0)
	self._minimizeIcon:SetSize(m.Icon - 2)
	self._closeButton.Size = UDim2.fromOffset(tb, tb)
	self._closeButton.Position = UDim2.new(1, -8, 0.5, 0)
	self._closeIcon:SetSize(m.Icon - 2)
	local titleX = 6 + tb + 8
	self._titleBadge.Position = UDim2.new(0, titleX, 0.5, 0)
	self._titleBadge.Size = UDim2.fromOffset(tb, tb)
	local labelX = titleX + tb + 6
	self._titleLabel.Position = UDim2.fromOffset(labelX, 0)
	self._titleLabel.Size = UDim2.new(1, -(labelX + buttonsWidth), 1, 0)
	self._titleLabel.TextSize = m.Text + 1
	self._body.Position = UDim2.fromOffset(0, m.Title)
	self._body.Size = UDim2.new(1, 0, 1, -m.Title)

	local sidebarSize = UDim2.new(0, sidebarWidth, 1, 0)
	local contentPosition = UDim2.fromOffset(sidebarWidth, 0)
	local contentSize = UDim2.new(1, -sidebarWidth, 1, 0)
	if animate then
		tween(self._sidebar, Anim.Normal, { Size = sidebarSize })
		tween(self._content, Anim.Normal, { Position = contentPosition, Size = contentSize })
	else
		self._sidebar.Size = sidebarSize
		self._content.Position = contentPosition
		self._content.Size = contentSize
	end
	self._listPadding.PaddingLeft = UDim.new(0, m.SidePad)
	self._listPadding.PaddingRight = UDim.new(0, m.SidePad)
	self._listPadding.PaddingTop = UDim.new(0, 8)
	self._listPadding.PaddingBottom = UDim.new(0, 8)
	self:_layoutSearch(animate)
	self._header.Position = UDim2.fromOffset(m.Pad + 4, 8)
	self._header.Size = UDim2.new(1, -(m.Pad * 2 + 8), 0, m.Header)
	self._header.TextSize = m.Text + 3
	if self._headerDivider then
		self._headerDivider.Position = UDim2.fromOffset(m.Pad + 4, m.Header + 10)
		self._headerDivider.Size = UDim2.new(1, -(m.Pad * 2 + 8), 0, 1)
	end
	self._pages.Position = UDim2.fromOffset(0, m.Header + 14)
	self._pages.Size = UDim2.new(1, 0, 1, -(m.Header + 14))
	self._ball.Size = UDim2.fromOffset(m.Ball, m.Ball)
	self._ball.Position = clampBallPosition(self._ball.Position, m.Ball)

	self:_layoutSidebar()
	for _, tab in ipairs(self._tabs) do tab:_applyCollapse(collapsed, animate and changed) end
	self:_moveIndicator(false)
	for _, tab in ipairs(self._tabs) do tab:_refresh() end
	self:_syncSettings()
end

function Window:_applyMetrics(animate)
	local fresh = computeMetrics(self._compact)
	for key, value in pairs(fresh) do self._metrics[key] = value end
	for _, callback in ipairs(self._layoutUpdaters) do callback() end
	for _, tab in ipairs(self._tabs) do tab:_applyMetrics() end
	self:_applyLayout(animate)
end

function Window:_resize(animate)
	if self._state ~= "Open" and self._state ~= "Opening" then return end
	local size = self:_getSize()
	local position = clampWindowPosition(self._root.Position, size)
	if animate then
		tween(self._root, Anim.Normal, { Size = size, Position = position })
	else
		self._root.Size = size
		self._root.Position = position
	end
	self:_applyLayout(animate)
end

function Window:_refreshAccent(animate)
	for _, callback in ipairs(self._accentUpdaters) do callback(animate) end
	self:_syncSettings()
end

function Window:_applyPerformance()
	local lowPerformance = State.LowPerformance
	if self._shadow then self._shadow.Sync() end
	for _, gradient in ipairs(self._gradients) do
		pcall(function() gradient.Enabled = not lowPerformance end)
	end
	if self._ballStroke then
		self._ballStroke.Transparency = 0
	end
	self:_refreshActivity()
	self:_syncSettings()
end

function Window:_syncSettings()
	local controls = self._settingsControls
	if self._syncing then return end
	self._syncing = true
	if controls then
		controls.Compact:Set(self._compact == true)
		controls.Sidebar:Set(self._collapsed == true)
		controls.LowPerformance:Set(State.LowPerformance == true)
		controls.SyncAccent()
	end
	local menu = self._menuControls
	if menu then
		if menu.SmartPerf then menu.SmartPerf:Set(SmartPerf.Enabled == true, true) end
		if menu.SmartMode then menu.SmartMode:Set(SmartPerf.Config.Mode, true) end
		if menu.SmartIntensity then menu.SmartIntensity:Set(SmartPerf.Config.Intensity, true) end
		if menu.SmartCulling then menu.SmartCulling:Set(SmartPerf.Config.FrustumCulling == true, true) end
		if menu.SmartEffects then menu.SmartEffects:Set(SmartPerf.Config.EffectOptimization == true, true) end
		if menu.SmartLights then menu.SmartLights:Set(SmartPerf.Config.LightOptimization == true, true) end
		if menu.SmartObjects then menu.SmartObjects:Set(SmartPerf.Config.ObjectOptimization == true, true) end
		if menu.SmartCharacters then menu.SmartCharacters:Set(SmartPerf.Config.CharacterOptimization == true, true) end
		if menu.SmartCombat then menu.SmartCombat:Set(SmartPerf.Config.CombatProtection == true, true) end
		if menu.SmartCleanup then menu.SmartCleanup:Set(SmartPerf.Config.EffectCleanup == true, true) end
	end
	self._syncing = false
end

function Window:_selectTab(tab, animate)
	if self._selectedTab == tab then return end
	local previous = self._selectedTab
	self._selectedTab = tab
	self:_closeDropdowns()
	local doAnim = animate and not State.LowPerformance
	local direction = 1
	if previous and previous._y and tab._y and tab._y < previous._y then direction = -1 end
	for _, other in ipairs(self._tabs) do
		if other ~= tab then
			if doAnim and other == previous and other._holder.Visible then
				if other._holderScale then
					tween(other._holderScale, Anim.Fast, { Scale = 0.97 })
				end
				local fade = tween(other._holder, Anim.Fast, {
					GroupTransparency = 1,
					Position = UDim2.fromOffset(0, -10 * direction),
				})
				fade.Completed:Connect(function(playbackState)
					if playbackState == Enum.PlaybackState.Completed and self._selectedTab ~= other then
						other._holder.Visible = false
						other._holder.Position = UDim2.fromOffset(0, 0)
						if other._holderScale then other._holderScale.Scale = 1 end
					end
				end)
			else
				other._holder.Visible = false
				other._holder.Position = UDim2.fromOffset(0, 0)
				if other._holderScale then other._holderScale.Scale = 1 end
			end
		end
		other:_paint(animate)
	end
	local metrics = self._metrics
	self._header.Text = tab._name
	if doAnim then
		self._header.TextTransparency = 1
		self._header.Position = UDim2.fromOffset(metrics.Pad + 12, 8)
		tween(self._header, Anim.Normal + 0.05, {
			TextTransparency = 0, Position = UDim2.fromOffset(metrics.Pad + 4, 8),
		})
	else
		self._header.TextTransparency = 0
		self._header.Position = UDim2.fromOffset(metrics.Pad + 4, 8)
	end
	local holder = tab._holder
	if tab._isMenu then
		samplePerfSnapshot(nil, nil, false)
		self:_updatePerfViews()
	end
	holder.Visible = true
	tab:_refresh()
	if doAnim then
		holder.Position = UDim2.fromOffset(0, 12 * direction)
		holder.GroupTransparency = 1
		if tab._holderScale then
			tab._holderScale.Scale = 0.96
			tween(tab._holderScale, Anim.Normal + 0.05, { Scale = 1 })
		end
		tween(holder, Anim.Normal + 0.05, {
			Position = UDim2.fromOffset(0, 0), GroupTransparency = 0,
		})
	else
		holder.Position = UDim2.fromOffset(0, 0)
		holder.GroupTransparency = 0
		if tab._holderScale then tab._holderScale.Scale = 1 end
	end
	self:_moveIndicator(animate)
	self:_clearSearch()
	self:_refreshActivity()
end

function Window:SelectTab(target)
	for _, tab in ipairs(self._tabs) do
		if tab == target or tab._name == target then
			self:_selectTab(tab, true)
			return
		end
	end
end

----------------------------------------------------------------
-- Search global (v2.3.0)
-- Indexa abas, secoes, rotulos, botoes, toggles, sliders, dropdowns
-- (e suas opcoes), cores e configuracoes. Resultados instantaneos e
-- clicaveis: abrem a aba, rolam ate o item e o destacam.
----------------------------------------------------------------
local KindInfo = {
	Tab = { Label = "Aba", Words = "aba tab pagina guia menu" },
	Section = { Label = "Secao", Words = "secao section grupo categoria" },
	Label = { Label = "Texto", Words = "texto label rotulo informacao info" },
	Button = { Label = "Botao", Words = "botao button funcao function acao action executar" },
	Toggle = { Label = "Toggle", Words = "toggle alternar interruptor switch ativar desativar ligar" },
	Slider = { Label = "Slider", Words = "slider controle deslizante barra valor ajuste" },
	Dropdown = { Label = "Dropdown", Words = "dropdown lista menu selecao selecionar escolher" },
	MultiDropdown = { Label = "Multi", Words = "multi multidropdown dropdown lista multipla selecao varios" },
	RadioGroup = { Label = "Radio", Words = "radio grupo group selecao unica opcao escolher" },
	ColorPicker = { Label = "Cor", Words = "cor color picker seletor paleta tema" },
	Option = { Label = "Opcao", Words = "opcao option item" },
}
local SettingsWords = " configuracoes configuracao settings config opcoes preferencias ajustes"
local MenuWords = " menu desempenho performance fps ping uptime grafico historico smart antilag anti-lag otimizacao"

function Window:_collectSearch(query)
	local q = normalizeText(query)
	q = string.match(q, "^%s*(.-)%s*$") or ""
	if q == "" then return {} end
	local tokens = {}
	for token in string.gmatch(q, "%S+") do table.insert(tokens, token) end

	local results, seq = {}, 0
	local function evaluate(name, extra)
		local n = normalizeText(name)
		local hay = n .. " " .. extra
		for _, token in ipairs(tokens) do
			if not string.find(hay, token, 1, true) then return nil end
		end
		if n == q then return 100 end
		if string.sub(n, 1, #q) == q then return 90 end
		if string.find(" " .. n, " " .. q, 1, true) then return 80 end
		if string.find(n, q, 1, true) then return 70 end
		for _, token in ipairs(tokens) do
			if not string.find(n, token, 1, true) then return 30 end
		end
		return 55
	end
	local function add(item, score, tabIndex, order)
		seq = seq + 1
		item.Score = score; item.TabIndex = tabIndex; item.Order = order; item.Seq = seq
		table.insert(results, item)
	end

	for tabIndex, tab in ipairs(self:_ordered()) do
		local extraWords = tab._isSettings and SettingsWords or (tab._isMenu and MenuWords or "")
		local tabScore = evaluate(tab._name, normalizeText(KindInfo.Tab.Words .. extraWords))
		if tabScore then
			add({
				Name = tab._name,
				Path = tab._isMenu and "Menu" or (tab._isSettings and "Configuracoes" or "Menu lateral"),
				KindLabel = KindInfo.Tab.Label, Kind = "Tab", Tab = tab,
			}, tabScore, tabIndex, -1)
		end
		for _, entry in ipairs(tab._entries) do
			local name = tostring(entry.GetName())
			local info = KindInfo[entry.Kind] or KindInfo.Label
			local path = tab._name
			if entry.SectionEntry then path = path .. " / " .. tostring(entry.SectionEntry.GetName()) end
			local score = evaluate(name, normalizeText(path .. " " .. info.Words .. extraWords))
			if score then
				add({
					Name = name, Path = path, KindLabel = info.Label,
					Kind = entry.Kind, Tab = tab, Entry = entry,
				}, score, tabIndex, entry.Order)
			end
			if entry.Options then
				local optionWords = normalizeText(KindInfo.Option.Words)
				for optionIndex, option in ipairs(entry.Options) do
					local optionScore = evaluate(tostring(option), optionWords)
					if optionScore then
						add({
							Name = tostring(option), Path = path .. " / " .. name,
							KindLabel = KindInfo.Option.Label, Kind = "Option",
							Tab = tab, Entry = entry, OptionIndex = optionIndex,
						}, optionScore - 5, tabIndex, entry.Order + optionIndex / 1000)
					end
				end
			end
		end
	end

	table.sort(results, function(a, b)
		if a.Score ~= b.Score then return a.Score > b.Score end
		if a.TabIndex ~= b.TabIndex then return a.TabIndex < b.TabIndex end
		if a.Order ~= b.Order then return a.Order < b.Order end
		return a.Seq < b.Seq
	end)
	while #results > 60 do table.remove(results) end
	return results
end

-- Barra de pesquisa acima das abas + lista de abas logo abaixo dela.
function Window:_layoutSearch(animate)
	local bar = self._searchBar
	if not bar then return end
	local m = self._metrics
	local collapsed = self._collapsed == true
	local sidebarWidth = collapsed and (m.SideRow + m.SidePad * 2) or m.SideWidth
	local height = m.Compact and 26 or (m.Mobile and 32 or 28)
	local width = sidebarWidth - m.SidePad * 2
	local active = self._searchFocused == true or (self._searchBox and self._searchBox.Text ~= "")
	if collapsed and active then
		width = math.max(width, math.min(210, self._root.Size.X.Offset - m.SidePad * 2))
	end
	self._searchBarW, self._searchBarH = width, height
	local size = UDim2.fromOffset(width, height)
	bar.Position = UDim2.fromOffset(m.SidePad, 6)
	if animate then tween(bar, Anim.Fast, { Size = size }) else bar.Size = size end
	local top = 6 + height + 6
	self._list.Position = UDim2.fromOffset(0, top)
	self._list.Size = UDim2.new(1, -1, 1, -top)
	self._searchBox.TextSize = m.Text - 1
	self:_placeSearchPopup()
end

function Window:_placeSearchPopup()
	local popup = self._searchPopup
	if not popup or not popup.Visible then return end
	local m = self._metrics
	local bodyW = self._root.Size.X.Offset
	local bodyH = self._root.Size.Y.Offset - m.Title
	local top = 6 + (self._searchBarH or 28) + 6
	local width = math.min(math.max(self._searchBarW or 120, 230), bodyW - m.SidePad * 2)
	local contentH = (self._searchRows or 1) * ((self._searchRowH or 36) + 2) + 8
	local maxH = math.max(bodyH - top - 8, 48)
	popup.Position = UDim2.fromOffset(m.SidePad, top)
	popup.Size = UDim2.fromOffset(math.max(width, 120), math.min(contentH, maxH, 280))
end

function Window:_closeDropdowns(except)
	local open = self._openDropdowns
	if not open then return end
	for token in pairs(open) do
		if token ~= except then token.Close() end
	end
end

-- Destaque temporario no elemento encontrado.
function Window:_flash(target)
	if not target or not target.Parent then return end
	local overlay = create("Frame", {
		Name = "SearchFlash", Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = accent(), BackgroundTransparency = 0.55,
		ZIndex = 9, Parent = target,
	})
	addCorner(overlay, 8)
	local stroke = addStroke(overlay, accentLight(), 0, 1.5)
	tween(overlay, 1.2, { BackgroundTransparency = 1 })
	local t = tween(stroke, 1.2, { Transparency = 1 })
	t.Completed:Connect(function()
		if overlay.Parent then overlay:Destroy() end
	end)
end

-- Abre a aba do resultado, rola ate o elemento e o destaca.
function Window:_goToEntry(item)
	if self._state == "Destroyed" then return end
	local tab = item.Tab
	if self._selectedTab ~= tab then self:_selectTab(tab, true) end
	local entry = item.Entry
	local page = tab._page
	if not entry then
		tween(page, Anim.Smooth, { CanvasPosition = Vector2.new(0, 0) })
		return
	end
	if item.OptionIndex and entry.Open then entry.Open() end
	task.delay(0.1, function()
		if self._state == "Destroyed" or not entry.Instance.Parent then return end
		local y = tab:_offsetOf(entry.Instance)
		tween(page, Anim.Smooth, { CanvasPosition = Vector2.new(0, math.max(0, y - self._metrics.Pad - 4)) })
		local target = entry.FlashTarget or entry.Instance
		if item.OptionIndex and entry.RowFor then
			if entry.ScrollToRow then entry.ScrollToRow(item.OptionIndex) end
			target = entry.RowFor(item.OptionIndex) or target
		end
		self:_flash(target)
	end)
end

function Window:_clearSearch()
	local box = self._searchBox
	if not box then return end
	if box.Text ~= "" then box.Text = "" end
	if box:IsFocused() then box:ReleaseFocus() end
	self:_renderSearchResults("")
	self:_layoutSearch(true)
end

function Window:_pickSearchResult(item)
	self:_clearSearch()
	self:_goToEntry(item)
end

function Window:_renderSearchResults(query)
	local popup, scroll = self._searchPopup, self._searchScroll
	if not popup then return end
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	self._searchResults = {}
	if normalizeText(query) == "" then
		popup.Visible = false
		self._searchRows = 0
		return
	end
	local m = self._metrics
	local results = self:_collectSearch(query)
	self._searchResults = results
	local rowH = (m.Compact and 34 or 40) + (m.Mobile and 4 or 0)
	self._searchRowH = rowH
	self._searchRows = math.max(#results, 1)

	if #results == 0 then
		create("TextLabel", {
			Name = "Empty", BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, rowH), Text = "Nenhum resultado",
			Font = Theme.Font, TextSize = m.Text - 1, TextColor3 = Theme.Muted, Parent = scroll,
		})
	end
	for i, item in ipairs(results) do
		local btn = create("TextButton", {
			Name = "R" .. i, LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, rowH),
			BackgroundColor3 = Theme.Element, BackgroundTransparency = 0,
			AutoButtonColor = false, Text = "", Parent = scroll,
		})
		addCorner(btn, Radius.Control)
		create("TextLabel", {
			Name = "Name", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 3), Size = UDim2.new(1, -86, 0, math.floor(rowH * 0.5)),
			Text = item.Name, Font = Theme.Font, TextSize = m.Text - 1,
			TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		})
		create("TextLabel", {
			Name = "Path", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, math.floor(rowH * 0.5)),
			Size = UDim2.new(1, -20, 0, math.floor(rowH * 0.5) - 3),
			Text = item.Path, Font = Theme.Font, TextSize = m.Text - 3,
			TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		})
		create("TextLabel", {
			Name = "Kind", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1,
			Position = UDim2.new(1, -10, 0, 3), Size = UDim2.fromOffset(70, math.floor(rowH * 0.5)),
			Text = item.KindLabel, Font = Theme.FontBold, TextSize = m.Text - 3,
			TextColor3 = accentLight(), TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
		})
		btn.MouseEnter:Connect(function()
			tween(btn, Anim.Fast, { BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0 })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, Anim.Fast, { BackgroundColor3 = Theme.Element, BackgroundTransparency = 0 })
		end)
		btn.Activated:Connect(function() self:_pickSearchResult(item) end)
	end
	popup.Visible = true
	self:_placeSearchPopup()
end

----------------------------------------------------------------
-- Tab lateral (com hover + bounce)
----------------------------------------------------------------
function Window:_createTab(label, iconSpec, isSettings, iconOpts, isMenu)
	local m = self._metrics
	if iconSpec == nil then iconSpec = guessIcon(label) end
	local button = create("TextButton", {
		Name = "Tab_" .. label, Size = UDim2.new(1, 0, 0, m.SideRow),
		BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 1,
		AutoButtonColor = false, Text = "", ClipsDescendants = true,
		ZIndex = 2, Parent = self._list,
	})
	addCorner(button, Radius.Card)
	local buttonScale = create("UIScale", { Parent = button })
	local hoverStroke = create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Theme.Stroke, Thickness = 1, Transparency = 1, Parent = button,
	})
	local icon = createIcon(iconSpec, button, m.Icon, Theme.SubText, iconOpts)
	if icon then
		local iconPx = iconSizeOf(icon, m.Icon)
		icon.Instance.AnchorPoint = Vector2.new(0, 0.5)
		icon.Instance.Position = UDim2.new(0, math.floor((m.SideRow - iconPx) / 2), 0.5, 0)
	end
	local nameLabel = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(m.SideRow, 0),
		Size = UDim2.new(1, -m.SideRow, 1, 0),
		Text = label, Font = Theme.Font, TextSize = m.Text,
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = button,
	})
	local holder = create("CanvasGroup", {
		Name = "Page_" .. label, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0), GroupTransparency = 1,
		Visible = false, Parent = self._pages,
	})
	local holderScale = create("UIScale", { Scale = 1, Parent = holder })
	local page = create("ScrollingFrame", {
		Name = "Scroll", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 2, ScrollBarImageColor3 = accent(),
		ScrollBarImageTransparency = 0.25,
		VerticalScrollBarInset = Enum.ScrollBarInset.None, Parent = holder,
	})
	local pagePadding = addPadding(page, m.Pad, m.Pad, m.Pad, m.Pad)
	local pageLayout = create("UIListLayout", {
		Padding = UDim.new(0, m.Gap), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page,
	})
	local tab = setmetatable({
		_window = self, _name = label,
		_isSettings = isSettings == true,
		_isMenu = isMenu == true,
		_page = page, _pagePadding = pagePadding, _pageLayout = pageLayout,
		_holder = holder, _holderScale = holderScale, _button = button, _label = nameLabel, _icon = icon,
		_metrics = m, _connections = self._connections, _order = 0,
		_entries = {}, _currentSection = nil,
		_hover = false, _collapsed = self._collapsed == true, _hoverStroke = hoverStroke,
	}, Tab)
	tab._updateCanvas = bindCanvas(page, pageLayout, "Y", 20)
	table.insert(self._tabs, tab)
	tab._scaleObj = buttonScale
	tab._pressed = false

	button.MouseEnter:Connect(function()
		tab._hover = true; tab:_paint(true)
		if self._selectedTab ~= tab then
			tween(hoverStroke, Anim.Fast, { Transparency = 0 })
		end
	end)
	button.MouseLeave:Connect(function()
		tab._hover = false; tab._pressed = false; tab:_paint(true)
		tween(hoverStroke, Anim.Fast, { Transparency = 1 })
	end)
	button.MouseButton1Down:Connect(function()
		tab._pressed = true
		tween(buttonScale, Anim.Micro, { Scale = 0.98 })
	end)
	button.MouseButton1Up:Connect(function()
		tab._pressed = false
		tween(buttonScale, Anim.Fast, { Scale = 1 })
	end)
	button.InputBegan:Connect(function(input)
		if isPointer(input) then detectPointerOffset(input, button) end
	end)
	button.Activated:Connect(function() self:_selectTab(tab, true) end)
	self:_onAccent(function(animate)
		page.ScrollBarImageColor3 = accent()
		tab:_paint(animate)
	end)
	tab:_applyCollapse(self._collapsed == true, false)
	self:_layoutSidebar()
	if not isSettings and not isMenu then
		self._userTabs = self._userTabs + 1
		if self._userTabs == 1 then self:_selectTab(tab, false) end
	end
	tab:_paint(false)
	self:_moveIndicator(false)
	return tab
end

function Window:AddTab(name, icon)
	local iconOpts = nil
	if typeof(name) == "table" then
		iconOpts = { Size = name.IconSize, Color = name.IconColor }
		icon = name.Icon or icon
		name = name.Name or name.Title
	end
	return self:_createTab(tostring(name or "Tab"), icon, false, iconOpts)
end
function Window:GetMenuTab() return self._menuTab end
function Window:GetSettingsTab() return self._settingsTab end

----------------------------------------------------------------
-- Aba Menu (Telemetria em tempo real + Grafico FPS + Smart Performance)
----------------------------------------------------------------
function Window:_buildMenu()
	local tab = self:_createTab("Menu", "activity", false, nil, true)
	self._menuTab = tab
	self:_layoutSidebar()
	self:_moveIndicator(false)

	tab:AddSection({ Text = "Desempenho em Tempo Real", Icon = "activity" })

	local page = tab._page
	local m = self._metrics

	local metricsCard = create("Frame", {
		Name = "MenuMetricsRow", LayoutOrder = tab:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Compact and 54 or 60),
		BackgroundTransparency = 1, Parent = page,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = metricsCard,
	})

	local function makeMetricTile(order, titleStr, initialVal)
		local tile = create("Frame", {
			Name = "Tile_" .. titleStr, LayoutOrder = order,
			Size = UDim2.new(1 / 3, -4, 1, 0),
			BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
			Parent = metricsCard,
		})
		addCorner(tile, Radius.Card)
		addStroke(tile, Theme.StrokeSoft, 0, 1)
		create("TextLabel", {
			Name = "Caption", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(9, 6), Size = UDim2.new(1, -18, 0, 12),
			Text = titleStr, Font = Theme.FontBold, TextSize = math.max(9, m.Text - 4),
			TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = tile,
		})
		local valLabel = create("TextLabel", {
			Name = "Value", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(9, 20), Size = UDim2.new(1, -18, 0, 18),
			Text = initialVal, Font = Theme.FontBold, TextSize = m.Text + 2,
			TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = tile,
		})
		local subLabel = create("TextLabel", {
			Name = "Sub", BackgroundTransparency = 1,
			Position = UDim2.fromOffset(9, 39), Size = UDim2.new(1, -18, 0, 12),
			Text = "--", Font = Theme.Font, TextSize = math.max(9, m.Text - 4),
			TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = tile,
		})
		return valLabel, subLabel
	end

	local fpsVal, fpsSub = makeMetricTile(1, "FPS", "60")
	local pingVal, pingSub = makeMetricTile(2, "PING", "-- ms")
	local uptimeVal, uptimeSub = makeMetricTile(3, "UPTIME", "00:00")

	local graphCard = create("Frame", {
		Name = "FpsGraphCard", LayoutOrder = tab:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Compact and 104 or 116),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		Parent = page,
	})
	addCorner(graphCard, Radius.Card)
	local graphStroke = addStroke(graphCard, Theme.StrokeSoft, 0, 1)

	create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(11, 7), Size = UDim2.new(0.45, -11, 0, 16),
		Text = "Historico de FPS", Font = Theme.FontBold, TextSize = m.Text - 1,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = graphCard,
	})
	local graphSummary = create("TextLabel", {
		Name = "Summary", BackgroundTransparency = 1,
		Position = UDim2.new(0.45, 0, 0, 7), Size = UDim2.new(0.55, -11, 0, 16),
		Text = "Min --  •  Med --  •  Max --", Font = Theme.Font, TextSize = math.max(9, m.Text - 3),
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = graphCard,
	})

	local plot = create("Frame", {
		Name = "Plot", BackgroundColor3 = Theme.BackgroundDeep, BackgroundTransparency = 0,
		Position = UDim2.fromOffset(10, 28), Size = UDim2.new(1, -20, 1, -38),
		ClipsDescendants = true, Parent = graphCard,
	})
	addCorner(plot, Radius.Control)
	addStroke(plot, Theme.StrokeSoft, 0, 1)

	-- Guias de referencia (30 FPS e 60 FPS)
	create("Frame", {
		Name = "Guide60", BackgroundColor3 = Theme.Success, BackgroundTransparency = 0.78,
		Position = UDim2.new(0, 0, 0.16, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 1, Parent = plot,
	})
	create("Frame", {
		Name = "Guide30", BackgroundColor3 = Theme.Warning, BackgroundTransparency = 0.78,
		Position = UDim2.new(0, 0, 0.58, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 1, Parent = plot,
	})

	local barCount = PerfMonitor.HistoryMax
	local barHolders = create("Frame", {
		Name = "Bars", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8),
		ZIndex = 2, Parent = plot,
	})
	local graphBars = {}
	for i = 1, barCount do
		local bar = create("Frame", {
			Name = "B" .. i, AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new((i - 1) / barCount, 1, 1, 0),
			Size = UDim2.new(1 / barCount, -2, 0.1, 0),
			BackgroundColor3 = Theme.Success, BackgroundTransparency = 0,
			ZIndex = 2, Parent = barHolders,
		})
		addCorner(bar, 2)
		graphBars[i] = bar
	end

	tab:AddSection({ Text = "Smart Performance (Anti-Lag)", Icon = "shield" })

	local toggleSmartPerf = tab:AddToggle({
		Name = "Smart Performance", Icon = "bolt", Default = SmartPerf.Enabled == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformance(value)
		end,
	})

	local dropMode = tab:AddDropdown({
		Name = "Modo Anti-Lag",
		Options = { "Automatico", "Leve", "Equilibrado", "Agressivo", "Ultra" },
		Default = SmartPerf.Config.Mode,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ Mode = value })
		end,
	})

	local sliderIntensity = tab:AddSlider({
		Name = "Intensidade da Otimizacao",
		Min = 20, Max = 100, Step = 5, Suffix = "%",
		Default = SmartPerf.Config.Intensity,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ Intensity = value })
		end,
	})

	local toggleCulling = tab:AddToggle({
		Name = "Culling por Visibilidade & Oclusao", Icon = "eye", Default = SmartPerf.Config.FrustumCulling == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ FrustumCulling = value })
		end,
	})

	local toggleEffects = tab:AddToggle({
		Name = "Otimizar Particulas & Efeitos", Icon = "flame", Default = SmartPerf.Config.EffectOptimization == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ EffectOptimization = value })
		end,
	})

	local toggleLights = tab:AddToggle({
		Name = "Otimizar Iluminacao", Icon = "sun", Default = SmartPerf.Config.LightOptimization == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ LightOptimization = value })
		end,
	})

	local toggleObjects = tab:AddToggle({
		Name = "Otimizar Objetos & Decals", Icon = "grid", Default = SmartPerf.Config.ObjectOptimization == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ ObjectOptimization = value })
		end,
	})

	local toggleCharacters = tab:AddToggle({
		Name = "Otimizar Personagens Distantes", Icon = "user", Default = SmartPerf.Config.CharacterOptimization == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ CharacterOptimization = value })
		end,
	})

	local toggleCombat = tab:AddToggle({
		Name = "Protecao de Combate", Icon = "shield", Default = SmartPerf.Config.CombatProtection == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ CombatProtection = value })
		end,
	})

	local toggleCleanup = tab:AddToggle({
		Name = "Limpeza Segura de Efeitos", Icon = "trash", Default = SmartPerf.Config.EffectCleanup == true,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetSmartPerformanceConfig({ EffectCleanup = value })
		end,
	})

	local smartCard = create("Frame", {
		Name = "SmartPerfCard", LayoutOrder = tab:_nextOrder(),
		Size = UDim2.new(1, 0, 0, m.Compact and 100 or 108),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		Parent = page,
	})
	addCorner(smartCard, Radius.Card)
	local smartStroke = addStroke(smartCard, Theme.StrokeSoft, 0, 1)

	local smartDot = create("Frame", {
		Name = "Dot", AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0, 16),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = SmartPerf.Enabled and Theme.Success or Theme.Muted,
		Parent = smartCard,
	})
	addCornerScale(smartDot, 0.5)

	local smartHeader = create("TextLabel", {
		Name = "Header", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(26, 7), Size = UDim2.new(1, -38, 0, 18),
		Text = "Anti-Lag Adaptativo: Inativo", Font = Theme.FontBold, TextSize = m.Text - 1,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = smartCard,
	})
	local smartZones = create("TextLabel", {
		Name = "Zones", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 27), Size = UDim2.new(1, -24, 0, 16),
		Text = "Perto: 0  •  Medio: 0  •  Longe: 0  •  Ocultos: 0", Font = Theme.Font, TextSize = m.Text - 2,
		TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = smartCard,
	})
	local smartDetail = create("TextLabel", {
		Name = "Detail", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 45), Size = UDim2.new(1, -24, 0, 16),
		Text = "Otimizados: 0  •  Protegidos: 0  •  Oclusos: 0  •  Limpos: 0", Font = Theme.Font, TextSize = m.Text - 3,
		TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = smartCard,
	})
	local smartRadii = create("TextLabel", {
		Name = "Radii", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 62), Size = UDim2.new(1, -24, 0, 15),
		Text = "Raios: 155 / 330 / 560 st  •  Ciclo: 180 ms  •  Cache: 0", Font = Theme.Font, TextSize = math.max(9, m.Text - 4),
		TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = smartCard,
	})
	create("TextLabel", {
		Name = "Guarantee", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 79), Size = UDim2.new(1, -24, 0, 15),
		Text = "Restauracao 1:1 ao voltar a visao, trocar modo ou desligar.",
		Font = Theme.Font, TextSize = math.max(9, m.Text - 4),
		TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = smartCard,
	})

	self:_onAccent(function(animate)
		setProps(graphStroke, { Color = Theme.StrokeSoft }, animate, Anim.Normal)
		setProps(smartStroke, { Color = SmartPerf.Enabled and accentBorder(0.6) or Theme.StrokeSoft }, animate, Anim.Normal)
	end)

	self._menuControls = {
		SmartPerf = toggleSmartPerf,
		SmartMode = dropMode,
		SmartIntensity = sliderIntensity,
		SmartCulling = toggleCulling,
		SmartEffects = toggleEffects,
		SmartLights = toggleLights,
		SmartObjects = toggleObjects,
		SmartCharacters = toggleCharacters,
		SmartCombat = toggleCombat,
		SmartCleanup = toggleCleanup,
		FpsVal = fpsVal, FpsSub = fpsSub,
		PingVal = pingVal, PingSub = pingSub,
		UptimeVal = uptimeVal, UptimeSub = uptimeSub,
		GraphSummary = graphSummary, GraphBars = graphBars,
		SmartDot = smartDot, SmartHeader = smartHeader,
		SmartZones = smartZones, SmartDetail = smartDetail,
		SmartRadii = smartRadii,
		SmartStroke = smartStroke,
	}
	tab:_refresh()
end

----------------------------------------------------------------
-- Configuracoes embutidas (Interface — preservada)
----------------------------------------------------------------
function Window:_buildSettings()
	local tab = self:_createTab("Interface", "settings", true)
	self._settingsTab = tab
	self:_layoutSidebar()
	self:_moveIndicator(false)
	local picker
	local function syncAccent()
		if not picker then return end
		picker:Set(State.Accent, true)
	end
	tab:AddSection({ Text = "Aparencia", Icon = "palette" })
	picker = tab:AddColorPicker({
		Name = "Cor de destaque", Default = State.Accent,
		Callback = function(color)
			if self._syncing then return end
			AetherUI.SetAccent(color)
		end,
	})
	tab:AddSection({ Text = "Interface", Icon = "gauge" })
	local toggleCompact = tab:AddToggle({
		Name = "Modo compacto", Icon = "maximize", Default = self._compact,
		Callback = function(value)
			if self._syncing then return end
			self:SetCompact(value)
		end,
	})
	local toggleSidebar = tab:AddToggle({
		Name = "Sidebar so com icones", Icon = "menu", Default = self._collapsed == true,
		Callback = function(value)
			if self._syncing then return end
			self:SetSidebarCollapsed(value)
		end,
	})
	local toggleLow = tab:AddToggle({
		Name = "Modo baixo desempenho", Icon = "bolt", Default = State.LowPerformance,
		Callback = function(value)
			if self._syncing then return end
			AetherUI.SetLowPerformance(value)
		end,
	})

	tab:AddSection({ Text = "Configuracoes", Icon = "save" })
	local configStatus = tab:AddLabel({
		Text = "Perfil: " .. tostring(self._configFolder or "AetherUI") .. "/" .. tostring(self._configFile or "default") .. ".json",
		Icon = "file",
	})
	tab:AddButton({
		Name = "Salvar configuracao", Icon = "save",
		Callback = function()
			local ok, info = self:SaveConfig()
			if ok then
				configStatus:SetText("Salvo: " .. tostring(info))
				AetherUI.Notify({ Title = "Configuracao salva", Content = "Salvo em " .. tostring(info), Type = "success", Duration = 3 })
			else
				configStatus:SetText("JSON gerado (sem writefile)")
				AetherUI.Notify({ Title = "Aviso de salvamento", Content = tostring(info), Type = "warning", Duration = 5 })
			end
		end,
	})
	tab:AddButton({
		Name = "Carregar configuracao", Icon = "upload",
		Callback = function()
			local ok, info = self:LoadConfig()
			if ok then
				configStatus:SetText("Carregado: " .. tostring(info))
				AetherUI.Notify({ Title = "Configuracao carregada", Content = "Valores restaurados.", Type = "success", Duration = 3 })
			else
				AetherUI.Notify({ Title = "Nao carregado", Content = tostring(info), Type = "warning", Duration = 4 })
			end
		end,
	})
	tab:AddButton({
		Name = "Exportar configuracao (JSON)", Icon = "copy",
		Callback = function()
			local jsonText = self:ExportConfig(false)
			local copied = false
			local okClip = pcall(function()
				local clipFn = (getgenv and getgenv().setclipboard) or setclipboard or toclipboard
				if typeof(clipFn) == "function" then
					clipFn(jsonText)
					copied = true
				end
			end)
			if okClip and copied then
				AetherUI.Notify({ Title = "JSON copiado", Content = "Configuracao exportada para a area de transferencia.", Type = "success", Duration = 3 })
			else
				AetherUI.Notify({ Title = "JSON exportado", Content = "Gerados " .. tostring(#jsonText) .. " bytes via ExportConfig().", Type = "info", Duration = 3 })
			end
		end,
	})
	self._settingsControls = {
		Compact = toggleCompact, Sidebar = toggleSidebar,
		LowPerformance = toggleLow, SyncAccent = syncAccent, ConfigStatus = configStatus,
	}
end

----------------------------------------------------------------
-- API de janela
----------------------------------------------------------------
function Window:SetTitle(text)
	if self._titleLabel then self._titleLabel.Text = tostring(text) end
end
function Window:SetAccent(color) AetherUI.SetAccent(color) end
function Window:GetAccent() return State.Accent end

function Window:SetCompact(value)
	value = value == true
	if self._state == "Destroyed" or self._compact == value then return end
	self._compact = value
	self:_applyMetrics(true)
	self:_resize(true)
end
function Window:GetCompact() return self._compact == true end

function Window:SetSidebarCollapsed(value)
	if self._state == "Destroyed" then return end
	self._collapsedManual = value == true
	self:_applyLayout(true)
end
function Window:GetSidebarCollapsed() return self._collapsed == true end
function Window:ToggleSidebar() self:SetSidebarCollapsed(not (self._collapsed == true)) end

function Window:SetLowPerformance(value) AetherUI.SetLowPerformance(value) end
function Window:GetLowPerformance() return State.LowPerformance end
function Window:Notify(config) return AetherUI.Notify(config) end

----------------------------------------------------------------
-- Save Configuration (Export/Import JSON + Sistema de Arquivos)
----------------------------------------------------------------
local function sanitizeFileName(name)
	local clean = tostring(name or "default"):gsub("[^%w%-%._]", "_")
	if clean == "" then clean = "default" end
	return clean
end

local function getFsApi()
	local env = nil
	if typeof(getgenv) == "function" then
		local ok, res = pcall(getgenv)
		if ok and typeof(res) == "table" then env = res end
	end
	local function resolveFn(name)
		if env and typeof(env[name]) == "function" then return env[name] end
		local ok, fn = pcall(function() return _G and _G[name] end)
		if ok and typeof(fn) == "function" then return fn end
		return nil
	end
	local writeFn = resolveFn("writefile")
	local readFn = resolveFn("readfile")
	local isFileFn = resolveFn("isfile")
	if not writeFn or not readFn then return nil end
	return {
		writefile = writeFn,
		readfile = readFn,
		isfile = isFileFn,
		isfolder = resolveFn("isfolder"),
		makefolder = resolveFn("makefolder"),
		listfiles = resolveFn("listfiles"),
		delfile = resolveFn("delfile"),
	}
end

local function serializeConfigValue(val)
	if typeof(val) == "Color3" then
		return {
			__aetherType = "Color3",
			R = math.round(val.R * 255),
			G = math.round(val.G * 255),
			B = math.round(val.B * 255),
		}
	end
	if typeof(val) == "table" then
		local out = {}
		for k, v in pairs(val) do
			out[k] = serializeConfigValue(v)
		end
		return out
	end
	if typeof(val) == "boolean" or typeof(val) == "number" or typeof(val) == "string" then
		return val
	end
	return nil
end

local function deserializeConfigValue(val)
	if typeof(val) == "table" then
		if val.__aetherType == "Color3" and val.R ~= nil and val.G ~= nil and val.B ~= nil then
			return Color3.fromRGB(tonumber(val.R) or 255, tonumber(val.G) or 255, tonumber(val.B) or 255)
		end
		local out = {}
		for k, v in pairs(val) do
			out[k] = deserializeConfigValue(v)
		end
		return out
	end
	return val
end

function Window:_resolveConfigPath(fileName)
	local folder = sanitizeFileName(self._configFolder or self._guiName or "AetherUI")
	local file = sanitizeFileName(fileName or self._configFile or "default")
	if not string.find(string.lower(file), "%.json$") then
		file = file .. ".json"
	end
	return folder, folder .. "/" .. file
end

function Window:ExportConfig(asTable)
	local payload = {
		Version = AetherUI.Version,
		Meta = {
			Accent = serializeConfigValue(State.Accent),
			Compact = self._compact == true,
			LowPerformance = State.LowPerformance == true,
			SmartPerformance = SmartPerf.Enabled == true,
			SmartPerfConfig = AetherUI.GetSmartPerformanceConfig(),
		},
		Flags = {},
	}
	for flag, obj in pairs(self.Flags or {}) do
		if typeof(obj.Get) == "function" then
			local ok, value = pcall(function() return obj:Get() end)
			if ok and value ~= nil and obj.Type ~= "Label" and obj.Type ~= "Section" and obj.Type ~= "Button" then
				payload.Flags[tostring(flag)] = serializeConfigValue(value)
			end
		end
	end
	if asTable then return payload end
	local ok, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
	if ok then return encoded end
	return "{}"
end

function Window:ImportConfig(dataOrJson, silent)
	local decoded = dataOrJson
	if typeof(dataOrJson) == "string" then
		local ok, res = pcall(function() return HttpService:JSONDecode(dataOrJson) end)
		if not ok or typeof(res) ~= "table" then
			return false, "JSON invalido ou corrompido."
		end
		decoded = res
	end
	if typeof(decoded) ~= "table" then
		return false, "Formato de configuracao invalido."
	end

	local meta = decoded.Meta
	if typeof(meta) == "table" then
		if meta.Accent ~= nil then
			local col = deserializeConfigValue(meta.Accent)
			if typeof(col) == "Color3" then AetherUI.SetAccent(col) end
		end
		if typeof(meta.Compact) == "boolean" then self:SetCompact(meta.Compact) end
		if typeof(meta.LowPerformance) == "boolean" then AetherUI.SetLowPerformance(meta.LowPerformance) end
		if typeof(meta.SmartPerfConfig) == "table" then AetherUI.SetSmartPerformanceConfig(meta.SmartPerfConfig) end
		if typeof(meta.SmartPerformance) == "boolean" then AetherUI.SetSmartPerformance(meta.SmartPerformance) end
	end

	local flagsData = typeof(decoded.Flags) == "table" and decoded.Flags or decoded
	local applied = 0
	for flag, rawVal in pairs(flagsData) do
		local obj = (self.Flags and self.Flags[flag]) or (AetherUI.Flags and AetherUI.Flags[flag])
		if obj and typeof(obj.Set) == "function" then
			local val = deserializeConfigValue(rawVal)
			if val ~= nil then
				pcall(function() obj:Set(val, silent == true) end)
				applied = applied + 1
			end
		end
	end
	self._pendingConfigData = flagsData
	return true, applied
end

function Window:SaveConfig(fileName)
	local fs = getFsApi()
	local json = self:ExportConfig(false)
	if not fs then
		return false, "Sistema de arquivos local (writefile/readfile) indisponivel neste ambiente; use ExportConfig()."
	end
	local folder, fullPath = self:_resolveConfigPath(fileName)
	local ok, err = pcall(function()
		if fs.isfolder and fs.makefolder then
			local exists = fs.isfolder(folder)
			if not exists then fs.makefolder(folder) end
		elseif fs.makefolder then
			pcall(fs.makefolder, folder)
		end
		fs.writefile(fullPath, json)
	end)
	if not ok then
		return false, tostring(err)
	end
	return true, fullPath
end

function Window:LoadConfig(fileName, silent)
	local fs = getFsApi()
	if not fs then
		return false, "Sistema de arquivos local (readfile) indisponivel neste ambiente; use ImportConfig()."
	end
	local _, fullPath = self:_resolveConfigPath(fileName)
	local exists = true
	if fs.isfile then
		local okCheck, res = pcall(fs.isfile, fullPath)
		if okCheck then exists = res == true end
	end
	if not exists then
		return false, "Arquivo de configuracao nao encontrado: " .. fullPath
	end
	local okRead, content = pcall(fs.readfile, fullPath)
	if not okRead or typeof(content) ~= "string" then
		return false, "Falha ao ler arquivo: " .. tostring(content)
	end
	local okImport, detail = self:ImportConfig(content, silent)
	if not okImport then return false, detail end
	return true, fullPath
end

function Window:DeleteConfig(fileName)
	local fs = getFsApi()
	if not fs or not fs.delfile then
		return false, "Funcao delfile indisponivel neste ambiente."
	end
	local _, fullPath = self:_resolveConfigPath(fileName)
	if fs.isfile and not fs.isfile(fullPath) then
		return false, "Arquivo nao existe: " .. fullPath
	end
	local ok, err = pcall(fs.delfile, fullPath)
	if not ok then return false, tostring(err) end
	return true, fullPath
end

function Window:ListConfigs()
	local fs = getFsApi()
	if not fs or not fs.listfiles then return {} end
	local folder = sanitizeFileName(self._configFolder or self._guiName or "AetherUI")
	if fs.isfolder and not fs.isfolder(folder) then return {} end
	local ok, items = pcall(fs.listfiles, folder)
	if not ok or typeof(items) ~= "table" then return {} end
	local names = {}
	for _, entry in ipairs(items) do
		local base = tostring(entry):match("([^/\\]+)$") or tostring(entry)
		local stripped = base:gsub("%.json$", "")
		if stripped ~= "" then table.insert(names, stripped) end
	end
	return names
end

function Window:SaveConfiguration(fileName) return self:SaveConfig(fileName) end
function Window:LoadConfiguration(fileName, silent) return self:LoadConfig(fileName, silent) end
function Window:DeleteConfiguration(fileName) return self:DeleteConfig(fileName) end
function Window:ListConfigurations() return self:ListConfigs() end

function Window:_needsPerfUpdates()
	if self._state == "Destroyed" then return false end
	local openWindow = self._state == "Open" or self._state == "Opening" or self._state == "Restoring"
	if not openWindow or (self._root and not self._root.Visible) then return false end
	if self._menuTab and self._selectedTab == self._menuTab then
		return true
	end
	return false
end

function Window:_updatePerfViews()
	if self._state == "Destroyed" then return end
	local st = PerfMonitor.Stats
	local fpsColor = st.FPS >= 50 and Theme.Success or (st.FPS >= 30 and Theme.Warning or Theme.Danger)

	local menu = self._menuControls
	if menu then
		menu.FpsVal.Text = string.format("%d", st.FPS)
		menu.FpsVal.TextColor3 = fpsColor
		menu.FpsSub.Text = string.format("%.1f ms", st.FrameTimeMs)

		if st.PingMs >= 0 then
			local pingColor = st.PingMs <= 90 and Theme.Success or (st.PingMs <= 160 and Theme.Warning or Theme.Danger)
			menu.PingVal.Text = string.format("%d ms", st.PingMs)
			menu.PingVal.TextColor3 = pingColor
			menu.PingSub.Text = st.PingMs <= 90 and "Estavel" or (st.PingMs <= 160 and "Moderado" or "Alto")
		else
			menu.PingVal.Text = "-- ms"
			menu.PingVal.TextColor3 = Theme.SubText
			menu.PingSub.Text = "Local"
		end

		menu.UptimeVal.Text = formatDurationClock(st.Uptime)
		menu.UptimeSub.Text = string.format("%.0f MB", st.MemoryMB)

		local hist = PerfMonitor.History
		local count = #hist
		local maxCap = #menu.GraphBars
		if count > 0 then
			menu.GraphSummary.Text = string.format("Min %d  •  Med %d  •  Max %d", st.MinFPS, st.AvgFPS, st.MaxFPS)
		else
			menu.GraphSummary.Text = "Aguardando amostras..."
		end
		local ceiling = math.max(70, st.MaxFPS + 8)
		local offset = math.max(0, maxCap - count)
		for i = 1, maxCap do
			local bar = menu.GraphBars[i]
			local sampleIdx = i - offset
			if sampleIdx >= 1 and hist[sampleIdx] then
				local val = hist[sampleIdx]
				local ratio = math.clamp(val / ceiling, 0.08, 1)
				local barColor = val >= 50 and Theme.Success or (val >= 30 and Theme.Warning or Theme.Danger)
				bar.Visible = true
				bar.Size = UDim2.new(1 / maxCap, -2, ratio, 0)
				bar.BackgroundColor3 = barColor
				bar.BackgroundTransparency = (i == maxCap) and 0 or 0.14
			else
				bar.Visible = true
				bar.Size = UDim2.new(1 / maxCap, -2, 0.06, 0)
				bar.BackgroundColor3 = Theme.Stroke
				bar.BackgroundTransparency = 0
			end
		end

		local sp = SmartPerf.Stats
		if sp.Enabled then
			menu.SmartDot.BackgroundColor3 = Theme.Success
			menu.SmartHeader.Text = string.format("%s (%s %d%%)  •  %d FPS", sp.Mode, sp.Profile, sp.IntensityPct, st.FPS)
			menu.SmartZones.Text = string.format("Perto: %d  •  Medio: %d  •  Longe: %d  •  Ocultos: %d", sp.NearCount, sp.MidCount, sp.FarCount, sp.CulledCount)
			menu.SmartDetail.Text = string.format("Otimizados: %d  •  Protegidos: %d  •  Oclusos: %d  •  Limpos: %d", sp.OptimizedCount, sp.ProtectedCount, sp.OccludedCount or 0, sp.CleanedCount)
			if menu.SmartRadii then
				menu.SmartRadii.Text = string.format("Raios: %d/%d/%d st  •  Ciclo: %dms  •  Cache: %d", sp.NearRadius, sp.FarRadius, sp.CullRadius, sp.StepIntervalMs or 180, sp.CachedCount)
			end
			menu.SmartStroke.Color = accentBorder(0.6)
		else
			menu.SmartDot.BackgroundColor3 = Theme.Muted
			menu.SmartHeader.Text = string.format("Inativo (%s %d%%)  •  %d FPS", sp.Mode or "Automatico", SmartPerf.Config.Intensity or 100, st.FPS)
			menu.SmartZones.Text = "Culling por visao/oclusao + LOD + protecao de combate"
			menu.SmartDetail.Text = "Otimizados: 0  •  Protegidos: 0  •  Oclusos: 0  •  Limpos: 0"
			if menu.SmartRadii then
				menu.SmartRadii.Text = string.format("Raios: %d/%d/%d st  •  Ciclo: %dms  •  Cache: 0", sp.NearRadius, sp.FarRadius, sp.CullRadius, sp.StepIntervalMs or 180)
			end
			menu.SmartStroke.Color = Theme.StrokeSoft
		end
	end
end

function Window:GetPerformanceStats()
	return AetherUI.GetPerformanceStats()
end

function Window:_showBall()
	self._ball.Position = clampBallPosition(self._ball.Position, self._metrics.Ball)
	self._ball.Visible = true
	self._ballStroke.Transparency = 0
	if not State.LowPerformance then
		self._ball.BackgroundTransparency = 1
		self._ballScale.Scale = 0.72
		tween(self._ball, Anim.Normal, { BackgroundTransparency = 0 })
		tween(self._ballScale, Anim.Normal, { Scale = 1 })
	else
		self._ball.BackgroundTransparency = 0
		self._ballScale.Scale = 1
	end
end

-- Estado + atividade. Toda mudanca de estado passa por aqui para que o
-- Heartbeat do Performance Monitor ligue e desligue junto com a visibilidade.
function Window:_setState(state)
	if self._state == "Destroyed" and state ~= "Destroyed" then return end
	self._state = state
	self:_refreshActivity()
end

function Window:_refreshActivity()
	refreshPerfSubscription()
end

-- Minimizar/Restaurar: maquina de estados por TOKEN + timers. Nao depende de
-- Tween.Completed (era cancelado por tweens concorrentes e deixava o estado
-- preso em "Minimizing"/"Restoring", impedindo a bolinha de reabrir).
-- Pode ser interrompida a qualquer momento (tocar na bolinha durante a
-- animacao reverte); nunca fica travada.
function Window:Minimize()
	local state = self._state
	if state ~= "Open" and state ~= "Opening" and state ~= "Restoring" then return end
	local root = self._root
	self._transition = (self._transition or 0) + 1
	local token = self._transition
	if state ~= "Restoring" or not self._restorePosition then
		self._restorePosition = root.Position
	end
	self:_setState("Minimizing")
	self:_closeDropdowns()
	self._ball.Position = clampBallPosition(self._ball.Position, self._metrics.Ball)

	local function finish()
		if self._transition ~= token or self._state ~= "Minimizing" then return end
		root.Visible = false
		self:_setState("Minimized")
		self:_showBall()
	end
	if State.LowPerformance then
		root.GroupTransparency = 1
		self._scale.Scale = 1
		finish()
		return
	end
	local duration = Anim.Normal + 0.1
	tween(root, duration, { GroupTransparency = 1, Position = self._ball.Position }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tween(self._scale, duration, { Scale = 0.1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	task.delay(duration + 0.04, finish)
end

function Window:Restore()
	local state = self._state
	if state ~= "Minimized" and state ~= "Minimizing" then return end
	self._transition = (self._transition or 0) + 1
	local token = self._transition
	local root = self._root
	if self._pulse then self._pulse:Cancel(); self._pulse = nil end

	local function settle()
		if self._transition ~= token or self._state ~= "Restoring" then return end
		self:_setState("Open")
	end

	if state == "Minimizing" then
		self:_setState("Restoring")
		local size = self:_getSize()
		local targetPos = clampWindowPosition(self._restorePosition or root.Position, size)
		if not State.LowPerformance then
			tween(root, Anim.Slow, { Position = targetPos, GroupTransparency = 0 })
			tween(self._scale, Anim.Slow, { Scale = 1 })
			task.delay(Anim.Slow + 0.05, settle)
		else
			root.Position = targetPos
			root.GroupTransparency = 0
			self._scale.Scale = 1
			settle()
		end
		return
	end

	self:_setState("Restoring")
	local ballPosition = clampBallPosition(self._ball.Position, self._metrics.Ball)
	if not State.LowPerformance then
		tween(self._ballScale, Anim.Fast, { Scale = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tween(self._ball, Anim.Fast, { BackgroundTransparency = 1 })
	end

	local function expand()
		if self._transition ~= token or self._state ~= "Restoring" then return end
		self._ball.Visible = false
		self._ball.BackgroundTransparency = Glass.Ball
		local size = self:_getSize()
		local targetPos = clampWindowPosition(self._restorePosition or ballPosition, size)
		root.Size = size
		if not State.LowPerformance then
			root.Position = ballPosition
			root.GroupTransparency = 1
			self._scale.Scale = 0.12
			root.Visible = true
			self:_refreshActivity()
			self:_applyLayout(false)
			tween(root, Anim.Slow, { Position = targetPos, GroupTransparency = 0 })
			tween(self._scale, Anim.Slow, { Scale = 1 })
			task.delay(Anim.Slow + 0.05, settle)
		else
			root.Position = targetPos
			root.GroupTransparency = 0
			self._scale.Scale = 1
			root.Visible = true
			self:_refreshActivity()
			self:_applyLayout(false)
			settle()
		end
	end
	if State.LowPerformance then expand() else task.delay(Anim.Fast + 0.03, expand) end
end

----------------------------------------------------------------
-- Confirmacao de fechamento (sim/nao)
----------------------------------------------------------------
function Window:_showCloseConfirm()
	if self._confirmLayer and self._confirmLayer.Parent then return end
	if self._confirmLayer then self._confirmLayer:Destroy() end

	local gui = self._gui
	local layer = create("Frame", {
		Name = "CloseConfirm", BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50, Parent = gui,
	})
	self._confirmLayer = layer
	pcall(function()
		layer.ClipsDescendants = true
	end)

	local overlay = create("Frame", {
		Name = "Overlay", BackgroundColor3 = Theme.Black,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), Parent = layer,
	})

	local card = create("CanvasGroup", {
		Name = "Card", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(296, 152),
		BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		GroupTransparency = 1, Parent = layer,
	})
	local cardScale = create("UIScale", { Scale = 1, Parent = card })
	addCorner(card, Radius.Window)
	addStroke(card, Theme.Stroke, 0, 1)
	attachShadow(card, layer, Radius.Window, cardScale)

	create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 18),
		Size = UDim2.new(1, -40, 0, 22),
		Text = "Fechar a interface?",
		Font = Theme.FontBold, TextSize = 15,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
	})
	create("TextLabel", {
		Name = "Msg", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 44),
		Size = UDim2.new(1, -40, 0, 44),
		Text = "A janela sera destruida e as alteracoes nao salvas serao descartadas.",
		Font = Theme.Font, TextSize = 12,
		TextColor3 = Theme.SubText, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
	})

	local function makeBtn(text, xPos, color, textColor)
		local b = create("TextButton", {
			Name = "Btn_" .. text, AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(xPos, 0, 1, -16),
			Size = UDim2.fromOffset(124, 34),
			BackgroundColor3 = color, AutoButtonColor = false,
			Text = text, Font = Theme.FontBold,
			TextSize = 13, TextColor3 = textColor, Parent = card,
		})
		addCorner(b, Radius.Control)
		return b
	end
	local noBtn = makeBtn("Cancelar", 0.5, Theme.Element, Theme.Text)
	noBtn.AnchorPoint = Vector2.new(1, 1)
	noBtn.Size = UDim2.fromOffset(124, 34)
	noBtn.Position = UDim2.new(0.5, -5, 1, -16)
	addStroke(noBtn, Theme.Stroke, 0, 1)
	local yesBtn = makeBtn("Fechar", 0.5, Theme.Danger, Theme.White)
	yesBtn.Position = UDim2.new(0.5, 5, 1, -16)

	local function microButton(b)
		local s = create("UIScale", { Parent = b })
		b.MouseButton1Down:Connect(function()
			tween(s, Anim.Micro, { Scale = 0.97 })
		end)
		b.MouseButton1Up:Connect(function()
			tween(s, Anim.Fast, { Scale = 1 })
		end)
	end
	microButton(noBtn); microButton(yesBtn)

	local function closeConfirm()
		if not layer.Parent then return end
		if not State.LowPerformance then
			local t = tween(card, Anim.Fast, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tween(cardScale, Anim.Fast, { Scale = 0.96 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tween(overlay, Anim.Fast, { BackgroundTransparency = 1 })
			t.Completed:Connect(function() if layer.Parent then layer:Destroy() end end)
		else
			layer:Destroy()
		end
		self._confirmLayer = nil
		self._confirming = false
	end

	noBtn.MouseEnter:Connect(function()
		tween(noBtn, Anim.Fast, { BackgroundColor3 = Theme.ElementHover })
	end)
	noBtn.MouseLeave:Connect(function()
		tween(noBtn, Anim.Fast, { BackgroundColor3 = Theme.Element })
	end)
	noBtn.Activated:Connect(closeConfirm)

	yesBtn.MouseEnter:Connect(function()
		tween(yesBtn, Anim.Fast, { BackgroundColor3 = Theme.Danger:Lerp(Theme.White, 0.1) })
	end)
	yesBtn.MouseLeave:Connect(function()
		tween(yesBtn, Anim.Fast, { BackgroundColor3 = Theme.Danger })
	end)
	yesBtn.Activated:Connect(function()
		closeConfirm()
		self:Close(true)
	end)

	self._confirming = true
	if not State.LowPerformance then
		cardScale.Scale = 0.95
		card.Position = UDim2.new(0.5, 0, 0.5, 8)
		card.GroupTransparency = 1
		tween(overlay, Anim.Normal, { BackgroundTransparency = 0.55 })
		tween(card, Anim.Normal, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) })
		tween(cardScale, Anim.Normal, { Scale = 1 })
	else
		overlay.BackgroundTransparency = 0.55
		card.GroupTransparency = 0
		cardScale.Scale = 1
	end
end

function Window:Close(skipConfirm)
	if self._state == "Closing" or self._state == "Destroyed" then return end
	if not skipConfirm and not self._confirming then
		self:_showCloseConfirm()
		return
	end
	local wasHidden = not self._root.Visible
	self._transition = (self._transition or 0) + 1
	self:_setState("Closing")
	safeCall(self._onClose)
	if wasHidden then self:Destroy(); return end
	if State.LowPerformance then
		self:Destroy()
		return
	end
	tween(self._root, Anim.Normal, {
		GroupTransparency = 1,
		Position = self._root.Position + UDim2.fromOffset(0, 14),
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tween(self._scale, Anim.Normal, { Scale = 0.92 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	task.delay(Anim.Normal + 0.03, function() self:Destroy() end)
end

function Window:Destroy()
	if self._state == "Destroyed" then return end
	self._state = "Destroyed"
	PerfMonitor.Subscribers[self] = nil
	for index, window in ipairs(Windows) do
		if window == self then table.remove(Windows, index); break end
	end
	for _, connection in ipairs(self._connections) do connection:Disconnect() end
	table.clear(self._connections)
	if self._cameraConnection then self._cameraConnection:Disconnect(); self._cameraConnection = nil end
	if self._pulse then self._pulse:Cancel(); self._pulse = nil end
	if self._confirmLayer then self._confirmLayer:Destroy(); self._confirmLayer = nil end
	if self._gui then
		cancelTweensUnder(self._gui)
		self._gui:Destroy()
	end
	refreshPerfSubscription()
	if #Windows == 0 then
		disableSmartPerf()
	end
end

function Window:_onViewportChanged()
	if self._state == "Destroyed" then return end
	if self._state == "Open" then self:_resize(true) end
	self._ball.Position = clampBallPosition(self._ball.Position, self._metrics.Ball)
end

function Window:_bindCamera()
	if self._cameraConnection then self._cameraConnection:Disconnect(); self._cameraConnection = nil end
	local camera = workspace.CurrentCamera
	if camera then
		self._cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:_onViewportChanged()
		end)
	end
end

----------------------------------------------------------------
-- API publica (Temas, Telemetria & Smart Performance)
----------------------------------------------------------------
function AetherUI.SetAccent(first, second)
	local color = first
	if first == AetherUI then color = second end
	if typeof(color) ~= "Color3" then return end
	State.Accent = color
	for _, window in ipairs(Windows) do window:_refreshAccent(true) end
end
function AetherUI.GetAccent() return State.Accent end

function AetherUI.SetLowPerformance(first, second)
	local value = first
	if first == AetherUI then value = second end
	State.LowPerformance = value == true
	for _, window in ipairs(Windows) do window:_applyPerformance() end
end
function AetherUI.GetLowPerformance() return State.LowPerformance end

function AetherUI.SetSmartPerformance(first, second)
	local value = first
	if first == AetherUI then value = second end
	value = value == true
	if value then
		enableSmartPerf()
	else
		disableSmartPerf()
	end
	for _, window in ipairs(Windows) do
		window:_syncSettings()
		if window:_needsPerfUpdates() then
			window:_updatePerfViews()
		end
	end
end
function AetherUI.GetSmartPerformance() return SmartPerf.Enabled == true end
function AetherUI.SetSmartPerformanceConfig(first, second)
	local cfg = first
	if first == AetherUI then cfg = second end
	if typeof(cfg) ~= "table" then return end
	local validModes = {
		Automatico = true, Leve = true, Equilibrado = true, Agressivo = true, Ultra = true,
	}
	if typeof(cfg.Mode) == "string" and validModes[cfg.Mode] then
		SmartPerf.Config.Mode = cfg.Mode
		SmartPerf.Stats.Mode = cfg.Mode
	end
	if typeof(cfg.Intensity) == "number" then
		SmartPerf.Config.Intensity = math.clamp(math.floor(cfg.Intensity + 0.5), 20, 100)
	end
	if typeof(cfg.FrustumCulling) == "boolean" then SmartPerf.Config.FrustumCulling = cfg.FrustumCulling end
	if typeof(cfg.CombatProtection) == "boolean" then SmartPerf.Config.CombatProtection = cfg.CombatProtection end
	if typeof(cfg.EffectOptimization) == "boolean" then SmartPerf.Config.EffectOptimization = cfg.EffectOptimization end
	if typeof(cfg.LightOptimization) == "boolean" then SmartPerf.Config.LightOptimization = cfg.LightOptimization end
	if typeof(cfg.ObjectOptimization) == "boolean" then SmartPerf.Config.ObjectOptimization = cfg.ObjectOptimization end
	if typeof(cfg.EffectCleanup) == "boolean" then SmartPerf.Config.EffectCleanup = cfg.EffectCleanup end
	if typeof(cfg.CharacterOptimization) == "boolean" then SmartPerf.Config.CharacterOptimization = cfg.CharacterOptimization end
	if typeof(cfg.TargetFPS) == "number" then SmartPerf.Config.TargetFPS = math.clamp(cfg.TargetFPS, 30, 120) end
	reconcileSmartConfig()
	for _, window in ipairs(Windows) do
		window:_syncSettings()
		if window:_needsPerfUpdates() then
			window:_updatePerfViews()
		end
	end
end
function AetherUI.GetSmartPerformanceConfig()
	local c = SmartPerf.Config
	return {
		Mode = c.Mode,
		Intensity = c.Intensity,
		FrustumCulling = c.FrustumCulling == true,
		CombatProtection = c.CombatProtection == true,
		EffectOptimization = c.EffectOptimization == true,
		LightOptimization = c.LightOptimization == true,
		ObjectOptimization = c.ObjectOptimization == true,
		EffectCleanup = c.EffectCleanup == true,
		CharacterOptimization = c.CharacterOptimization == true,
		TargetFPS = c.TargetFPS,
	}
end
function AetherUI.GetSmartPerformanceStats()
	local s = SmartPerf.Stats
	return {
		Enabled = s.Enabled == true,
		Mode = s.Mode,
		Profile = s.Profile,
		IntensityPct = s.IntensityPct,
		FPS = s.FPS,
		NearCount = s.NearCount,
		MidCount = s.MidCount,
		FarCount = s.FarCount,
		CulledCount = s.CulledCount,
		OccludedCount = s.OccludedCount,
		ProtectedCount = s.ProtectedCount,
		CleanedCount = s.CleanedCount,
		OptimizedCount = s.OptimizedCount,
		CachedCount = s.CachedCount,
		NearRadius = s.NearRadius,
		FarRadius = s.FarRadius,
		CullRadius = s.CullRadius,
		StepIntervalMs = s.StepIntervalMs,
	}
end

function Window:SetSmartPerformance(value) AetherUI.SetSmartPerformance(value) end
function Window:GetSmartPerformance() return AetherUI.GetSmartPerformance() end
function Window:ToggleSmartPerformance() AetherUI.SetSmartPerformance(not AetherUI.GetSmartPerformance()) end
function Window:SetSmartPerformanceConfig(cfg) AetherUI.SetSmartPerformanceConfig(cfg) end
function Window:GetSmartPerformanceConfig() return AetherUI.GetSmartPerformanceConfig() end
function Window:GetSmartPerformanceStats() return AetherUI.GetSmartPerformanceStats() end

function AetherUI.GetPing()
	return readPingMs()
end
function AetherUI.GetUptime()
	return os.clock() - LibraryStartClock
end
function AetherUI.GetPerformanceStats()
	local st = samplePerfSnapshot(nil, nil, false)
	return {
		FPS = st.FPS,
		MinFPS = st.MinFPS,
		MaxFPS = st.MaxFPS,
		AvgFPS = st.AvgFPS,
		FrameTimeMs = st.FrameTimeMs,
		PingMs = st.PingMs,
		Uptime = st.Uptime,
		UptimeFormatted = formatDurationClock(st.Uptime),
		History = table.clone(PerfMonitor.History),
		ActiveElements = st.ActiveElements,
		GuiObjects = st.GuiObjects,
		ActiveTweens = st.ActiveTweens,
		Connections = st.Connections,
		MemoryMB = st.MemoryMB,
		Windows = st.Windows,
		SmartPerformance = AetherUI.GetSmartPerformanceStats(),
	}
end

function AetherUI.CreateWindow(config)
	config = config or {}
	if typeof(config.Accent) == "Color3" then AetherUI.SetAccent(config.Accent) end
	if config.LowPerformance ~= nil then AetherUI.SetLowPerformance(config.LowPerformance) end
	local guiParent = resolveParent()
	local guiName = tostring(config.Name or "AetherUI")
	local previous = guiParent:FindFirstChild(guiName)
	if previous and previous:IsA("ScreenGui") then previous:Destroy() end

	local self = setmetatable({}, Window)
	self._guiName = guiName
	local cfgSaving = typeof(config.ConfigurationSaving) == "table" and config.ConfigurationSaving or nil
	self._configFolder = sanitizeFileName(
		(cfgSaving and cfgSaving.FolderName) or config.ConfigFolder or guiName
	)
	self._configFile = sanitizeFileName(
		(cfgSaving and cfgSaving.FileName) or config.ConfigFile or "default"
	)
	self._autoLoadConfig = (cfgSaving and cfgSaving.Enabled == true) or (config.AutoLoadConfig == true)
	self._pendingConfigData = nil

	self._compact = config.Compact == true
	local m = computeMetrics(self._compact)
	self._metrics = m
	self._connections = {}
	self._tabs = {}
	self._selectedTab = nil
	self._state = "Opening"
	self._onClose = config.OnClose
	self._layoutUpdaters = {}
	self._accentUpdaters = {}
	self._gradients = {}
	self._userTabs = 0
	self._collapsedManual = nil
	if config.SidebarCollapsed ~= nil then self._collapsedManual = config.SidebarCollapsed == true end
	self._collapsed = false
	self._syncing = false
	self._confirming = false
	self._searchQuery = ""
	self._searchFocused = false
	self._openDropdowns = {}

	if typeof(config.SmartPerfConfig) == "table" then AetherUI.SetSmartPerformanceConfig(config.SmartPerfConfig) end
	if config.SmartPerformance ~= nil then AetherUI.SetSmartPerformance(config.SmartPerformance) end

	if self._autoLoadConfig then
		local fs = getFsApi()
		if fs then
			local _, fullPath = self:_resolveConfigPath(self._configFile)
			local exists = true
			if fs.isfile then
				local okCheck, res = pcall(fs.isfile, fullPath)
				if okCheck then exists = res == true end
			end
			if exists then
				local okRead, content = pcall(fs.readfile, fullPath)
				if okRead and typeof(content) == "string" then
					local okDec, decoded = pcall(function() return HttpService:JSONDecode(content) end)
					if okDec and typeof(decoded) == "table" then
						if typeof(decoded.Meta) == "table" then
							if decoded.Meta.Accent ~= nil then
								local c = deserializeConfigValue(decoded.Meta.Accent)
								if typeof(c) == "Color3" then AetherUI.SetAccent(c) end
							end
							if typeof(decoded.Meta.Compact) == "boolean" then
								self._compact = decoded.Meta.Compact
								self._metrics = computeMetrics(self._compact)
								m = self._metrics
							end
							if typeof(decoded.Meta.LowPerformance) == "boolean" then
								AetherUI.SetLowPerformance(decoded.Meta.LowPerformance)
							end
							if typeof(decoded.Meta.SmartPerfConfig) == "table" then
								AetherUI.SetSmartPerformanceConfig(decoded.Meta.SmartPerfConfig)
							end
							if typeof(decoded.Meta.SmartPerformance) == "boolean" then
								AetherUI.SetSmartPerformance(decoded.Meta.SmartPerformance)
							end
						end
						self._pendingConfigData = typeof(decoded.Flags) == "table" and decoded.Flags or decoded
					end
				end
			end
		end
	end

	local gui = create("ScreenGui", {
		Name = guiName, ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent,
	})
	self._gui = gui

	-- Botao do X respeita config.CloseButton (default true)
	local showClose = config.CloseButton ~= false

	local root = create("CanvasGroup", {
		Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 8), Size = self:_getSize(),
		BackgroundColor3 = Theme.Background, BackgroundTransparency = 0, GroupTransparency = 1, Parent = gui,
	})
	addCorner(root, Radius.Window)
	addStroke(root, Theme.Stroke, 0, 1)
	local rootScale = create("UIScale", { Scale = 0.96, Parent = root })
	self._root = root
	self._scale = rootScale
	self._shadow = attachShadow(root, gui, Radius.Window, rootScale, self._connections)

	local titleBar = create("Frame", {
		Name = "TitleBar", Size = UDim2.new(1, 0, 0, m.Title),
		BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0, Parent = root,
	})
	self._titleBar = titleBar
	local titleLabel = create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1,
		Text = tostring(config.Title or "AetherUI"),
		Font = Theme.FontBold, TextSize = m.Text + 1,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Active = true, Parent = titleBar,
	})
	self._titleLabel = titleLabel

	-- Emblema estrutural ao lado do titulo; fundo neutro elevado e icone na AccentColor.
	local titleBadge = create("Frame", {
		Name = "LogoBadge", AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6 + m.TitleButton + 8, 0.5, 0),
		Size = UDim2.fromOffset(m.TitleButton, m.TitleButton),
		BackgroundColor3 = Theme.SurfaceHigh, Parent = titleBar,
	})
	addCorner(titleBadge, Radius.Control)
	addStroke(titleBadge, Theme.Stroke, 0, 1)
	local titleBadgeIcon = create("ImageLabel", {
		Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.62, 0.62), BackgroundTransparency = 1,
		Image = Assets.Logo, ImageColor3 = accentLight(),
		ScaleType = Enum.ScaleType.Fit, Parent = titleBadge,
	})
	self._titleBadge = titleBadge
	create("Frame", {
		Name = "Divider", AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Divider, Parent = titleBar,
	})

	local function makeTitleButton(iconName, hoverColor, hoverIconColor, restColor)
		local button = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(m.TitleButton, m.TitleButton),
			BackgroundColor3 = hoverColor, BackgroundTransparency = 1,
			AutoButtonColor = false, Text = "",
			ClipsDescendants = true, Parent = titleBar,
		})
		addCorner(button, Radius.Control)
		local buttonScale = create("UIScale", { Parent = button })
		local icon = createIcon(iconName, button, m.Icon - 2, Theme.SubText)
		icon.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Instance.Position = UDim2.fromScale(0.5, 0.5)
		button.MouseEnter:Connect(function()
			tween(button, Anim.Fast, { BackgroundTransparency = 0 })
			icon:Tween(hoverIconColor, Anim.Fast)
		end)
		button.MouseLeave:Connect(function()
			tween(button, Anim.Fast, { BackgroundTransparency = 1 })
			icon:Tween(restColor and restColor() or Theme.SubText, Anim.Fast)
			tween(buttonScale, Anim.Fast, { Scale = 1 })
		end)
		button.MouseButton1Down:Connect(function()
			tween(buttonScale, Anim.Micro, { Scale = 0.92 })
		end)
		button.MouseButton1Up:Connect(function()
			tween(buttonScale, Anim.Fast, { Scale = 1 })
		end)
		return button, icon
	end

	local closeButton, closeIcon = makeTitleButton("close", Theme.Danger, Theme.White)
	local minimizeButton, minimizeIcon = makeTitleButton("minus", Theme.ElementHover, Theme.Text)
	local menuButton, menuIcon = makeTitleButton("menu", Theme.ElementHover, Theme.Text)
	menuButton.AnchorPoint = Vector2.new(0, 0.5)
	self._closeButton = closeButton
	self._closeIcon = closeIcon
	self._minimizeButton = minimizeButton
	self._minimizeIcon = minimizeIcon
	self._menuButton = menuButton
	self._menuIcon = menuIcon
	closeButton.Visible = showClose

	closeButton.Activated:Connect(function() self:Close() end)
	minimizeButton.Activated:Connect(function() self:Minimize() end)
	menuButton.Activated:Connect(function() self:ToggleSidebar() end)

	local body = create("Frame", {
		Name = "Body", BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.fromOffset(0, m.Title),
		Size = UDim2.new(1, 0, 1, -m.Title), Parent = root,
	})
	self._body = body

	local sidebar = create("Frame", {
		Name = "Sidebar", BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0,
		ClipsDescendants = true, Size = UDim2.new(0, m.SideWidth, 1, 0), Parent = body,
	})
	self._sidebar = sidebar
	create("Frame", {
		Name = "Divider", AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = Theme.Divider,
		ZIndex = 5, Parent = sidebar,
	})

	local list = create("ScrollingFrame", {
		Name = "Tabs", BackgroundTransparency = 1,
		Size = UDim2.new(1, -1, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0, Parent = sidebar,
	})
	self._list = list
	self._listPadding = addPadding(list, m.SidePad, 8, m.SidePad, 8)

	self._separator = create("Frame", {
		Name = "Separator", BackgroundColor3 = Theme.Divider,
		Size = UDim2.new(1, -8, 0, 1), Visible = false, Parent = list,
	})
	self._highlight = create("Frame", {
		Name = "Highlight", BackgroundColor3 = accentSurface(0.16), BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, m.SideRow), ZIndex = 1, Visible = false, Parent = list,
	})
	addCorner(self._highlight, Radius.Card)
	self._highlightStroke = addStroke(self._highlight, accentBorder(0.4), 0, 1)
	self._indicator = create("Frame", {
		Name = "Indicator", BackgroundColor3 = accent(), BackgroundTransparency = 0,
		Size = UDim2.fromOffset(3, 14), ZIndex = 3, Visible = false, Parent = list,
	})
	addCornerScale(self._indicator, 0.5)

	local content = create("Frame", {
		Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.fromOffset(m.SideWidth, 0),
		Size = UDim2.new(1, -m.SideWidth, 1, 0), Parent = body,
	})
	self._content = content
	self._header = create("TextLabel", {
		Name = "Header", BackgroundTransparency = 1, Text = "",
		Font = Theme.FontBold, TextSize = m.Text + 3,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = content,
	})
	self._headerDivider = create("Frame", {
		Name = "HeaderDivider", BackgroundColor3 = Theme.Divider,
		Position = UDim2.fromOffset(m.Pad + 4, m.Header + 10),
		Size = UDim2.new(1, -(m.Pad * 2 + 8), 0, 1), Parent = content,
	})
	self._pages = create("Frame", {
		Name = "Pages", BackgroundTransparency = 1, ClipsDescendants = true, Parent = content,
	})

	-- Barra de pesquisa: fica ACIMA das abas (filha do body, ZIndex alto) e a
	-- lista de abas comeca logo abaixo dela, entao nunca ha sobreposicao.
	local searchBar = create("Frame", {
		Name = "SearchBar", BackgroundColor3 = Theme.BackgroundDeep, BackgroundTransparency = 0,
		Position = UDim2.fromOffset(m.SidePad, 6),
		Size = UDim2.fromOffset(m.SideWidth - m.SidePad * 2, m.Compact and 26 or 28),
		ClipsDescendants = true, ZIndex = 20, Parent = body,
	})
	addCorner(searchBar, Radius.Card)
	local searchStroke = addStroke(searchBar, Theme.StrokeSoft, 0, 1)
	local searchIcon = createIcon("search", searchBar, 12, Theme.Muted)
	if searchIcon then
		searchIcon.Instance.AnchorPoint = Vector2.new(0, 0.5)
		searchIcon.Instance.Position = UDim2.new(0, 8, 0.5, 0)
	end
	local searchBox = create("TextBox", {
		Name = "Box", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -54, 1, 0),
		Text = "", PlaceholderText = "Pesquisar...",
		Font = Theme.Font, TextSize = m.Text - 1,
		TextColor3 = Theme.Text, PlaceholderColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, Parent = searchBar,
	})
	local searchClear = create("TextButton", {
		Name = "Clear", AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
		Visible = false, ZIndex = 4, Parent = searchBar,
	})
	local clearIcon = createIcon("close", searchClear, 10, Theme.Muted)
	if clearIcon then
		clearIcon.Instance.AnchorPoint = Vector2.new(0.5, 0.5)
		clearIcon.Instance.Position = UDim2.fromScale(0.5, 0.5)
	end
	-- Toque/clique em qualquer ponto da barra (inclusive recolhida) foca o campo.
	local searchHit = create("TextButton", {
		Name = "Hit", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", AutoButtonColor = false, ZIndex = 3, Parent = searchBar,
	})
	self._searchBar = searchBar
	self._searchBox = searchBox

	local searchPopup = create("Frame", {
		Name = "SearchResults", BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0,
		Visible = false, ClipsDescendants = true, ZIndex = 21, Parent = body,
	})
	addCorner(searchPopup, Radius.Popup)
	addStroke(searchPopup, Theme.Stroke, 0, 1)
	local searchScroll = create("ScrollingFrame", {
		Name = "List", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 2, ScrollBarImageColor3 = accent(),
		ScrollBarImageTransparency = 0.25, Parent = searchPopup,
	})
	addPadding(searchScroll, 4, 4, 4, 4)
	local searchListLayout = create("UIListLayout", {
		Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = searchScroll,
	})
	bindCanvas(searchScroll, searchListLayout, "Y", 8)
	self._searchPopup = searchPopup
	self._searchScroll = searchScroll

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self._searchQuery = searchBox.Text
		searchClear.Visible = searchBox.Text ~= ""
		self:_layoutSearch(true)
		self:_renderSearchResults(searchBox.Text)
		tween(searchStroke, Anim.Fast, {
			Color = (searchBox.Text ~= "" or self._searchFocused) and accent() or Theme.StrokeSoft,
		})
	end)
	searchBox.Focused:Connect(function()
		self._searchFocused = true
		searchHit.Visible = false
		tween(searchStroke, Anim.Fast, { Color = accent(), Transparency = 0 })
		self:_layoutSearch(true)
		self:_renderSearchResults(searchBox.Text)
	end)
	searchBox.FocusLost:Connect(function(enterPressed)
		self._searchFocused = false
		searchHit.Visible = true
		if searchBox.Text == "" then
			tween(searchStroke, Anim.Fast, { Color = Theme.StrokeSoft, Transparency = 0 })
		end
		self:_layoutSearch(true)
		local first = self._searchResults and self._searchResults[1]
		if enterPressed and first then
			self:_pickSearchResult(first)
		end
	end)
	searchHit.Activated:Connect(function() searchBox:CaptureFocus() end)
	searchClear.Activated:Connect(function() self:_clearSearch() end)

	local viewport = getViewport()
	local ball = create("TextButton", {
		Name = "Ball", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = clampBallPosition(
			UDim2.fromOffset(math.floor(viewport.X * 0.5), math.max(math.floor(m.Ball / 2 + 8), getGuiInset().Y + math.floor(m.Ball / 2 + 6))),
			m.Ball
		),
		Size = UDim2.fromOffset(m.Ball, m.Ball),
		BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0, AutoButtonColor = false,
		Text = "", Visible = false, Parent = gui,
	})
	addCornerScale(ball, 0.5)
	local ballIcon = create("ImageLabel", {
		Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.6), BackgroundTransparency = 1,
		Image = Assets.Logo, ImageColor3 = accentLight(),
		ScaleType = Enum.ScaleType.Fit, Active = false, Parent = ball,
	})
	self._ballStroke = create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = accentBorder(0.65), Transparency = 0, Thickness = 1.5, Parent = ball,
	})
	self._ball = ball
	self._ballScale = create("UIScale", { Scale = 0, Parent = ball })

	ball.MouseEnter:Connect(function()
		if self._state == "Minimized" then
			tween(self._ballScale, Anim.Fast, { Scale = 1.05 })
		end
	end)
	ball.MouseLeave:Connect(function()
		if self._state == "Minimized" then
			tween(self._ballScale, Anim.Fast, { Scale = 1 })
		end
	end)

	makeDraggable(titleLabel, root, self._connections, {
		Clamp = function(position) return clampWindowPosition(position, root.Size) end,
	})
	makeDraggable(titleBar, root, self._connections, {
		Clamp = function(position) return clampWindowPosition(position, root.Size) end,
	})
	makeDraggable(ball, ball, self._connections, {
		Clamp = function(position) return clampBallPosition(position, self._metrics.Ball) end,
		OnClick = function() self:Restore() end,
	})

	self:_onAccent(function(animate)
		setProps(self._highlight, { BackgroundColor3 = accentSurface(0.16) }, animate, Anim.Normal)
		setProps(self._highlightStroke, { Color = accentBorder(0.4) }, animate, Anim.Normal)
		setProps(self._indicator, { BackgroundColor3 = accent() }, animate, Anim.Normal)
		ballIcon.ImageColor3 = accentLight()
		self._ballStroke.Color = accentBorder(0.65)
		titleBadgeIcon.ImageColor3 = accentLight()
		setProps(searchStroke, { Color = (searchBox.Text ~= "" or self._searchFocused) and accent() or Theme.StrokeSoft }, animate, Anim.Normal)
		self._searchScroll.ScrollBarImageColor3 = accent()
	end)

	self:_applyLayout(false)
	if config.MenuTab ~= false then self:_buildMenu() end
	if config.Settings ~= false then self:_buildSettings() end
	self:_applyLayout(false)
	self:_applyPerformance()

	table.insert(self._connections, gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		self:_refreshActivity()
	end))

	PerfMonitor.Subscribers[self] = true

	self:_bindCamera()
	table.insert(self._connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		self:_bindCamera(); self:_onViewportChanged()
	end))
	table.insert(Windows, self)

	-- Animacao fixa de abertura: Fade + Slide sutil + Scale
	if not State.LowPerformance then
		root.GroupTransparency = 1
		rootScale.Scale = 0.96
		root.Position = UDim2.new(0.5, 0, 0.5, 8)
		tween(root, Anim.Normal, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) })
		tween(rootScale, Anim.Normal, { Scale = 1 })
		task.delay(Anim.Normal + 0.04, function()
			if self._state == "Opening" then self:_setState("Open") end
		end)
	else
		root.GroupTransparency = 0
		rootScale.Scale = 1
		root.Position = UDim2.new(0.5, 0, 0.5, 0)
		self:_setState("Open")
	end
	self:_refreshActivity()

	return self
end

----------------------------------------------------------------
-- API padronizada (estilo Rayfield) - camada de compatibilidade v2.5.0
--
-- Nada foi recriado: os Create* traduzem parametros e delegam aos Add*
-- existentes, e os Add* continuam aceitando os parametros antigos
-- (Default, Min, Max, Step...). Documentacao no cabecalho de AetherUI.lua.
--
-- Parametros (estilo Rayfield -> equivalente antigo):
--   Toggle       Name, CurrentValue (Default), Flag, Callback(Value)
--   Slider       Name, Range {min,max} (Min/Max), Increment (Step), Suffix,
--                CurrentValue (Default), Flag, Callback(Value)
--   Dropdown     Name, Options, CurrentOption (Default), MultipleOptions,
--                Flag, Callback(tabela de opcoes)
--   ColorPicker  Name, Color (Default), Flag, Callback(Color3)
--   Button       Name, Callback
--   Label        texto ou Name
-- Se o parametro novo e o antigo forem informados, o novo tem prioridade.
-- Parametros exclusivos da Rayfield (LoadingTitle, ConfigurationSaving,
-- KeySystem, Theme...) sao ignorados.
----------------------------------------------------------------
AetherUI.Flags = {}

local function copyConfig(config)
	local copy = {}
	if typeof(config) == "table" then
		for key, value in pairs(config) do copy[key] = value end
	end
	return copy
end

-- Primeiro valor que nao seja nil (false e valido).
local function pick(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value ~= nil then return value end
	end
	return nil
end

local function toList(value)
	if value == nil then return {} end
	if typeof(value) == "table" then return value end
	return { value }
end

-- Marca o objeto (Type, Flag), expoe propriedades "vivas" (CurrentValue,
-- CurrentOption, Color...) lidas sempre do estado real e registra a Flag.
local function decorate(tab, config, object, kind, live)
	object.Type = kind
	object.Flag = config.Flag
	setmetatable(object, {
		__index = function(_, key)
			local getter = live and live[key]
			if getter then return getter() end
			return nil
		end,
	})
	if config.Flag ~= nil then
		local win = tab._window
		win.Flags = win.Flags or {}
		if win.Flags[config.Flag] ~= nil and win.Flags[config.Flag] ~= object then
			warn("[AetherUI] Flag duplicada: " .. tostring(config.Flag) .. " (a anterior foi substituida)")
		end
		win.Flags[config.Flag] = object
		AetherUI.Flags[config.Flag] = object
		if win._pendingConfigData ~= nil and win._pendingConfigData[config.Flag] ~= nil and typeof(object.Set) == "function" then
			local restored = deserializeConfigValue(win._pendingConfigData[config.Flag])
			if restored ~= nil then
				pcall(function() object:Set(restored, true) end)
			end
		end
	end
	return object
end

local function asConfig(config)
	-- Section/Label aceitam string; os demais, tabela.
	if typeof(config) == "table" then return config end
	return {}
end

-- Wrappers dos Add* (aditivos: mesmo comportamento + Type/Flag/CurrentValue)
local rawAddSection = Tab.AddSection
function Tab:AddSection(config)
	return decorate(self, asConfig(config), rawAddSection(self, config), "Section", nil)
end

local rawAddLabel = Tab.AddLabel
function Tab:AddLabel(config)
	return decorate(self, asConfig(config), rawAddLabel(self, config), "Label", nil)
end

local rawAddButton = Tab.AddButton
function Tab:AddButton(config)
	return decorate(self, asConfig(config), rawAddButton(self, config), "Button", nil)
end

local rawAddToggle = Tab.AddToggle
function Tab:AddToggle(config)
	local object = rawAddToggle(self, config)
	return decorate(self, asConfig(config), object, "Toggle", {
		CurrentValue = function() return object:Get() end,
	})
end

local rawAddSlider = Tab.AddSlider
function Tab:AddSlider(config)
	local object = rawAddSlider(self, config)
	return decorate(self, asConfig(config), object, "Slider", {
		CurrentValue = function() return object:Get() end,
	})
end

-- Dropdown simples: Set aceita string ou tabela ({ "A" }); nil/{} limpa.
local rawAddDropdown = Tab.AddDropdown
function Tab:AddDropdown(config)
	local object = rawAddDropdown(self, config)
	local rawSet = object.Set
	function object:Set(value, silent)
		if typeof(value) == "table" then value = value[1] end
		if value == nil then
			if object:Get() ~= nil then object:Clear(silent) end
			return
		end
		return rawSet(object, value, silent)
	end
	return decorate(self, asConfig(config), object, "Dropdown", {
		CurrentValue = function() return object:Get() end,
		CurrentOption = function()
			local value = object:Get()
			return value ~= nil and { value } or {}
		end,
	})
end

-- MultiDropdown: Set aceita tabela ou string unica.
local rawAddMultiDropdown = Tab.AddMultiDropdown
function Tab:AddMultiDropdown(config)
	local object = rawAddMultiDropdown(self, config)
	local rawSet = object.Set
	function object:Set(values, silent)
		return rawSet(object, toList(values), silent)
	end
	object.Multiple = true
	return decorate(self, asConfig(config), object, "Dropdown", {
		CurrentValue = function() return object:Get() end,
		CurrentOption = function() return object:Get() end,
	})
end

local rawAddRadioGroup = Tab.AddRadioGroup
function Tab:AddRadioGroup(config)
	local object = rawAddRadioGroup(self, config)
	return decorate(self, asConfig(config), object, "RadioGroup", {
		CurrentValue = function() return object:Get() end,
		CurrentOption = function() return object:Get() end,
	})
end

local rawAddColorPicker = Tab.AddColorPicker
function Tab:AddColorPicker(config)
	local object = rawAddColorPicker(self, config)
	return decorate(self, asConfig(config), object, "ColorPicker", {
		CurrentValue = function() return object:Get() end,
		Color = function() return object:Get() end,
		CurrentColor = function() return object:Get() end,
	})
end

-- Window ---------------------------------------------------------
local originalCreateWindow = AetherUI.CreateWindow

function AetherUI.CreateWindow(config)
	if typeof(config) == "string" then config = { Name = config } end
	config = copyConfig(config)
	-- Na Rayfield, Name e o titulo exibido na janela.
	if config.Title == nil and config.Name ~= nil then config.Title = tostring(config.Name) end
	local win = originalCreateWindow(config)
	win.Flags = win.Flags or {}
	return win
end

function Window:CreateTab(name, icon)
	return self:AddTab(name, icon)
end

-- Tab:Create* ----------------------------------------------------
function Tab:CreateSection(config, icon)
	if typeof(config) == "table" then
		config = copyConfig(config)
		config.Text = pick(config.Text, config.Name)
		config.Icon = pick(config.Icon, icon)
	elseif icon ~= nil then
		config = { Text = config, Icon = icon }
	end
	return self:AddSection(config)
end

function Tab:CreateLabel(config, icon)
	if typeof(config) == "table" then
		config = copyConfig(config)
		config.Text = pick(config.Text, config.Name)
		config.Icon = pick(config.Icon, icon)
	else
		config = { Text = config, Icon = icon }
	end
	return self:AddLabel(config)
end

function Tab:CreateButton(config)
	config = copyConfig(config)
	config.Name = pick(config.Name, "Button")
	return self:AddButton(config)
end

function Tab:CreateToggle(config)
	config = copyConfig(config)
	config.Name = pick(config.Name, "Toggle")
	config.Default = pick(config.CurrentValue, config.Default) == true
	return self:AddToggle(config)
end

function Tab:CreateSlider(config)
	config = copyConfig(config)
	config.Name = pick(config.Name, "Slider")
	local range = config.Range
	if typeof(range) == "table" then
		config.Min = pick(range[1], config.Min)
		config.Max = pick(range[2], config.Max)
	end
	config.Step = pick(config.Increment, config.Step)
	config.Default = pick(config.CurrentValue, config.Default)
	return self:AddSlider(config)
end

-- Estilo Rayfield: o Callback recebe SEMPRE uma tabela de opcoes
-- (simples: { "A" } ou {}; multiplo: lista). Os Add* seguem como antes.
function Tab:CreateDropdown(config)
	config = copyConfig(config)
	config.Name = pick(config.Name, "Dropdown")
	local current = pick(config.CurrentOption, config.Default)
	if config.MultipleOptions == true then
		config.Default = toList(current)
		return self:AddMultiDropdown(config)
	end
	if typeof(current) == "table" then current = current[1] end
	config.Default = current
	local user = config.Callback
	config.Callback = function(value)
		safeCall(user, value ~= nil and { value } or {})
	end
	return self:AddDropdown(config)
end

function Tab:CreateMultiDropdown(config)
	config = copyConfig(config)
	config.MultipleOptions = true
	return self:CreateDropdown(config)
end

function Tab:CreateRadioGroup(config)
	config = copyConfig(config)
	config.Name = pick(config.Name, "Radio Group")
	config.Default = pick(config.CurrentOption, config.CurrentValue, config.Default)
	return self:AddRadioGroup(config)
end

function Tab:CreateColorPicker(config)
	config = copyConfig(config)
	config.Name = pick(config.Name, "Color Picker")
	config.Default = pick(config.Color, config.Default)
	return self:AddColorPicker(config)
end

return AetherUI

--[=[
	EXEMPLO DE USO (LocalScript)

	-- API padronizada (v2.9.0, estilo Rayfield)
	local win = AetherUI.CreateWindow({ Name = "Meu Hub" })
	local tab = win:CreateTab("Principal", "home")
	tab:CreateSection("Controles")
	tab:CreateToggle({ Name = "Ativar", CurrentValue = false, Flag = "Ativar", Callback = function(v) end })
	tab:CreateSlider({ Name = "Velocidade", Range = { 0, 100 }, Increment = 5, Suffix = " km/h",
		CurrentValue = 50, Flag = "Vel", Callback = function(v) end })
	tab:CreateDropdown({ Name = "Arma", Options = { "Sword", "Bow" }, CurrentOption = { "Sword" },
		Flag = "Arma", Callback = function(opcoes) print(opcoes[1]) end })
	tab:CreateMultiDropdown({ Name = "Modulos", Options = { "ESP", "Fly" }, CurrentOption = { "ESP" },
		Callback = function(lista) end })
	tab:CreateColorPicker({ Name = "Cor", Color = Color3.fromRGB(124, 92, 255), Flag = "Cor",
		Callback = function(c) end })
	-- AetherUI.Flags.Vel.CurrentValue / :Set(valor, true) (true = sem disparar Callback)

	-- API classica (continua valida):

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local AetherUI = require(ReplicatedStorage:WaitForChild("AetherUI"))

	local window = AetherUI.CreateWindow({
		Title = "AetherUI Demo",
		Accent = Color3.fromRGB(124, 92, 255),
		Compact = false,
		CloseButton = true, -- X com confirmacao (Sim/Nao + blur)
		OnClose = function() print("Janela fechada") end,
	})

	local main = window:AddTab("Principal", "home")
	main:AddSection("Controles")

	-- Dropdown
	local dd = main:AddDropdown({
		Name = "Arma", Options = { "Sword", "Bow", "Staff", "Dagger" },
		Default = "Sword",
		Callback = function(v) print("Arma:", v) end,
	})

	-- MultiDropdown
	local md = main:AddMultiDropdown({
		Name = "Modulos", Options = { "ESP", "Aimbot", "Fly", "Speed", "Noclip" },
		Default = { "ESP", "Speed" },
		Callback = function(list) print("Selecionados:", table.concat(list, ", ")) end,
	})

	-- ColorPicker (seletor circular + tonalidades + tons + presets + HEX)
	main:AddColorPicker({
		Name = "Cor do tema", Default = Color3.fromRGB(124, 92, 255),
		Callback = function(c) print("Cor:", c) end,
	})

	main:AddToggle({ Name = "Ativar", Default = false })
	main:AddSlider({ Name = "Velocidade", Min = 0, Max = 100, Default = 50 })
	main:AddButton({ Name = "Notificar", Callback = function()
		AetherUI:Notify({ Title = "Ok", Content = "Funcionando", Type = "success" })
	end })

	-- Search: a barra fica acima das abas. Busca abas, secoes, botoes, toggles,
	-- sliders, dropdowns (e opcoes), cores e configuracoes; clicar no resultado
	-- abre a aba e rola ate o elemento.
]=]
