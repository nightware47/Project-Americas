import { useCallback, useEffect, useMemo, useState } from 'react'
import type { NervePreviewAdapter } from '../nerve/contracts.ts'
import { MusicService, AppStoreService, type PhoneContact, type PhoneMessage, type PhoneSettings, type PhoneState, type PreviewPhoneService } from '../nerve/preview.ts'
import { BankingApp } from './apps/BankingApp.tsx'
import { CalculatorApp } from './apps/CalculatorApp.tsx'
import { CameraApp } from './apps/CameraApp.tsx'
import { ClockApp } from './apps/ClockApp.tsx'
import { MailApp } from './apps/MailApp.tsx'
import { MapApp } from './apps/MapApp.tsx'
import { AppStoreApp } from './apps/AppStoreApp.tsx'
import { CryptoApp } from './apps/CryptoApp.tsx'
import { HouseApp } from './apps/HouseApp.tsx'
import { BillingApp } from './apps/BillingApp.tsx'
import { CityWarnApp } from './apps/CityWarnApp.tsx'
import { DarkChatApp } from './apps/DarkChatApp.tsx'
import { CompaniesApp } from './apps/CompaniesApp.tsx'
import { CrewLinkApp } from './apps/CrewLinkApp.tsx'
import { HealthApp } from './apps/HealthApp.tsx'
import { LocalPagesApp } from './apps/LocalPagesApp.tsx'
import { WeazelNewsApp } from './apps/WeazelNewsApp.tsx'
import { FlareApp } from './apps/FlareApp.tsx'
import { FlipTokApp } from './apps/FlipTokApp.tsx'
import { PicstagramApp } from './apps/PicstagramApp.tsx'
import { RadioApp } from './apps/RadioApp.tsx'
import { CalendarApp } from './apps/CalendarApp.tsx'
import { MemosApp } from './apps/MemosApp.tsx'
import { SkyRideApp } from './apps/SkyRideApp.tsx'
import { CityMarktApp } from './apps/CityMarktApp.tsx'
import { SnakeApp } from './apps/SnakeApp.tsx'
import { MemoryApp } from './apps/MemoryApp.tsx'
import { NumberMergeApp } from './apps/NumberMergeApp.tsx'
import { MinesweeperApp } from './apps/MinesweeperApp.tsx'
import { TowerStackApp } from './apps/TowerStackApp.tsx'
import { SkyFlappyApp } from './apps/SkyFlappyApp.tsx'
import { NeonDropApp } from './apps/NeonDropApp.tsx'
import { FeatherApp } from './apps/FeatherApp.tsx'
import { GarageApp } from './apps/GarageApp.tsx'
import { MusicApp } from './apps/MusicApp.tsx'
import { NotesApp } from './apps/NotesApp.tsx'
import { PhotosApp } from './apps/PhotosApp.tsx'
import { WeatherApp } from './apps/WeatherApp.tsx'
import { DOCK_PHONE_APPS, PHONE_APPS } from './phone-apps.ts'
import { PhoneControlCenter } from './PhoneControlCenter.tsx'
import { PhoneDynamicIsland } from './PhoneDynamicIsland.tsx'
import { PhoneHomeIndicator } from './PhoneHomeIndicator.tsx'
import { PhoneLockScreen, type PhoneNotificationItem } from './PhoneLockScreen.tsx'
import { PhoneSpringboard } from './PhoneSpringboard.tsx'
import { PhoneStatusBar } from './PhoneStatusBar.tsx'
import './phone.css'

type PhoneApp = 'home' | string

const emptyState: PhoneState = {
  phoneNumber: '',
  battery: 87,
  contacts: [],
  conversations: [],
  settings: {
    airplaneMode: false,
    wifiEnabled: true,
    bluetoothEnabled: true,
    darkMode: true,
    ringtone: 'Aurora',
  },
}

const defaultNotifications: PhoneNotificationItem[] = [
  {
    id: 'notif-1',
    app: 'messages',
    title: 'Alex Mercer',
    body: 'I left the car at the central garage. Meet you there?',
    time: '12:18',
  },
  {
    id: 'notif-2',
    app: 'citywarn',
    title: 'Sun City Emergency Alert',
    body: 'High surf advisory in effect along Del Perro coastline.',
    time: '11:45',
  },
]

type Props = {
  nerve: NervePreviewAdapter
  onClose?: () => void
  onActiveAppChange?: (appId: string) => void
}

