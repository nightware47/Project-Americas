// src/phone/roblox/RobloxExplorerTree.tsx
// Interactive Roblox Studio Explorer Window
// Inspects the live Roblox UI Instance Tree matching Roblox Studio Explorer 1:1

import { useState } from 'react'
import type { RobloxInstanceJson } from '../../renderer/RobloxRenderer.tsx'

type Props = {
  tree: RobloxInstanceJson
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

export function RobloxExplorerTree({ tree }: Props) {
  const [selectedNode, setSelectedNode] = useState<string | null>('Screen')

  return (
    <div className="flex flex-col h-full bg-slate-950 border border-slate-800 rounded-xl overflow-hidden shadow-2xl">
      {/* Explorer Header */}
      <div className="flex items-center justify-between px-3 py-2 bg-slate-900 border-b border-slate-800">
        <div className="flex items-center gap-2">
          <span className="text-sm">🗂️</span>
          <span className="text-xs font-bold text-slate-200 tracking-wide">Studio Explorer</span>
          <span className="text-[10px] bg-blue-500/20 text-blue-300 px-1.5 py-0.5 rounded font-mono border border-blue-500/30">
            Live Instances
          </span>
        </div>
        <span className="text-[10px] text-slate-400 font-mono">1:1 Pair</span>
      </div>

      {/* Instance Tree Content */}
      <div className="flex-1 overflow-y-auto p-2 space-y-0.5 custom-scrollbar">
        <InstanceNode
          instance={tree}
          selectedNode={selectedNode}
          onSelect={setSelectedNode}
        />
      </div>

      {/* Footer Info */}
      <div className="px-3 py-2 bg-slate-900/80 border-t border-slate-800 text-[11px] text-slate-400 flex items-center justify-between">
        <span>Roblox UI Engine (pure Luau semantics)</span>
        <span className="font-mono text-blue-400">UDim2 • Color3</span>
      </div>
    </div>
  )
}
