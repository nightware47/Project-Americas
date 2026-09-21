# Sky Phone - Pure Luau Script-Only Architecture

> **Invariant**: Zero Pre-Baked GUI. `len([desc for desc in StarterGui.Phone:GetDescendants() if desc:IsA("GuiObject")]) == 0`.
> 100% code-driven modular architecture running in pure Luau.

## Architecture Overview

```
StarterPlayerScripts / ReplicatedStorage
└── SkyPhone/
    ├── SkyPhoneClient.client.luau   -- Client bootstrap and dynamic mount loader
    ├── init.luau                    -- Core package coordinator & lifecycle manager
    ├── Chassis.luau                 -- 3D chassis, dynamic island, status bar, official wallpaper
    ├── Springboard.luau             -- 3-page springboard, 4x2 music widget, 2x2 weather/clock widgets, dock
    ├── AppSuite_Core.luau           -- Phone, Messages, Contacts, Settings, Camera, Photos
    ├── AppSuite_Tools.luau          -- Clock (4 tabs), Weather, Notes, Voice Memos, Mail
    ├── AppSuite_Finance_Gaming.luau -- Maze Banking, VaultX, Billing, Snake, Memory, 2048, Minesweeper, Tower Stack, Sky Flappy, Neon Drop
    ├── AppSuite_Ecosystem.luau      -- Map, Garage, DarkChat, FlipTok, Picstagram, Flare, Feather, House, SkyRide, CityMarkt, Local Pages, Radio, Calendar, CrewLink, Companies, Weazel News, CityWarn, Health, App Store
    ├── BottomSheet.luau             -- Fluid bottom modal sheets & dynamic popovers
    └── Router.luau                  -- App routing, transitions, and lifecycle hooks
```

## Features
- **Official Deep Space Wallpaper**: Restored asset ID `rbxassetid://82226915452893` with smooth gradient fallback.
- **Dynamic Island**: Interactive pill with live call, music scrubber, flashlight, and expand/collapse physics.
- **Real-Time Clock & Weather**: Dynamic local time sync and weather metrics.
- **Pure Dynamic Instantiation**: All UI elements (`Frame`, `ImageLabel`, `TextLabel`, `UICorner`, `UIStroke`, etc.) are constructed programmatically at runtime with clean lifecycle management.

