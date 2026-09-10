import React, { useState, useEffect, useMemo, useRef, useCallback, Fragment } from "react";
import {
  BellRing, Bluetooth, Camera, Check, EyeOff, KeyRound, Images,
  Monitor, PanelsTopLeft, Moon, Plane, RotateCcw, Settings as SettingsIcon,
  ShieldCheck, Signal, Smartphone, Sun, Upload, UserRound, Volume1,
  Volume2, Wifi
} from "lucide-react";
import { nerve } from "@nerve/core";
import "./SettingsApp.css";

// Provide mock/stub imports for UI elements
const SkyAppPage: any = "div";
const SkyBlock: any = "div";
const SkyButton: any = "button";
const SkyDialog: any = "div";
const SkyDialogButton: any = "button";
const SkyField: any = "input";
const SkyLink: any = "a";
const SkyNavbar: any = "nav";
const SkyScrollArea: any = "div";
const SkySearchbar: any = "input";
const SkySegmented: any = "div";
const SkySegmentedButton: any = "button";
const SkySettingsGroup: any = "div";
const SkySettingsIcon: any = "div";
const SkySettingsRangeRow: any = "div";
const SkySettingsRow: any = "div";
const SkySpinner: any = "div";
const SkyNotification: any = "div";
const PhonePasscode: any = "div";

type SettingsView =
  | "root"
  | "account"
  | "security"
  | "notifications"
  | "notification-detail"
  | "sounds"
  | "connectivity"
  | "focus"
  | "general"
  | "appearance"
  | "wallpaper"
  | "reset";

