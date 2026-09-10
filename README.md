# Project Americas

[![Live Studio Preview](https://img.shields.io/badge/Live%20Preview-Project%20Americas-0A84FF.svg)](https://nightware47.github.io/Project-Americas/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An open-source, modern Roblox game framework and UI ecosystem featuring a native Luau Apple iOS 17/18-style **Sky Phone**, typed **Nerve** service architecture, and live **Abraxius** Roblox Studio companion synchronization.

---

## 🌐 Live Web Preview
Experience the interactive UI studio and live phone showcase in your browser:
**[https://nightware47.github.io/Project-Americas/](https://nightware47.github.io/Project-Americas/)**

---

## 📦 Connected Repositories & Forks

1. **[nightware47/Project-Americas](https://github.com/nightware47/Project-Americas)** (This Repository)
   - Core project, web studio preview, and Roblox Luau codebases.
2. **[nightware47/Nerve](https://github.com/nightware47/Nerve)** *(Forked from [velumix/Nerve](https://github.com/velumix/Nerve))*
   - Batteries-included Roblox framework with typed ByteNet networking, service/controller lifecycle, and reactive state.
3. **[nightware47/Abraxius](https://github.com/nightware47/Abraxius)** *(Forked from [velumix/Abraxius](https://github.com/velumix/Abraxius))*
   - Windows-hosted companion daemon and verified Studio script synchronization system.

---

## 📁 Repository Structure

`	ext
Project-Americas/
├── my-ui/                  # React + Vite web studio preview (deployed to GitHub Pages)
├── roblox/
│   ├── phone/              # Complete native Luau Sky Phone system
│   │   ├── PhoneUI.luau            # CanvasGroup screen, Dynamic Island, Springboard, 7 Apps
│   │   ├── PhoneTheme.luau         # iOS 17/18 Dark Appearance design tokens
│   │   ├── PhoneController.luau    # Client controller (Hotkeys, sounds, HUD toggle)
│   │   ├── PhoneService.luau       # Authoritative server service (Calling, Banking, Garage)
│   │   ├── PhonePreview_Plugin.luau# Studio Edit Mode preview plugin
│   │   └── README.md
│   ├── framework/Nerve/    # Bundled Nerve engine (ByteNet, Lifecycle, Runtime)
│   ├── nerve/              # 41 Game & Phone services powered by Nerve
│   ├── components/         # Reusable Roblox UI modules
│   ├── plugins/            # Roblox Studio companion & preview plugins
│   │   ├── AbraxiusCompanion.luau  # Abraxius Studio live sync companion
│   │   └── PhonePreview_Plugin.luau# Studio edit-mode phone preview
│   └── scripts/            # Server & Client bootstrap scripts
└── scripts/                # Local development & sync bridges
`

---

## ⚡ Quick Start

### Web UI Studio
`ash
npm install
npm run dev
`

### Building for Production
`ash
npm run build
`