export function PhoneScreen({ nerve, onClose, onActiveAppChange }: Props) {
  const phone = nerve.GetService<PreviewPhoneService>('PhoneService')
  const [state, setState] = useState<PhoneState>(emptyState)
  const [activeApp, setActiveApp] = useState<PhoneApp>('home')
  const [activeContactId, setActiveContactId] = useState('alex')
  const [thread, setThread] = useState<PhoneMessage[]>([])
  const [draft, setDraft] = useState('')
  const [dialNumber, setDialNumber] = useState('')
  const [call, setCall] = useState<{ status: string; number: string } | null>(null)
  const [notice, setNotice] = useState('')

  // OS-level state
  const [locked, setLocked] = useState(false)
  const [controlCenterOpen, setControlCenterOpen] = useState(false)
  const [brightness, setBrightness] = useState(85)
  const [volume, setVolume] = useState(70)
  const [flashlightActive, setFlashlightActive] = useState(false)
  const [musicPlaying, setMusicPlaying] = useState(false)
  const [currentTrack, setCurrentTrack] = useState({ title: 'Midnight City', artist: 'M83' })
  const [notifications, setNotifications] = useState<PhoneNotificationItem[]>(defaultNotifications)

  const [installedAppIds, setInstalledAppIds] = useState<string[]>(() =>
    PHONE_APPS.filter((a) => a.installed).map((a) => a.id)
  )

  useEffect(() => {
    void AppStoreService.GetInstalledApps.request(undefined).then(([ids]: [string[] | undefined]) => {
      if (ids) setInstalledAppIds(ids)
    })
    const unsub = AppStoreService.InstalledAppsChanged.connect((next: string[]) => {
      setInstalledAppIds(next)
    })
    return () => {
      unsub()
    }
  }, [])

  const dynamicInstalledApps = useMemo(() => {
    const set = new Set(installedAppIds)
    return PHONE_APPS.filter((app) => set.has(app.id))
  }, [installedAppIds])


  
  useEffect(() => {
    const unsub = MusicService.PlaybackChanged.connect((playback) => {
      setMusicPlaying(playback.isPlaying)
      if (playback.track) {
        setCurrentTrack({ title: playback.track.title, artist: playback.track.artist })
      }
    })
    return () => unsub()
  }, [])

  const toggleMusicPlayback = async () => {
    const [ok, state] = await MusicService.TogglePlayback.request(undefined)
    if (ok && state) {
      setMusicPlaying(state.isPlaying)
      if (state.track) {
        setCurrentTrack({ title: state.track.title, artist: state.track.artist })
      }
    } else {
      setMusicPlaying((prev) => !prev)
    }
  }

  const activeContact = useMemo(
    () => state.contacts.find((contact) => contact.id === activeContactId) ?? state.contacts[0],
    [activeContactId, state.contacts],
  )

  const refreshState = useCallback(() => {
    void phone.GetPhoneState.request(undefined)
      .then(([next]) => setState(next))
      .catch(() => setNotice('Unable to load phone data.'))
  }, [phone])

  useEffect(() => {
    refreshState()
    const messageConnection = phone.MessageReceived.connect((number) => {
      if (activeContact?.number === number) {
        void phone.GetMessages.request(number).then(([next]) => setThread(next))
      }
      refreshState()
    })
    const callConnection = phone.CallStateChanged.connect((status, number) => {
      setCall(status === 'ended' ? null : { status, number })
    })
    const settingsConnection = phone.PhoneSettingsChanged.connect((settings) => {
      setState((current) => ({ ...current, settings }))
    })
    return () => {
      messageConnection()
      callConnection()
      settingsConnection()
    }
  }, [activeContact?.number, phone, refreshState])

  useEffect(() => {
    if (!activeContact) return
    void phone.GetMessages.request(activeContact.number).then(([next]) => setThread(next))
  }, [activeContact, phone])

  const launch = (app: PhoneApp) => {
    setNotice('')
    setActiveApp(app)
    onActiveAppChange?.(app)
  }

  const selectContact = (contact: PhoneContact) => {
    setActiveContactId(contact.id)
    launch('messages')
  }

  const sendMessage = () => {
    if (!activeContact || !draft.trim()) return
    void phone.SendMessage.request({ number: activeContact.number, body: draft }).then(([success, error]) => {
      if (!success) {
        setNotice(error ?? 'Message failed.')
        return
      }
      setDraft('')
      void phone.GetMessages.request(activeContact.number).then(([next]) => setThread(next))
    })
  }

  const startCall = (number = dialNumber || activeContact?.number) => {
    if (!number) return
    void phone.StartCall.request(number).then(([success, error]) => {
      if (!success) setNotice(error ?? 'Call failed.')
    })
  }

  const endCall = () => {
    void phone.EndCall.request(undefined).then(([success, error]) => {
      if (!success) setNotice(error ?? 'No active call.')
    })
  }

  const updateSetting = (key: keyof PhoneSettings, value: boolean | string) => {
    const settings = { ...state.settings, [key]: value }
    setState((current) => ({ ...current, settings }))
    void phone.SavePhoneSettings.request(settings).then(([success, error]) => {
      if (!success) setNotice(error ?? 'Settings failed to save.')
    })
  }

  const toggleSettingBoolean = (key: 'airplaneMode' | 'wifiEnabled' | 'bluetoothEnabled' | 'darkMode') => {
    updateSetting(key, !state.settings[key])
  }

  const appLabel = PHONE_APPS.find((app) => app.id === activeApp)?.label ?? activeApp

  // Handle Home Indicator action: return to springboard from apps, or close phone when on springboard
  const handleHomeIndicatorAction = useCallback(() => {
    if (activeApp !== 'home') {
      launch('home')
    } else if (onClose) {
      onClose()
    }
  }, [activeApp, launch, onClose])

  return (
    <div className="phone-device" data-roblox-name="PhoneDevice" data-roblox-class="ScreenGui">


      {/* Frame overlay */}
      <img
        className="phone-device__frame"
        src={`${import.meta.env.BASE_URL}assets/phone/frames/black.webp`}
        alt=""
        aria-hidden="true"
        draggable={false}
      />

      {/* Hardware Buttons */}
      <button
        type="button"
        className="phone-hardware-button phone-hardware-button--action"
        aria-label="Action"
        title="Action / Mute"
      />
      <button
        type="button"
        className="phone-hardware-button phone-hardware-button--volume-up"
        aria-label="Volume Up"
        title="Volume Up"
        onClick={() => setVolume((v) => Math.min(100, v + 10))}
      />
      <button
        type="button"
        className="phone-hardware-button phone-hardware-button--volume-down"
        aria-label="Volume Down"
        title="Volume Down"
        onClick={() => setVolume((v) => Math.max(0, v - 10))}
      />
      <button
        type="button"
        className="phone-hardware-button phone-hardware-button--power"
        aria-label="Power"
        title="Power / Lock (or Close)"
        onClick={() => {
          if (onClose && locked) {
            onClose();
          } else {
            setLocked(!locked);
          }
        }}
      />

      {/* Main Screen Viewport (Clipped display panel) */}
      <div className={`phone-screen ${state.settings.darkMode ? 'phone-screen--dark' : 'phone-screen--light'}`}>
        {/* Official Restored Wallpaper */}
        <div className="phone-screen-wallpaper" />

        {/* Dynamic Island sits at top center of display */}
        <PhoneDynamicIsland
          activeCall={call}
          onEndCall={endCall}
          musicPlaying={musicPlaying}
          currentTrack={currentTrack}
          onToggleMusic={toggleMusicPlayback}
          flashlightActive={flashlightActive}
          onToggleFlashlight={() => setFlashlightActive(!flashlightActive)}
        />

        {/* OS Status Bar with Time and Indicators */}
        <PhoneStatusBar
          carrier={state.settings.airplaneMode ? 'AIRPLANE MODE' : 'SUN CITY'}
          battery={state.battery || 87}
          airplaneMode={state.settings.airplaneMode}
          wifiEnabled={state.settings.wifiEnabled}
          onOpenControlCenter={() => setControlCenterOpen(true)}
          onLockPhone={() => setLocked(true)}
        />

        {/* Screen Content: Home Springboard or Active App View */}
        {activeApp === 'home' ? (
          <PhoneSpringboard
            onLaunch={launch}
            installedApps={dynamicInstalledApps}
            dockApps={DOCK_PHONE_APPS}
          />
        ) : (
          <div className="phone-app-container">
            <div className="phone-appbar">
              <button type="button" onClick={() => launch('home')} aria-label="Home">
                Home
              </button>
              <strong>{appLabel}</strong>
              <span>{state.settings.wifiEnabled ? 'ONLINE' : 'OFFLINE'}</span>
            </div>
            {activeApp === 'messages' && (
              <Messages
                state={state}
                activeContact={activeContact}
                messages={thread}
                draft={draft}
                setDraft={setDraft}
                onSelect={(contact) => {
                  setActiveContactId(contact.id)
                  void phone.GetMessages.request(contact.number).then(([next]) => setThread(next))
                }}
                onSend={sendMessage}
                onCall={() => startCall(activeContact?.number)}
              />
            )}
            {activeApp === 'contacts' && (
              <Contacts
                contacts={state.contacts}
                onSelect={selectContact}
                onCall={startCall}
              />
            )}
            {activeApp === 'phone' && (
              <Dialer
                value={dialNumber}
                setValue={setDialNumber}
                onCall={() => startCall()}
                call={call}
                onEnd={endCall}
              />
            )}
            {activeApp === 'settings' && (
              <PhoneSettings
                settings={state.settings}
                onChange={updateSetting}
              />
            )}
            {activeApp === 'banking' && (
              <BankingApp nerve={nerve} contacts={state.contacts} />
            )}
            {activeApp === 'camera' && (
              <CameraApp
                nerve={nerve}
                onOpenPhotos={() => launch('photos')}
              />
            )}
            {activeApp === 'photos' && (
              <PhotosApp
                nerve={nerve}
                contacts={state.contacts}
              />
            )}
            {activeApp === 'calculator' && <CalculatorApp />}
            {activeApp === 'clock' && <ClockApp />}
            {activeApp === 'weather' && <WeatherApp />}
            {activeApp === 'notes' && <NotesApp />}
            {activeApp === 'mail' && <MailApp />}
            {activeApp === 'map' && <MapApp />}
            {activeApp === 'music' && <MusicApp />}
            {activeApp === 'garage' && <GarageApp />}
            {activeApp === 'feather' && <FeatherApp />}
            {activeApp === 'app-store' && <AppStoreApp onLaunchApp={launch} />}
            {activeApp === 'crypto' && <CryptoApp />}
            {activeApp === 'house' && <HouseApp onOpenMap={() => launch('map')} />}
            {activeApp === 'billing' && <BillingApp />}
            {activeApp === 'citywarn' && <CityWarnApp onOpenMap={() => launch('map')} />}
            {activeApp === 'darkchat' && <DarkChatApp />}
            {activeApp === 'companies' && <CompaniesApp onOpenMap={() => launch('map')} onCall={() => launch('phone')} />}
            {activeApp === 'crewlink' && <CrewLinkApp onOpenMap={() => launch('map')} />}
            {activeApp === 'health' && <HealthApp />}
            {activeApp === 'local-pages' && <LocalPagesApp onOpenMap={() => launch('map')} onCall={() => launch('phone')} />}
            {activeApp === 'weazel-news' && <WeazelNewsApp />}
            {activeApp === 'flare' && <FlareApp />}
            {activeApp === 'fliptok' && <FlipTokApp />}
            {activeApp === 'picstagram' && <PicstagramApp />}
            {activeApp === 'radio' && <RadioApp />}
            {activeApp === 'calendar' && <CalendarApp />}
            {activeApp === 'memos' && <MemosApp />}
            {activeApp === 'skyride' && <SkyRideApp />}
            {activeApp === 'citymarkt' && <CityMarktApp />}
            {activeApp === 'snake' && <SnakeApp />}
            {activeApp === 'memory' && <MemoryApp />}
            {activeApp === 'number-merge' && <NumberMergeApp />}
            {activeApp === 'minesweeper' && <MinesweeperApp />}
            {activeApp === 'tower-stack' && <TowerStackApp />}
            {activeApp === 'sky-flappy' && <SkyFlappyApp />}
            {activeApp === 'neon-drop' && <NeonDropApp />}
            {activeApp !== 'messages' &&
              activeApp !== 'contacts' &&
              activeApp !== 'phone' &&
              activeApp !== 'settings' &&
              activeApp !== 'banking' &&
              activeApp !== 'camera' &&
              activeApp !== 'photos' &&
              activeApp !== 'calculator' &&
              activeApp !== 'clock' &&
              activeApp !== 'weather' &&
              activeApp !== 'mail' &&
              activeApp !== 'map' &&
              activeApp !== 'music' &&
              activeApp !== 'garage' &&
              activeApp !== 'feather' &&
              activeApp !== 'app-store' &&
              activeApp !== 'crypto' &&
              activeApp !== 'house' &&
              activeApp !== 'billing' &&
              activeApp !== 'citywarn' &&
              activeApp !== 'darkchat' &&
              activeApp !== 'companies' &&
              activeApp !== 'crewlink' &&
              activeApp !== 'health' &&
              activeApp !== 'local-pages' &&
              activeApp !== 'weazel-news' &&
              activeApp !== 'flare' &&
              activeApp !== 'fliptok' &&
              activeApp !== 'picstagram' &&
              activeApp !== 'radio' &&
              activeApp !== 'calendar' &&
              activeApp !== 'memos' &&
              activeApp !== 'skyride' &&
              activeApp !== 'citymarkt' &&
              activeApp !== 'snake' &&
              activeApp !== 'memory' &&
              activeApp !== 'number-merge' &&
              activeApp !== 'minesweeper' &&
              activeApp !== 'tower-stack' &&
              activeApp !== 'sky-flappy' &&
              activeApp !== 'neon-drop' &&
              activeApp !== 'notes' && <CatalogApp app={activeApp} />}
          </div>
        )}

        {notice && (
          <button className="phone-notice" type="button" onClick={() => setNotice('')}>
            {notice}
          </button>
        )}

        {/* Control Center Overlay */}
        <PhoneControlCenter
          open={controlCenterOpen}
          onClose={() => setControlCenterOpen(false)}
          airplaneMode={state.settings.airplaneMode}
          wifiEnabled={state.settings.wifiEnabled}
          bluetoothEnabled={state.settings.bluetoothEnabled}
          darkMode={state.settings.darkMode}
          onToggleSetting={toggleSettingBoolean}
          brightness={brightness}
          onChangeBrightness={setBrightness}
          volume={volume}
          onChangeVolume={setVolume}
          flashlightActive={flashlightActive}
          onToggleFlashlight={() => setFlashlightActive(!flashlightActive)}
          musicPlaying={musicPlaying}
          currentTrack={currentTrack}
          onToggleMusic={toggleMusicPlayback}
          onLaunchApp={launch}
        />

        {/* Lock Screen Overlay */}
        <PhoneLockScreen
          locked={locked}
          onUnlock={() => setLocked(false)}
          notifications={notifications}
          onDismissNotification={(id) => setNotifications((list) => list.filter((n) => n.id !== id))}
          onClearNotifications={() => setNotifications([])}
          flashlightActive={flashlightActive}
          onToggleFlashlight={() => setFlashlightActive(!flashlightActive)}
          onLaunchCamera={() => {
            setLocked(false)
            launch('camera')
          }}
        />

        {/* Home Indicator (Swipe/click bar at bottom) */}
        <PhoneHomeIndicator
          onHome={handleHomeIndicatorAction}
          isHome={activeApp === 'home'}
          interactive={true}
        />
      </div>
    </div>
  )
}

