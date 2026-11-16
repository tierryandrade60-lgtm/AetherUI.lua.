# AetherUI — Documentação Técnica da API (v2.7.0)

Manual técnico oficial baseado diretamente na implementação real de `AetherUI.lua`.

---

## 1. Introdução à AetherUI

A **AetherUI** (`v2.7.0`) é uma biblioteca de interface gráfica em arquivo único para Roblox (`LocalScript` / executores), projetada para funcionar tanto em **PC** quanto em **Mobile**.

Principais recursos embutidos na biblioteca:
- **Sistema de animação centralizado**: cache de `TweenInfo`, mesclagem de tweens concorrentes sem travamentos e atribuição direta quando elementos estão ocultos ou no modo de baixo desempenho.
- **Otimização Mobile e Toque**: dimensionamento responsivo (retrato e paisagem), clamping seguro abaixo do topbar (`GuiService:GetGuiInset()`), alvos de toque maiores e calibração automática de coordenadas no **ColorPicker** e no **Slider** (`Active = true` + offset de toque/inset para acompanhar exatamente o dedo sem deslocamentos).
- **Floating Dock inteligente**: retângulo arredondado com esfera central e ícone da biblioteca que aparece **somente quando o painel principal está minimizado**. Quando o painel abre, o Dock desaparece; ao minimizar, o Dock reaparece. Segurar por `1.5s` oculta/exibe a pílula lateral, e os atalhos (`menu`, `star`, `search`, `settings`) restauram a janela e executam a ação ao tocar.
- **Busca global integrada**: barra de pesquisa no topo da barra lateral que indexa abas, seções, textos, botões, toggles, sliders, dropdowns (e suas opções individuais), **radio groups**, color pickers e configurações.
- **Sistema de Favoritos**: botão de estrela no cabeçalho para exibir/ocultar estrelas individuais em abas, seções e componentes, além de uma aba dedicada `"Favoritos"`.
- **Save Configuration integrado**: exportação/importação universal em JSON (`ExportConfig` / `ImportConfig`) + salvamento em disco (`SaveConfig` / `LoadConfig` / `DeleteConfig` / `ListConfigs` e aliases `*Configuration`, com suporte a `ConfigurationSaving` no `CreateWindow` e controles na aba `"Interface"`).
- **Biblioteca expandida de ícones**: mais de 65 ícones vetoriais embutidos + aliases (`AetherUI.Icons`), suporte a `IconSize` / `IconColor` / tabelas e imagens personalizadas (`rbxassetid://`), além de `AetherUI.RegisterIcon`, `AetherUI.CreateIcon` e `AetherUI.GetIcons`.
- **Notificações**: fila independente (`DisplayOrder = 990`, sempre abaixo da janela principal), com tipos semânticos (`info`, `success`, `warning`, `error`), barra de progresso e callback de clique.
- **Camada de compatibilidade estilo Rayfield**: suporta tanto os métodos clássicos (`AddTab`, `AddToggle`, `AddRadioGroup`, etc.) quanto os métodos padronizados (`CreateTab`, `CreateToggle`, `CreateRadioGroup`, etc.) e registro automático em `Flags`.

---

## 2. Instalação e Utilização

> **Importante sobre `LocalScript` vs Executor:**
> A AetherUI cria interfaces em `gethui()` (quando disponível) ou `Players.LocalPlayer.PlayerGui`.
> - Em **Roblox Studio** (`LocalScript` padrão), `game:HttpGet()` e `loadstring()` no cliente são bloqueados por segurança do Roblox — utilize um `ModuleScript` com `require(...)`.
> - Em **executores** compatíveis, você pode usar diretamente `loadstring(game:HttpGet("..."))()` apontando para o arquivo `AetherUI.lua` em um **repositório GitHub público**.

