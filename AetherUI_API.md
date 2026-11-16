# AetherUI — Documentação Técnica da API (v2.6.0)

Manual técnico oficial baseado diretamente na implementação real de `AetherUI.lua`.

---

## 1. Introdução à AetherUI

A **AetherUI** (`v2.6.0`) é uma biblioteca de interface gráfica em arquivo único para Roblox (`LocalScript`), projetada para funcionar tanto em **PC** quanto em **Mobile**.

Principais recursos embutidos na biblioteca:
- **Sistema de animação centralizado**: cache de `TweenInfo`, mesclagem de tweens concorrentes sem travamentos e atribuição direta quando elementos estão ocultos ou no modo de baixo desempenho.
- **Busca global integrada**: barra de pesquisa no topo da barra lateral que indexa abas, seções, textos, botões, toggles, sliders, dropdowns (e suas opções individuais), color pickers e configurações.
- **Sistema de Favoritos**: botão de estrela no cabeçalho para exibir/ocultar estrelas individuais em abas, seções e componentes, além de uma aba dedicada `"Favoritos"`.
- **Dock flutuante superior**: esfera central (minimiza/restaura a janela ao tocar) com pílula expansível contendo atalhos rápidos (`menu`, `star`, `search`, `settings`). Segurar por `1.5s` oculta/exibe a pílula lateral.
- **Notificações**: fila independente (`DisplayOrder = 990`, sempre abaixo da janela principal), com tipos semânticos (`info`, `success`, `warning`, `error`), barra de progresso e callback de clique.
- **Aba embutida "Interface"**: permite ao usuário ajustar em tempo real a cor de destaque (`Accent`), o modo compacto, o recolhimento da barra lateral e o modo baixo desempenho.
- **Camada de compatibilidade estilo Rayfield**: suporta tanto os métodos clássicos (`AddTab`, `AddToggle`, etc.) quanto os métodos padronizados (`CreateTab`, `CreateToggle`, etc.) e registro automático em `Flags`.

---

## 2. Instalação e Utilização

> **Importante:** A AetherUI cria interfaces em `gethui()` (quando disponível) ou `Players.LocalPlayer.PlayerGui`. Portanto, deve ser executada a partir de um **LocalScript** no cliente.

### Opção 1: Uso via `ModuleScript` (Roblox Studio)
1. Copie o conteúdo integral de `AetherUI.lua` para um `ModuleScript` (por exemplo, em `ReplicatedStorage.AetherUI`).
2. Carregue no seu `LocalScript`:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AetherUI = require(ReplicatedStorage:WaitForChild("AetherUI"))
```

### Opção 2: Uso via `loadstring` + `HttpGet` (GitHub RAW)
Com o arquivo `AetherUI.lua` hospedado em um repositório GitHub, utilize o link RAW estável:
```lua
local AetherUI = loadstring(game:HttpGet("LINK_RAW_DA_AETHERUI"))()
```

---

## 3. Estrutura da Biblioteca

A hierarquia de objetos da AetherUI segue o fluxo:

```text
AetherUI (módulo global)
 ├── AetherUI.Version          -> "2.6.0"
 ├── AetherUI.Flags            -> Tabela global de componentes com Flag
 ├── AetherUI.CreateWindow()   -> Retorna Window
 │    ├── Window.Flags         -> Tabela de Flags desta janela
 │    ├── Window:CreateTab()   -> Retorna Tab (alias de AddTab)
 │    │    ├── CreateSection / AddSection
 │    │    ├── CreateLabel   / AddLabel
 │    │    ├── CreateButton  / AddButton
 │    │    ├── CreateToggle  / AddToggle
 │    │    ├── CreateSlider  / AddSlider
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
| `Dock` | `boolean` | `true` | Cria a dock flutuante superior. Passe `false` para usar a bolinha padrão ao minimizar. |

### Métodos da Janela (`Window`)

| Método | Descrição |
| :--- | :--- |
| `Window:CreateTab(name, icon)` | Cria uma nova aba (alias de `Window:AddTab`). |
| `Window:AddTab(name, icon)` | Cria uma nova aba. Também aceita tabela `{ Name/Title, Icon }`. |
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
| `Window:Minimize()` | Minimiza a janela para a esfera da Dock (ou bolinha flutuante). |
| `Window:Restore()` | Restaura a janela minimizada (reverte mesmo durante a animação). |
| `Window:Close(skipConfirm)` | Abre o modal de confirmação (`Sim`/`Não`). Se `skipConfirm == true`, fecha direto. |
| `Window:Destroy()` | Destrói imediatamente a `ScreenGui`, desconecta eventos e cancela tweens. |

