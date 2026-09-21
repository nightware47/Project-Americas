import { useState, useMemo } from 'react'
import './roblox-studio-explorer.css'

export interface ExplorerNode {
  id: string
  name: string
  className: 'Folder' | 'ScreenGui' | 'ModuleScript' | 'LocalScript' | 'StarterGui'
  moduleId?: string
  children?: ExplorerNode[]
  iconType: 'starter_gui' | 'screen_gui' | 'folder' | 'module_script' | 'local_script'
}

// Exact Roblox Studio Hierarchy matching user screenshot media_1790026736848.png
export const SKY_PHONE_EXPLORER_TREE: ExplorerNode = {
  id: 'StarterGui',
  name: 'StarterGui',
  className: 'StarterGui',
  iconType: 'starter_gui',
  children: [
    {
      id: 'SkyPhone_Emulator',
      name: 'SkyPhone_Emulator',
      className: 'ScreenGui',
      iconType: 'screen_gui',
      children: [
        {
          id: 'Modules',
          name: 'Modules',
          className: 'Folder',
          iconType: 'folder',
          children: [
            {
              id: 'AppSuite_Core',
              name: 'AppSuite_Core',
              className: 'ModuleScript',
              moduleId: 'suite-core',
              iconType: 'module_script',
            },
            {
              id: 'AppSuite_Ecosystem',
              name: 'AppSuite_Ecosystem',
              className: 'ModuleScript',
              moduleId: 'suite-ecosystem',
              iconType: 'module_script',
            },
            {
              id: 'AppSuite_Finance_Gaming',
              name: 'AppSuite_Finance_Gaming',
              className: 'ModuleScript',
              moduleId: 'suite-finance-gaming',
              iconType: 'module_script',
            },
            {
              id: 'AppSuite_Tools',
              name: 'AppSuite_Tools',
              className: 'ModuleScript',
              moduleId: 'suite-tools',
              iconType: 'module_script',
            },
            {
              id: 'BottomSheet',
              name: 'BottomSheet',
              className: 'ModuleScript',
              moduleId: 'bottomsheet',
              iconType: 'module_script',
            },
            {
              id: 'Chassis',
              name: 'Chassis',
              className: 'ModuleScript',
              moduleId: 'chassis',
              iconType: 'module_script',
            },
            {
              id: 'Router',
              name: 'Router',
              className: 'ModuleScript',
              moduleId: 'router',
              iconType: 'module_script',
            },
            {
              id: 'SkyPhone',
              name: 'SkyPhone',
              className: 'ModuleScript',
              moduleId: 'init',
              iconType: 'module_script',
            },
            {
              id: 'Springboard',
              name: 'Springboard',
              className: 'ModuleScript',
              moduleId: 'springboard',
              iconType: 'module_script',
            },
          ],
        },
        {
          id: 'SkyPhoneClient',
          name: 'SkyPhoneClient',
          className: 'LocalScript',
          moduleId: 'client',
          iconType: 'local_script',
        },
      ],
    },
  ],
}