### Opção 1: Uso via `ModuleScript` (Roblox Studio)
1. Copie o conteúdo integral de `AetherUI.lua` para um `ModuleScript` (por exemplo, em `ReplicatedStorage.AetherUI`).
2. Carregue no seu `LocalScript`:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AetherUI = require(ReplicatedStorage:WaitForChild("AetherUI"))
```

### Opção 2: Uso via `loadstring` + `HttpGet` (GitHub RAW Público)
Com o arquivo `AetherUI.lua` sincronizado em um repositório GitHub **público**, utilize o link RAW terminando em `/AetherUI.lua`:
```lua
local AetherUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/AetherUI.lua"))()
```

---

## 3. Estrutura da Biblioteca

A hierarquia de objetos da AetherUI segue o fluxo:

```text
AetherUI (módulo global)
 ├── AetherUI.Version          -> "2.7.0"
 ├── AetherUI.Flags            -> Tabela global de componentes com Flag
 ├── AetherUI.Icons            -> Dicionário dos ícones vetoriais embutidos
 ├── AetherUI.RegisterIcon()   -> Registra ícone personalizado (vetor ou imagem)
 ├── AetherUI.CreateIcon()     -> Cria ícone avulso em qualquer GuiObject
 ├── AetherUI.GetIcons()       -> Lista nomes de ícones disponíveis
 ├── AetherUI.CreateWindow()   -> Retorna Window
 │    ├── Window.Flags         -> Tabela de Flags desta janela
 │    ├── Window:ExportConfig() / ImportConfig()
 │    ├── Window:SaveConfig() / LoadConfig() / DeleteConfig() / ListConfigs()
 │    ├── Window:CreateTab()   -> Retorna Tab (alias de AddTab)
 │    │    ├── CreateSection / AddSection
 │    │    ├── CreateLabel   / AddLabel
 │    │    ├── CreateButton  / AddButton
 │    │    ├── CreateToggle  / AddToggle
 │    │    ├── CreateSlider  / AddSlider
 │    │    ├── CreateRadioGroup / AddRadioGroup
 │    │    ├── CreateDropdown / AddDropdown
 │    │    ├── CreateMultiDropdown / AddMultiDropdown
 │    │    └── CreateColorPicker / AddColorPicker
 │    ├── Aba "Favoritos"      -> Gerada automaticamente (se FavoritesTab ~= false)
 │    └── Aba "Interface"      -> Gerada automaticamente (se Settings ~= false)
 └── AetherUI.Notify()         -> Exibe notificações independentes
```

---

## 4. Criação de Janelas (`CreateWindow`)

```lua
local Window = AetherUI.CreateWindow(config)
```

Se `config` for uma `string`, ela é tratada automaticamente como `{ Name = config }`.

### Parâmetros de `CreateWindow(config)`

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"AetherUI"` | Nome interno do `ScreenGui`. Se `Title` não for informado, também define o título exibido na barra superior. |
| `Title` | `string` | `Name` ou `"AetherUI"` | Título exibido na barra superior da janela. |
| `Accent` | `Color3` | `Color3.fromRGB(124, 92, 255)` | Define a cor de destaque inicial via `AetherUI.SetAccent`. |
| `Compact` | `boolean` | `false` | Ativa o modo compacto (dimensões e espaçamentos reduzidos). |
| `LowPerformance` | `boolean` | `false` | Desativa gradientes, sombras dinâmicas, luas de fundo e animações via tween. |
| `SidebarCollapsed` | `boolean` | `nil` (automático se largura < 360px) | Força a barra lateral recolhida (apenas ícones) ou expandida. |
| `CloseButton` | `boolean` | `true` | Exibe ou oculta o botão `X` de fechamento no topo. |
| `OnClose` | `function` | `nil` | Executado quando a janela é fechada definitivamente. |
| `Favorites` | `table` (`{string}`) | `{}` | Lista inicial de chaves de itens favoritos a restaurar. |
| `ShowFavoriteStars` | `boolean` | `false` | Inicia com os botões de estrela visíveis nos itens. |
| `OnFavoritesChanged` | `function(lista)` | `nil` | Callback disparado sempre que os favoritos são alterados. |
| `FavoritesTab` | `boolean` | `true` | Cria a aba `"Favoritos"`. Passe `false` para desabilitar. |
| `FavoriteButton` | `boolean` | `true` | Exibe o botão de estrela na barra superior. Passe `false` para ocultar. |
| `Settings` | `boolean` | `true` | Cria a aba `"Interface"`. Passe `false` para desabilitar. |
| `Dock` | `boolean` | `true` | Habilita o Floating Dock ao minimizar. Passe `false` para usar apenas a bolinha flutuante padrão. |
| `ConfigurationSaving` | `table` | `nil` | `{ Enabled = true, FolderName = "Pasta", FileName = "Perfil" }` para carregar automaticamente a configuração salva ao abrir (quando `readfile` estiver disponível). |
| `ConfigFolder` | `string` | `Name` ou `"AetherUI"` | Pasta padrão para salvar arquivos `.json`. |
| `ConfigFile` | `string` | `"default"` | Nome padrão do arquivo `.json` (sem precisar da extensão). |
| `AutoLoadConfig` | `boolean` | `false` | Ativa o carregamento automático ao criar a janela (equivalente a `ConfigurationSaving.Enabled`). |