function Messages({
  state,
  activeContact,
  messages,
  draft,
  setDraft,
  onSelect,
  onSend,
  onCall,
}: {
  state: PhoneState
  activeContact?: PhoneContact
  messages: PhoneMessage[]
  draft: string
  setDraft: (value: string) => void
  onSelect: (contact: PhoneContact) => void
  onSend: () => void
  onCall: () => void
}) {
  return (
    <div className="phone-messages">
      <aside className="phone-conversations city-message-list">
        {state.conversations.map((conversation) => {
          const contact = state.contacts.find((entry) => entry.id === conversation.contactId)
          if (!contact) return null
          return (
            <button
              type="button"
              key={contact.id}
              className={activeContact?.id === contact.id ? 'is-active' : ''}
              onClick={() => onSelect(contact)}
            >
              <i>{contact.name[0]}</i>
              <span>
                <strong>{contact.name}</strong>
                <small>{conversation.lastMessage}</small>
              </span>
              <time>{conversation.time}</time>
              {conversation.unread > 0 && <b>{conversation.unread}</b>}
            </button>
          )
        })}
      </aside>
      <section className="phone-thread city-conversation">
        <header>
          <div>
            <h2>{activeContact?.name ?? 'Select a contact'}</h2>
            <small>{activeContact?.number}</small>
          </div>
          <button type="button" onClick={onCall} disabled={!activeContact}>
            CALL
          </button>
        </header>
        <div className="phone-bubbles">
          {messages.map((message) => (
            <p key={message.id} className={message.fromPlayer ? 'from-player' : ''}>
              {message.body}
              <time>{message.time}</time>
            </p>
          ))}
        </div>
        <form
          onSubmit={(event) => {
            event.preventDefault()
            onSend()
          }}
        >
          <input
            value={draft}
            onChange={(event) => setDraft(event.target.value)}
            placeholder="Message"
            aria-label="Message"
          />
          <button type="submit" disabled={!draft.trim() || !activeContact}>
            SEND
          </button>
        </form>
      </section>
    </div>
  )
}

