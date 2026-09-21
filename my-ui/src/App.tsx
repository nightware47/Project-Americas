import { useEffect, useMemo, useState } from 'react'
import { RobloxRenderer } from './renderer/RobloxRenderer.tsx'
import { previewEventAdapter } from './renderer/preview-handlers.ts'
import { previewNetworkAdapter } from './renderer/preview-network.ts'
import { createScenarioRunner } from './scenarios/scenario-runner.ts'
import type { PlaybackSpeed, ScenarioPlaybackState } from './scenarios/scenario-runner.ts'
import { createNervePreview } from './nerve/preview.ts'
import { applyEffectPatches, createEffectPlayer } from './effects/roblox-effects.ts'
import { applyBindings, createReactiveBindingStore } from './bindings/reactive-bindings.ts'
import { createPreviewActions, createPreviewHandlers } from './actions/preview-actions.ts'
import { compileRobloxProject } from './features/project-compiler.ts'
import { PreviewFeature } from './features/preview-feature.ts'
import { ShopFeature } from './features/shop-feature.ts'
import { SettingsFeature } from './features/settings-feature.ts'
import { createRobloxRuntimeContext } from './runtime/roblox-runtime.ts'
import { createRobloxPersistence } from './persistence/roblox-persistence.ts'
import { createRobloxRealm } from './realm/roblox-realm.ts'
import { ScenarioInspector } from './scenarios/ScenarioInspector.tsx'
import { ScenarioParameters } from './scenarios/ScenarioParameters.tsx'
import { RobloxViewportPreview } from './viewport/RobloxViewportPreview.tsx'
import { InventoryScreen } from './inventory/InventoryScreen.tsx'
import { PhoneScreen } from './phone/PhoneScreen.tsx'
import { LuauCodePreviewer } from './phone/luau/LuauCodePreviewer.tsx'
import { setupLivingUiListeners, uiAudio } from './audio/ui-audio.ts'

