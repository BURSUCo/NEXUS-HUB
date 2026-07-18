# 📚 Nothing Library — Documentație Completă

> **Versiune:** 1.0  
> **Platformă:** Delta Executor / Roblox  
> **Repo:** [github.com/BURSUCo/NEXUS-HUB](https://github.com/BURSUCo/NEXUS-HUB)  
> **Loadstring URL:** `https://raw.githubusercontent.com/BURSUCo/NEXUS-HUB/refs/heads/main/ui-library/library.lua`

---

## 📋 Cuprins

1. [Introducere](#-introducere)
2. [Încărcare & Inițializare](#-încărcare--inițializare)
3. [Configurare Fereastră](#-configurare-fereastră-librarynew)
4. [Tab-uri](#-tab-uri-windowtablenewtab)
5. [Secțiuni / Groupbox-uri](#-secțiuni--groupbox-uri-addleftgroupboxaddrightgroupbox)
6. [Componente](#-componente)
   - [Toggle](#1-newtoggle)
   - [Button](#2-newbutton)
   - [Slider](#3-newslider)
   - [Dropdown](#4-newdropdown)
   - [Keybind](#5-newkeybind)
   - [Textbox](#6-newtextbox)
   - [Title](#7-newtitle)
7. [Efecte & Gradiente](#-efecte--gradiente)
8. [Notificări](#-notificări)
9. [Console](#-console)
10. [Dropdown System](#-dropdown-system)
11. [Exemple Complete](#-exemple-complete)
12. [Referință Rapidă](#-referință-rapidă)

---

## 🚀 Introducere

**Nothing Library** este o bibliotecă UI modernă pentru script-uri Roblox care rulează prin executori precum **Delta Executor**. Oferă o interfață completă cu:

- 🔹 Ferestre mobile și minimizabile
- 🔹 Sistem de tab-uri
- 🔹 Secțiuni stânga/dreapta (Groupbox-uri)
- 🔹 Componente: Toggle, Button, Slider, Dropdown, Keybind, Textbox
- 🔹 Efecte vizuale (blur, gradient)
- 🔹 Sistem de notificări
- 🔹 Consolă integrată
- 🔹 Animații Tween

---

## 📥 Încărcare & Inițializare

```lua
-- Încarcă biblioteca
local Library = loadstring(game:HttpGetAsync([[
    https://raw.githubusercontent.com/BURSUCo/NEXUS-HUB/refs/heads/main/ui-library/library.lua
]]))()

-- Creează fereastra principală
local Window = Library.new({
    Title       = "Numele Scriptului",
    Description = "descrierea scriptului",
    Keybind     = Enum.KeyCode.LeftControl,
    Logo        = "http://www.roblox.com/asset/?id=18810965406",
    Size        = UDim2.new(0, 445, 0, 315)
})
```

Fereastra creată poate fi:
- 🔄 **Mută** — trage de header
- 🔽 **Minimizată** — apasă butonul home (⚪) din colțul dreapta sus
- ⌨️ **Toggle** — apasă `Keybind`-ul configurat

> **Notă:** Când minimizezi fereastra, efectul de blur se dezactivează automat.

---

## ⚙️ Configurare Fereastră (`Library.new`)

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"UI Library"` | Titlul ferestrei |
| `Description` | `string` | `"discord.gg/BH6pE7jesa"` | Descrierea/subtitlul |
| `Keybind` | `Enum.KeyCode` | `Enum.KeyCode.LeftControl` | Tasta care deschide/închide meniul |
| `Logo` | `string` | `"http://www.roblox.com/asset/?id=18810965406"` | URL pentru logo |
| `Size` | `UDim2` | `UDim2.new(0, 445, 0, 315)` | Dimensiunea ferestrei |

### Metode pe `Window` (WindowTable):

| Metodă | Descriere |
|---|---|
| `Window:NewTab(cfg)` | Adaugă un tab nou |
| `Window:AddEffect(color)` | Adaugă efect de gradient animat |
| `Window.ToggleButton` | Callback personalizat când fereastra e toggle-uită |
| `Window.WindowToggle` | Starea curentă (deschis/închis) |
| `Window.Keybind` | Keycode-ul pentru toggle |

---

## 📑 Tab-uri (`WindowTable:NewTab`)

```lua
local MainTab = Window:NewTab({
    Title       = "Principal",
    Description = "Setări principale",
    Icon        = "rbxassetid://7733964640"
})
```

### Parametri `cfg`:

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Example"` | Numele tab-ului |
| `Description` | `string` | `"Tab: #"` | Descrierea tab-ului |
| `Icon` | `string` | `"rbxassetid://7733964640"` | Iconița (asset ID sau cheie din Icons) |

### Iconițe disponibile:

| Asset ID | Nume |
|---|---|
| `rbxassetid://7733964640` | Default / Scut |
| `rbxassetid://7733993211` | Home |
| `rbxassetid://7734081424` | Stea |
| `rbxassetid://7734097599` | Setări / Gear |
| `rbxassetid://7734112560` | Coroană |
| `rbxassetid://7734028266` | Sabie |

> Se poate folosi și `Icons[cfg.Icon]` din tabelul global `Library.Icons` (dacă s-a încărcat JSON-ul de iconițe).

---

## 📦 Secțiuni / Groupbox-uri (`AddLeftGroupbox`/`AddRightGroupbox`)

```lua
-- Secțiune în stânga
local LeftGroup = MainTab:AddLeftGroupbox('Titlu Secțiune')

-- Secțiune în dreapta
local RightGroup = MainTab:AddRightGroupbox('Altă Secțiune')
```

**Metode pe groupbox (`GroupboxTable`):**
- `Group:NewToggle(cfg)` — adaugă toggle
- `Group:NewButton(cfg, callback)` — adaugă buton
- `Group:NewSlider(cfg)` — adaugă slider
- `Group:NewDropdown(cfg)` — adaugă dropdown
- `Group:NewKeybind(cfg)` — adaugă keybind
- `Group:NewTextbox(cfg)` — adaugă textbox
- `Group:NewTitle(cfg)` — adaugă titlu/separator

---

## 🧩 Componente

### 1️⃣ `NewToggle`

```lua
local MyToggle = LeftGroup:NewToggle({
    Title   = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Toggle:", state)
    end
})

-- Metode disponibile:
MyToggle.Value(false)     -- Setează valoarea
MyToggle.Visible(true)    -- Arată/ascunde
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Toggle"` | Textul toggle-ului |
| `Default` | `boolean` | `false` | Starea inițială |
| `Callback` | `function(state)` | `function() end` | Apelat la schimbare |

**Returnează:**
- `Value(newValue)` — setează valoarea
- `Visible(bool)` — arată/ascunde componenta

---

### 2️⃣ `NewButton`

```lua
local MyButton = LeftGroup:NewButton({
    Title    = "Apasă-mă",
    Callback = function()
        print("Buton apăsat!")
    end
})

-- Metode disponibile:
MyButton.Visible(false)   -- Ascunde butonul
MyButton.Fire()           -- Rulează callback-ul manual
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Button"` | Textul butonului |
| `Callback` | `function()` | `function() end` | Apelat la click |

**Returnează:**
- `Visible(bool)` — arată/ascunde
- `Fire()` — rulează callback-ul manual

---

### 3️⃣ `NewSlider`

```lua
local MySlider = LeftGroup:NewSlider({
    Title   = "Viteză",
    Min     = 0,
    Max     = 100,
    Default = 50,
    Callback = function(value)
        print("Slider:", value)
    end
})

-- Metode disponibile:
MySlider.Value(75)        -- Setează valoarea
MySlider.Visible(false)   -- Ascunde
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Slider"` | Textul slider-ului |
| `Min` | `number` | `0` | Valoarea minimă |
| `Max` | `number` | `100` | Valoarea maximă |
| `Default` | `number` | `50` | Valoarea inițială |
| `Callback` | `function(value)` | `function() end` | Apelat la schimbare |

**Returnează:**
- `Value(newValue)` — setează valoarea
- `Visible(bool)` — arată/ascunde

---

### 4️⃣ `NewDropdown`

```lua
local MyDropdown = LeftGroup:NewDropdown({
    Title   = "Opțiuni",
    Data    = { 'Unu', 'Doi', 'Trei', 'Patru' },
    Default = 'Doi',
    Callback = function(value)
        print("Dropdown:", value)
    end
})

-- Metode disponibile:
MyDropdown.Value('Trei')  -- Setează valoarea
MyDropdown.Open(val)      -- Deschide dropdown-ul
MyDropdown.Close(val)     -- Închide dropdown-ul
MyDropdown.Clear()        -- Curăță opțiunile
MyDropdown.Set({'A', 'B'}) -- Setează opțiuni noi
MyDropdown.Visible(false) -- Ascunde
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Dropdown"` | Textul dropdown-ului |
| `Data` | `table` | `{'One','Two','Three','Four'}` | Lista de opțiuni |
| `Default` | `any` | `'Two'` | Valoarea implicită |
| `Callback` | `function(value)` | `function() end` | Apelat la schimbare |

**Returnează:**
- `Value(newValue)` — setează valoarea
- `Open(value)` — deschide meniul
- `Close(value)` — închide meniul
- `Clear()` — curăță toate opțiunile
- `Set(newTable)` — înlocuiește opțiunile
- `Visible(bool)` — arată/ascunde

---

### 5️⃣ `NewKeybind`

```lua
local MyKeybind = LeftGroup:NewKeybind({
    Title    = "Flight",
    Default  = Enum.KeyCode.E,
    Callback = function(key)
        print("Keybind apăsat:", key)
    end
})

-- Metode disponibile:
MyKeybind.Value(Enum.KeyCode.F)  -- Setează keybind-ul
MyKeybind.Visible(false)          -- Ascunde
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Keybind"` | Textul keybind-ului |
| `Default` | `Enum.KeyCode` | `Enum.KeyCode.E` | Tasta implicită |
| `Callback` | `function(key)` | `function() end` | Apelat la apăsare |

**Returnează:**
- `Value(newKeyCode)` — setează keybind-ul
- `Visible(bool)` — arată/ascunde

> Procesul de înregistrare: utilizatorul dă click pe butonul keybind-ului, apoi apasă tasta dorită. UI-ul se actualizează automat.

---

### 6️⃣ `NewTextbox`

```lua
local MyTextbox = LeftGroup:NewTextbox({
    Title    = "Nume",
    Default  = "",
    FileType = "",
    Callback = function(text)
        print("Text:", text)
    end
})
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Textbox"` | Textul deasupra căsuței |
| `Default` | `string` | `""` | Textul implicit |
| `FileType` | `string` | `""` | Tip fișier (opțional) |
| `Callback` | `function(text)` | `function() end` | Apelat când se pierde focusul |

**Returnează:** `GroupboxTable` (se poate folosi pentru a adăuga alte componente în același lanț)

---

### 7️⃣ `NewTitle`

```lua
LeftGroup:NewTitle({
    Title       = "Setări Avansate",
    Description = "Configurează opțiunile avansate"
})
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `-` | Titlul secțiunii |
| `Description` | `string` | `-` | Descrierea subtilă |

> Folosește `NewTitle` ca separator între grupuri de componente într-o secțiune.

---

## ✨ Efecte & Gradiente

### Gradient Image

```lua
-- Adaugă efect de gradient animat pe fereastră
Window:AddEffect(Color3.fromRGB(0, 150, 255))

-- Sau manual:
Library.GradientImage(frame, Color3.fromRGB(255, 0, 0))
```

Efectul creează o imagine animată plutitoare cu culori care se schimbă aleator.

### Blur Effect (ElBlurSource)

Blur-ul se activează automat la deschiderea ferestrei. Folosește `DepthOfFieldEffect` și `SurfaceGui` pentru a crea un efect de blur pe fundal.

```lua
-- Controlează blur-ul
Window.ElBlurUI.Enabled = true   -- activează
Window.ElBlurUI.Enabled = false  -- dezactivează
Window.ElBlurUI.Update()        -- forțează update
```

---

## 🔔 Notificări

```lua
-- Folosește Library.Notification direct
Library.Notification({
    Title       = "Succes!",
    Description = "Acțiunea a fost completată.",
    Duration    = 5,        -- secunde (default: 5)
    Icon        = "rbxassetid://7733993369"  -- opțional
})
```

| Parametru | Tip | Default | Descriere |
|---|---|---|---|
| `Title` | `string` | `"Notification"` | Titlul notificării |
| `Description` | `string` | `"Description"` | Textul notificării |
| `Duration` | `number` | `5` | Durata în secunde |
| `Icon` | `string` | `"rbxassetid://7733993369"` | Iconița |

---

## 🖥️ Console

```lua
-- Deschide consola
Library:Console()
```

Consola afișează output-ul scriptului într-o fereastră separată. Poți scrie în consolă folosind funcțiile standard de print.

---

## 📌 Dropdown System

Sistemul intern de dropdown este accesibil prin `Window.Dropdown`:

```lua
window.Dropdown:Setup(targetFrame)     -- Setează frame-ul țintă
window.Dropdown:Open(args, default, callback)  -- Deschide
window.Dropdown:Close()                       -- Închide
window.Dropdown.Value                -- Starea curentă (boolean)
```

> Acesta este folosit automat de componenta `NewDropdown`.

---

## 💡 Exemple Complete

### Exemplu 1: Script simplu

```lua
local Library = loadstring(game:HttpGetAsync([[
    https://raw.githubusercontent.com/BURSUCo/NEXUS-HUB/refs/heads/main/ui-library/library.lua
]]))()

local Window = Library.new({
    Title       = "My Script",
    Description = "by BURSUCo",
    Keybind     = Enum.KeyCode.RightControl,
    Size        = UDim2.new(0, 500, 0, 350)
})

Window:AddEffect(Color3.fromRGB(0, 170, 255))

local MainTab = Window:NewTab({
    Title       = "Main",
    Description = "Main features",
    Icon        = "rbxassetid://7733964640"
})

-- Left groupbox
local PlayerGroup = MainTab:AddLeftGroupbox('Player')

PlayerGroup:NewToggle({
    Title   = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

PlayerGroup:NewButton({
    Title    = "Kill All",
    Callback = function()
        print("Killed everyone!")
    end
})

-- Right groupbox
local VisualGroup = MainTab:AddRightGroupbox('Visuals')

VisualGroup:NewSlider({
    Title   = "FOV",
    Min     = 0,
    Max     = 120,
    Default = 70,
    Callback = function(val)
        print("FOV:", val)
    end
})

VisualGroup:NewDropdown({
    Title     = "ESP Mode",
    Data      = { 'Box', 'Tracer', 'Name', 'Health' },
    Default   = 'Box',
    Callback  = function(val)
        print("ESP:", val)
    end
})
```

### Exemplu 2: Script cu multiple tab-uri

```lua
local Library = loadstring(game:HttpGetAsync([[...]]))()
local Window = Library.new({
    Title   = "Multi-Tab Script",
    Description = "Example with 3 tabs",
    Keybind = Enum.KeyCode.Insert
})

local CombatTab = Window:NewTab({Title="Combat", Description="Combat features"})
local PlayerTab = Window:NewTab({Title="Player", Description="Player settings"})
local MiscTab   = Window:NewTab({Title="Misc",   Description="Other features"})

-- Tab 1: Combat
local AimGroup = CombatTab:AddLeftGroupbox('Aimbot')
AimGroup:NewToggle({Title="Aimbot", Default=true})
AimGroup:NewSlider({Title="Smoothness", Min=1, Max=10, Default=5})

-- Tab 2: Player
local MoveGroup = PlayerTab:AddLeftGroupbox('Movement')
MoveGroup:NewToggle({Title="Speed", Default=false})
MoveGroup:NewKeybind({Title="Speed Key", Default=Enum.KeyCode.X})

-- Tab 3: Misc
local SettingsGroup = MiscTab:AddLeftGroupbox('Settings')
SettingsGroup:NewTextbox({Title="Webhook URL", Default=""})
SettingsGroup:NewTitle({Title="Info", Description="Set your webhook URL above"})
```

---

## 📖 Referință Rapidă

### Flow-ul Corect

```
Library.loadstring()()        → Încarcă biblioteca
  └── Library.new(config)     → Creează fereastra
        └── Window:NewTab()   → Adaugă tab
              ├── Tab:AddLeftGroupbox('Nume')    → Secțiune stânga
              │     ├── Group:NewToggle(...)
              │     ├── Group:NewButton(...)
              │     ├── Group:NewSlider(...)
              │     ├── Group:NewDropdown(...)
              │     ├── Group:NewKeybind(...)
              │     ├── Group:NewTextbox(...)
              │     └── Group:NewTitle(...)
              └── Tab:AddRightGroupbox('Nume')   → Secțiune dreapta
                    └── (aceleași componente)
```

### Toate Componentele — Privire de ansamblu

| Componentă | Constructor | Returnează |
|---|---|---|
| **Toggle** | `:NewToggle({Title, Default, Callback})` | `Value()`, `Visible()` |
| **Button** | `:NewButton({Title, Callback})` | `Visible()`, `Fire()` |
| **Slider** | `:NewSlider({Title, Min, Max, Default, Callback})` | `Value()`, `Visible()` |
| **Dropdown** | `:NewDropdown({Title, Data, Default, Callback})` | `Value()`, `Open()`, `Close()`, `Clear()`, `Set()`, `Visible()` |
| **Keybind** | `:NewKeybind({Title, Default, Callback})` | `Value()`, `Visible()` |
| **Textbox** | `:NewTextbox({Title, Default, FileType, Callback})` | GroupboxTable |
| **Title** | `:NewTitle({Title, Description})` | — |

### Constante Utile

```lua
Library.Icons         -- Tabel cu iconițe (dacă s-a încărcat)
Library.FetchIcon     -- URL-ul de unde se încarcă iconițele
Library['.']          -- Versiunea library-ului
```

---

## ⚠️ Note Importante

1. **Executor compatibil:** Funcționează cu Delta Executor (și alți executori care suportă `gethui()`)
2. **Autentificare:** Library-ul are sistem de auth (`Library.NewAuth`) — poate necesita cheie
3. **Animații:** Toate animațiile folosesc `TweenService` — au nevoie de `UserInputService`
4. **Iconițe:** Se încarcă din JSON de pe GitHub la inițializare
5. **Blur:** Folosește `DepthOfFieldEffect` și un `Part` în workspace — poate afecta performanța pe device-uri slabe

---

## 📸 Galerie (exemple vizuale)

```
┌─────────────────────────────────────────────────┐
│  ┌────────────┐  Title Bar        [⚪]          │
│  │ 📁 Main    │                                  │
│  │ ⚙️ Settings│  ┌─ Secțiune Stânga ──────────┐ │
│  │ 🔧 Misc    │  │ 📋 Auto Farm      [🔘]      │ │
│  │            │  │ 🔘 Kill All                  │ │
│  │            │  └──────────────────────────────┘ │
│  │            │  ┌─ Secțiune Dreapta ──────────┐ │
│  │            │  │ 📊 FOV         ──●───── 70  │ │
│  │            │  │ 📑 ESP Mode   [Box    ▼]    │ │
│  │            │  └──────────────────────────────┘ │
│  └────────────┘                                   │
└─────────────────────────────────────────────────┘
```

---

*Documentație generată pe baza analizei codului sursă Nothing Library.*  
*Creat de BURSUCo • Script pentru Delta Executor*