export const SettingsApp: React.FC = () => {
  const isDevelopment = process.env.NODE_ENV === "development";

  // Mock Nerve bindings to replace FiveM specific logic
  const phoneStore = nerve.GetService<any>("PhoneStore");
  const accountStore = nerve.GetService<any>("AccountStore");
  const mediaPickerStore = nerve.GetService<any>("MediaPickerStore");

  const [activeView, setActiveView] = useState<SettingsView>("root");
  const [query, setQuery] = useState("");
  const [selectedNotificationAppId, setSelectedNotificationAppId] = useState("calculator");
  const [framePickerOpened, setFramePickerOpened] = useState(false);

  // Account State
  const [accountMode, setAccountMode] = useState<"login" | "register">("login");
  const [accountEmail, setAccountEmail] = useState("");
  const [accountPassword, setAccountPassword] = useState("");
  const [accountConfirm, setAccountConfirm] = useState("");
  const [accountSubmitting, setAccountSubmitting] = useState(false);
  const [accountToast, setAccountToast] = useState("");

  const [accountEmailData, setAccountEmailData] = useState<string | null>(null);
  const [accountDevices, setAccountDevices] = useState<any[]>([]);

  // Passcode State
  const [passcodeBusy, setPasscodeBusy] = useState(false);
  const [passcodeCurrent, setPasscodeCurrent] = useState("");
  const [passcodeError, setPasscodeError] = useState("");
  const [passcodeFirst, setPasscodeFirst] = useState("");
  const [passcodeFlow, setPasscodeFlow] = useState<string | null>(null);
  const [passcodeLength, setPasscodeLength] = useState<4 | 6>(6);
  const [passcodeResetKey, setPasscodeResetKey] = useState(0);

  // Dialog States
  const [removeDeviceImei, setRemoveDeviceImei] = useState("");
  const [removeDevicePassword, setRemoveDevicePassword] = useState("");
  const [removeDeviceOpened, setRemoveDeviceOpened] = useState(false);
  const [resetOpened, setResetOpened] = useState(false);
  const [simEjectOpened, setSimEjectOpened] = useState(false);

  // Factory Reset
  const [factoryResetting, setFactoryResetting] = useState(false);
  const [factoryResetProgress, setFactoryResetProgress] = useState(0);

  // Wallpaper
  const [wallpaperTarget, setWallpaperTarget] = useState<"home" | "lock">("home");
  const [customWallpaperUploadAvailable, setCustomWallpaperUploadAvailable] = useState(false);

  // Store mocks
  const [preferences, setPreferences] = useState<any>({
    frame: "default",
    airplaneMode: false,
    streamerMode: false,
    wifiEnabled: true,
    bluetoothEnabled: true,
    cellularEnabled: true,
    focusMode: false,
    ringtoneVolume: 50,
    notificationVolume: 50,
    notificationDurationSeconds: 5,
    screenBrightness: 80,
    phoneScale: 100,
    graphicsMode: "high",
    appearanceMode: "light",
    wallpaperHistory: []
  });

  const [securityEnabled, setSecurityEnabled] = useState(false);
  const [deviceData, setDeviceData] = useState({
    imei: "123456789", sim: { removable: true, number: "555-0100", type: "registered" }
  });

  const PHONE_FRAME_COLORS: Record<string, string> = { default: "#111", silver: "#ccc" };
  const PHONE_FRAME_IDS = ["default", "silver"];
  const APPEARANCE_MODE_IDS = ["light", "dark", "auto"];
  const GRAPHICS_MODE_IDS = ["high", "low"];
  const PHONE_SCALE_MIN = 80;
  const PHONE_SCALE_MAX = 120;
  const PHONE_SCALE_STEP = 5;
  const RINGTONE_IDS = ["classic", "modern"];
  const NOTIFICATION_SOUND_IDS = ["chime", "beep"];
  const WALLPAPER_IDS = ["abstract", "nature", "city"];

  const notificationApps = [
    { id: "calculator", label: "Calculator", iconImage: "" },
    { id: "mail", label: "Mail", iconImage: "" },
  ];

  const goBack = () => {
    setFramePickerOpened(false);
    setActiveView(activeView === "notification-detail" ? "notifications" : "root");
  };

  const openView = (view: SettingsView) => {
    setActiveView(view);
  };

  const setRootSetting = (key: string, value: boolean) => {
    setPreferences((prev: any) => ({ ...prev, [key]: value }));
  };

  const updateNumberPreference = (key: string, value: number) => {
    setPreferences((prev: any) => ({ ...prev, [key]: value }));
  };

  const toggleRows = [
    { key: "airplaneMode", icon: Plane, iconColor: "#ff9500" },
    { key: "streamerMode", icon: EyeOff, iconColor: "#af52de" },
  ];
  const serviceRows = [
    { key: "notifications", view: "notifications" as SettingsView, icon: BellRing, iconColor: "#ff3b30" },
    { key: "sounds", view: "sounds" as SettingsView, icon: Volume2, iconColor: "#ff2d55" },
  ];
  const preferenceRows = [
    { key: "connectivity", view: "connectivity" as SettingsView, icon: Wifi, iconColor: "#007aff" },
    { key: "focus", view: "focus" as SettingsView, icon: Moon, iconColor: "#5856d6" },
    { key: "security", view: "security" as SettingsView, icon: KeyRound, iconColor: "#34c759" },
    { key: "general", view: "general" as SettingsView, icon: SettingsIcon, iconColor: "#8e8e93" },
    { key: "appearance", view: "appearance" as SettingsView, icon: Sun, iconColor: "#007aff" },
    { key: "wallpaper", view: "wallpaper" as SettingsView, icon: Monitor, iconColor: "#32ade6" },
  ];

  const connectivityRows = [
    { key: "wifi", preferenceKey: "wifiEnabled", icon: Wifi, iconColor: "#007aff" },
    { key: "bluetooth", preferenceKey: "bluetoothEnabled", icon: Bluetooth, iconColor: "#007aff" },
    { key: "cellular", preferenceKey: "cellularEnabled", icon: Signal, iconColor: "#34c759" },
  ];

  const matchesSearch = (key: string) => !query || key.toLowerCase().includes(query.toLowerCase());
  const visibleToggleRows = toggleRows.filter((r) => matchesSearch(r.key));
  const visibleServiceRows = serviceRows.filter((r) => matchesSearch(r.key));
  const visiblePreferenceRows = preferenceRows.filter((r) => matchesSearch(r.key));

  const t = (key: string) => key.split(".").pop();

  const handleAccountSubmit = () => {
    setAccountSubmitting(true);
    setTimeout(() => {
      setAccountSubmitting(false);
      if (accountMode === "login") {
        setAccountEmailData(accountEmail);
        setAccountDevices([{ current: true, device_name: "Local Phone", imei: "123456789" }]);
      } else {
        setAccountToast("Account registered");
      }
    }, 500);
  };

  const logoutAccount = () => {
    setAccountEmailData(null);
    setAccountDevices([]);
  };

  return (
    <SkyAppPage className="settings-app" accent="#0a84ff" accentSoft="rgba(10, 132, 255, 0.16)" label="Settings">
      <SkyNavbar className="settings-navbar" title={activeView === "root" ? "Settings" : t(activeView)} variant={activeView === "root" ? "large" : "compact"} showBack={activeView !== "root"} backAppearance="surface" backLabel="Back" onBack={goBack}>
        {activeView === "account" && !accountEmailData && (
          <SkyLink onClick={() => setAccountMode(accountMode === "login" ? "register" : "login")}>
            {accountMode === "login" ? "Register" : "Login"}
          </SkyLink>
        )}
      </SkyNavbar>

      <SkyScrollArea padded className={`settings-content ${activeView !== "root" ? "settings-content--subpage" : ""}`}>
        {activeView === "root" && (
          <Fragment>
            <div className="settings-search" role="search">
              <SkySearchbar value={query} onChange={(e: any) => setQuery(e.target?.value || e)} clearLabel="Clear" label="Search" placeholder="Search" />
            </div>

            <SkySettingsGroup ariaLabel="Account">
              <SkySettingsRow kind="navigation" title="Account" description="Manage Cloud Account" onActivate={() => openView("account")}>
                <SkySettingsIcon color="#8e8e93"><UserRoundIcon aria-hidden="true" /></SkySettingsIcon>
              </SkySettingsRow>
            </SkySettingsGroup>

            {visibleToggleRows.length > 0 && (
              <SkySettingsGroup ariaLabel="Preferences">
                {visibleToggleRows.map((row) => (
                  <SkySettingsRow key={row.key} kind="toggle" modelValue={preferences[row.key]} title={t(row.key)} onUpdateModelValue={(e: boolean) => setRootSetting(row.key, e)}>
                    <SkySettingsIcon color={row.iconColor}><row.icon aria-hidden="true" /></SkySettingsIcon>
                  </SkySettingsRow>
                ))}
              </SkySettingsGroup>
            )}

            {visibleServiceRows.length > 0 && (
              <SkySettingsGroup ariaLabel="Services">
                {visibleServiceRows.map((row) => (
                  <SkySettingsRow key={row.key} kind="navigation" title={t(row.key)} onActivate={() => openView(row.view)}>
                    <SkySettingsIcon color={row.iconColor}><row.icon aria-hidden="true" /></SkySettingsIcon>
                  </SkySettingsRow>
                ))}
              </SkySettingsGroup>
            )}

            {visiblePreferenceRows.length > 0 && (
              <SkySettingsGroup ariaLabel="Options">
                {visiblePreferenceRows.map((row) => (
                  <SkySettingsRow key={row.key} kind="navigation" title={t(row.key)} onActivate={() => openView(row.view)} value={(row.key === "security" && securityEnabled) || (row.key === "focus" && preferences.focusMode) ? "On" : undefined}>
                    <SkySettingsIcon color={row.iconColor}><row.icon aria-hidden="true" /></SkySettingsIcon>
                  </SkySettingsRow>
                ))}
              </SkySettingsGroup>
            )}
          </Fragment>
        )}

        {activeView === "account" && (
          <Fragment>
            {!accountEmailData ? (
              <Fragment>
                <SkyBlock className="settings-copy">{accountMode === "login" ? "Sign in to access iCloud." : "Create an account."}</SkyBlock>
                <SkySettingsGroup>
                  <SkyField value={accountEmail} onChange={(e: any) => setAccountEmail(e.target?.value || e)} label={accountMode === "login" ? "Email" : "Local Part"} />
                  <SkyField type="password" value={accountPassword} onChange={(e: any) => setAccountPassword(e.target?.value || e)} label="Password" />
                  {accountMode === "register" && (
                    <SkyField type="password" value={accountConfirm} onChange={(e: any) => setAccountConfirm(e.target?.value || e)} label="Confirm Password" />
                  )}
                </SkySettingsGroup>
                <div className="settings-primary-action">
                  <SkyButton block large disabled={accountSubmitting} onClick={handleAccountSubmit}>
                    {accountSubmitting ? <SkySpinner size={18} /> : (accountMode === "login" ? "Login" : "Register")}
                  </SkyButton>
                </div>
              </Fragment>
            ) : (
              <Fragment>
                <SkySettingsGroup>
                  <SkySettingsRow title={accountEmailData} description="Cloud Account">
                    <SkySettingsIcon color="#0a84ff"><UserRoundIcon aria-hidden="true" /></SkySettingsIcon>
                  </SkySettingsRow>
                </SkySettingsGroup>
                <SkySettingsGroup title="Linked Devices">
                  {accountDevices.map((device) => (
                    <Fragment key={device.imei}>
                      <SkySettingsRow title={device.device_name} description={device.imei} value={device.current ? "This Device" : undefined}>
                        <Smartphone size={20} aria-hidden="true" />
                      </SkySettingsRow>
                      {!device.current && (
                        <SkySettingsRow kind="action" tone="danger" title="Remove Device" onActivate={() => {
                          setRemoveDeviceImei(device.imei);
                          setRemoveDeviceOpened(true);
                        }} />
                      )}
                    </Fragment>
                  ))}
                </SkySettingsGroup>
                <SkySettingsGroup>
                  <SkySettingsRow kind="action" tone="danger" title="Sign Out" onActivate={logoutAccount} />
                </SkySettingsGroup>
              </Fragment>
            )}
          </Fragment>
        )}

        {activeView === "security" && (
          <Fragment>
            <SkyBlock className="settings-copy">Set a passcode to secure your device.</SkyBlock>
            {!securityEnabled ? (
              <Fragment>
                <SkySettingsGroup title="Code Length">
                  <div className="settings-segmented-row">
                    <SkySegmented>
                      <SkySegmentedButton active={passcodeLength === 6} onClick={() => setPasscodeLength(6)}>6 Digit</SkySegmentedButton>
                      <SkySegmentedButton active={passcodeLength === 4} onClick={() => setPasscodeLength(4)}>4 Digit</SkySegmentedButton>
                    </SkySegmented>
                  </div>
                </SkySettingsGroup>
                <SkySettingsGroup>
                  <SkySettingsRow kind="action" title="Turn Passcode On" onActivate={() => setPasscodeFlow("set-new")} />
                </SkySettingsGroup>
              </Fragment>
            ) : (
              <Fragment>
                <SkySettingsGroup ariaLabel="Status">
                  <SkySettingsRow title="Passcode Status" value="On" />
                </SkySettingsGroup>
                <SkySettingsGroup>
                  <SkySettingsRow kind="action" title="Change Passcode" onActivate={() => setPasscodeFlow("change-current")} />
                  <SkySettingsRow kind="action" tone="danger" title="Turn Passcode Off" onActivate={() => setPasscodeFlow("disable")} />
                </SkySettingsGroup>
              </Fragment>
            )}
          </Fragment>
        )}
        
        {activeView === "connectivity" && (
          <SkySettingsGroup title="Connections">
            {connectivityRows.map((row) => (
              <SkySettingsRow key={row.key} kind="toggle" disabled={preferences.airplaneMode} modelValue={preferences[row.preferenceKey]} title={t(row.key)} onUpdateModelValue={(val: boolean) => setRootSetting(row.preferenceKey, val)}>
                <SkySettingsIcon color={row.iconColor}><row.icon aria-hidden="true" /></SkySettingsIcon>
              </SkySettingsRow>
            ))}
          </SkySettingsGroup>
        )}

        {activeView === "sounds" && (
          <Fragment>
            <SkySettingsGroup>
              <SkySettingsRangeRow modelValue={preferences.ringtoneVolume} title="Ringtone Volume" min={0} max={100} onUpdateModelValue={(val: number) => updateNumberPreference("ringtoneVolume", val)} />
              <SkySettingsRangeRow modelValue={preferences.notificationVolume} title="Notification Volume" min={0} max={100} onUpdateModelValue={(val: number) => updateNumberPreference("notificationVolume", val)} />
            </SkySettingsGroup>
            {/* Ringtones and Notification Sounds Selection can go here */}
          </Fragment>
        )}

        {activeView === "appearance" && (
          <Fragment>
            <SkySettingsGroup title="Graphics Mode">
              {GRAPHICS_MODE_IDS.map((mode) => (
                <SkySettingsRow key={mode} kind="choice" selected={preferences.graphicsMode === mode} title={mode} onActivate={() => setPreferences({ ...preferences, graphicsMode: mode })} />
              ))}
            </SkySettingsGroup>
            <SkySettingsGroup title="Appearance Mode">
              {APPEARANCE_MODE_IDS.map((mode) => (
                <SkySettingsRow key={mode} kind="choice" selected={preferences.appearanceMode === mode} title={mode} onActivate={() => setPreferences({ ...preferences, appearanceMode: mode })} />
              ))}
            </SkySettingsGroup>
            <SkySettingsGroup>
              <SkySettingsRangeRow modelValue={preferences.screenBrightness} title="Brightness" min={10} max={100} onUpdateModelValue={(val: number) => updateNumberPreference("screenBrightness", val)} />
            </SkySettingsGroup>
            <SkySettingsGroup title="Phone Frame">
              <SkySettingsRow kind="navigation" title="Phone Frame" onActivate={() => setFramePickerOpened(true)} />
            </SkySettingsGroup>
          </Fragment>
        )}

        {activeView === "wallpaper" && (
          <Fragment>
            <SkySegmented className="settings-wallpaper-target">
              <SkySegmentedButton active={wallpaperTarget === "home"} onClick={() => setWallpaperTarget("home")}>Home Screen</SkySegmentedButton>
              <SkySegmentedButton active={wallpaperTarget === "lock"} onClick={() => setWallpaperTarget("lock")}>Lock Screen</SkySegmentedButton>
            </SkySegmented>
            <section className="settings-wallpaper-actions">
              <button type="button"><span className="settings-wallpaper-actions__icon"><Images /></span><strong>Photos</strong></button>
              <button type="button"><span className="settings-wallpaper-actions__icon"><Camera /></span><strong>Camera</strong></button>
            </section>
          </Fragment>
        )}
        
        {activeView === "focus" && (
          <SkySettingsGroup>
            <SkySettingsRow kind="toggle" modelValue={preferences.focusMode} title="Focus Mode" onUpdateModelValue={(val: boolean) => setRootSetting("focusMode", val)}>
              <SkySettingsIcon color="#5856d6"><Moon aria-hidden="true" /></SkySettingsIcon>
            </SkySettingsRow>
          </SkySettingsGroup>
        )}
        
        {activeView === "general" && (
          <Fragment>
            <SkySettingsGroup>
              <SkySettingsRangeRow modelValue={preferences.notificationDurationSeconds} title="Duration" min={3} max={30} onUpdateModelValue={(val: number) => updateNumberPreference("notificationDurationSeconds", val)} />
            </SkySettingsGroup>
            <SkySettingsGroup title="About">
              <SkySettingsRow title="Device" value="Phone" />
              <SkySettingsRow title="Software Version" value="0.1.0" />
            </SkySettingsGroup>
            <SkySettingsGroup title="Device Information">
              <SkySettingsRow title="IMEI" value={deviceData.imei} />
              <SkySettingsRow title="SIM Number" value={deviceData.sim.number} />
              {deviceData.sim.removable && (
                <SkySettingsRow kind="action" tone="danger" title="Eject SIM" onActivate={() => setSimEjectOpened(true)} />
              )}
            </SkySettingsGroup>
            <SkySettingsGroup>
              <SkySettingsRow kind="navigation" title="Transfer or Reset" onActivate={() => openView("reset")}>
                <SkySettingsIcon color="#8e8e93"><RotateCcw size={18} /></SkySettingsIcon>
              </SkySettingsRow>
            </SkySettingsGroup>
          </Fragment>
        )}
        
        {activeView === "reset" && (
          <Fragment>
            <section className="settings-reset-hero">
              <div className="settings-reset-hero__icon"><RotateCcw size={35} /></div>
              <h2>Reset Device</h2>
              <p>Erases all settings and content.</p>
            </section>
            <SkySettingsGroup title="Erased from this phone">
              <SkySettingsRow title="Device Settings" />
              <SkySettingsRow title="Local Content" />
            </SkySettingsGroup>
            <SkySettingsGroup>
              <SkySettingsRow kind="action" tone="danger" title="Factory Reset" onActivate={() => setResetOpened(true)} />
            </SkySettingsGroup>
          </Fragment>
        )}
        
      </SkyScrollArea>

      {/* Dialogs */}
      <SkyDialog opened={framePickerOpened} title="Phone Frame" onBackdropclick={() => setFramePickerOpened(false)} onEscape={() => setFramePickerOpened(false)}>
        <div className="settings-frame-grid" role="group">
          {PHONE_FRAME_IDS.map((frame) => (
            <button key={frame} className={`settings-frame-choice ${preferences.frame === frame ? "settings-frame-choice--selected" : ""}`} onClick={() => setPreferences({ ...preferences, frame })}>
              <span className="settings-frame-choice__swatch" style={{ background: PHONE_FRAME_COLORS[frame] }} />
              {preferences.frame === frame && <Check size={17} />}
            </button>
          ))}
        </div>
        <SkyDialogButton onClick={() => setFramePickerOpened(false)}>Cancel</SkyDialogButton>
      </SkyDialog>

      <SkyDialog opened={resetOpened} title="Factory Reset" content="Are you sure?" onBackdropclick={() => setResetOpened(false)} onEscape={() => setResetOpened(false)}>
        <SkyDialogButton onClick={() => setResetOpened(false)}>Cancel</SkyDialogButton>
        <SkyDialogButton className="settings-dialog-button--danger" strong onClick={() => { setResetOpened(false); setFactoryResetting(true); }}>Reset</SkyDialogButton>
      </SkyDialog>
      
      {simEjectOpened && (
        <SkyDialog opened={simEjectOpened} title="Eject SIM" content="Are you sure?" onBackdropclick={() => setSimEjectOpened(false)} onEscape={() => setSimEjectOpened(false)}>
          <SkyDialogButton onClick={() => setSimEjectOpened(false)}>Cancel</SkyDialogButton>
          <SkyDialogButton className="settings-dialog-button--danger" strong onClick={() => setSimEjectOpened(false)}>Eject</SkyDialogButton>
        </SkyDialog>
      )}
      
      {factoryResetting && (
        <div className="settings-reset-overlay">
          <div className="settings-reset-content">
            <div className="settings-reset-heading"><h2>Factory Reset in Progress</h2></div>
          </div>
        </div>
      )}

      {passcodeFlow && (
        <PhonePasscode busy={passcodeBusy} error={passcodeError} length={passcodeLength} resetKey={passcodeResetKey} onCancel={() => setPasscodeFlow(null)} onComplete={() => setPasscodeFlow(null)} />
      )}

      <SkyNotification opened={Boolean(accountToast)} text={accountToast} onClick={() => setAccountToast("")} />
    </SkyAppPage>
  );
};
