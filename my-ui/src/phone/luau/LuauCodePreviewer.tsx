import { useState, useMemo, useEffect, useRef } from 'react'
import { LUAU_MODULES, getModuleByAppId, type LuauModuleInfo } from './luau-modules-bundle.ts'
import { RobloxStudioExplorer } from '../roblox/RobloxStudioExplorer.tsx'
import './luau-previewer.css'

interface Props {
  activeAppId?: string
  initialModuleId?: string
  onClose?: () => void
}

// Regex patterns for Luau syntax tokenization
const LUAU_KEYWORDS = new Set([
  'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function',
  'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then',
  'true', 'until', 'while', 'export', 'type',
])

const ROBLOX_GLOBALS = new Set([
  'Instance', 'Vector2', 'Vector3', 'UDim', 'UDim2', 'Color3', 'Enum',
  'task', 'game', 'workspace', 'script', 'math', 'string', 'table',
  'ipairs', 'pairs', 'type', 'typeof', 'print', 'warn', 'error',
  'pcall', 'xpcall', 'setmetatable', 'getmetatable', 'TweenInfo', 'Rect',
  'ColorSequence', 'ColorSequenceKeypoint', 'NumberSequence', 'NumberSequenceKeypoint',
])

function highlightLuauLine(line: string, query: string): (string | { type: string; text: string })[] {
  if (!line) return [' ']

  // Quick tokenization logic
  const tokens: (string | { type: string; text: string })[] = []
  let pos = 0
  const len = line.length

  while (pos < len) {
    // Comment
    if (line.slice(pos, pos + 2) === '--') {
      tokens.push({ type: 'comment', text: line.slice(pos) })
      break
    }

    // String ("..." or '...')
    if (line[pos] === '"' || line[pos] === "'") {
      const quote = line[pos]
      let end = pos + 1
      while (end < len && line[end] !== quote) {
        if (line[end] === '\\') end += 2
        else end++
      }
      end = Math.min(end + 1, len)
      tokens.push({ type: 'str', text: line.slice(pos, end) })
      pos = end
      continue
    }

    // Numbers
    if (/[0-9]/.test(line[pos]) && (pos === 0 || /[^A-Za-z0-9_]/.test(line[pos - 1]))) {
      let end = pos
      while (end < len && /[0-9.eE_]/.test(line[end])) end++
      tokens.push({ type: 'num', text: line.slice(pos, end) })
      pos = end
      continue
    }

    // Identifiers or Keywords
    if (/[A-Za-z_]/.test(line[pos])) {
      let end = pos
      while (end < len && /[A-Za-z0-9_]/.test(line[end])) end++
      const word = line.slice(pos, end)

      // Check if previous char was : or .
      const prevChar = pos > 0 ? line[pos - 1] : ''
      if (prevChar === ':') {
        tokens.push({ type: 'method', text: word })
      } else if (prevChar === '.') {
        tokens.push({ type: 'prop', text: word })
      } else if (LUAU_KEYWORDS.has(word)) {
        tokens.push({ type: 'kw', text: word })
      } else if (ROBLOX_GLOBALS.has(word)) {
        tokens.push({ type: 'built', text: word })
      } else {
        tokens.push(word)
      }
      pos = end
      continue
    }

    // Other characters (whitespace, punctuation)
    tokens.push(line[pos])
    pos++
  }

  // If query is present, highlight search matches inside text tokens
  if (query.trim()) {
    const qLower = query.toLowerCase()
    const result: (string | { type: string; text: string })[] = []

    for (const tok of tokens) {
      if (typeof tok === 'string') {
        const strLower = tok.toLowerCase()
        let lastIdx = 0
        let matchIdx = strLower.indexOf(qLower)
        if (matchIdx === -1) {
          result.push(tok)
        } else {
          while (matchIdx !== -1) {
            if (matchIdx > lastIdx) result.push(tok.slice(lastIdx, matchIdx))
            result.push({ type: 'match', text: tok.slice(matchIdx, matchIdx + query.length) })
            lastIdx = matchIdx + query.length
            matchIdx = strLower.indexOf(qLower, lastIdx)
          }
          if (lastIdx < tok.length) result.push(tok.slice(lastIdx))
        }
      } else {
        result.push(tok)
      }
    }
    return result
  }

  return tokens
}