### Métodos Globais de `AetherUI`

- `AetherUI.SetAccent(color)` / `AetherUI.GetAccent()` (aceitam chamada com `.` ou `:`)
- `AetherUI.SetLowPerformance(value)` / `AetherUI.GetLowPerformance()` (aceitam chamada com `.` ou `:`)
- `AetherUI.Notify(config)` (aceita chamada com `.` ou `:`)

---

## 5. Criação de Abas (`CreateTab` / `AddTab`)

```lua
local Tab = Window:CreateTab("Combate", "sword")
-- ou:
local Tab2 = Window:AddTab({ Name = "Visual", Icon = "eye" })
```

Se `icon` for omitido (`nil`), a biblioteca escolhe automaticamente um ícone vetorial pelo nome da aba (`guessIcon`):
- `"principal"`, `"main"`, `"home"`, `"inicio"`, `"geral"` → `"home"`
- `"config"`, `"setting"`, `"ajuste"`, `"opcoes"` → `"settings"`
- `"combat"`, `"aim"`, `"attack"`, `"pvp"`, `"fight"` → `"sword"`
- `"visual"`, `"esp"`, `"view"`, `"render"` → `"eye"`
- `"player"`, `"jogador"`, `"user"`, `"perfil"`, `"conta"` → `"user"`
- `"teleport"`, `"alvo"`, `"target"`, `"mapa"` → `"target"`
- `"farm"`, `"auto"`, `"speed"`, `"exploit"`, `"script"` → `"bolt"`
- `"prote"`, `"defes"`, `"segur"`, `"anti"` → `"shield"`
- `"notif"`, `"aviso"`, `"alert"` → `"bell"`
- `"info"`, `"sobre"`, `"about"`, `"ajuda"` → `"info"`
- `"tema"`, `"theme"`, `"color"`, `"aparenc"` → `"palette"`
- Padrão caso não corresponda: `"grid"`.

### Ícones Vetoriais Embutidos (`Icon`)
Qualquer componente ou aba aceita no parâmetro `Icon`:
- Nome de ícone embutido: `"home"`, `"settings"`, `"user"`, `"eye"`, `"bolt"`, `"shield"`, `"sword"`, `"grid"`, `"bell"`, `"info"`, `"check"`, `"close"`, `"minus"`, `"menu"`, `"warning"`, `"star"`, `"star_fill"`, `"gauge"`, `"palette"`, `"target"`, `"list"`, `"maximize"`, `"search"`, `"dropdown"`, `"confirm"`, `"chevron-right"`, `"chevron-left"`, `"chevron-down"`.
- Asset ID numérico (ex.: `113083945240866`), string numérica (`"113083945240866"`), `"rbxassetid://..."` ou URL `http...`.
- Texto curto / glifo Unicode.
- `false` ou `nil` para não exibir ícone (exceto `Label`, que usa `"info"` por padrão quando `Icon == nil`).

---

## 6. Criação de Seções (`CreateSection` / `AddSection`)

```lua
local Section = Tab:CreateSection("Controles", "bolt")
-- ou:
local Section2 = Tab:AddSection({ Text = "Controles", Icon = "bolt" })
-- ou apenas string:
local Section3 = Tab:CreateSection("Controles")
```

**Parâmetros:**
- `Text` ou `Name` (`string`): texto exibido em maiúsculas.
- `Icon` (`string | number | boolean`): ícone opcional. Quando ausente, exibe uma barra vertical com a cor de destaque.
- `Flag` (`string`): opcional.

**Métodos do objeto retornado:**
- `Section:SetText(novoTexto)` / `Section:Set(novoTexto)`
- `Section:Get()` → retorna o texto original (`string`).

---

## 7. Componentes Disponíveis

Todos os componentes possuem `Type` e `Flag` (quando informada), além de integração automática com a busca global e com os favoritos.

### 7.1. Label (`CreateLabel` / `AddLabel`)