// Pixel-perfect SVG Class Icons for Roblox Studio
function RobloxClassIcon({ type }: { type: ExplorerNode['iconType'] }) {
  switch (type) {
    case 'starter_gui':
      return (
        <svg className="rbx-class-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
          {/* Yellow Folder body */}
          <path
            d="M1.5 3C1.5 2.45 1.95 2 2.5 2H6L7.5 3.5H13.5C14.05 3.5 14.5 3.95 14.5 4.5V12.5C14.5 13.05 14.05 13.5 13.5 13.5H2.5C1.95 13.5 1.5 13.05 1.5 12.5V3Z"
            fill="#F5D061"
            stroke="#A37E1C"
            strokeWidth="0.8"
          />
          <path d="M2.5 4.5H13.5V12.5H2.5V4.5Z" fill="#FAD97A" />
          {/* Screen GUI overlay badge in bottom right corner */}
          <rect x="7" y="7" width="8" height="6.5" rx="1" fill="#FFFFFF" stroke="#22262E" strokeWidth="0.8" />
          <rect x="8" y="8" width="6" height="4" fill="#3A86FF" />
          <rect x="9.5" y="13" width="3" height="1" fill="#555A64" />
        </svg>
      )

    case 'screen_gui':
      return (
        <svg className="rbx-class-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
          {/* Blue outline window with title bar */}
          <rect
            x="1.5"
            y="2.5"
            width="13"
            height="11"
            rx="1.5"
            fill="#0B2B48"
            fillOpacity="0.45"
            stroke="#00A2FF"
            strokeWidth="1.2"
          />
          <line x1="2" y1="5.5" x2="14" y2="5.5" stroke="#00A2FF" strokeWidth="1" />
          <rect x="3.5" y="3.5" width="2" height="1" fill="#00A2FF" />
          <rect x="6.5" y="3.5" width="1.5" height="1" fill="#00A2FF" />
        </svg>
      )

    case 'folder':
      return (
        <svg className="rbx-class-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
          {/* Classic Roblox yellow folder */}
          <path
            d="M1.5 3C1.5 2.45 1.95 2 2.5 2H6.2L7.7 3.5H13.5C14.05 3.5 14.5 3.95 14.5 4.5V12.5C14.5 13.05 14.05 13.5 13.5 13.5H2.5C1.95 13.5 1.5 13.05 1.5 12.5V3Z"
            fill="#E8B038"
            stroke="#A77A18"
            strokeWidth="0.8"
          />
          <path d="M2.5 5H13.5V12.5H2.5V5Z" fill="#FAD97A" />
        </svg>
      )

    case 'module_script':
      return (
        <svg className="rbx-class-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
          {/* Purple script document */}
          <path d="M2.5 1.5H10.5L13.5 4.5V14.5H2.5V1.5Z" fill="#884EA0" stroke="#5B2C6F" strokeWidth="0.8" />
          {/* Top folded corner */}
          <path d="M10.5 1.5V4.5H13.5" fill="#BB8FCE" />
          {/* White code lines */}
          <line x1="4.5" y1="4.5" x2="9" y2="4.5" stroke="#FFFFFF" strokeWidth="1" strokeLinecap="round" />
          <line x1="4.5" y1="7" x2="11.5" y2="7" stroke="#FFFFFF" strokeWidth="1" strokeLinecap="round" />
          <line x1="4.5" y1="9.5" x2="8" y2="9.5" stroke="#FFFFFF" strokeWidth="1" strokeLinecap="round" />
          {/* White right shortcut arrow badge */}
          <path
            d="M8.5 11.5H11.5V9.5L14.5 12.5L11.5 15.5V13.5H8.5V11.5Z"
            fill="#FFFFFF"
            stroke="#5B2C6F"
            strokeWidth="0.5"
          />
        </svg>
      )

    case 'local_script':
      return (
        <svg className="rbx-class-icon" width="16" height="16" viewBox="0 0 16 16" fill="none">
          {/* Blue script document */}
          <path d="M2.5 1.5H10.5L13.5 4.5V14.5H2.5V1.5Z" fill="#0084FF" stroke="#005FB8" strokeWidth="0.8" />
          {/* Top folded corner */}
          <path d="M10.5 1.5V4.5H13.5" fill="#66B8FF" />
          {/* White code lines */}
          <line x1="4.5" y1="4.5" x2="9" y2="4.5" stroke="#FFFFFF" strokeWidth="1" strokeLinecap="round" />
          <line x1="4.5" y1="7" x2="11.5" y2="7" stroke="#FFFFFF" strokeWidth="1" strokeLinecap="round" />
          <line x1="4.5" y1="9.5" x2="8" y2="9.5" stroke="#FFFFFF" strokeWidth="1" strokeLinecap="round" />
          {/* White desktop monitor badge */}
          <rect x="7" y="10" width="7.5" height="5" rx="0.6" fill="#FFFFFF" stroke="#003D7A" strokeWidth="0.5" />
          <rect x="8" y="11" width="5.5" height="3" fill="#005FB8" />
          <rect x="9.5" y="14.8" width="2.5" height="1" fill="#FFFFFF" />
        </svg>
      )

    default:
      return null
  }
}

interface Props {
  selectedModuleId?: string
  onSelectModule?: (moduleId: string, scriptName: string) => void
  showTitleBar?: boolean
  className?: string
}

