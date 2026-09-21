export type RobloxAssetState = 'loading' | 'ready' | 'error'

export type RobloxAssetRecord = {
  canonical: string
  url?: string
  state: RobloxAssetState
  error?: string
}

export type RobloxAssetResolver = {
  resolve(reference: string, kind?: 'image' | 'thumbnail' | 'font'): RobloxAssetRecord
  load(reference: string, kind?: 'image' | 'thumbnail' | 'font'): Promise<RobloxAssetRecord>
  resolveFontFamily(family: string): string
  getFallback?(reference: string): string | undefined
  clear(): void
}

const ASSET_PATTERN = /^rbxassetid:\/\/(\d+)$/i

const ASSET_FALLBACKS: Record<string, string> = {
  // Wallpaper: Deep space nebula gradient with stars matching Roblox Studio
  '82226915452893': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="390" height="844" viewBox="0 0 390 844"><defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%230c0e1c"/><stop offset="35%" stop-color="%231a1630"/><stop offset="65%" stop-color="%2323143d"/><stop offset="100%" stop-color="%230c0e1c"/></linearGradient><radialGradient id="nebula1" cx="70%" cy="30%" r="55%"><stop offset="0%" stop-color="%237928ca" stop-opacity="0.35"/><stop offset="60%" stop-color="%232b0f54" stop-opacity="0.1"/><stop offset="100%" stop-color="%23000000" stop-opacity="0"/></radialGradient><radialGradient id="nebula2" cx="30%" cy="70%" r="50%"><stop offset="0%" stop-color="%230070f3" stop-opacity="0.25"/><stop offset="100%" stop-color="%23000000" stop-opacity="0"/></radialGradient></defs><rect width="390" height="844" fill="url(%23bg)"/><rect width="390" height="844" fill="url(%23nebula1)"/><rect width="390" height="844" fill="url(%23nebula2)"/></svg>`,
  // Phone: Green phone icon
  '70546187772415': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%2334c759"/><path d="M19 16c1.2 0 2.2.8 2.6 1.9l1 2.8c.3.9.1 1.9-.6 2.6l-1.5 1.5c1.4 2.8 3.7 5.1 6.5 6.5l1.5-1.5c.7-.7 1.7-.9 2.6-.6l2.8 1c1.1.4 1.9 1.4 1.9 2.6v3.2c0 1.5-1.2 2.7-2.7 2.7C24.4 38.7 15.3 29.6 16.3 18.7c0-1.5 1.2-2.7 2.7-2.7H19z" fill="white"/></svg>`,
  // Messages: Green chat bubble
  '139358287735244': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%2334c759"/><path d="M27 15c-7.7 0-14 5.4-14 12 0 3.8 2.1 7.2 5.4 9.4L17 40l4.8-1.6c1.6.5 3.3.8 5.2.8 7.7 0 14-5.4 14-12s-6.3-12-14-12z" fill="white"/></svg>`,
  // Camera: Neutral grey camera
  '134300653681700': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%238e8e93"/><circle cx="27" cy="28" r="9" fill="%232c2c2e"/><circle cx="27" cy="28" r="5" fill="%23007aff"/><path d="M22 17l1.5-2.5h7L32 17h5c1.1 0 2 .9 2 2v17c0 1.1-.9 2-2 2H17c-1.1 0-2-.9-2-2V19c0-1.1.9-2 2-2h5z" fill="none" stroke="white" stroke-width="2.5"/></svg>`,
  // Clock: Analog dark clock face
  '103043499972901': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%231c1c1e"/><circle cx="27" cy="27" r="18" fill="%23000" stroke="%233a3a3c" stroke-width="2"/><line x1="27" y1="27" x2="27" y2="16" stroke="white" stroke-width="2" stroke-linecap="round"/><line x1="27" y1="27" x2="35" y2="27" stroke="white" stroke-width="2" stroke-linecap="round"/><circle cx="27" cy="27" r="2" fill="%23ff9500"/></svg>`,
  // Calculator: Pastel green calculator
  '129797552944912': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%23a8d5ba"/><rect x="15" y="13" width="24" height="9" rx="3" fill="%23e8f5e9"/><circle cx="19" cy="29" r="2.5" fill="%23388e3c"/><circle cx="27" cy="29" r="2.5" fill="%23388e3c"/><circle cx="35" cy="29" r="2.5" fill="%23ff9800"/><circle cx="19" cy="37" r="2.5" fill="%23388e3c"/><circle cx="27" cy="37" r="2.5" fill="%23388e3c"/><circle cx="35" cy="37" r="2.5" fill="%23f44336"/></svg>`,
  // Banking: Navy Bank Temple
  '113219823990413': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%23007aff"/><path d="M27 15l-12 6v3h24v-3L27 15zm-10 11v10h3V26h-3zm7 0v10h3V26h-3zm7 0v10h3V26h-3zm-16 12v3h26v-3H15z" fill="white"/></svg>`,
  // Weather: Sun & Cloud
  '93316242404129': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%235ac8fa"/><circle cx="33" cy="22" r="8" fill="%23ffcc00"/><path d="M21 37h15c4 0 7-3 7-7 0-3.5-2.5-6.4-6-6.9C36.3 19.3 32.5 16 28 16c-4.8 0-8.8 3.8-9 8.6C15.6 25.3 13 28 13 31.5c0 3 2.5 5.5 5.5 5.5h2.5z" fill="white"/></svg>`,
  // Billing: Coral red receipt
  '120691943073443': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%23ff3b30"/><path d="M17 14h20v26l-3.5-2-3.5 2-3-2-3 2-3.5-2-3.5 2V14z" fill="white"/><rect x="21" y="20" width="12" height="2" rx="1" fill="%23ff3b30"/><rect x="21" y="25" width="12" height="2" rx="1" fill="%23ff3b30"/><rect x="21" y="30" width="8" height="2" rx="1" fill="%23ff3b30"/></svg>`,
  // Mail: Blue envelope
  '124444731583599': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%23007aff"/><path d="M15 19c0-1.1.9-2 2-2h20c1.1 0 2 .9 2 2v16c0 1.1-.9 2-2 2H17c-1.1 0-2-.9-2-2V19zm3 0l9 7 9-7H18zm20 3.2l-8.5 6.6-2.5 1.9-2.5-1.9L16 22.2V35h22V22.2z" fill="white"/></svg>`,
  // VaultX: Cyan crystal
  '75815873536189': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%231a2332"/><circle cx="27" cy="27" r="14" fill="none" stroke="%2330d158" stroke-width="3"/><polygon points="27,17 35,23 35,31 27,37 19,31 19,23" fill="%2300c7be"/></svg>`,
  // Notes: Yellow notepad
  '126379364685622': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%23ffcc00"/><path d="M18 15h18c1.1 0 2 .9 2 2v20c0 1.1-.9 2-2 2H18c-1.1 0-2-.9-2-2V17c0-1.1.9-2 2-2z" fill="white"/><line x1="20" y1="21" x2="34" y2="21" stroke="%23ffcc00" stroke-width="2"/><line x1="20" y1="26" x2="34" y2="26" stroke="%23e5e5ea" stroke-width="2"/></svg>`,
  // Voice Memos: Black waveform
  '105967486602343': `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 54 54"><rect width="54" height="54" rx="13" fill="%231c1c1e"/><rect x="17" y="24" width="2" height="6" rx="1" fill="white"/><rect x="21" y="20" width="2" height="14" rx="1" fill="white"/><rect x="25" y="16" width="2" height="22" rx="1" fill="white"/><rect x="29" y="18" width="2" height="18" rx="1" fill="%23ff3b30"/><rect x="33" y="22" width="2" height="10" rx="1" fill="%23ff3b30"/></svg>`,
}