### Métodos da Janela (`Window`)

| Método | Descrição |
| :--- | :--- |
| `Window:CreateTab(name, icon)` | Cria uma nova aba (alias de `Window:AddTab`). |
| `Window:AddTab(name, icon)` | Cria uma nova aba. Também aceita tabela `{ Name/Title, Icon, IconSize, IconColor }`. |
| `Window:SelectTab(target)` | Seleciona a aba pelo objeto `Tab` ou pelo nome (`string`). |
| `Window:GetSettingsTab()` | Retorna a aba embutida `"Interface"`. |
| `Window:GetFavoritesTab()` | Retorna a aba embutida `"Favoritos"`. |
| `Window:SetTitle(text)` | Altera o título exibido na barra superior. |
| `Window:SetAccent(color)` | Altera a cor de destaque global (`Color3`). |
| `Window:GetAccent()` | Retorna a `Color3` de destaque atual. |
| `Window:SetCompact(bool)` | Ativa/desativa o modo compacto e recalcula o layout. |
| `Window:GetCompact()` | Retorna `boolean` indicando se o modo compacto está ativo. |
| `Window:SetSidebarCollapsed(bool)` | Recolhe ou expande a barra lateral. |
| `Window:GetSidebarCollapsed()` | Retorna `boolean` indicando se a barra lateral está recolhida. |
| `Window:ToggleSidebar()` | Alterna entre barra lateral recolhida e expandida. |
| `Window:SetLowPerformance(bool)` | Ativa/desativa o modo de baixo desempenho global. |
| `Window:GetLowPerformance()` | Retorna `boolean` do modo de baixo desempenho. |
| `Window:Notify(config)` | Atalho para `AetherUI.Notify(config)`. |
| `Window:Minimize()` | Minimiza o painel principal e exibe o Floating Dock (ou bolinha flutuante). |
| `Window:Restore()` | Oculta o Floating Dock e restaura o painel principal (reverte mesmo durante a animação). |
| `Window:ExportConfig(asTable)` | Exporta todas as Flags + metadados (`Accent`, `Compact`, `LowPerformance`, `Favorites`) em string JSON (ou tabela se `asTable == true`). Funciona em qualquer ambiente Roblox. |
| `Window:ImportConfig(dataOrJson, silent)` | Restaura Flags e metadados a partir de string JSON ou tabela. |
| `Window:SaveConfig(fileName)` | Salva a configuração em `<ConfigFolder>/<fileName>.json` usando `writefile` (ou retorna `false, motivo` se `writefile` não existir). |
| `Window:LoadConfig(fileName, silent)` | Carrega a configuração de `<ConfigFolder>/<fileName>.json` usando `readfile`. |
| `Window:DeleteConfig(fileName)` | Remove um arquivo de configuração salvo usando `delfile`. |
| `Window:ListConfigs()` | Lista os nomes dos perfis `.json` encontrados na pasta configurada (`listfiles`). |
| `Window:SaveConfiguration(fileName)` | Alias de `Window:SaveConfig`. |
| `Window:LoadConfiguration(fileName, silent)` | Alias de `Window:LoadConfig`. |
| `Window:DeleteConfiguration(fileName)` | Alias de `Window:DeleteConfig`. |
| `Window:ListConfigurations()` | Alias de `Window:ListConfigs`. |
| `Window:Close(skipConfirm)` | Abre o modal de confirmação (`Sim`/`Não`). Se `skipConfirm == true`, fecha direto e oculta o Dock. |
| `Window:Destroy()` | Destrói imediatamente a `ScreenGui`, oculta o Dock, desconecta eventos e cancela tweens. |

