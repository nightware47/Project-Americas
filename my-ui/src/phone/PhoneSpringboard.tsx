import { useState, useEffect } from 'react'
import { PHONE_APPS, type PhoneAppDefinition } from './phone-apps'

type Props = {
  onLaunch: (appId: string) => void
  installedApps: PhoneAppDefinition[]
  dockApps?: PhoneAppDefinition[]
}

export function PhoneSpringboard({ onLaunch, dockApps = [] }: Props) {
  const [activePageIndex, setActivePageIndex] = useState(0)
  const [currentTime, setCurrentTime] = useState({
    day: 'Thursday',
    time: '20:16',
    fullDate: 'Thursday, September 10',
  })

  useEffect(() => {
    const updateTime = () => {
      const now = new Date()
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ]
      const h = String(now.getHours()).padStart(2, '0')
      const m = String(now.getMinutes()).padStart(2, '0')
      const day = days[now.getDay()]
      const month = months[now.getMonth()]
      const date = now.getDate()
      setCurrentTime({
        day,
        time: `${h}:${m}`,
        fullDate: `${day}, ${month} ${date}`,
      })
    }
    updateTime()
    const timer = setInterval(updateTime, 1000)
    return () => clearInterval(timer)
  }, [])

  // Page 0 Hero Apps (exact 8 apps from the screenshot)
  const page0AppIds = [
    'calculator', 'banking', 'weather', 'billing',
    'mail', 'crypto', 'notes', 'memos'
  ]
  const page0Apps = page0AppIds
    .map((id) => PHONE_APPS.find((a) => a.id === id))
    .filter(Boolean) as PhoneAppDefinition[]

  // Page 1: System & Lifestyle apps
  const page1AppIds = [
    'photos', 'app-store', 'settings', 'map',
    'music', 'garage', 'house', 'citywarn',
    'feather', 'calendar', 'health', 'darkchat',
    'companies', 'crewlink', 'local-pages', 'weazel-news'
  ]
  const page1Apps = page1AppIds
    .map((id) => PHONE_APPS.find((a) => a.id === id))
    .filter(Boolean) as PhoneAppDefinition[]

  // Page 2: Entertainment & Media
  const page2AppIds = [
    'flare', 'fliptok', 'picstagram', 'radio',
    'skyride', 'citymarkt'
  ]
  const page2Apps = page2AppIds
    .map((id) => PHONE_APPS.find((a) => a.id === id))
    .filter(Boolean) as PhoneAppDefinition[]

  // Page 3: Games
  const page3AppIds = [
    'snake', 'memory', 'number-merge', 'minesweeper',
    'tower-stack', 'sky-flappy', 'neon-drop'
  ]
  const page3Apps = page3AppIds
    .map((id) => PHONE_APPS.find((a) => a.id === id))
    .filter(Boolean) as PhoneAppDefinition[]

  const pages = [page0Apps, page1Apps, page2Apps, page3Apps]
  const currentPage = pages[activePageIndex] ?? pages[0]

  return (
    <div className="phone-springboard">
      <div className="phone-springboard-scroll">
        {/* Page 0: Authentic Sky Phone Widgets */}
        {activePageIndex === 0 && (
          <div className="phone-widgets-container">
            {/* Top Row: Clock & Weather Widgets (2x2 square widgets side-by-side) */}
            <div className="phone-widgets-top-row">
              {/* Clock Widget */}
              <div className="phone-widget-unit" onClick={() => onLaunch('clock')}>
                <div className="phone-widget-card phone-widget-clock-card">
                  <div className="phone-widget-clock-day">{currentTime.day}</div>
                  <div className="phone-widget-clock-time">{currentTime.time}</div>
                  <div className="phone-widget-clock-date">{currentTime.fullDate}</div>
                </div>
                <span className="phone-widget-label">Clock</span>
              </div>

              {/* Weather Widget */}
              <div className="phone-widget-unit" onClick={() => onLaunch('weather')}>
                <div className="phone-widget-card phone-widget-weather-card">
                  <div className="phone-widget-weather-city">Los Santos</div>
                  <div className="phone-widget-weather-temp">24°</div>
                  <div className="phone-widget-weather-desc">
                    <span className="phone-widget-weather-icon">⛅</span>
                    <span>Partly Cloudy</span>
                  </div>
                  <div className="phone-widget-weather-hl">H: 24° L: 13°</div>
                </div>
                <span className="phone-widget-label">Weather</span>
              </div>
            </div>

            {/* Second Row: Music Widget (4x2 wide widget) */}
            <div className="phone-widget-unit phone-widget-music-unit" onClick={() => onLaunch('music')}>
              <div className="phone-widget-card phone-widget-music-card">
                <div className="phone-widget-music-inner">
                  <div className="phone-widget-music-art">
                    <span className="phone-widget-music-icon">🎵</span>
                  </div>
                  <div className="phone-widget-music-info">
                    <div className="phone-widget-music-header">
                      <span className="phone-widget-music-glyph">♫</span>
                    </div>
                    <div className="phone-widget-music-bars">
                      <div className="phone-widget-music-bar-track"></div>
                    </div>
                  </div>
                </div>
                <div className="phone-widget-music-footer">
                  No recently played music
                </div>
              </div>
              <span className="phone-widget-label">Music</span>
            </div>
          </div>
        )}

        {/* Springboard App Grid for current page */}
        <div className={`phone-app-grid ${activePageIndex === 0 ? 'phone-app-grid--hero' : ''}`}>
          {currentPage.map((app) => (
            <button
              type="button"
              key={app.id}
              onClick={() => onLaunch(app.id)}
              className="phone-springboard-icon-btn"
              aria-label={`Open ${app.label}`}
              title={app.label}
            >
              <div className="phone-app-icon-wrapper">
                <img className="phone-app-icon" src={app.icon} alt="" loading="lazy" />
                {app.badge && app.badge > 0 && (
                  <span className="phone-app-badge">{app.badge}</span>
                )}
              </div>
              <span className="phone-app-label">{app.label}</span>
            </button>
          ))}
        </div>

        {/* Pagination Page Dots */}
        <div className="phone-pagination-dots" role="tablist" aria-label="Springboard pages">
          {pages.map((_, idx) => (
            <button
              type="button"
              key={idx}
              className={`phone-page-dot ${idx === activePageIndex ? 'is-active' : ''}`}
              onClick={() => setActivePageIndex(idx)}
              aria-label={`Page ${idx + 1}`}
              aria-selected={idx === activePageIndex}
              role="tab"
            />
          ))}
        </div>
      </div>

      {/* Frosted Glass Springboard Dock */}
      {dockApps.length > 0 && (
        <nav className="phone-dock" aria-label="Phone navigation">
          {dockApps.map((app) => (
            <button
              type="button"
              key={app.id}
              onClick={() => onLaunch(app.id)}
              className="phone-dock-btn"
              aria-label={app.label}
              title={app.label}
            >
              <div className="phone-dock-icon-wrapper">
                <img className="phone-dock-icon" src={app.icon} alt="" loading="lazy" />
              </div>
            </button>
          ))}
        </nav>
      )}
    </div>
  )
}