function Contacts({
  contacts,
  onSelect,
  onCall,
}: {
  contacts: PhoneContact[]
  onSelect: (contact: PhoneContact) => void
  onCall: (number: string) => void
}) {
  return (
    <div className="phone-list-view">
      <p className="phone-kicker">CONTACTS</p>
      {contacts.map((contact) => (
        <article className="phone-contact-row" key={contact.id}>
          <i>{contact.name.split(' ').map((part) => part[0]).join('')}</i>
          <div>
            <strong>{contact.name}</strong>
            <small>{contact.number}</small>
          </div>
          <button type="button" onClick={() => onCall(contact.number)}>
            CALL
          </button>
          <button type="button" onClick={() => onSelect(contact)}>
            MESSAGE
          </button>
        </article>
      ))}
    </div>
  )
}

function Dialer({
  value,
  setValue,
  onCall,
  call,
  onEnd,
}: {
  value: string
  setValue: (value: string) => void
  onCall: () => void
  call: { status: string; number: string } | null
  onEnd: () => void
}) {
  const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
  return (
    <div className="phone-dialer">
      {call ? (
        <div className="phone-call-active">
          <i>CALL</i>
          <strong>{call.number}</strong>
          <small>{call.status.toUpperCase()}</small>
          <button type="button" onClick={onEnd}>
            END CALL
          </button>
        </div>
      ) : (
        <>
          <output>{value || 'Enter number'}</output>
          <div className="phone-keypad">
            {keys.map((key) => (
              <button type="button" key={key} onClick={() => setValue(value + key)}>
                {key}
              </button>
            ))}
          </div>
          <div className="phone-dial-actions">
            <button type="button" onClick={() => setValue(value.slice(0, -1))}>
              DELETE
            </button>
            <button type="button" className="phone-call-button" onClick={onCall}>
              CALL
            </button>
            <button type="button" onClick={() => setValue('')}>
              CLEAR
            </button>
          </div>
        </>
      )}
    </div>
  )
}

