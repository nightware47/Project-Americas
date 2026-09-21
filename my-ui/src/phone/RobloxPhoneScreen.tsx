// src/phone/RobloxPhoneScreen.tsx
// 1:1 In-Engine Roblox Studio Phone Screen
// Renders the exact Roblox UI Instance Tree via RobloxRenderer.tsx

import { useCallback, useEffect, useMemo, useState } from 'react'
import { RobloxRenderer, type RobloxInstanceJson } from '../renderer/RobloxRenderer.tsx'
import { createSkyPhoneInstanceTree } from './roblox/roblox-sky-phone-tree.ts'
import { uiAudio } from '../audio/ui-audio.ts'

type Props = {
  onActiveAppChange?: (appId: string) => void
  onClose?: () => void
}

export function RobloxPhoneScreen({ onActiveAppChange, onClose }: Props) {
  const [activeApp, setActiveApp] = useState<string>('home')
  const [activePhoneTab, setActivePhoneTab] = useState<'Recents' | 'Contacts' | 'Keypad'>('Recents')
  const [currentPage, setCurrentPage] = useState<number>(1)
  const [dynamicIslandExpanded, setDynamicIslandExpanded] = useState<boolean>(false)
  const [isMusicPlaying, setIsMusicPlaying] = useState<boolean>(false)
  const [timeText, setTimeText] = useState<string>('18:40')

  // Update clock display
  useEffect(() => {
    const updateTime = () => {
      const now = new Date()
      const hours = String(now.getHours()).padStart(2, '0')
      const minutes = String(now.getMinutes()).padStart(2, '0')
      setTimeText(`${hours}:${minutes}`)
    }
    updateTime()
    const timer = setInterval(updateTime, 10000)
    return () => clearInterval(timer)
  }, [])

  // Handle instance activations from the Roblox UI Engine
  const handleInstanceActivated = useCallback((instance: RobloxInstanceJson) => {
    const name = instance.Name ?? ''

    // 1. App Launch
    if (name.startsWith('App_') || name.startsWith('LibApp_')) {
      const appName = name.replace(/^(App_|LibApp_)/, '')
      uiAudio.playModalOpen()
      setActiveApp(appName)
      onActiveAppChange?.(appName)
      return
    }

    // 2. Widget Launch
    if (name.startsWith('Widget_')) {
      const widgetName = name.replace('Widget_', '')
      if (widgetName === 'Music') {
        setIsMusicPlaying((playing) => !playing)
        uiAudio.playCardFlip()
      } else {
        uiAudio.playModalOpen()
        setActiveApp(widgetName)
        onActiveAppChange?.(widgetName)
      }
      return
    }

    // 3. Page Indicator Dots
    if (name.startsWith('Dot_')) {
      const dotNum = Number(name.replace('Dot_', ''))
      if (!Number.isNaN(dotNum)) {
        uiAudio.playHover()
        setCurrentPage(dotNum)
      }
      return
    }

    // 4. Dynamic Island Click (Expand / Collapse)
    if (name === 'DynamicIsland') {
      uiAudio.playHover()
      setDynamicIslandExpanded((exp) => !exp)
      return
    }

    // 5. Home Indicator Bar Click (Return to Springboard)
    if (name === 'HomeIndicator') {
      uiAudio.playModalClose()
      setActiveApp('home')
      onActiveAppChange?.('home')
      return
    }

    // 6. Phone App Tabs
    if (name === 'Tab_Recents') {
      uiAudio.playHover()
      setActivePhoneTab('Recents')
      return
    }
    if (name === 'Tab_Contacts') {
      uiAudio.playHover()
      setActivePhoneTab('Contacts')
      return
    }
    if (name === 'Tab_Keypad') {
      uiAudio.playHover()
      setActivePhoneTab('Keypad')
      return
    }
  }, [onActiveAppChange])

  // Build the live Roblox instance tree
  const tree = useMemo(() => {
    return createSkyPhoneInstanceTree({
      activeApp,
      activePhoneTab,
      currentPage,
      dynamicIslandExpanded,
      timeText,
      isMusicPlaying,
      trackTitle: 'Neon Rain',
      artist: 'Mirror Park',
      trackProgress: isMusicPlaying ? 0.62 : 0.45,
      weatherTemp: '24°',
      weatherCity: 'Los Santos',
      weatherCond: '⛅ Partly Cloudy',
    })
  }, [activeApp, activePhoneTab, currentPage, dynamicIslandExpanded, isMusicPlaying, timeText])

  return (
    <div className="relative w-full h-full flex items-center justify-center select-none">
      {/* Phone Stage Wrapper */}
      <div className="relative w-full max-w-[390px] aspect-[390/844] max-h-[92vh] flex items-center justify-center">
        {/* Rendered via pure Roblox UI Engine */}
        <RobloxRenderer
          tree={tree}
          onInstanceActivated={handleInstanceActivated}
        />
      </div>

      {/* Floating Springboard Navigation Controls */}
      {activeApp.toLowerCase() === 'home' && (
        <div className="absolute -bottom-7 flex items-center gap-2 bg-slate-900/90 backdrop-blur-md px-3 py-1 rounded-full border border-slate-800 text-[11px] text-slate-400 shadow-xl">
          <span className="font-mono text-slate-300">Pages:</span>
          {[1, 2, 3, 4].map((page) => (
            <button
              key={page}
              type="button"
              className={`px-2 py-0.5 rounded font-mono transition-colors ${
                currentPage === page
                  ? 'bg-blue-600 text-white font-bold'
                  : 'hover:bg-slate-800 text-slate-400 hover:text-slate-200'
              }`}
              onClick={() => {
                uiAudio.playHover()
                setCurrentPage(page)
              }}
            >
              {page === 4 ? 'Lib' : `P${page}`}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