```lua
local Label = Tab:CreateLabel("Texto informativo")
-- ou:
local Label2 = Tab:CreateLabel({ Text = "Status", Icon = "info", Flag = "StatusLabel" })
```

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Text` / `Name` | `string` | `"Label"` | Texto exibido (também aceita string direta como 1º argumento). |
| `Icon` | `string \| number \| boolean` | `"info"` | Passe `false` para remover o ícone padrão. |
| `Flag` | `string` | `nil` | Chave opcional em `Flags`. |

**Métodos:** `SetText(texto)`, `Set(texto)`, `Get()`.

---

### 7.2. Button (`CreateButton` / `AddButton`)

```lua
local Button = Tab:CreateButton({
	Name = "Executar",
	Icon = "bolt",
	Flag = "BtnExecutar",
	Callback = function()
		print("Clicado!")
	end,
})
```

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Button"` | Texto do botão. |
| `Icon` | `string \| number` | `nil` | Ícone opcional à esquerda. |
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
| `Icon` | `string \| number` | `nil` | Ícone opcional à esquerda. |
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

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Slider"` | Rótulo do controle. |
| `Icon` | `string \| number` | `nil` | Ícone opcional à esquerda. |
| `Range` | `{ number, number }` | `{ 0, 100 }` | Limites `{ Min, Max }` para `CreateSlider`. |
| `Min` / `Max` | `number` | `0` / `100` | Limites diretos (usados por `AddSlider` ou como fallback). |
| `Increment` / `Step` | `number` | `1` | Passo de arredondamento (`Increment` tem prioridade). |
| `Suffix` | `string` | `""` | Sufixo exibido junto ao número (ex.: `"%"`, `"m"`). |
| `CurrentValue` / `Default` | `number` | `Min` | Valor inicial ajustado ao passo. |
| `Flag` | `string` | `nil` | Chave em `Flags`. |
| `Callback` | `function(number)` | `nil` | Chamado ao alterar o valor. |

**Métodos e Propriedades:**
- `Slider:Set(numero, silent)`
- `Slider:Get()` → `number`
- `Slider.CurrentValue` → número atual dinâmico
- `Slider.Type` → `"Slider"`

---

### 7.5. Dropdown (`CreateDropdown` / `AddDropdown`)

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

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Dropdown"` / `"Selecionar"` | Título do seletor. |
| `Icon` | `string \| number` | `nil` | Ícone opcional à esquerda. |
| `Options` | `table` | `{}` | Lista de opções disponíveis. |
| `CurrentOption` / `Default` | `string \| table` | `nil` | Opção inicial selecionada. |
| `MultipleOptions` | `boolean` | `false` | Se `true`, delega automaticamente para `MultiDropdown`. |
| `Flag` | `string` | `nil` | Chave em `Flags`. |
| `Callback` | `function` | `nil` | Recebe `{ valor }` em `CreateDropdown` ou `valor` em `AddDropdown`. |

**Métodos e Propriedades:**
- `Dropdown:Set(valor, silent)` — aceita `"Opcao"`, `{ "Opcao" }`, ou `nil` (limpa seleção).
- `Dropdown:Get()` → valor selecionado ou `nil`.
- `Dropdown:Clear(silent)` — limpa a seleção atual.
- `Dropdown:SetOptions(novasOpcoes, silent)` / `Dropdown:Refresh(novasOpcoes, silent)` — substitui a lista de opções; se a opção atual deixar de existir, limpa a seleção.
- `Dropdown:Open()`, `Dropdown:Close()`, `Dropdown:Toggle()`, `Dropdown:IsOpen()`
- `Dropdown:SetText(texto)`
- `Dropdown.CurrentValue` → valor único atual (ou `nil`)
- `Dropdown.CurrentOption` → `{ valor }` ou `{}`
- `Dropdown.Type` → `"Dropdown"`

---

### 7.6. MultiDropdown (`CreateMultiDropdown` / `AddMultiDropdown`)

```lua
local Multi = Tab:CreateMultiDropdown({
	Name = "Modulos",
	Icon = "list",
	Options = { "ESP", "Fly", "Speed" },
	CurrentOption = { "ESP" },
	Flag = "Modulos",
	Callback = function(lista)
		print("Selecionados:", table.concat(lista, ", "))
	end,
})
```