### Métodos Globais de `AetherUI`

- `AetherUI.SetAccent(color)` / `AetherUI.GetAccent()` (aceitam chamada com `.` ou `:`)
- `AetherUI.SetLowPerformance(value)` / `AetherUI.GetLowPerformance()` (aceitam chamada com `.` ou `:`)
- `AetherUI.Notify(config)` (aceita chamada com `.` ou `:`)
- `AetherUI.RegisterIcon(name, spec)` — registra um ícone personalizado (`"rbxassetid://..."`, ID numérico, tabela de configuração ou formas vetoriais) pelo nome.
- `AetherUI.CreateIcon(spec, parent, size, color, opts)` — instancia qualquer ícone da biblioteca diretamente em um `GuiObject`.
- `AetherUI.GetIcons()` — retorna uma lista ordenada com todos os nomes de ícones embutidos e personalizados registrados.

---

## 5. Criação de Abas e Biblioteca de Ícones (`CreateTab` / `AddTab`)

```lua
local Tab = Window:CreateTab("Combate", "sword")
-- ou com personalização completa do ícone:
local Tab2 = Window:AddTab({
	Name = "Visual",
	Icon = "eye",
	IconSize = 18,
	IconColor = Color3.fromRGB(59, 130, 246),
})
```

### Formatos Aceitos para `Icon` e Personalização
Qualquer aba ou componente (`Section`, `Label`, `Button`, `Toggle`, `Slider`, `RadioGroup`, `Dropdown`, `MultiDropdown`, `ColorPicker`) aceita:
1. **Nome de ícone embutido ou registrado**: string como `"home"`, `"rocket"`, `"crosshair"`, etc.
2. **Imagem personalizada**: ID numérico (`113083945240866`), string numérica, `"rbxassetid://..."` ou URL `http...`.
3. **Tabela de configuração completa**:
   ```lua
   Icon = {
   	Name = "crown", -- ou Icon = ..., ou Image = "rbxassetid://..."
   	Size = 18,      -- sobrescreve o tamanho padrão
   	Color = Color3.fromRGB(245, 176, 65), -- mantém a cor personalizada mesmo em hover/aba ativa
   	Transparency = 0,
   	ScaleType = Enum.ScaleType.Fit,
   	CornerRadius = 6, -- útil para avatares/imagens personalizadas
   }
   ```
4. **Parâmetros diretos no componente**: `IconSize = number` e `IconColor = Color3`.
5. **Glifo Unicode curto** ou `false` para omitir.

### Catálogo de Ícones Vetoriais Embutidos (`AetherUI.Icons`)

- **Navegação & UI**: `"home"`, `"menu"`, `"grid"`, `"search"`, `"settings"`, `"sliders"`, `"filter"`, `"layers"`, `"list"`, `"maximize"`, `"chevron-right"`, `"chevron-left"`, `"chevron-down"`, `"external"`, `"link"`
- **Ações & Estado**: `"check"`, `"confirm"`, `"close"`, `"minus"`, `"plus"`, `"warning"`, `"info"`, `"bell"`, `"refresh"`, `"copy"`, `"edit"`, `"trash"`, `"save"`, `"upload"`, `"download"`, `"play"`, `"pause"`, `"stop"`, `"power"`
- **Combate, Jogo & Mundo**: `"sword"`, `"shield"`, `"target"`, `"crosshair"`, `"bolt"`, `"flame"`, `"sparkles"`, `"crown"`, `"gem"`, `"trophy"`, `"heart"`, `"skull"`, `"rocket"`, `"car"`, `"compass"`, `"globe"`, `"map"`, `"pin"`, `"coins"`, `"package"`
- **Perfil, Mídia & Sistema**: `"user"`, `"users"`, `"eye"`, `"eye-off"`, `"lock"`, `"unlock"`, `"key"`, `"palette"`, `"gauge"`, `"radio"`, `"circle"`, `"dot"`, `"dropdown"`, `"star"`, `"star_fill"`, `"bookmark"`, `"tag"`, `"clock"`, `"calendar"`, `"camera"`, `"image"`, `"music"`, `"volume"`, `"mic"`, `"message"`, `"send"`, `"cloud"`, `"wifi"`, `"cpu"`, `"terminal"`, `"code"`, `"bug"`, `"wrench"`, `"moon"`, `"sun"`, `"folder"`, `"file"`
- **Aliases práticos**: `"cog"`, `"gear"`, `"config"`, `"flash"`, `"lightning"`, `"alert"`, `"delete"`, `"reload"`, `"sync"`, `"aim"`, `"floppy"`, `"disk"`, `"hub"`, `"player"`, `"profile"`, `"x"`.