export function createRobloxAssetResolver(): RobloxAssetResolver {
  const cache = new Map<string, RobloxAssetRecord>()
  const fontPromises = new Map<string, Promise<RobloxAssetRecord>>()
  return {
    resolve(reference, kind = 'image') {
      const key = `${kind}:${reference}`
      const cached = cache.get(key)
      if (cached) return cached
      const match = ASSET_PATTERN.exec(reference)
      if (!match) {
        const record = { canonical: reference, state: 'error' as const, error: 'Unsupported Roblox asset reference' }
        cache.set(key, record)
        return record
      }
      const id = match[1]
      const fallbackUrl = ASSET_FALLBACKS[id]
      const url = kind === 'thumbnail'
        ? `https://www.roblox.com/asset-thumbnail/image?assetId=${id}&width=420&height=420&format=png`
        : `https://assetdelivery.roblox.com/v1/asset/?id=${id}`
      const record = { canonical: reference, url: fallbackUrl || url, state: 'loading' as const }
      cache.set(key, record)
      return record
    },
    async load(reference, kind = 'image') {
      const record = this.resolve(reference, kind)
      if (record.state === 'error' || !record.url) return record
      return record
    },
    resolveFontFamily(family) {
      const match = ASSET_PATTERN.exec(family)
      if (!match) return family.split('/').pop()?.replace(/\.json$/i, '') ?? family
      const fontName = `RobloxFont_${match[1]}`
      if (!fontPromises.has(family) && typeof FontFace !== 'undefined' && typeof document !== 'undefined') {
        const promise = new FontFace(fontName, `url(${this.resolve(family, 'font').url ?? ''})`).load().then((font) => {
          document.fonts.add(font)
          return { canonical: family, state: 'ready' as const, url: fontName }
        }).catch((error: unknown) => ({ canonical: family, state: 'error' as const, error: String(error) }))
        fontPromises.set(family, promise)
      }
      return fontName
    },
    getFallback(reference: string) {
      const match = ASSET_PATTERN.exec(reference)
      if (match && ASSET_FALLBACKS[match[1]]) {
        return ASSET_FALLBACKS[match[1]]
      }
      return undefined
    },
    clear() {
      cache.clear()
      fontPromises.clear()
    },
  }
}