**Diferenças específicas do MultiDropdown:**
- `Callback` recebe uma lista ordenada conforme `Options` (ex.: `{ "ESP", "Speed" }`).
- `Multi:Set(valores, silent)` aceita tabela (`{ "ESP", "Fly" }`) ou string única (`"ESP"`).
- `Multi:Toggle(opcao)` alterna uma opção específica e dispara o `Callback`.
- `Multi:Clear(silent)` desmarca todas as opções e dispara `Callback({})` (se `silent` não for `true`).
- `Multi:SetOptions(novasOpcoes, silent)` / `Multi:Refresh(novasOpcoes, silent)`
- `Multi:Open()`, `Multi:Close()`, `Multi:IsOpen()`, `Multi:SetText(texto)`
- `Multi.Multiple` → `true`
- `Multi.Type` → `"Dropdown"`
- `Multi.CurrentValue` e `Multi.CurrentOption` → retornam `Multi:Get()` (lista de selecionados).

---

### 7.7. ColorPicker (`CreateColorPicker` / `AddColorPicker`)

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

Interface embutida do painel:
- Quadrado SV (saturação/valor) com seletor circular + barra lateral de matiz (Hue), compatíveis com mouse e toque.
- Campo de texto `#RRGGBB` editável (aceita formatos HEX de 3 ou 6 dígitos).
- Grade `TONS` (branco ao preto) e grade `PRESETS` (`Colors` ou `DefaultSwatches` da biblioteca).

| Parâmetro | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `Name` | `string` | `"Color Picker"` / `"Cor"` | Rótulo do controle. |
| `Icon` | `string \| number` | `"palette"` | Ícone exibido à esquerda. |
| `Color` / `Default` | `Color3` | `Color3.fromRGB(255, 255, 255)` | Cor inicial. |
| `Colors` | `{ Color3 }` | `DefaultSwatches` (8 cores) | Lista de presets circulares exibidos no painel. |
| `Flag` | `string` | `nil` | Chave em `Flags`. |
| `Callback` | `function(Color3)` | `nil` | Executado quando a cor muda. |

**Métodos e Propriedades:**
- `Picker:Set(color3, silent)`
- `Picker:Get()` → `Color3`
- `Picker:SetText(texto)`
- `Picker:Open()`, `Picker:Close()`, `Picker:Toggle()`, `Picker:IsOpen()`
- `Picker.CurrentValue`, `Picker.Color`, `Picker.CurrentColor` → retornam a `Color3` atual.
- `Picker.Type` → `"ColorPicker"`

---

### 7.8. Notificações (`AetherUI.Notify` / `Window:Notify`)

```lua
local n = AetherUI.Notify({
	Title = "Aviso",
	Content = "Configuracao aplicada com sucesso.",
	Type = "success", -- "info", "success", "warning", "error"
	Duration = 4,     -- <= 0 ou >= 1000000 cria notificacao persistente
	Color = nil,      -- Color3 opcional (sobrescreve a cor do Type)
	Icon = nil,       -- icone opcional (nil usa o icone do Type; false oculta)
	Callback = function()
		print("Usuario clicou na notificacao")
	end,
})
-- Para fechar manualmente:
-- n.Dismiss()
```

- Máximo de **5** notificações simultâneas na tela (a mais antiga é fechada automaticamente quando o limite é excedido).
- `DisplayOrder = 990` (sempre posicionada abaixo da janela principal, que usa `1000`).
- Em `AetherUI.Notify("Texto")`, a string é tratada como `{ Title = "Texto" }`.

---

## 8. `Get`, `Set` e Atualização Silenciosa (`silent`)

Todos os componentes interativos implementam `:Get()` e `:Set(valor, silent)`:
- Quando `silent` é `nil` ou `false`, `:Set(...)` atualiza a interface e executa o `Callback`.
- Quando `silent` é `true`, `:Set(...)` atualiza apenas o estado interno e a interface visual, **sem disparar o `Callback`**.
- `Clear(silent)` em `Dropdown` e `MultiDropdown` segue a mesma regra de `silent`.

```lua
-- Atualiza o slider para 80 sem acionar o Callback
Slider:Set(80, true)
```

---

## 9. `Callbacks` e `Flags`

Sempre que você informa `Flag = "MinhaChave"` em qualquer componente (`Section`, `Label`, `Button`, `Toggle`, `Slider`, `Dropdown`, `MultiDropdown`, `ColorPicker`):
- O objeto retornado passa a ficar acessível em **`AetherUI.Flags["MinhaChave"]`** e **`Window.Flags["MinhaChave"]`**.
- Caso uma mesma `Flag` seja reutilizada, a biblioteca emite um aviso via `warn(...)` e substitui a referência anterior.
- Propriedades como `CurrentValue`, `CurrentOption`, `Color` e `CurrentColor` são lidas dinamicamente via `metatable.__index`, refletindo sempre o estado mais recente do componente.