export function LuauCodePreviewer({ activeAppId, initialModuleId = 'client', onClose }: Props) {
  // Default to 'client' matching the user's screenshot where SkyPhoneClient is selected
  const [selectedModuleId, setSelectedModuleId] = useState<string>(initialModuleId)
  const [searchQuery, setSearchQuery] = useState('')
  const [copied, setCopied] = useState(false)
  const [explorerCollapsed, setExplorerCollapsed] = useState(false)
  const codeViewportRef = useRef<HTMLDivElement>(null)

  // React to activeAppId from the phone:
  useEffect(() => {
    if (activeAppId) {
      const mapped = getModuleByAppId(activeAppId)
      if (mapped) {
        setSelectedModuleId(mapped.id)
      }
    }
  }, [activeAppId])

  const selectedModule = useMemo(() => {
    return LUAU_MODULES.find((m) => m.id === selectedModuleId) ?? LUAU_MODULES[0]
  }, [selectedModuleId])

  const lines = useMemo(() => {
    return selectedModule.code.split('\n')
  }, [selectedModule])

  const handleCopyCode = async () => {
    try {
      await navigator.clipboard.writeText(selectedModule.code)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // Fallback
    }
  }

  const handleDownloadFile = () => {
    const blob = new Blob([selectedModule.code], { type: 'text/plain;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = selectedModule.filename
    link.click()
    URL.revokeObjectURL(url)
  }

  // Scroll to top when switching modules
  useEffect(() => {
    if (codeViewportRef.current) {
      codeViewportRef.current.scrollTop = 0
    }
  }, [selectedModuleId])

  return (
    <div className="luau-previewer-root">
      <div className="luau-previewer-body">
        {/* Left Pane: Authentic Roblox Studio Explorer Tree */}
        <aside
          className={`luau-explorer-sidebar ${explorerCollapsed ? 'is-collapsed' : ''}`}
          aria-label="Roblox Studio Explorer"
        >
          <RobloxStudioExplorer
            selectedModuleId={selectedModuleId}
            onSelectModule={(modId) => setSelectedModuleId(modId)}
            showTitleBar={true}
          />
        </aside>

        {/* Right Pane: Roblox Studio Script Editor */}
        <div className="luau-editor-pane">
          {/* Top Script Tabs Bar */}
          <div className="luau-tabs-bar">
            <div className="luau-tabs-group">
              <div className="luau-tab-item">
                <span className="text-xs">
                  {selectedModule.id === 'client' ? '💻' : '📜'}
                </span>
                <span>{selectedModule.filename}</span>
              </div>
            </div>

            <div className="luau-tab-actions">
              {/* Explorer Toggle Button */}
              <button
                type="button"
                className={`luau-tab-btn ${!explorerCollapsed ? 'is-active' : ''}`}
                onClick={() => setExplorerCollapsed((c) => !c)}
                title={explorerCollapsed ? 'Show Roblox Studio Explorer' : 'Hide Roblox Studio Explorer'}
              >
                <span>🗂️</span>
                <span className="hidden sm:inline">Explorer</span>
              </button>

              <button
                type="button"
                className={`luau-tab-btn ${copied ? 'is-success' : ''}`}
                onClick={handleCopyCode}
                title="Copy current Luau script to clipboard"
              >
                {copied ? (
                  <>
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                    <span>Copied!</span>
                  </>
                ) : (
                  <>
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
                      <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
                    </svg>
                    <span>Copy</span>
                  </>
                )}
              </button>

              <button
                type="button"
                className="luau-tab-btn"
                onClick={handleDownloadFile}
                title={`Download ${selectedModule.filename}`}
              >
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                  <polyline points="7 10 12 15 17 10" />
                  <line x1="12" y1="15" x2="12" y2="3" />
                </svg>
                <span>Download</span>
              </button>

              {onClose && (
                <button
                  type="button"
                  className="luau-tab-btn text-slate-400 hover:text-white"
                  onClick={onClose}
                  title="Close Panel"
                >
                  ✕
                </button>
              )}
            </div>
          </div>

          {/* Secondary Meta Bar */}
          <div className="luau-meta-bar">
            <div className="luau-meta-left">
              <span className="luau-meta-badge badge-category">{selectedModule.category}</span>
              <span className="luau-meta-badge">{selectedModule.linesCount.toLocaleString()} lines</span>
              <span className="luau-meta-badge">{(selectedModule.sizeBytes / 1024).toFixed(1)} KB</span>
              {activeAppId && selectedModule.appIds.includes(activeAppId) && (
                <span className="luau-meta-badge badge-sync" title="Synchronized with active phone app">
                  ⚡ App: {activeAppId}
                </span>
              )}
            </div>

            <div className="luau-search-box">
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#6e7681" strokeWidth="2" className="mr-1">
                <circle cx="11" cy="11" r="8" />
                <line x1="21" y1="21" x2="16.65" y2="16.65" />
              </svg>
              <input
                type="text"
                className="luau-search-input"
                placeholder="Search code..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
          </div>

          {/* Module Description */}
          <div className="luau-module-desc">
            <strong>{selectedModule.name}:</strong> {selectedModule.description}
          </div>

          {/* Code Viewport with Line Numbers and Syntax Highlighting */}
          <div className="luau-code-viewport" ref={codeViewportRef}>
            <div className="luau-code-table">
              {lines.map((rawLine, idx) => {
                const lineNum = idx + 1
                const tokens = highlightLuauLine(rawLine, searchQuery)
                const hasQuery = searchQuery.trim().length > 0 && rawLine.toLowerCase().includes(searchQuery.toLowerCase())

                return (
                  <div key={lineNum} className={`luau-line-row ${hasQuery ? 'is-highlighted' : ''}`}>
                    <div className="luau-line-num">{lineNum}</div>
                    <div className="luau-line-content">
                      {tokens.map((tok, tIdx) => {
                        if (typeof tok === 'string') {
                          return <span key={tIdx}>{tok}</span>
                        }
                        return (
                          <span key={tIdx} className={`tok-${tok.type}`}>
                            {tok.text}
                          </span>
                        )
                      })}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