function PhoneSettings({
  settings,
  onChange,
}: {
  settings: PhoneSettings
  onChange: (key: keyof PhoneSettings, value: boolean | string) => void
}) {
  const rows: Array<[keyof PhoneSettings, string]> = [
    ['airplaneMode', 'Airplane mode'],
    ['wifiEnabled', 'Wi-Fi'],
    ['bluetoothEnabled', 'Bluetooth'],
    ['darkMode', 'Dark appearance'],
  ]
  return (
    <div className="phone-list-view">
      <p className="phone-kicker">PHONE SETTINGS</p>
      {rows.map(([key, label]) => (
        <label className="phone-setting-row" key={key}>
          <span>
            {label}
            <small>Saved by Roblox PhoneService</small>
          </span>
          <input
            type="checkbox"
            aria-label={label}
            checked={settings[key] as boolean}
            onChange={(event) => onChange(key, event.target.checked)}
          />
        </label>
      ))}
      <label className="phone-setting-row">
        <span>
          Ringtone<small>Incoming call sound</small>
        </span>
        <select value={settings.ringtone} onChange={(event) => onChange('ringtone', event.target.value)}>
          <option>Aurora</option>
          <option>Pulse</option>
          <option>Classic</option>
        </select>
      </label>
    </div>
  )
}

function CatalogApp({ app }: { app: string }) {
  const definition = PHONE_APPS.find((entry) => entry.id === app)
  return (
    <div className="phone-simple-app">
      <img src={definition?.icon} alt="" />
      <h2>{definition?.label ?? app}</h2>
      <p>{definition?.category.toUpperCase()} APP</p>
      <button type="button">OPEN {definition?.label ?? app}</button>
    </div>
  )
}