---

## 6. Criação de Seções (`CreateSection` / `AddSection`)

```lua
local Section = Tab:CreateSection("Controles", "bolt")
-- ou:
local Section2 = Tab:AddSection({
	Text = "Controles",
	Icon = "rocket",
	IconSize = 16,
	IconColor = Color3.fromRGB(124, 92, 255),
})
```

**Parâmetros:**
- `Text` ou `Name` (`string`): texto exibido em maiúsculas.
- `Icon` (`string | number | table | boolean`): ícone opcional. Quando ausente, exibe uma barra vertical com a cor de destaque.
- `IconSize` (`number`) e `IconColor` (`Color3`): opcionais.
- `Flag` (`string`): opcional.

**Métodos do objeto retornado:**
- `Section:SetText(novoTexto)` / `Section:Set(novoTexto)`
- `Section:Get()` → retorna o texto original (`string`).

---

## 7. Componentes Disponíveis

Todos os componentes possuem `Type`, `Flag` (quando informada) e suportam `Icon`, `IconSize` e `IconColor`, além de integração automática com a busca global e com os favoritos.

### 7.1. Label (`CreateLabel` / `AddLabel`)

```lua
local Label = Tab:CreateLabel("Texto informativo")
-- ou:
local Label2 = Tab:CreateLabel({ Text = "Status", Icon = "info", Flag = "StatusLabel" })
```

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Text` / `Name` | `string` | `"Label"` | Texto exibido (também aceita string direta como 1º argumento). |
| `Icon` | `string \| number \| table \| boolean` | `"info"` | Passe `false` para remover o ícone padrão. |
| `IconSize` / `IconColor` | `number` / `Color3` | automático | Tamanho e cor customizados para o ícone. |
| `Flag` | `string` | `nil` | Chave opcional em `Flags`. |

**Métodos:** `SetText(texto)`, `Set(texto)`, `Get()`.

---

### 7.2. Button (`CreateButton` / `AddButton`)

```lua
local Button = Tab:CreateButton({
	Name = "Executar",
	Icon = "bolt",
	IconSize = 18,
	IconColor = Color3.fromRGB(72, 199, 128),
	Flag = "BtnExecutar",
	Callback = function()
		print("Clicado!")
	end,
})
```

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Button"` | Texto do botão. |
| `Icon` | `string \| number \| table` | `nil` | Ícone opcional à esquerda. |
| `IconSize` / `IconColor` | `number` / `Color3` | automático | Tamanho e cor customizados para o ícone. |
| `Callback` | `function()` | `nil` | Executado ao clicar/tocar no botão. |
| `Flag` | `string` | `nil` | Chave opcional em `Flags`. |

**Métodos:** `SetText(texto)`, `Set(texto)`, `Get()`.

---

### 7.3. Toggle (`CreateToggle` / `AddToggle`)

