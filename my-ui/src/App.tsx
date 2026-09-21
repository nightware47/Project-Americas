import { useEffect, useMemo, useState } from 'react'
import { RobloxPhoneScreen } from './phone/RobloxPhoneScreen.tsx'
import { LuauCodePreviewer } from './phone/luau/LuauCodePreviewer.tsx'
import { RobloxExplorerTree } from './phone/roblox/RobloxExplorerTree.tsx'
import { createSkyPhoneInstanceTree } from './phone/roblox/roblox-sky-phone-tree.ts'
import { setupLivingUiListeners } from './audio/ui-audio.ts'

function App() {
  const [phoneOpen, setPhoneOpen] = useState(true)
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [sidebarTab, setSidebarTab] = useState<'luau' | 'explorer'>('luau')
  const [activePhoneApp, setActivePhoneApp] = useState('home')
  const [phoneKey, setPhoneKey] = useState(0)

  useEffect(() => {
    const cleanup = setupLivingUiListeners()
    return cleanup
  }, [])

  useEffect(() => {
    const handleHotkeys = (event: KeyboardEvent) => {
      if (event.ctrlKey || event.metaKey || event.altKey || event.repeat) return
      if (event.target instanceof HTMLElement && event.target.closest('input, textarea, select')) return
      if (event.code === 'KeyP') {
        event.preventDefault()
        setPhoneOpen((open) => !open)
      } else if (event.code === 'KeyL') {
        event.preventDefault()
        setSidebarTab('luau')
        setSidebarOpen((open) => (sidebarTab === 'luau' ? !open : true))
      } else if (event.code === 'KeyE') {
        event.preventDefault()
        setSidebarTab('explorer')
        setSidebarOpen((open) => (sidebarTab === 'explorer' ? !open : true))
      }
    }
    window.addEventListener('keydown', handleHotkeys)
    return () => window.removeEventListener('keydown', handleHotkeys)
  }, [sidebarTab])

  const resetPhone = () => {
    setPhoneKey((k) => k + 1)
    setActivePhoneApp('home')
  }

  // Generate the current live instance tree for the Explorer
  const currentLiveTree = useMemo(() => {
    return createSkyPhoneInstanceTree({
      activeApp: activePhoneApp,
      currentPage: 1,
    })
  }, [activePhoneApp])

  return (
    <div className="ag-app-root">
      {/* Top Application Bar - Google Antigravity & Sky Phone Studio */}
      <header className="ag-top-bar">
        {/* Left: Brand Logo & Title */}
        <div className="flex items-center gap-3">
          <div className="ag-brand">
            <svg
              className="ag-logo-glyph"
              width="22"
              height="22"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M12 2L2 19.5H22L12 2Z"
                fill="url(#agGrad)"
                stroke="#60a5fa"
                strokeWidth="1.5"
                strokeLinejoin="round"
              />
              <path
                d="M12 8L6.5 17.5H17.5L12 8Z"
                fill="#0f172a"
                stroke="#93c5fd"
                strokeWidth="1.2"
                strokeLinejoin="round"
              />
              <defs>
                <linearGradient id="agGrad" x1="12" y1="2" x2="12" y2="20" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#3b82f6" />
                  <stop offset="1" stopColor="#1d4ed8" />
                </linearGradient>
              </defs>
            </svg>
            <span className="ag-brand-title">Sky Phone</span>
            <span className="ag-pill-badge text-[10px] bg-blue-500/20 text-blue-300 border-blue-500/30 font-semibold">
              Roblox Studio 1:1 Pair
            </span>
          </div>

          <div className="ag-header-divider" />

          <div className="hidden lg:flex items-center gap-2 text-xs text-slate-400">
            <span className="font-mono text-slate-300 bg-slate-800/80 px-2 py-0.5 rounded border border-slate-700">
              390 × 844
            </span>
            <span>•</span>
            <span className="text-slate-400">Roblox UI Engine</span>
            <span>•</span>
            <span className="text-purple-300 bg-purple-500/10 px-2 py-0.5 rounded border border-purple-500/20">
              Zero Pre-Baked GUI (Rule 10)
            </span>
          </div>
        </div>

        {/* Center: Live Status Readout */}
        <div className="ag-status-capsule hidden md:flex items-center gap-2">
          <span className="ag-status-dot dot-online animate-pulse" />
          <span className="ag-status-text font-semibold">ONLINE</span>
          <span className="text-ag-border">•</span>
          <span className="ag-status-step font-mono text-ag-text-muted">
            Active: <strong className="text-slate-200 capitalize">{activePhoneApp}</strong>
          </span>
          <span className="text-ag-border">•</span>
          <span className="ag-status-time font-mono text-sky-400">
            rbxassetid://82226915452893
          </span>
        </div>

        {/* Right: Controls */}
        <div className="flex items-center gap-2">
          <button
            type="button"
            className="ag-btn-secondary py-1 text-xs"
            onClick={resetPhone}
            title="Reset Phone to Home State"
          >
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" />
              <path d="M3 3v5h5" />
            </svg>
            <span>Reset</span>
          </button>

          <button
            type="button"
            className={`ag-btn-secondary py-1 text-xs ${phoneOpen ? 'active text-blue-300 border-blue-500/50' : ''}`}
            onClick={() => setPhoneOpen((open) => !open)}
            aria-label="Toggle Phone"
            title="Toggle Phone Display (Press P)"
          >
            <span className="text-xs">📱</span>
            <span>Phone</span>
            <kbd className="text-[9px] font-mono bg-slate-800/80 px-1 py-0.5 rounded text-slate-300 border border-slate-700">P</kbd>
          </button>

          <button
            type="button"
            className={`ag-btn-secondary py-1 text-xs ${sidebarOpen && sidebarTab === 'explorer' ? 'active text-purple-300 border-purple-500/50' : ''}`}
            onClick={() => {
              if (sidebarOpen && sidebarTab === 'explorer') {
                setSidebarOpen(false)
              } else {
                setSidebarTab('explorer')
                setSidebarOpen(true)
              }
            }}
            aria-label="Toggle Studio Explorer"
            title="Toggle Roblox Explorer Tree (Press E)"
          >
            <span className="text-xs">🗂️</span>
            <span>Explorer</span>
            <kbd className="text-[9px] font-mono bg-slate-800/80 px-1 py-0.5 rounded text-slate-300 border border-slate-700">E</kbd>
          </button>

          <button
            type="button"
            className={`ag-btn-secondary py-1 text-xs ${sidebarOpen && sidebarTab === 'luau' ? 'active text-sky-300 border-sky-500/50' : ''}`}
            onClick={() => {
              if (sidebarOpen && sidebarTab === 'luau') {
                setSidebarOpen(false)
              } else {
                setSidebarTab('luau')
                setSidebarOpen(true)
              }
            }}
            aria-label="Toggle Luau Code Previewer"
            title="Toggle Luau Code Previewer (Press L)"
          >
            <span className="text-xs">📜</span>
            <span>Luau Code</span>
            <span className="ag-pill-badge text-[10px] bg-sky-500/20 text-sky-300 border-sky-500/30">10 Modules</span>
            <kbd className="text-[9px] font-mono bg-slate-800/80 px-1 py-0.5 rounded text-slate-300 border border-slate-700">L</kbd>
          </button>
        </div>
      </header>

      {/* Main Workspace: Dedicated Phone Showcase + Luau / Explorer Dock */}
      <main className="ag-main-workspace">
        {/* Center: Phone Showcase Stage (Roblox UI Engine 1:1 Pair) */}
        <div className="phone-showcase-container">
          <div className="phone-showcase-backdrop-grid" />
          {phoneOpen ? (
            <div className="phone-showcase-stage">
              <RobloxPhoneScreen
                key={phoneKey}
                onActiveAppChange={(appId) => setActivePhoneApp(appId)}
                onClose={() => setPhoneOpen(false)}
              />
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center gap-4 text-center p-8 z-10">
              <div className="w-16 h-16 rounded-2xl bg-slate-800/80 border border-slate-700/60 flex items-center justify-center text-3xl shadow-xl">
                📱
              </div>
              <h2 className="text-lg font-bold text-slate-200">Sky Phone is Closed</h2>
              <p className="text-xs text-slate-400 max-w-sm">
                Press <kbd className="font-mono bg-slate-800 px-1.5 py-0.5 rounded border border-slate-700 text-slate-300">P</kbd> or click below to launch the Roblox Studio phone.
              </p>
              <button
                type="button"
                className="ag-btn-primary text-xs px-4 py-2"
                onClick={() => setPhoneOpen(true)}
              >
                Open Sky Phone
              </button>
            </div>
          )}
        </div>

        {/* Right Dock: Luau Code Previewer OR Roblox Explorer Tree */}
        {sidebarOpen && (
          <aside className="ag-luau-dock flex flex-col">
            {/* Dock Tab Selector */}
            <div className="flex items-center gap-2 p-2 bg-slate-900 border-b border-slate-800">
              <button
                type="button"
                className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-semibold flex items-center justify-center gap-2 transition-colors ${
                  sidebarTab === 'luau'
                    ? 'bg-blue-600 text-white shadow'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800'
                }`}
                onClick={() => setSidebarTab('luau')}
              >
                <span>📜</span>
                <span>Luau Source (10 Modules)</span>
              </button>
              <button
                type="button"
                className={`flex-1 py-1.5 px-3 rounded-lg text-xs font-semibold flex items-center justify-center gap-2 transition-colors ${
                  sidebarTab === 'explorer'
                    ? 'bg-purple-600 text-white shadow'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800'
                }`}
                onClick={() => setSidebarTab('explorer')}
              >
                <span>🗂️</span>
                <span>Studio Explorer</span>
              </button>
              <button
                type="button"
                className="p-1.5 rounded-lg text-slate-400 hover:text-slate-200 hover:bg-slate-800"
                onClick={() => setSidebarOpen(false)}
                title="Close Panel"
              >
                ✕
              </button>
            </div>

            {/* Dock Content */}
            <div className="flex-1 overflow-hidden">
              {sidebarTab === 'luau' ? (
                <LuauCodePreviewer
                  activeAppId={activePhoneApp}
                  onClose={() => setSidebarOpen(false)}
                />
              ) : (
                <div className="h-full p-2">
                  <RobloxExplorerTree tree={currentLiveTree} />
                </div>
              )}
            </div>
          </aside>
        )}
      </main>
    </div>
  )
}

export default App
