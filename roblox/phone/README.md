# Sky Phone for Roblox (Native Luau Edition)

This is a complete, native Roblox Luau port of the open-source [Sky Systems Phone](https://github.com/sky-systems/sky_phone), tailored with an Apple iOS 17/18 dark human interface design, Dynamic Island hardware notch, smooth UI animations, and full client/server networking.

---

## 📁 File Structure & Placement

| File Path in Workspace | Destination in Roblox Studio | Role |
| :--- | :--- | :--- |
| [`roblox/components/PhoneTheme.lua`](file:///D:/Blender/Projects/Antigravity/roblox/components/PhoneTheme.lua) | `ReplicatedStorage.PhoneComponents.PhoneTheme` | Design tokens, iOS dark palette, squircle measurements, and app metadata |
| [`roblox/components/PhoneUI.lua`](file:///D:/Blender/Projects/Antigravity/roblox/components/PhoneUI.lua) | `ReplicatedStorage.PhoneComponents.PhoneUI` | Modular UI component (CanvasGroup curved screen, Dynamic Island, Lock Screen, Springboard grid, Dock, and interactive apps) |
| [`roblox/scripts/PhoneController.lua`](file:///D:/Blender/Projects/Antigravity/roblox/scripts/PhoneController.lua) | `StarterPlayer.StarterPlayerScripts.PhoneController` | Client controller handling keybinds (`M`), floating quick toggle widget, sound effects, and server synchronization |
| [`roblox/scripts/PhoneService.lua`](file:///D:/Blender/Projects/Antigravity/roblox/scripts/PhoneService.lua) | `ServerScriptService.PhoneService` | Authoritative server service handling phone numbers (`555-XXXX`), messaging, bank transactions, and vehicle actions |
| [`roblox/plugins/PhonePreview_Plugin.lua`](file:///D:/Blender/Projects/Antigravity/roblox/plugins/PhonePreview_Plugin.lua) | `%localappdata%\Roblox\Plugins\` or Studio Command Bar | Live Studio preview plugin to test the phone UI directly in edit mode |

---

## 📱 Features Included

1. **Hardware Chassis & Display**:
   - 312 × 636 pt curved phone bezel with glass highlight edges.
   - Inner `CanvasGroup` screen with 38 px corner radius for clipping.
   - Dynamic Island (Notch) displaying call states and audio activity dot.
   - Live status bar with clock, cellular signal, Wi-Fi status, and battery indicator.

2. **Lock Screen & Springboard**:
   - Big typographic lockscreen clock, date, flashlight / camera shortcuts, and swipe-up unlock.
   - 4-column squircle icon springboard grid with notification badges and top search widget.
   - Frosted glass dock holding primary apps: **Phone**, **Messages**, **Bank**, and **Settings**.
   - Interactive home indicator pill at bottom (tap to return to home or minimize).

3. **In-App Systems**:
   - 📞 **Phone / Calls**: 3×4 numeric keypad dialer with backspace, call button, and an active calling overlay screen with caller avatar, elapsed timer, and end call button.
   - 💬 **Messages**: Conversation chat view with sent/received chat bubbles, text input box, and push notification drop-down alerts.
   - 💳 **Sun City Bank**: Inset platinum credit card with live balance, quick transfer simulation modal, and recent transactions statement.
   - 🚗 **Garage**: Player vehicle cards displaying fuel/health percentages, lock/unlock toggle, and GPS waypoint buttons.
   - ⚙️ **Settings**: Smooth iOS toggle switches for Airplane Mode, Wi-Fi, Bluetooth, and About device specifications.
   - 📝 **Notes**: Clean notes list with previews and apartment/garage codes.
   - 📷 **Camera**: Viewfinder overlay, yellow focus reticle, and shutter button with screen flash effect.

4. **Client & Server Architecture**:
   - Server dynamically allocates unique `555-XXXX` phone numbers to players.
   - Safe `DataStoreService` integration with automatic in-memory fallback for testing in Studio.
   - Full `RemoteFunction` and `RemoteEvent` networking inside `ReplicatedStorage.PhoneNetwork`.
   - Procedural sound effects for keypad dial clicks, message whoosh, notification chimes, and ringtone.