```lua
local Toggle = Tab:CreateToggle({
	Name = "Ativar",
	Icon = "check",
	CurrentValue = false, -- ou Default (AddToggle)
	Flag = "MeuToggle",
	Callback = function(valor)
		print("Toggle:", valor)
	end,
})
```

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Toggle"` | Rótulo do interruptor. |
| `Icon` | `string \| number \| table` | `nil` | Ícone opcional à esquerda. |
| `CurrentValue` / `Default` | `boolean` | `false` | Estado inicial. `CurrentValue` tem prioridade sobre `Default`. |
| `Flag` | `string` | `nil` | Chave em `AetherUI.Flags` e `Window.Flags`. |
| `Callback` | `function(boolean)` | `nil` | Disparado quando o estado muda. |

**Métodos e Propriedades:**
- `Toggle:Set(valor, silent)`
- `Toggle:Get()` → `boolean`
- `Toggle:SetText(texto)`
- `Toggle.CurrentValue` → lê o estado atual dinamicamente (`boolean`)
- `Toggle.Type` → `"Toggle"`

---

### 7.4. Slider (`CreateSlider` / `AddSlider`)

```lua
local Slider = Tab:CreateSlider({
	Name = "Velocidade",
	Icon = "gauge",
	Range = { 0, 100 },  -- ou Min / Max no AddSlider
	Increment = 5,       -- ou Step no AddSlider
	Suffix = " km/h",
	CurrentValue = 50,   -- ou Default no AddSlider
	Flag = "Vel",
	Callback = function(valor)
		print("Valor:", valor)
	end,
})
```

- Possui captura tátil calibrada (`detectPointerOffset` + `Active = true`) e pausa automática do scroll vertical durante o arraste no Mobile.

**Métodos e Propriedades:**
- `Slider:Set(numero, silent)`
- `Slider:Get()` → `number`
- `Slider.CurrentValue` → número atual dinâmico
- `Slider.Type` → `"Slider"`

---

### 7.5. RadioGroup (`CreateRadioGroup` / `AddRadioGroup`)

Lista inline de seleção única exclusiva com anel indicador animado, compatível com Mobile, Busca Global, Favoritos, Flags e Save Configuration.

```lua
local Radio = Tab:CreateRadioGroup({
	Name = "Modo de Prioridade",
	Icon = "crosshair",
	Options = { "Mais Proximo", "Menor Vida", "Aleatorio" },
	CurrentOption = "Mais Proximo", -- ou Default / CurrentValue
	Flag = "Prioridade",
	Callback = function(selecionado)
		print("Selecionado:", tostring(selecionado))
	end,
})
```

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Radio Group"` / `"Selecao Unica"` | Título do grupo. |
| `Icon` | `string \| number \| table` | `nil` | Ícone opcional à esquerda. |
| `Options` | `table` | `{}` | Lista de opções exibidas como botões de rádio. |
| `CurrentOption` / `CurrentValue` / `Default` | `any` | `nil` | Opção inicial selecionada (deve existir em `Options`). |
| `Flag` | `string` | `nil` | Chave em `Flags` (incluída em `SaveConfig` / `ExportConfig`). |
| `Callback` | `function(valor)` | `nil` | Chamado quando a opção muda (ou `nil` ao usar `Clear()`). |

**Métodos e Propriedades:**
- `Radio:Set(valor, silent)` — seleciona a opção correspondente (ou chama `Clear(silent)` se `valor == nil`).
- `Radio:Get()` → opção atual selecionada (ou `nil`).
- `Radio:Clear(silent)` — limpa a seleção atual.
- `Radio:SetOptions(novasOpcoes, silent)` / `Radio:Refresh(novasOpcoes, silent)` — atualiza a lista de opções disponíveis; limpa a seleção caso a anterior não exista mais.
- `Radio:SetText(novoTitulo)`
- `Radio.CurrentValue` e `Radio.CurrentOption` → retornam `Radio:Get()`.
- `Radio.Type` → `"RadioGroup"`

---

### 7.6. Dropdown (`CreateDropdown` / `AddDropdown`)

```lua
local Dropdown = Tab:CreateDropdown({
	Name = "Arma",
	Icon = "sword",
	Options = { "Sword", "Bow", "Staff" },
	CurrentOption = { "Sword" }, -- aceita string ou tabela
	MultipleOptions = false,
	Flag = "Arma",
	Callback = function(opcoes)
		print("Selecionada:", opcoes[1])
	end,
})
```

