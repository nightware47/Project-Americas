// src/phone/roblox/RobloxExplorerTree.tsx
// Interactive Roblox Studio Explorer Window
// Supports both Rule 10 StarterGui Scripts Hierarchy and PlayerGui Live Runtime Tree

import { useState } from 'react'
import type { RobloxInstanceJson } from '../../renderer/RobloxRenderer.tsx'
import { RobloxStudioExplorer } from './RobloxStudioExplorer.tsx'

type Props = {
  tree: RobloxInstanceJson
  selectedModuleId?: string
  onSelectModule?: (moduleId: string) => void
}

const CLASS_ICONS: Record<string, string> = {
  ScreenGui: '🖥️',
  Frame: '⬜',
  TextLabel: '📝',
  TextButton: '🔘',
  ImageLabel: '🖼️',
  ImageButton: '🔘',
  ScrollingFrame: '📜',
  UICorner: '◻️',
  UIStroke: '⭕',
  UIGradient: '🌈',
  UIListLayout: '📑',
  UIGridLayout: '▦',
  UIPageLayout: '📖',
  UIAspectRatioConstraint: '📐',
  Folder: '📁',
}

function InstanceNode({
  instance,
  level = 0,
  selectedNode,
  onSelect,
}: {
  instance: RobloxInstanceJson
  level?: number
  selectedNode: string | null
  onSelect: (name: string) => void
}) {
  const [collapsed, setCollapsed] = useState(level > 2)
  const hasChildren = Boolean(instance.Children && instance.Children.length > 0)
  const isSelected = selectedNode === (instance.Name ?? instance.ClassName)
  const icon = CLASS_ICONS[instance.ClassName] ?? '🔹'

  return (
    <div className="text-[12px] font-mono select-none">
      <div
        className={`flex items-center gap-1.5 py-1 px-2 rounded cursor-pointer transition-colors ${
          isSelected
            ? 'bg-blue-600/30 text-blue-200 border border-blue-500/40'
            : 'hover:bg-slate-800/60 text-slate-300'
        }`}
        style={{ paddingLeft: `${Math.max(8, level * 16)}px` }}
        onClick={() => onSelect(instance.Name ?? instance.ClassName)}
      >
        {hasChildren ? (
          <button
            type="button"
            className="w-3.5 h-3.5 flex items-center justify-center text-[9px] text-slate-400 hover:text-slate-200"
            onClick={(e) => {
              e.stopPropagation()
              setCollapsed(!collapsed)
            }}
          >
            {collapsed ? '▶' : '▼'}
          </button>
        ) : (
          <span className="w-3.5" />
        )}

        <span className="text-[11px] opacity-80">{icon}</span>
        <span className="font-semibold text-slate-200">{instance.Name ?? instance.ClassName}</span>
        <span className="text-[10px] text-slate-500 font-sans">({instance.ClassName})</span>
      </div>

      {!collapsed && hasChildren && (
        <div>
          {instance.Children!.map((child, idx) => (
            <InstanceNode
              key={`${child.Name ?? child.ClassName}-${idx}`}
              instance={child}
              level={level + 1}
              selectedNode={selectedNode}
              onSelect={onSelect}
            />
          ))}
        </div>
      )}
    </div>
  )
}

export function RobloxExplorerTree({ tree, selectedModuleId = 'client', onSelectModule }: Props) {
  const [explorerMode, setExplorerMode] = useState<'starter_gui' | 'player_gui'>('starter_gui')
  const [selectedNode, setSelectedNode] = useState<string | null>('Screen')

  return (
    <div className="flex flex-col h-full bg-[#232527] border border-[#303338] rounded-xl overflow-hidden shadow-2xl">
      {/* Explorer Mode Switcher Header */}
      <div className="flex items-center justify-between px-3 py-2 bg-[#2c2e33] border-b border-[#1c1d20]">
        <div className="flex items-center gap-1 bg-[#1a1b1e] p-1 rounded-md border border-[#383c44]">
          <button
            type="button"
            className={`px-2.5 py-1 text-xs font-semibold rounded transition-colors ${
              explorerMode === 'starter_gui'
                ? 'bg-[#005fb8] text-white shadow'
                : 'text-slate-400 hover:text-slate-200'
            }`}
            onClick={() => setExplorerMode('starter_gui')}
            title="Rule 10: StarterGui (Pure Luau Scripts Only)"
          >
            StarterGui (Rule 10)
          </button>
          <button
            type="button"
            className={`px-2.5 py-1 text-xs font-semibold rounded transition-colors ${
              explorerMode === 'player_gui'
                ? 'bg-[#005fb8] text-white shadow'
                : 'text-slate-400 hover:text-slate-200'
            }`}
            onClick={() => setExplorerMode('player_gui')}
            title="Live Runtime PlayerGui In-Engine GUI Tree"
          >
            PlayerGui (Live)
          </button>
        </div>

        <span className="text-[10px] text-slate-400 font-mono">Roblox Studio 1:1</span>
      </div>

      {/* Explorer Content */}
      <div className="flex-1 overflow-hidden">
        {explorerMode === 'starter_gui' ? (
          <RobloxStudioExplorer
            selectedModuleId={selectedModuleId}
            onSelectModule={(modId) => {
              if (onSelectModule) {
                onSelectModule(modId)
              }
            }}
            showTitleBar={true}
          />
        ) : (
          <div className="h-full overflow-y-auto p-2 space-y-0.5 custom-scrollbar bg-slate-950">
            <InstanceNode
              instance={tree}
              selectedNode={selectedNode}
              onSelect={setSelectedNode}
            />
          </div>
        )}
      </div>

      {/* Footer Info */}
      <div className="px-3 py-1.5 bg-[#1e2023] border-t border-[#18191c] text-[11px] text-slate-400 flex items-center justify-between">
        <span>{explorerMode === 'starter_gui' ? 'Pure Luau Architecture' : 'Roblox UI Engine (UDim2)'}</span>
        <span className="font-mono text-sky-400">
          {explorerMode === 'starter_gui' ? '10 Modules • 0 Pre-Baked GUI' : 'Dynamic Runtime'}
        </span>
      </div>
    </div>
  )
}