function App() {
  const bindingStore = useMemo(() => createReactiveBindingStore(), [])
  const runtime = useMemo(() => createRobloxRuntimeContext(), [])
  const persistence = useMemo(() => createRobloxPersistence(), [])
  const realm = useMemo(() => createRobloxRealm(persistence), [persistence])
  const nerve = useMemo(() => createNervePreview({ persistence }), [persistence])
  const featureProject = useMemo(() => compileRobloxProject([PreviewFeature, ShopFeature, SettingsFeature]), [])
  const compiledTree = featureProject.Tree
  const effectPlayer = useMemo(
    () => createEffectPlayer(compiledTree, featureProject.Effects),
    [compiledTree, featureProject],
  )
  const [scenarioId, setScenarioId] = useState(featureProject.Scenarios[0].id)
  const activeScenario =
    featureProject.Scenarios.find((scenario) => scenario.id === scenarioId) ??
    featureProject.Scenarios[0]

  const scenarioRunner = useMemo(
    () =>
      createScenarioRunner({
        nerve,
        network: previewNetworkAdapter,
        effects: effectPlayer,
        bindings: bindingStore,
        runtime,
        persistence,
        realm,
      }),
    [bindingStore, effectPlayer, nerve, persistence, realm, runtime],
  )

  const actions = useMemo(
    () =>
      createPreviewActions(
        {
          bindings: bindingStore,
          effects: effectPlayer,
          nerve,
          network: previewNetworkAdapter,
          persistence,
          getTimeMs: () => scenarioRunner.getState().timeMs,
          getTrace: scenarioRunner.getTrace,
        },
        featureProject.Actions,
      ),
    [bindingStore, effectPlayer, featureProject.Actions, nerve, persistence, scenarioRunner],
  )

  const previewHandlers = useMemo(
    () =>
      createPreviewHandlers(
        actions,
        featureProject.ActionBindings,
        featureProject.EffectHooks,
        effectPlayer,
        () => scenarioRunner.getState().timeMs,
      ),
    [actions, effectPlayer, featureProject.ActionBindings, featureProject.EffectHooks, scenarioRunner],
  )

  const [playback, setPlayback] = useState<ScenarioPlaybackState>(scenarioRunner.getState())
  const [effectPatches, setEffectPatches] = useState(effectPlayer.getPatches())
  const [parameters, setParameters] = useState<Record<string, unknown>>({})
  const [, setBindingVersion] = useState(0)
  const [inspectorOpen, setInspectorOpen] = useState(false)
  const [menuRevision, setMenuRevision] = useState(0)
  const [phoneOpen, setPhoneOpen] = useState(true)
  const [luauOpen, setLuauOpen] = useState(true)
  const [activePhoneApp, setActivePhoneApp] = useState('home')

  useEffect(() => {
    const unsub = bindingStore.subscribePath('UI.PhoneOpen', (val) => {
      setPhoneOpen(Boolean(val))
    })
    return unsub
  }, [bindingStore])

  const renderedTree = applyEffectPatches(applyBindings(compiledTree, bindingStore), effectPatches)
  // The browser menu replaces these legacy panels; their Roblox export templates remain available.
  const browserTree = {
    ...renderedTree,
    Children: renderedTree.Children?.map(child => child.Name === 'GameModalsContainer' ? {
      ...child, Children: child.Children?.filter(panel => !['InventoryPanelModal', 'QuestsPanelModal', 'StatsPanelModal', 'SettingsPanelModal'].includes(panel.Name ?? '')),
    } : child),
  }
  const traceEvents = scenarioRunner.getTrace().events()

  useEffect(() => {
    const cleanup = setupLivingUiListeners()
    return cleanup
  }, [])

  const currentActivePanel = String(bindingStore.get('UI.ActivePanel') ?? 'None')
  useEffect(() => {
    if (currentActivePanel !== 'None') {
      uiAudio.playModalOpen()
    }
  }, [currentActivePanel])

  useEffect(() => {
    const handleHotkeys = (event: KeyboardEvent) => {
      if (event.ctrlKey || event.metaKey || event.altKey || event.repeat) return
      if (event.target instanceof HTMLElement && event.target.closest('input, textarea, select')) return
      if (event.code === 'KeyI') {
        if (event.target instanceof HTMLElement && event.target.closest('[role="dialog"]')) return
        event.preventDefault()
        void actions.run('TogglePanel', { Panel: 'Inventory' }).promise
      } else if (event.code === 'KeyP') {
        event.preventDefault()
        setPhoneOpen((open) => {
          const next = !open
          bindingStore.set('UI.PhoneOpen', next)
          return next
        })
      } else if (event.code === 'KeyL') {
        event.preventDefault()
        setLuauOpen((open) => !open)
      }
    }
    window.addEventListener('keydown', handleHotkeys)
    return () => window.removeEventListener('keydown', handleHotkeys)
  }, [actions, bindingStore])

  useEffect(() => {
    scenarioRunner.start(activeScenario)
    const playbackConnection = scenarioRunner.subscribe((state) => {
      setPlayback(state)
      setEffectPatches(effectPlayer.getPatches())
    })
    const bindingConnection = bindingStore.subscribe(() =>
      setBindingVersion((version) => version + 1),
    )
    const moneyConnection = previewNetworkAdapter.Network.MoneyChanged.connect((payload) => {
      console.info('Network.MoneyChanged.connect', payload.Amount)
    })

    void previewNetworkAdapter.Network.GetInventory.request({}).then((response) => {
      console.info('Network.GetInventory.request', response.Items)
    })

    return () => {
      moneyConnection()
      playbackConnection()
      bindingConnection()
      actions.cancel()
      scenarioRunner.stop()
    }
  }, [actions, activeScenario, bindingStore, effectPlayer, featureProject, nerve, scenarioId, scenarioRunner])

  const handleScenarioChange = (nextId: string) => {
    setScenarioId(nextId)
    const nextScenario = featureProject.Scenarios.find((scenario) => scenario.id === nextId)
    setParameters(
      Object.fromEntries(
        Object.entries(nextScenario?.parameters ?? {}).map(([name, definition]) => [
          name,
          definition.default,
        ]),
      ),
    )
  }

  const timelinePercent = playback.durationMs > 0 ? (playback.timeMs / playback.durationMs) * 100 : 0

  return (
    <div className="ag-app-root">
      {/* Top Application Bar - Google Antigravity Style */}
      <header className="ag-top-bar">
        {/* Left: Antigravity Brand & Scenario Switcher */}
        <div className="flex items-center gap-3">
          <div className="ag-brand">
            <svg
              className="ag-logo-glyph"
              width="20"
              height="20"
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
            <span className="ag-brand-title">Project Americas</span>
            <span className="ag-pill-badge text-[10px] bg-blue-500/20 text-blue-300 border-blue-500/30">Sky Phone</span>
          </div>

          <div className="ag-header-divider" />

          {/* Scenario Selector */}
          <div className="ag-select-wrapper">
            <select
              className="ag-select-field font-medium text-xs text-ag-text"
              value={scenarioId}
              onChange={(e) => handleScenarioChange(e.target.value)}
              aria-label="Scenario"
            >
              {featureProject.Scenarios.map((scenario) => (
                <option key={scenario.id} value={scenario.id}>
                  {scenario.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Center: Live Status Readout */}
        <div className="ag-status-capsule hidden md:flex items-center gap-2">
          <span
            className={`ag-status-dot ${playback.playing ? 'dot-online animate-pulse' : 'dot-idle'}`}
          />
          <span className="ag-status-text font-semibold">
            {playback.playing ? 'SIMULATING' : 'PAUSED'}
          </span>
          <span className="text-ag-border">•</span>
          <span className="ag-status-step font-mono text-ag-text-muted">
            {playback.currentStep ?? 'Ready'}
          </span>
          <span className="text-ag-border">•</span>
          <span className="ag-status-time font-mono tabular-nums">
            {Math.round(playback.timeMs)}ms / {playback.durationMs}ms
          </span>
        </div>

        {/* Right: Actions & Inspector Toggle */}
        <div className="flex items-center gap-2">
          <button
            type="button"
            className="ag-btn-secondary py-1 text-xs"
            onClick={() => {
              actions.cancel()
              scenarioRunner.restart()
              setMenuRevision(version => version + 1)
            }}
            title="Restart Scenario"
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
            onClick={() => {
              setPhoneOpen((open) => {
                const next = !open
                bindingStore.set('UI.PhoneOpen', next)
                return next
              })
            }}
            aria-label="Toggle Phone" title="Toggle Phone (Press P)"
          >
            <span className="text-xs">📱</span>
            <span>Phone</span>
            <kbd className="text-[9px] font-mono bg-slate-800/80 px-1 py-0.5 rounded text-slate-300 border border-slate-700">P</kbd>
          </button>

          <button
            type="button"
            className={`ag-btn-secondary py-1 text-xs ${luauOpen ? 'active text-sky-300 border-sky-500/50' : ''}`}
            onClick={() => setLuauOpen((open) => !open)}
            aria-label="Toggle Luau Code Previewer"
            title="Toggle Luau Code Previewer (Press L)"
          >
            <span className="text-xs">📜</span>
            <span>Luau Code</span>
            <span className="ag-pill-badge text-[10px] bg-sky-500/20 text-sky-300 border-sky-500/30">10 Modules</span>
            <kbd className="text-[9px] font-mono bg-slate-800/80 px-1 py-0.5 rounded text-slate-300 border border-slate-700">L</kbd>
          </button>

          <button
            type="button"
            className={`ag-btn-secondary py-1 text-xs ${inspectorOpen ? 'active' : ''}`}
            onClick={() => setInspectorOpen((prev) => !prev)}
            title="Toggle Scenario Inspector"
          >
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
              <line x1="15" y1="3" x2="15" y2="21" />
            </svg>
            <span>Inspector</span>
            <span className="ag-pill-badge">{traceEvents.length}</span>
          </button>
        </div>
      </header>

      {/* Main Workspace: Canvas Dock + Inspector Dock */}
      <main className="ag-main-workspace">
        {/* Center Workspace Column */}
        <div className="ag-center-workspace">
          {/* Viewport Canvas Area */}
          <RobloxViewportPreview runtime={runtime} device={parameters.Device}>
            <RobloxRenderer
              tree={browserTree}
              Handlers={previewHandlers}
              eventAdapter={previewEventAdapter}
            />
            <InventoryScreen key={`${scenarioId}-${menuRevision}`} panel={String(bindingStore.get('UI.ActivePanel') ?? 'None')} bindings={bindingStore} nerve={nerve}
              onPanelChange={panel => bindingStore.set('UI.ActivePanel', panel)}
              onClose={() => { void actions.run('ClosePanel', {}).promise }} />
            {phoneOpen && (
              <aside className="phone-stage">
                <PhoneScreen
                  nerve={nerve}
                  onActiveAppChange={(appId) => setActivePhoneApp(appId)}
                  onClose={() => {
                    setPhoneOpen(false)
                    bindingStore.set('UI.PhoneOpen', false)
                  }}
                />
              </aside>
            )}
          </RobloxViewportPreview>

          {/* Bottom Deck: Transport Controls & Parameters */}
          <div className="ag-transport-dock">
            {/* Playback Controls Row */}
            <div className="ag-transport-row">
              {/* Play / Pause / Step Controls */}
              <div className="flex items-center gap-1.5">
                {playback.playing ? (
                  <button
                    type="button"
                    className="ag-btn-primary"
                    onClick={() => scenarioRunner.pause()}
                    title="Pause"
                  >
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor">
                      <rect x="6" y="4" width="4" height="16" rx="1" />
                      <rect x="14" y="4" width="4" height="16" rx="1" />
                    </svg>
                    <span>Pause</span>
                  </button>
                ) : (
                  <button
                    type="button"
                    className="ag-btn-primary"
                    onClick={() => scenarioRunner.play()}
                    title="Play"
                  >
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor">
                      <polygon points="5 3 19 12 5 21 5 3" />
                    </svg>
                    <span>Play</span>
                  </button>
                )}

                <button
                  type="button"
                  className="ag-btn-secondary"
                  onClick={() => scenarioRunner.stepForward()}
                  title="Step forward"
                >
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <polygon points="5 4 15 12 5 20 5 4" />
                    <line x1="19" y1="5" x2="19" y2="19" />
                  </svg>
                  <span>Step</span>
                </button>

                {/* Playback Speed Pills */}
                <div className="ag-speed-group">
                  {([0.25, 0.5, 1, 2] as PlaybackSpeed[]).map((speed) => (
                    <button
                      key={speed}
                      type="button"
                      className={`ag-speed-pill ${playback.speed === speed ? 'active' : ''}`}
                      onClick={() => scenarioRunner.setSpeed(speed)}
                    >
                      {speed}x
                    </button>
                  ))}
                </div>
              </div>

              {/* Timeline Scrubber */}
              <div className="ag-timeline-wrapper">
                <div className="flex items-center justify-between text-[11px] text-ag-text-muted mb-1 font-mono">
                  <span className="text-ag-text tabular-nums">{Math.round(playback.timeMs)}ms</span>
                  <span className="ag-pill-badge text-[10px]">{playback.currentStep ?? 'Ready'}</span>
                  <span className="tabular-nums">{playback.durationMs}ms</span>
                </div>
                <div className="ag-slider-track-container">
                  <input
                    className="ag-timeline-range"
                    type="range"
                    min="0"
                    max={playback.durationMs}
                    step="1"
                    value={playback.timeMs}
                    style={{
                      background: `linear-gradient(to right, #3b82f6 ${timelinePercent}%, rgba(255, 255, 255, 0.1) ${timelinePercent}%)`,
                    }}
                    onChange={(event) => {
                      actions.cancel()
                      scenarioRunner.scrub(Number(event.target.value))
                    }}
                    aria-label="Scenario timeline"
                  />
                </div>
              </div>

              {/* Scenario Triggers */}
              {activeScenario.triggers && activeScenario.triggers.length > 0 && (
                <div className="ag-triggers-group">
                  {activeScenario.triggers.map((trigger) => (
                    <button
                      key={trigger.id}
                      type="button"
                      className="ag-btn-secondary text-xs"
                      onClick={() => scenarioRunner.trigger(trigger.id)}
                    >
                      <span className="ag-trigger-dot" />
                      <span>{trigger.label}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Scenario Parameters Tray */}
            <ScenarioParameters
              definitions={activeScenario.parameters ?? {}}
              values={parameters}
              onChange={(name, value) => {
                scenarioRunner.setParameter(name, value)
                setParameters(scenarioRunner.getParameters())
              }}
            />
          </div>
        </div>

        {/* Right Dock: Luau Code Previewer */}
        {luauOpen && (
          <aside className="ag-luau-dock">
            <LuauCodePreviewer
              activeAppId={activePhoneApp}
              onClose={() => setLuauOpen(false)}
            />
          </aside>
        )}

        {/* Right Dock: Inspector */}
        <ScenarioInspector
          scenarioName={activeScenario.name}
          playback={playback}
          events={traceEvents}
          bindings={bindingStore}
          realm={realm}
          effectPatches={effectPatches}
          persistenceSnapshot={persistence.snapshot()}
          isOpen={inspectorOpen}
          onClose={() => setInspectorOpen(false)}
        />
      </main>
    </div>
  )
}

export default App