> **Diferença importante entre `CreateDropdown` e `AddDropdown`:**
> - Em `CreateDropdown` (padrão Rayfield, sem `MultipleOptions = true`), o `Callback` recebe **sempre uma tabela**: `{ "Sword" }` ou `{}` quando vazio.
> - Em `AddDropdown` (API clássica), o `Callback` recebe **o valor direto** (ex.: `"Sword"` ou `nil` ao chamar `Clear`).

**Métodos:** `Set(valor, silent)`, `Get()`, `Clear(silent)`, `SetOptions(opcoes, silent)`, `Refresh(opcoes, silent)`, `Open()`, `Close()`, `Toggle()`, `IsOpen()`, `SetText(texto)`.

---

### 7.7. MultiDropdown (`CreateMultiDropdown` / `AddMultiDropdown`)

```lua
local Multi = Tab:CreateMultiDropdown({
	Name = "Modulos",
	Icon = "layers",
	Options = { "ESP", "Fly", "Speed" },
	CurrentOption = { "ESP" },
	Flag = "Modulos",
	Callback = function(lista)
		print("Selecionados:", table.concat(lista, ", "))
	end,
})
```

**Métodos:** `Set(valores, silent)`, `Get()`, `Toggle(opcao)`, `Clear(silent)`, `SetOptions(opcoes, silent)`, `Refresh(opcoes, silent)`, `Open()`, `Close()`, `IsOpen()`, `SetText(texto)`.

---

### 7.8. ColorPicker (`CreateColorPicker` / `AddColorPicker`)

```lua
local Picker = Tab:CreateColorPicker({
	Name = "Cor",
	Icon = "palette",
	Color = Color3.fromRGB(124, 92, 255), -- ou Default no AddColorPicker
	Colors = { Color3.fromRGB(124, 92, 255), Color3.fromRGB(59, 130, 246) },
	Flag = "Cor",
	Callback = function(cor)
		print("Nova cor:", cor)
	end,
})
```

- **Precisão no Mobile (v2.7.0)**: utiliza hitboxes `Active = true`, listener global no `UserInputService.InputChanged` e calibração de coordenadas (`detectPointerOffset`), fazendo com que os seletores de **Saturação/Valor (SV)** e **Matiz (Hue)** acompanhem exatamente a posição do dedo sem deslocamentos de Topbar/GuiInset.
- Inclui campo `#RRGGBB`, grade `TONS` e grade `PRESETS`.

**Métodos:** `Set(color3, silent)`, `Get()`, `SetText(texto)`, `Open()`, `Close()`, `Toggle()`, `IsOpen()`.

---

### 7.9. Notificações (`AetherUI.Notify` / `Window:Notify`)

```lua
local n = AetherUI.Notify({
	Title = "Aviso",
	Content = "Configuracao aplicada com sucesso.",
	Type = "success", -- "info", "success", "warning", "error"
	Duration = 4,     -- <= 0 ou >= 1000000 cria notificacao persistente
	Color = nil,      -- Color3 opcional
	Icon = nil,       -- icone opcional (aceita tabela { Name, Size, Color })
	Callback = function()
		print("Usuario clicou na notificacao")
	end,
})
```

---

## 8. `Get`, `Set` e Atualização Silenciosa (`silent`)

Todos os componentes interativos implementam `:Get()` e `:Set(valor, silent)`:
- Quando `silent` é `nil` ou `false`, `:Set(...)` atualiza a interface e executa o `Callback`.
- Quando `silent` é `true`, `:Set(...)` atualiza apenas o estado interno e a interface visual, **sem disparar o `Callback`**.

---

## 9. `Callbacks` e `Flags`

Sempre que você informa `Flag = "MinhaChave"` em qualquer componente (`Section`, `Label`, `Button`, `Toggle`, `Slider`, `RadioGroup`, `Dropdown`, `MultiDropdown`, `ColorPicker`):
- O objeto fica acessível em **`AetherUI.Flags["MinhaChave"]`** e **`Window.Flags["MinhaChave"]`**.
- Caso uma `Flag` registrada corresponda a um valor previamente carregado por `ConfigurationSaving`, ela é aplicada silenciosamente durante a criação do componente.

