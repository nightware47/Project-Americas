export type PhoneAppCategory = 'utilities' | 'social' | 'productivity' | 'games' | 'shopping'
export type PhoneAppDefinition = {
  id: string
  label: string
  category: PhoneAppCategory
  icon: string
  installed: boolean
  dock: boolean
  badge?: number
}

// Full app roster matching upstream sky_phone specification
const installed = new Set([
  'phone', 'messages', 'camera', 'clock',
  'calculator', 'banking', 'weather', 'billing',
  'mail', 'crypto', 'notes', 'memos',
  'photos', 'app-store', 'settings', 'map', 'music', 'garage',
  'feather', 'calendar', 'health', 'citywarn', 'house',
  'darkchat', 'companies', 'crewlink', 'local-pages', 'weazel-news',
  'flare', 'fliptok', 'picstagram', 'radio', 'skyride', 'citymarkt',
  'snake', 'memory', 'number-merge', 'minesweeper', 'tower-stack', 'sky-flappy', 'neon-drop'
])

// 4 Dock icons matching the official Sky Phone hardware springboard
const dock = new Set(['phone', 'messages', 'camera', 'clock'])

const entries: Array<[string, string, PhoneAppCategory, number?]> = [
  // Page 1 Hero Apps (Exact 8 items matching Sky Phone specification)
  ['calculator', 'Calculator', 'productivity'],
  ['banking', 'Banking', 'social'],
  ['weather', 'Weather', 'utilities'],
  ['billing', 'Billing', 'utilities', 2],
  ['mail', 'Mail', 'social', 1],
  ['crypto', 'VaultX', 'utilities'],
  ['notes', 'Notes', 'productivity'],
  ['memos', 'Memos', 'productivity'],

  // Dock items
  ['phone', 'Phone', 'utilities'],
  ['messages', 'Messages', 'utilities'],
  ['camera', 'Camera', 'utilities'],
  ['clock', 'Clock', 'productivity'],

  // Page 2: System & Lifestyle apps
  ['photos', 'Photos', 'utilities'],
  ['app-store', 'App Store', 'utilities'],
  ['settings', 'Settings', 'utilities'],
  ['map', 'Map', 'utilities'],
  ['music', 'Music', 'productivity'],
  ['garage', 'Garage', 'utilities'],
  ['house', 'House', 'utilities'],
  ['citywarn', 'CityWarn', 'utilities'],
  ['feather', 'Feather', 'social'],
  ['calendar', 'Calendar', 'productivity'],
  ['health', 'Health', 'utilities'],
  ['darkchat', 'DarkChat', 'social'],
  ['companies', 'Companies', 'utilities'],
  ['crewlink', 'CrewLink', 'social'],
  ['local-pages', 'Local Pages', 'social'],
  ['weazel-news', 'Weazel News', 'social'],

  // Page 3: Entertainment & Media
  ['flare', 'Flare', 'social'],
  ['fliptok', 'FlipTok', 'social'],
  ['picstagram', 'Picstagram', 'social'],
  ['radio', 'Radio', 'social'],
  ['skyride', 'SkyRide', 'utilities'],
  ['citymarkt', 'CityMarkt', 'shopping'],

  // Page 4: Games
  ['snake', 'Snake', 'games'],
  ['memory', 'Memory', 'games'],
  ['number-merge', 'Number Merge', 'games'],
  ['minesweeper', 'Minesweeper', 'games'],
  ['tower-stack', 'Tower Stack', 'games'],
  ['sky-flappy', 'Sky Flappy', 'games'],
  ['neon-drop', 'Neon Drop', 'games'],
]

const iconMap: Record<string, string> = {
  photos: 'gallery',
  messages: 'sms',
  'app-store': 'apps',
  crypto: 'crypto',
}

export const PHONE_APPS: PhoneAppDefinition[] = entries.map(([id, label, category, badge]) => ({
  id,
  label,
  category,
  badge,
  installed: installed.has(id),
  dock: dock.has(id),
  icon: `${import.meta.env.BASE_URL}assets/phone/app-icons/${iconMap[id] ?? id}.webp`,
}))

export const INSTALLED_PHONE_APPS = PHONE_APPS.filter((app) => app.installed)
export const DOCK_PHONE_APPS = [
  PHONE_APPS.find((a) => a.id === 'phone')!,
  PHONE_APPS.find((a) => a.id === 'messages')!,
  PHONE_APPS.find((a) => a.id === 'camera')!,
  PHONE_APPS.find((a) => a.id === 'clock')!,
].filter(Boolean)