export function RobloxStudioExplorer({
  selectedModuleId = 'client',
  onSelectModule,
  showTitleBar = true,
  className = '',
}: Props) {
  const [filterQuery, setFilterQuery] = useState('')
  const [expandedNodes, setExpandedNodes] = useState<Record<string, boolean>>({
    StarterGui: true,
    SkyPhone_Emulator: true,
    Modules: true,
  })

  // Selected row id: matches node.id
  const [selectedNodeId, setSelectedNodeId] = useState<string>('SkyPhoneClient')

  // Keep selectedNodeId in sync if selectedModuleId changes from outside
  useMemo(() => {
    if (selectedModuleId) {
      if (selectedModuleId === 'client') setSelectedNodeId('SkyPhoneClient')
      else if (selectedModuleId === 'init') setSelectedNodeId('SkyPhone')
      else if (selectedModuleId === 'chassis') setSelectedNodeId('Chassis')
      else if (selectedModuleId === 'springboard') setSelectedNodeId('Springboard')
      else if (selectedModuleId === 'bottomsheet') setSelectedNodeId('BottomSheet')
      else if (selectedModuleId === 'router') setSelectedNodeId('Router')
      else if (selectedModuleId === 'suite-core') setSelectedNodeId('AppSuite_Core')
      else if (selectedModuleId === 'suite-tools') setSelectedNodeId('AppSuite_Tools')
      else if (selectedModuleId === 'suite-finance-gaming') setSelectedNodeId('AppSuite_Finance_Gaming')
      else if (selectedModuleId === 'suite-ecosystem') setSelectedNodeId('AppSuite_Ecosystem')
    }
  }, [selectedModuleId])

  const toggleExpand = (id: string, e: React.MouseEvent) => {
    e.stopPropagation()
    setExpandedNodes((prev) => ({
      ...prev,
      [id]: !prev[id],
    }))
  }

  const handleSelectNode = (node: ExplorerNode) => {
    setSelectedNodeId(node.id)
    if (node.moduleId && onSelectModule) {
      onSelectModule(node.moduleId, node.name)
    }
  }

  // Recursive tree renderer matching Roblox Studio Explorer layout
  const renderNode = (node: ExplorerNode, depth = 0) => {
    const hasChildren = Boolean(node.children && node.children.length > 0)
    const isExpanded = expandedNodes[node.id] ?? true
    const isSelected = selectedNodeId === node.id

    // Check if node or its descendants match search query
    const q = filterQuery.toLowerCase().trim()
    const matchesSelf = !q || node.name.toLowerCase().includes(q)
    const matchesChild =
      hasChildren && node.children?.some((c) => c.name.toLowerCase().includes(q))

    if (q && !matchesSelf && !matchesChild) {
      return null
    }

    // Indentation: matching Roblox Studio Explorer
    // Depth 0: 4px
    // Depth 1: 18px
    // Depth 2: 32px
    // Depth 3: 46px
    const paddingLeft = 4 + depth * 14

    return (
      <div key={node.id} className="rbx-tree-item-group">
        <div
          className={`rbx-explorer-row ${isSelected ? 'is-selected' : ''}`}
          style={{ paddingLeft: `${paddingLeft}px` }}
          onClick={() => handleSelectNode(node)}
          title={`${node.name} (${node.className})`}
        >
          {/* Chevron slot */}
          {hasChildren ? (
            <button
              type="button"
              className="rbx-chevron-btn"
              onClick={(e) => toggleExpand(node.id, e)}
              aria-label={isExpanded ? 'Collapse' : 'Expand'}
            >
              {isExpanded ? (
                <svg width="8" height="8" viewBox="0 0 8 8" fill="currentColor">
                  <polygon points="1,2 7,2 4,6" />
                </svg>
              ) : (
                <svg width="8" height="8" viewBox="0 0 8 8" fill="currentColor">
                  <polygon points="2,1 6,4 2,7" />
                </svg>
              )}
            </button>
          ) : (
            <span className="rbx-chevron-spacer" />
          )}

          {/* Class Icon */}
          <div className="rbx-icon-slot">
            <RobloxClassIcon type={node.iconType} />
          </div>

          {/* Label */}
          <span className="rbx-node-name">{node.name}</span>
        </div>

        {/* Recursive Children */}
        {hasChildren && isExpanded && (
          <div className="rbx-tree-children">
            {node.children!.map((child) => renderNode(child, depth + 1))}
          </div>
        )}
      </div>
    )
  }

  return (
    <div className={`rbx-explorer-container ${className}`}>
      {/* Studio Window Header */}
      {showTitleBar && (
        <div className="rbx-explorer-header">
          <div className="rbx-explorer-title-row">
            <span className="rbx-explorer-title">Explorer</span>
            <div className="rbx-explorer-actions">
              <span className="rbx-studio-badge" title="Rule 10: Scripts Only in StarterGui">
                Rule 10
              </span>
            </div>
          </div>

          {/* Filter Bar */}
          <div className="rbx-filter-wrap">
            <svg
              className="rbx-filter-icon"
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
            >
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
            <input
              type="text"
              className="rbx-filter-input"
              placeholder="Filter StarterGui (Ctrl+Shift+X)"
              value={filterQuery}
              onChange={(e) => setFilterQuery(e.target.value)}
              spellCheck={false}
            />
            {filterQuery && (
              <button
                type="button"
                className="rbx-filter-clear"
                onClick={() => setFilterQuery('')}
                aria-label="Clear filter"
              >
                ✕
              </button>
            )}
          </div>
        </div>
      )}

      {/* Explorer Tree Canvas */}
      <div className="rbx-explorer-tree-viewport">
        {renderNode(SKY_PHONE_EXPLORER_TREE, 0)}
      </div>

      {/* Status Bar */}
      <div className="rbx-explorer-footer">
        <span className="text-[10px] text-neutral-400">10 Luau Modules • 0 Pre-Baked GUI</span>
        <span className="rbx-status-mode">StarterGui</span>
      </div>
    </div>
  )
}