---

## 10. Configurações, Favoritos e Save Configuration

### Floating Dock (Minimizar / Abrir)
- Quando a janela é aberta inicialmente ou restaurada (`Window:Restore()`), o **Floating Dock permanece oculto** (`Visible = false`).
- Ao minimizar a janela (`Window:Minimize()` ou botão `-`), o **Floating Dock aparece** no topo (com esfera central + pílula expansível).
- Ao tocar na esfera do Dock ou em qualquer um dos atalhos da pílula (`menu`, `star`, `search`, `settings`), a janela principal abre e o Dock desaparece novamente.

### Save Configuration (JSON e Sistema de Arquivos)
- **`Window:ExportConfig(asTable)` / `Window:ImportConfig(dataOrJson, silent)`**: funcionam em **qualquer ambiente** (Roblox Studio e executores) serializando todas as Flags (incluindo `Color3`, `RadioGroup`, `Toggle`, `Slider`, `Dropdown`, `MultiDropdown`) e metadados da janela (`Accent`, `Compact`, `LowPerformance`, `Favorites`) via `HttpService:JSONEncode` / `JSONDecode`.
- **`Window:SaveConfig(fileName)` / `LoadConfig` / `DeleteConfig` / `ListConfigs`** (e aliases `SaveConfiguration` / `LoadConfiguration` / `DeleteConfiguration` / `ListConfigurations`): gravam e lêem `<ConfigFolder>/<fileName>.json` quando `writefile`/`readfile` estão disponíveis no ambiente. Se essas funções não existirem (ex.: Roblox Studio padrão), retornam `false` com a explicação honesta do motivo em vez de simular um salvamento em disco.
- Na aba embutida **`"Interface"`**, a seção **`"Configuracoes"`** oferece botões diretos para salvar, carregar e exportar JSON para a área de transferência.

### Sistema de Favoritos
Métodos disponíveis na `Window`:
- `Window:GetFavorites()` / `Window:SetFavorites(lista)` / `Window:ClearFavorites()` / `Window:IsFavorite(chave)`
- `Window:SetFavoritesVisible(bool)` / `Window:GetFavoritesVisible()` / `Window:ToggleFavoritesMode()`

---

## 11. Busca Global

A barra de pesquisa acima das abas indexa automaticamente em tempo real abas, seções, labels, botões, toggles, sliders, **radio groups** (e suas opções), dropdowns (e suas opções), color pickers e configurações.

---

## 12. Compatibilidade e Observações Importantes

1. **Compatibilidade Rayfield e Scripts Antigos**:
   - Toda a API clássica (`AddTab`, `AddSection`, `AddLabel`, `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiDropdown`, `AddColorPicker`) permanece 100% compatível e agora também inclui `AddRadioGroup`.
   - Os métodos `CreateWindow`, `CreateTab`, `CreateSection`, `CreateLabel`, `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateRadioGroup`, `CreateDropdown`, `CreateMultiDropdown` e `CreateColorPicker` traduzem parâmetros no estilo Rayfield para os componentes reais da AetherUI.
   - Parâmetros exclusivos da Rayfield não utilizados (como `LoadingTitle`, `KeySystem`, `Theme`) continuam sendo ignorados sem gerar erros, enquanto `ConfigurationSaving` agora integra diretamente com o sistema real de salvamento da AetherUI.
2. **Apenas um painel aberto por vez**: abrir um `Dropdown`, `MultiDropdown` ou `ColorPicker` fecha automaticamente qualquer outro painel aberto na mesma janela.
3. **Execução única por `Name`**: ao chamar `AetherUI.CreateWindow({ Name = "X" })`, caso já exista uma `ScreenGui` com o mesmo `Name`, a anterior é destruída antes de criar a nova.
4. **Arquivos completos de referência**: consulte `AetherUI_Examples.lua` para exemplos executáveis atualizados da versão `v2.7.0`.