```lua
if AetherUI.Flags.AutoMode.CurrentValue then
	print("Velocidade atual:", AetherUI.Flags.Velocidade.CurrentValue)
end
```

---

## 10. Configurações, Favoritos e Salvamento

### Aba "Interface" Embutida
Quando `Settings ~= false`, a janela cria automaticamente a aba `"Interface"` com os controles sincronizados:
- **Cor de destaque** (`ColorPicker`) → chama `AetherUI.SetAccent(cor)`.
- **Modo compacto** (`Toggle`) → chama `Window:SetCompact(valor)`.
- **Sidebar só com ícones** (`Toggle`) → chama `Window:SetSidebarCollapsed(valor)`.
- **Modo baixo desempenho** (`Toggle`) → chama `AetherUI.SetLowPerformance(valor)`.

### Sistema de Favoritos e Persistência
Cada aba, seção e componente recebe uma chave determinística no formato:
- Aba: `"T::<NomeAba>"`
- Seção: `"S::<NomeAba>::Section::<Texto>#<n>"`
- Componente: `"C::<NomeAba>::<Kind>::<Nome>#<n>"`

Ocultar as estrelas pelo botão do topo (`ToggleFavoritesMode()`) **não apaga** os favoritos salvos.

Métodos disponíveis na `Window`:
- `Window:GetFavorites()` → retorna lista ordenada de chaves (`{ string }`).
- `Window:SetFavorites(lista)` → restaura uma lista de chaves.
- `Window:ClearFavorites()` → remove todos os favoritos.
- `Window:IsFavorite(chave)` → retorna `boolean`.
- `Window:SetFavoritesVisible(bool)` / `Window:GetFavoritesVisible()` / `Window:ToggleFavoritesMode()`.

Para persistir favoritos e Flags entre sessões (por exemplo, usando `writefile`/`readfile` em executores compatíveis ou `HttpService:JSONEncode`), basta salvar `Window:GetFavorites()` no evento `OnFavoritesChanged` e passar a tabela recuperada em `Favorites` ao chamar `AetherUI.CreateWindow`.

---

## 11. Busca Global

A barra de pesquisa acima das abas indexa automaticamente em tempo real:
- Nomes de abas (inclusive `"Interface"` e `"Favoritos"`),
- Nomes de seções e componentes,
- Caminhos (`Aba / Seção`),
- Tipos em português e inglês (`aba`, `botão`, `toggle`, `slider`, `dropdown`, `cor`, etc.),
- Opções internas de `Dropdown` e `MultiDropdown`.

Ao clicar em um resultado (ou pressionar `Enter`), a biblioteca muda para a aba correspondente, abre o dropdown (quando o resultado for uma opção interna), rola a página até o componente e aplica um destaque visual temporário.

---

## 12. Compatibilidade e Observações Importantes

1. **Compatibilidade Rayfield**:
   - Os métodos `CreateWindow`, `CreateTab`, `CreateSection`, `CreateLabel`, `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateDropdown`, `CreateMultiDropdown` e `CreateColorPicker` são uma camada aditiva sobre os métodos `Add*`.
   - Se parâmetros novos (`CurrentValue`, `Range`, `Increment`, `CurrentOption`, `Color`) e antigos (`Default`, `Min`, `Max`, `Step`) forem enviados juntos, os novos têm prioridade.
   - Parâmetros exclusivos da Rayfield que não fazem parte da arquitetura da AetherUI (como `LoadingTitle`, `ConfigurationSaving`, `KeySystem` e `Theme`) são ignorados sem gerar erro.
2. **Apenas um painel aberto por vez**: abrir um `Dropdown`, `MultiDropdown` ou `ColorPicker` fecha automaticamente qualquer outro painel que esteja aberto na mesma janela, e clicar fora do controle fecha o painel aberto.
3. **Execução única por `Name`**: ao chamar `AetherUI.CreateWindow({ Name = "X" })`, caso já exista uma `ScreenGui` com o mesmo `Name` no container pai (`gethui()` / `PlayerGui`), a anterior é destruída antes de criar a nova.
4. **Arquivos completos de referência**: consulte `AetherUI_Examples.lua` para exemplos executáveis de todos os recursos descritos neste manual.
