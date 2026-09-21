// src/phone/roblox/roblox-sky-phone-tree.ts
// Pure Roblox Instance JSON Tree modeling the exact in-engine Roblox Studio hierarchy
// from Chassis.luau, Springboard.luau, AppSuite_Core.luau, AppSuite_Tools.luau, etc.

import type { RobloxInstanceJson, RobloxColor3, RobloxUDim2, RobloxUDim } from '../../renderer/RobloxRenderer.tsx'

export const udim = (scale: number, offset: number): RobloxUDim => ({
  Scale: scale,
  Offset: offset,
})

export const udim2 = (xs: number, xo: number, ys: number, yo: number): RobloxUDim2 => ({
  X: { Scale: xs, Offset: xo },
  Y: { Scale: ys, Offset: yo },
})

export const color3 = (r: number, g: number, b: number): RobloxColor3 => ({
  R: r > 1 ? r / 255 : r,
  G: g > 1 ? g / 255 : g,
  B: b > 1 ? b / 255 : b,
})

export type SkyPhoneTreeOptions = {
  activeApp: string
  activePhoneTab?: 'Recents' | 'Contacts' | 'Keypad'
  currentPage: number
  dynamicIslandExpanded?: boolean
  timeText?: string
  isMusicPlaying?: boolean
  trackTitle?: string
  artist?: string
  trackProgress?: number
  weatherTemp?: string
  weatherCity?: string
  weatherCond?: string
}

export function createSkyPhoneInstanceTree(options: SkyPhoneTreeOptions): RobloxInstanceJson {
  const {
    activeApp = 'home',
    activePhoneTab = 'Recents',
    currentPage = 1,
    dynamicIslandExpanded = false,
    timeText = '18:40',
    isMusicPlaying = false,
    trackTitle = 'Neon Rain',
    artist = 'Mirror Park',
    trackProgress = 0.45,
    weatherTemp = '24°',
    weatherCity = 'Los Santos',
    weatherCond = '⛅ Partly Cloudy',
  } = options

  const isHome = activeApp.toLowerCase() === 'home'

  // Helper for App Icon Button in Springboard
  const createAppIcon = (
    name: string,
    label: string,
    iconAsset: string,
    layoutOrder: number,
    badgeNum = 0,
  ): RobloxInstanceJson => {
    const isCalendar = name === 'Calendar'
    const children: RobloxInstanceJson[] = [
      // Icon Background / Image
      {
        ClassName: 'ImageLabel',
        Name: 'Icon',
        Size: udim2(0, 54, 0, 54),
        Position: udim2(0.5, -27, 0, 0),
        BackgroundColor3: isCalendar ? color3(255, 255, 255) : color3(28, 30, 40),
        Image: isCalendar ? '' : iconAsset,
        ScaleType: 'Fit',
        ZIndex: 13,
        Children: [
          {
            ClassName: 'UICorner',
            CornerRadius: udim(0, 13),
          },
          ...(isCalendar
            ? [
                {
                  ClassName: 'TextLabel',
                  Name: 'CalMon',
                  Size: udim2(1, 0, 0, 16),
                  Position: udim2(0, 0, 0, 4),
                  BackgroundTransparency: 1,
                  Text: 'Mon',
                  TextColor3: color3(235, 60, 50),
                  Font: 'GothamBold',
                  TextSize: 11,
                  TextXAlignment: 'Center',
                  ZIndex: 14,
                },
                {
                  ClassName: 'TextLabel',
                  Name: 'CalDay',
                  Size: udim2(1, 0, 0, 26),
                  Position: udim2(0, 0, 0, 19),
                  BackgroundTransparency: 1,
                  Text: '21',
                  TextColor3: color3(28, 30, 36),
                  Font: 'GothamBold',
                  TextSize: 22,
                  TextXAlignment: 'Center',
                  ZIndex: 14,
                },
              ]
            : []),
        ],
      },
      // Label below Icon
      {
        ClassName: 'TextLabel',
        Name: 'Label',
        Size: udim2(1, 8, 0, 14),
        Position: udim2(0, -4, 0, 56),
        BackgroundTransparency: 1,
        Text: label,
        TextColor3: color3(255, 255, 255),
        Font: 'GothamMedium',
        TextSize: 11,
        TextXAlignment: 'Center',
        TextTruncate: 'AtEnd',
        ZIndex: 13,
      },
    ]

    // Notification Badge
    if (badgeNum > 0) {
      children.push({
        ClassName: 'Frame',
        Name: 'Badge',
        AnchorPoint: { X: 1, Y: 0 },
        Position: udim2(1, 0, 0, -3),
        Size: udim2(0, 18, 0, 18),
        BackgroundColor3: color3(255, 59, 48),
        BorderSizePixel: 0,
        ZIndex: 15,
        Children: [
          {
            ClassName: 'UICorner',
            CornerRadius: udim(1, 0),
          },
          {
            ClassName: 'TextLabel',
            Size: udim2(1, 0, 1, 0),
            BackgroundTransparency: 1,
            Text: String(badgeNum),
            TextColor3: color3(255, 255, 255),
            Font: 'GothamBold',
            TextSize: 10,
            TextXAlignment: 'Center',
            TextYAlignment: 'Center',
            ZIndex: 16,
          },
        ],
      })
    }

    return {
      ClassName: 'TextButton',
      Name: `App_${name}`,
      Size: udim2(0, 58, 0, 72),
      BackgroundTransparency: 1,
      Text: '',
      AutoButtonColor: false,
      LayoutOrder: layoutOrder,
      ZIndex: 12,
      Children: children,
    }
  }

  // ==========================================
  // PAGE 1: PICTURE 1 (Clock, Weather, Music, 8 Hero Apps)
  // ==========================================
  const page1HeroApps = [
    { name: 'Calculator', label: 'Calculator', asset: 'rbxassetid://129797552944912', badge: 0 },
    { name: 'Banking', label: 'Banking', asset: 'rbxassetid://113219823990413', badge: 0 },
    { name: 'Weather', label: 'Weather', asset: 'rbxassetid://93316242404129', badge: 0 },
    { name: 'Billing', label: 'Billing', asset: 'rbxassetid://120691943073443', badge: 2 },
    { name: 'Mail', label: 'Mail', asset: 'rbxassetid://124444731583599', badge: 1 },
    { name: 'VaultX', label: 'VaultX', asset: 'rbxassetid://75815873536189', badge: 0 },
    { name: 'Notes', label: 'Notes', asset: 'rbxassetid://126379364685622', badge: 0 },
    { name: 'VoiceMemos', label: 'Memos', asset: 'rbxassetid://105967486602343', badge: 0 },
  ]

  const page1Tree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'Page1',
    Size: udim2(1, 0, 1, 0),
    BackgroundTransparency: 1,
    LayoutOrder: 1,
    Visible: currentPage === 1,
    ZIndex: 11,
    Children: [
      // Top Widgets Grid (Clock & Weather)
      {
        ClassName: 'Frame',
        Name: 'WidgetGrid',
        Size: udim2(1, -28, 0, 134),
        Position: udim2(0, 14, 0, 56),
        BackgroundTransparency: 1,
        ZIndex: 11,
        Children: [
          // Clock Widget
          {
            ClassName: 'TextButton',
            Name: 'Widget_Clock',
            Size: udim2(0.485, 0, 1, 0),
            Position: udim2(0, 0, 0, 0),
            BackgroundColor3: color3(22, 22, 26),
            BackgroundTransparency: 0.05,
            Text: '',
            AutoButtonColor: false,
            ZIndex: 12,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0, 24) },
              {
                ClassName: 'UIStroke',
                Color: color3(255, 255, 255),
                Transparency: 0.9,
                Thickness: 1,
              },
              {
                ClassName: 'TextLabel',
                Name: 'Day',
                Size: udim2(1, -24, 0, 16),
                Position: udim2(0, 14, 0, 14),
                BackgroundTransparency: 1,
                Text: 'Monday',
                TextColor3: color3(152, 152, 159),
                Font: 'GothamMedium',
                TextSize: 12,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
              {
                ClassName: 'TextLabel',
                Name: 'TimeText',
                Size: udim2(1, -24, 0, 44),
                Position: udim2(0, 14, 0, 30),
                BackgroundTransparency: 1,
                Text: timeText,
                TextColor3: color3(255, 255, 255),
                Font: 'GothamBold',
                TextSize: 38,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
              {
                ClassName: 'TextLabel',
                Name: 'Date',
                Size: udim2(1, -24, 0, 26),
                Position: udim2(0, 14, 1, -32),
                BackgroundTransparency: 1,
                Text: 'Monday, September\n21',
                TextColor3: color3(142, 142, 147),
                Font: 'Gotham',
                TextSize: 10,
                TextWrapped: true,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
            ],
          },
          // Weather Widget
          {
            ClassName: 'TextButton',
            Name: 'Widget_Weather',
            Size: udim2(0.485, 0, 1, 0),
            Position: udim2(0.515, 0, 0, 0),
            BackgroundColor3: color3(36, 62, 96),
            Text: '',
            AutoButtonColor: false,
            ZIndex: 12,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0, 24) },
              {
                ClassName: 'UIStroke',
                Color: color3(255, 255, 255),
                Transparency: 0.9,
                Thickness: 1,
              },
              {
                ClassName: 'TextLabel',
                Name: 'City',
                Size: udim2(1, -24, 0, 16),
                Position: udim2(0, 14, 0, 14),
                BackgroundTransparency: 1,
                Text: weatherCity,
                TextColor3: color3(180, 205, 235),
                Font: 'GothamMedium',
                TextSize: 12,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
              {
                ClassName: 'TextLabel',
                Name: 'Temp',
                Size: udim2(1, -24, 0, 44),
                Position: udim2(0, 14, 0, 30),
                BackgroundTransparency: 1,
                Text: weatherTemp,
                TextColor3: color3(255, 255, 255),
                Font: 'GothamBold',
                TextSize: 40,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
              {
                ClassName: 'TextLabel',
                Name: 'Cond',
                Size: udim2(1, -24, 0, 16),
                Position: udim2(0, 14, 1, -36),
                BackgroundTransparency: 1,
                Text: weatherCond,
                TextColor3: color3(220, 235, 255),
                Font: 'GothamMedium',
                TextSize: 11,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
              {
                ClassName: 'TextLabel',
                Name: 'HL',
                Size: udim2(1, -24, 0, 14),
                Position: udim2(0, 14, 1, -20),
                BackgroundTransparency: 1,
                Text: 'H: 24°  L: 13°',
                TextColor3: color3(170, 195, 225),
                Font: 'Gotham',
                TextSize: 10,
                TextXAlignment: 'Left',
                ZIndex: 13,
              },
            ],
          },
        ],
      },
      // Widget Labels
      {
        ClassName: 'TextLabel',
        Name: 'LblClock',
        Size: udim2(0.485, -14, 0, 14),
        Position: udim2(0, 14, 0, 194),
        BackgroundTransparency: 1,
        Text: 'Clock',
        TextColor3: color3(255, 255, 255),
        Font: 'GothamMedium',
        TextSize: 11,
        TextXAlignment: 'Center',
        ZIndex: 13,
      },
      {
        ClassName: 'TextLabel',
        Name: 'LblWeather',
        Size: udim2(0.485, 0, 0, 14),
        Position: udim2(0.515, 14, 0, 194),
        BackgroundTransparency: 1,
        Text: 'Weather',
        TextColor3: color3(255, 255, 255),
        Font: 'GothamMedium',
        TextSize: 11,
        TextXAlignment: 'Center',
        ZIndex: 13,
      },
      // Music Widget (4x2 Wide Card)
      {
        ClassName: 'TextButton',
        Name: 'Widget_Music',
        Size: udim2(1, -28, 0, 114),
        Position: udim2(0, 14, 0, 218),
        BackgroundColor3: color3(22, 22, 26),
        BackgroundTransparency: 0.05,
        Text: '',
        AutoButtonColor: false,
        ZIndex: 12,
        Children: [
          { ClassName: 'UICorner', CornerRadius: udim(0, 24) },
          {
            ClassName: 'UIStroke',
            Color: color3(255, 255, 255),
            Transparency: 0.9,
            Thickness: 1,
          },
          // Album Art Frame
          {
            ClassName: 'Frame',
            Name: 'ArtFrame',
            Size: udim2(0, 72, 0, 72),
            Position: udim2(0, 16, 0, 14),
            BackgroundColor3: color3(38, 38, 42),
            BorderSizePixel: 0,
            ZIndex: 13,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0, 16) },
              {
                ClassName: 'TextLabel',
                Size: udim2(1, 0, 1, 0),
                BackgroundTransparency: 1,
                Text: '♪',
                TextColor3: isMusicPlaying ? color3(255, 45, 85) : color3(110, 112, 120),
                Font: 'GothamMedium',
                TextSize: 32,
                TextXAlignment: 'Center',
                TextYAlignment: 'Center',
                ZIndex: 14,
              },
            ],
          },
          // Red Musical Note Accent
          {
            ClassName: 'TextLabel',
            Size: udim2(0, 20, 0, 20),
            Position: udim2(1, -30, 0, 16),
            BackgroundTransparency: 1,
            Text: '♪',
            TextColor3: color3(255, 45, 85),
            Font: 'GothamBold',
            TextSize: 18,
            ZIndex: 14,
          },
          // Track Info & Scrubber
          ...(isMusicPlaying
            ? [
                {
                  ClassName: 'TextLabel',
                  Name: 'TrackTitle',
                  Size: udim2(1, -125, 0, 18),
                  Position: udim2(0, 102, 0, 18),
                  BackgroundTransparency: 1,
                  Text: trackTitle,
                  TextColor3: color3(255, 255, 255),
                  Font: 'GothamBold',
                  TextSize: 14,
                  TextXAlignment: 'Left',
                  ZIndex: 14,
                },
                {
                  ClassName: 'TextLabel',
                  Name: 'Artist',
                  Size: udim2(1, -125, 0, 15),
                  Position: udim2(0, 102, 0, 36),
                  BackgroundTransparency: 1,
                  Text: artist,
                  TextColor3: color3(142, 142, 147),
                  Font: 'Gotham',
                  TextSize: 11,
                  TextXAlignment: 'Left',
                  ZIndex: 14,
                },
                {
                  ClassName: 'Frame',
                  Name: 'Scrubber',
                  Size: udim2(0, 96, 0, 4),
                  Position: udim2(0, 102, 0, 56),
                  BackgroundColor3: color3(80, 25, 35),
                  BorderSizePixel: 0,
                  ZIndex: 13,
                  Children: [
                    { ClassName: 'UICorner', CornerRadius: udim(1, 0) },
                    {
                      ClassName: 'Frame',
                      Name: 'Fill',
                      Size: udim2(trackProgress, 0, 1, 0),
                      BackgroundColor3: color3(255, 45, 85),
                      BorderSizePixel: 0,
                      ZIndex: 14,
                      Children: [{ ClassName: 'UICorner', CornerRadius: udim(1, 0) }],
                    },
                  ],
                },
              ]
            : [
                {
                  ClassName: 'TextLabel',
                  Name: 'SubText',
                  Size: udim2(1, -20, 0, 20),
                  Position: udim2(0, 10, 1, -24),
                  BackgroundTransparency: 1,
                  Text: 'No recently played music',
                  TextColor3: color3(220, 222, 230),
                  Font: 'GothamBold',
                  TextSize: 11.5,
                  TextXAlignment: 'Center',
                  ZIndex: 13,
                },
              ]),
        ],
      },
      // Music Label
      {
        ClassName: 'TextLabel',
        Name: 'LblMusic',
        Size: udim2(1, 0, 0, 14),
        Position: udim2(0, 0, 0, 338),
        BackgroundTransparency: 1,
        Text: 'Music',
        TextColor3: color3(255, 255, 255),
        Font: 'GothamMedium',
        TextSize: 11,
        TextXAlignment: 'Center',
        ZIndex: 13,
      },
      // Page 1 App Grid (8 Hero Apps)
      {
        ClassName: 'Frame',
        Name: 'AppGrid',
        Size: udim2(1, -24, 0, 160),
        Position: udim2(0, 12, 0, 360),
        BackgroundTransparency: 1,
        ZIndex: 12,
        Children: [
          {
            ClassName: 'UIGridLayout',
            CellSize: udim2(0, 58, 0, 72),
            CellPadding: udim2(0, 14, 0, 12),
            HorizontalAlignment: 'Center',
            SortOrder: 'LayoutOrder',
          },
          ...page1HeroApps.map((app, idx) =>
            createAppIcon(app.name, app.label, app.asset, idx + 1, app.badge),
          ),
        ],
      },
    ],
  }

  // ==========================================
  // PAGE 2: PICTURE 2 (24 Apps in 6x4 Grid)
  // ==========================================
  const page2Apps = [
    { name: 'Photos', label: 'Photos', asset: 'rbxassetid://76222215665071', badge: 0 },
    { name: 'AppStore', label: 'App Store', asset: 'rbxassetid://138098392316055', badge: 0 },
    { name: 'Settings', label: 'Settings', asset: 'rbxassetid://134186256578892', badge: 0 },
    { name: 'Health', label: 'Health', asset: 'rbxassetid://131644135355880', badge: 0 },
    { name: 'Maps', label: 'Map', asset: 'rbxassetid://87510415537199', badge: 0 },
    { name: 'Snake', label: 'Snake', asset: 'rbxassetid://98087609718142', badge: 0 },
    { name: 'Memory', label: 'Memory', asset: 'rbxassetid://81614406065481', badge: 0 },
    { name: 'Game2048', label: '2048', asset: 'rbxassetid://73681664605256', badge: 0 },
    { name: 'Minesweeper', label: 'Mineswe...', asset: 'rbxassetid://128647845095689', badge: 0 },
    { name: 'TowerStack', label: 'Tower Sta...', asset: 'rbxassetid://74730984383151', badge: 0 },
    { name: 'SkyFlappy', label: 'Sky Flappy', asset: 'rbxassetid://123795653808019', badge: 0 },
    { name: 'NeonDrop', label: 'Neon Drop', asset: 'rbxassetid://90607228374109', badge: 0 },
    { name: 'CityMarkt', label: 'CityMarkt', asset: 'rbxassetid://95951474710933', badge: 5 },
    { name: 'LocalPages', label: 'Local Pages', asset: 'rbxassetid://130772677041911', badge: 0 },
    { name: 'Calendar', label: 'Calendar', asset: 'rbxassetid://120088589434683', badge: 0 },
    { name: 'Radio', label: 'Radio', asset: 'rbxassetid://76034907691302', badge: 0 },
    { name: 'FlipTok', label: 'FlipTok', asset: 'rbxassetid://137548902900974', badge: 0 },
    { name: 'DarkChat', label: 'DarkChat', asset: 'rbxassetid://120681331774905', badge: 2 },
    { name: 'Picstagram', label: 'Picstagram', asset: 'rbxassetid://138647675714650', badge: 0 },
    { name: 'Garage', label: 'Garage', asset: 'rbxassetid://131470370579445', badge: 0 },
    { name: 'Flare', label: 'Flare', asset: 'rbxassetid://91154694947031', badge: 0 },
    { name: 'Feather', label: 'Feather', asset: 'rbxassetid://138549145828003', badge: 0 },
    { name: 'House', label: 'House', asset: 'rbxassetid://128366375527070', badge: 0 },
    { name: 'SkyRide', label: 'SkyRide', asset: 'rbxassetid://119249104472495', badge: 0 },
  ]

  const page2Tree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'Page2',
    Size: udim2(1, 0, 1, 0),
    BackgroundTransparency: 1,
    LayoutOrder: 2,
    Visible: currentPage === 2,
    ZIndex: 11,
    Children: [
      {
        ClassName: 'Frame',
        Name: 'AppGrid',
        Size: udim2(1, -24, 0, 492),
        Position: udim2(0, 12, 0, 68),
        BackgroundTransparency: 1,
        ZIndex: 12,
        Children: [
          {
            ClassName: 'UIGridLayout',
            CellSize: udim2(0, 58, 0, 72),
            CellPadding: udim2(0, 14, 0, 12),
            HorizontalAlignment: 'Center',
            SortOrder: 'LayoutOrder',
          },
          ...page2Apps.map((app, idx) =>
            createAppIcon(app.name, app.label, app.asset, idx + 1, app.badge),
          ),
        ],
      },
    ],
  }

  // ==========================================
  // PAGE 3: PICTURE 3 (5 Secondary Apps)
  // ==========================================
  const page3Apps = [
    { name: 'Music', label: 'Music', asset: 'rbxassetid://127792277672651', badge: 0 },
    { name: 'CrewLink', label: 'CrewLink', asset: 'rbxassetid://96986862031142', badge: 0 },
    { name: 'Companies', label: 'Companies', asset: 'rbxassetid://83617015141028', badge: 2 },
    { name: 'WeazelNews', label: 'Weazel N...', asset: 'rbxassetid://127924170113015', badge: 0 },
    { name: 'CityWarn', label: 'CityWarn', asset: 'rbxassetid://136532607231789', badge: 0 },
  ]

  const page3Tree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'Page3',
    Size: udim2(1, 0, 1, 0),
    BackgroundTransparency: 1,
    LayoutOrder: 3,
    Visible: currentPage === 3,
    ZIndex: 11,
    Children: [
      {
        ClassName: 'Frame',
        Name: 'AppGrid',
        Size: udim2(1, -24, 0, 492),
        Position: udim2(0, 12, 0, 68),
        BackgroundTransparency: 1,
        ZIndex: 12,
        Children: [
          {
            ClassName: 'UIGridLayout',
            CellSize: udim2(0, 58, 0, 72),
            CellPadding: udim2(0, 14, 0, 12),
            HorizontalAlignment: 'Center',
            SortOrder: 'LayoutOrder',
          },
          ...page3Apps.map((app, idx) =>
            createAppIcon(app.name, app.label, app.asset, idx + 1, app.badge),
          ),
        ],
      },
    ],
  }

  // ==========================================
  // PAGE 4: APP LIBRARY
  // ==========================================
  const makeLibraryFolder = (
    title: string,
    xPos: number,
    yPos: number,
    apps: { name: string; asset: string }[],
  ): RobloxInstanceJson => ({
    ClassName: 'Frame',
    Name: `Folder_${title}`,
    Size: udim2(0.46, 0, 0, 130),
    Position: udim2(xPos, 0, 0, yPos),
    BackgroundColor3: color3(26, 28, 38),
    BackgroundTransparency: 0.5,
    BorderSizePixel: 0,
    ZIndex: 12,
    Children: [
      { ClassName: 'UICorner', CornerRadius: udim(0, 20) },
      {
        ClassName: 'TextLabel',
        Size: udim2(1, -16, 0, 20),
        Position: udim2(0, 10, 0, 8),
        Text: title,
        Font: 'GothamBold',
        TextSize: 12,
        TextColor3: color3(255, 255, 255),
        TextXAlignment: 'Left',
        BackgroundTransparency: 1,
        ZIndex: 13,
      },
      {
        ClassName: 'Frame',
        Size: udim2(1, -20, 1, -36),
        Position: udim2(0, 10, 0, 30),
        BackgroundTransparency: 1,
        ZIndex: 13,
        Children: [
          {
            ClassName: 'UIGridLayout',
            CellSize: udim2(0.46, 0, 0.46, 0),
            CellPadding: udim2(0.08, 0, 0.08, 0),
          },
          ...apps.map((a) => ({
            ClassName: 'ImageButton',
            Name: `LibApp_${a.name}`,
            BackgroundColor3: color3(36, 38, 50),
            Image: a.asset,
            ScaleType: 'Fit',
            ZIndex: 14,
            Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 8) }],
          })),
        ],
      },
    ],
  })

  const page4Tree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'Page4',
    Size: udim2(1, 0, 1, 0),
    BackgroundTransparency: 1,
    LayoutOrder: 4,
    Visible: currentPage === 4,
    ZIndex: 11,
    Children: [
      {
        ClassName: 'TextLabel',
        Name: 'LibTitle',
        Size: udim2(1, -28, 0, 32),
        Position: udim2(0, 14, 0, 52),
        Text: 'App Library',
        Font: 'GothamBold',
        TextSize: 24,
        TextColor3: color3(255, 255, 255),
        TextXAlignment: 'Left',
        BackgroundTransparency: 1,
        ZIndex: 12,
      },
      makeLibraryFolder('Utilities', 0.035, 94, [
        { name: 'Calculator', asset: 'rbxassetid://129797552944912' },
        { name: 'Clock', asset: 'rbxassetid://103043499972901' },
        { name: 'Notes', asset: 'rbxassetid://126379364685622' },
        { name: 'Settings', asset: 'rbxassetid://134186256578892' },
      ]),
      makeLibraryFolder('Social', 0.51, 94, [
        { name: 'Messages', asset: 'rbxassetid://139358287735244' },
        { name: 'FlipTok', asset: 'rbxassetid://137548902900974' },
        { name: 'DarkChat', asset: 'rbxassetid://120681331774905' },
        { name: 'Picstagram', asset: 'rbxassetid://138647675714650' },
      ]),
      makeLibraryFolder('Entertainment', 0.035, 238, [
        { name: 'Radio', asset: 'rbxassetid://76034907691302' },
        { name: 'SkyFlappy', asset: 'rbxassetid://123795653808019' },
        { name: 'NeonDrop', asset: 'rbxassetid://90607228374109' },
        { name: 'Photos', asset: 'rbxassetid://76222215665071' },
      ]),
      makeLibraryFolder('Finance', 0.51, 238, [
        { name: 'Banking', asset: 'rbxassetid://113219823990413' },
        { name: 'VaultX', asset: 'rbxassetid://75815873536189' },
        { name: 'Billing', asset: 'rbxassetid://120691943073443' },
        { name: 'CityMarkt', asset: 'rbxassetid://95951474710933' },
      ]),
    ],
  }

  // ==========================================
  // SPRINGBOARD DOCK (Frosted Glass with 4 Apps)
  // ==========================================
  const dockApps = [
    { name: 'Phone', asset: 'rbxassetid://70546187772415' },
    { name: 'Messages', asset: 'rbxassetid://139358287735244' },
    { name: 'Camera', asset: 'rbxassetid://134300653681700' },
    { name: 'Clock', asset: 'rbxassetid://103043499972901' },
  ]

  const dockTree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'Dock',
    AnchorPoint: { X: 0.5, Y: 1 },
    Position: udim2(0.5, 0, 1, -26),
    Size: udim2(1, -24, 0, 76),
    BackgroundColor3: color3(36, 40, 52),
    BackgroundTransparency: 0.5,
    BorderSizePixel: 0,
    ZIndex: 14,
    Children: [
      { ClassName: 'UICorner', CornerRadius: udim(0, 30) },
      {
        ClassName: 'UIStroke',
        Color: color3(255, 255, 255),
        Transparency: 0.85,
        Thickness: 1,
      },
      {
        ClassName: 'UIListLayout',
        FillDirection: 'Horizontal',
        HorizontalAlignment: 'Center',
        VerticalAlignment: 'Center',
        SortOrder: 'LayoutOrder',
        Padding: udim(0, 14),
      },
      ...dockApps.map((a, idx) => ({
        ClassName: 'TextButton',
        Name: `App_${a.name}`,
        Size: udim2(0, 54, 0, 54),
        BackgroundTransparency: 1,
        Text: '',
        AutoButtonColor: false,
        LayoutOrder: idx + 1,
        ZIndex: 15,
        Children: [
          {
            ClassName: 'ImageLabel',
            Name: 'Icon',
            Size: udim2(1, 0, 1, 0),
            BackgroundColor3: color3(32, 34, 44),
            Image: a.asset,
            ScaleType: 'Fit',
            ZIndex: 16,
            Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 13) }],
          },
        ],
      })),
    ],
  }

  // ==========================================
  // SPRINGBOARD PAGE DOTS (4 Dots)
  // ==========================================
  const dotsTree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'DotsContainer',
    AnchorPoint: { X: 0.5, Y: 1 },
    Position: udim2(0.5, 0, 1, -112),
    Size: udim2(0, 72, 0, 16),
    BackgroundTransparency: 1,
    ZIndex: 14,
    Children: [
      {
        ClassName: 'UIListLayout',
        FillDirection: 'Horizontal',
        HorizontalAlignment: 'Center',
        VerticalAlignment: 'Center',
        Padding: udim(0, 8),
      },
      ...[1, 2, 3, 4].map((dotIdx) => ({
        ClassName: 'TextButton',
        Name: `Dot_${dotIdx}`,
        Size: udim2(0, 7, 0, 7),
        BackgroundColor3: dotIdx === currentPage ? color3(255, 255, 255) : color3(120, 125, 140),
        BackgroundTransparency: dotIdx === currentPage ? 0 : 0.5,
        Text: '',
        BorderSizePixel: 0,
        ZIndex: 15,
        Children: [{ ClassName: 'UICorner', CornerRadius: udim(1, 0) }],
      })),
    ],
  }

  // ==========================================
  // HOME SCREEN (Combining Pages, Dots, Dock)
  // ==========================================
  const homeScreenTree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'HomeScreen',
    Size: udim2(1, 0, 1, 0),
    BackgroundTransparency: 1,
    BorderSizePixel: 0,
    ClipsDescendants: true,
    Visible: isHome,
    ZIndex: 4,
    Children: [
      { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
      // Pages Container
      {
        ClassName: 'Frame',
        Name: 'PagesContainer',
        Size: udim2(1, 0, 1, -84),
        Position: udim2(0, 0, 0, 0),
        BackgroundTransparency: 1,
        ZIndex: 10,
        Children: [page1Tree, page2Tree, page3Tree, page4Tree],
      },
      dotsTree,
      dockTree,
    ],
  }

  // ==========================================
  // IN-APP VIEWS (Pure Roblox Instance Implementations)
  // ==========================================
  const appContainerTree: RobloxInstanceJson = {
    ClassName: 'Frame',
    Name: 'AppContainer',
    Size: udim2(1, 0, 1, 0),
    BackgroundTransparency: 1,
    Visible: !isHome,
    ZIndex: 16,
    Children: [
      // 1. Phone App View (Matching restored_wallpaper_03_phone_app.png)
      {
        ClassName: 'Frame',
        Name: 'PhoneApp',
        Size: udim2(1, 0, 1, 0),
        BackgroundColor3: color3(14, 16, 24),
        BorderSizePixel: 0,
        ClipsDescendants: true,
        Visible: activeApp.toLowerCase() === 'phone',
        ZIndex: 17,
        Children: [
          { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
          // Header Bar with segmented control All / Missed
          {
            ClassName: 'Frame',
            Name: 'PhoneHeader',
            Size: udim2(1, 0, 0, 120),
            Position: udim2(0, 0, 0, 44),
            BackgroundTransparency: 1,
            ZIndex: 18,
            Children: [
              // Segmented Pill
              {
                ClassName: 'Frame',
                Name: 'SegmentedPill',
                AnchorPoint: { X: 0.5, Y: 0 },
                Position: udim2(0.5, 0, 0, 6),
                Size: udim2(0, 140, 0, 28),
                BackgroundColor3: color3(28, 30, 40),
                ZIndex: 19,
                Children: [
                  { ClassName: 'UICorner', CornerRadius: udim(0, 14) },
                  {
                    ClassName: 'TextButton',
                    Name: 'SegAll',
                    Size: udim2(0.5, 0, 1, 0),
                    BackgroundColor3: color3(58, 62, 76),
                    Text: 'All',
                    TextColor3: color3(255, 255, 255),
                    Font: 'GothamBold',
                    TextSize: 12,
                    ZIndex: 20,
                    Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 14) }],
                  },
                  {
                    ClassName: 'TextButton',
                    Name: 'SegMissed',
                    Position: udim2(0.5, 0, 0, 0),
                    Size: udim2(0.5, 0, 1, 0),
                    BackgroundTransparency: 1,
                    Text: 'Missed',
                    TextColor3: color3(160, 165, 180),
                    Font: 'GothamMedium',
                    TextSize: 12,
                    ZIndex: 20,
                  },
                ],
              },
              // Recents Title
              {
                ClassName: 'TextLabel',
                Name: 'AppTitle',
                Size: udim2(1, -32, 0, 32),
                Position: udim2(0, 16, 0, 40),
                BackgroundTransparency: 1,
                Text: 'Recents',
                TextColor3: color3(255, 255, 255),
                Font: 'GothamBold',
                TextSize: 28,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
              // Search Calls Bar
              {
                ClassName: 'Frame',
                Name: 'SearchBar',
                Size: udim2(1, -32, 0, 36),
                Position: udim2(0, 16, 0, 76),
                BackgroundColor3: color3(28, 30, 42),
                BorderSizePixel: 0,
                ZIndex: 19,
                Children: [
                  { ClassName: 'UICorner', CornerRadius: udim(0, 10) },
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(1, -40, 1, 0),
                    Position: udim2(0, 34, 0, 0),
                    BackgroundTransparency: 1,
                    Text: '🔍 Search Calls',
                    TextColor3: color3(140, 145, 160),
                    Font: 'Gotham',
                    TextSize: 13,
                    TextXAlignment: 'Left',
                    ZIndex: 20,
                  },
                ],
              },
            ],
          },
          // Recents Call List
          {
            ClassName: 'ScrollingFrame',
            Name: 'CallList',
            Size: udim2(1, 0, 1, -240),
            Position: udim2(0, 0, 0, 168),
            BackgroundTransparency: 1,
            BorderSizePixel: 0,
            ScrollBarThickness: 3,
            ZIndex: 18,
            Children: [
              {
                ClassName: 'UIListLayout',
                FillDirection: 'Vertical',
                SortOrder: 'LayoutOrder',
                Padding: udim(0, 2),
              },
              ...[
                { initial: 'A', name: 'Alex Rivera', sub: '📞 Call Ended', time: '03:09 AM', isMissed: false },
                { initial: 'M', name: 'Morgan Reed', sub: '📞 Call Ended', time: '02:59 AM', isMissed: false },
                { initial: 'L', name: 'Los Santos Taxi', sub: '📞 Call Ended', time: '02:35 AM', isMissed: false },
                { initial: 'J', name: 'Jamie Chen', sub: '📞 Missed', time: '01:42 AM', isMissed: true },
                { initial: 'E', name: 'Emily Hart', sub: '📞 No Answer', time: 'Sunday', isMissed: true },
                { initial: 'Y', name: 'Yakup Brooooo', sub: '📞 Call Ended', time: 'Sunday', isMissed: false },
                { initial: 'D', name: 'Downtown Custom', sub: '555 404 0404', time: '', isMissed: false },
              ].map((c, idx) => ({
                ClassName: 'TextButton',
                Name: `RecentRow_${idx}`,
                Size: udim2(1, 0, 0, 52),
                BackgroundColor3: color3(20, 22, 32),
                BackgroundTransparency: 0.4,
                BorderSizePixel: 0,
                Text: '',
                LayoutOrder: idx + 1,
                ZIndex: 19,
                Children: [
                  // Circle Avatar
                  {
                    ClassName: 'Frame',
                    Size: udim2(0, 36, 0, 36),
                    Position: udim2(0, 16, 0.5, -18),
                    BackgroundColor3: color3(36, 38, 52),
                    ZIndex: 20,
                    Children: [
                      { ClassName: 'UICorner', CornerRadius: udim(1, 0) },
                      {
                        ClassName: 'TextLabel',
                        Size: udim2(1, 0, 1, 0),
                        BackgroundTransparency: 1,
                        Text: c.initial,
                        TextColor3: color3(255, 255, 255),
                        Font: 'GothamBold',
                        TextSize: 14,
                        ZIndex: 21,
                      },
                    ],
                  },
                  // Name
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0.6, 0, 0, 18),
                    Position: udim2(0, 60, 0, 8),
                    BackgroundTransparency: 1,
                    Text: c.name,
                    TextColor3: c.isMissed ? color3(255, 69, 58) : color3(255, 255, 255),
                    Font: 'GothamBold',
                    TextSize: 14,
                    TextXAlignment: 'Left',
                    ZIndex: 20,
                  },
                  // Sub status
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0.6, 0, 0, 14),
                    Position: udim2(0, 60, 0, 28),
                    BackgroundTransparency: 1,
                    Text: c.sub,
                    TextColor3: color3(142, 142, 147),
                    Font: 'Gotham',
                    TextSize: 11,
                    TextXAlignment: 'Left',
                    ZIndex: 20,
                  },
                  // Time
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0.25, 0, 0, 14),
                    Position: udim2(1, -70, 0.5, -7),
                    BackgroundTransparency: 1,
                    Text: c.time,
                    TextColor3: color3(142, 142, 147),
                    Font: 'Gotham',
                    TextSize: 11,
                    TextXAlignment: 'Right',
                    ZIndex: 20,
                  },
                  // Info icon
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0, 20, 0, 20),
                    Position: udim2(1, -30, 0.5, -10),
                    BackgroundTransparency: 1,
                    Text: 'ⓘ',
                    TextColor3: color3(0, 122, 255),
                    Font: 'GothamBold',
                    TextSize: 14,
                    ZIndex: 20,
                  },
                ],
              })),
            ],
          },
          // Bottom Tab Bar: Contacts, Keypad, Recents
          {
            ClassName: 'Frame',
            Name: 'PhoneTabBar',
            AnchorPoint: { X: 0.5, Y: 1 },
            Position: udim2(0.5, 0, 1, -16),
            Size: udim2(1, -32, 0, 50),
            BackgroundColor3: color3(24, 26, 36),
            BorderSizePixel: 0,
            ZIndex: 22,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0, 25) },
              {
                ClassName: 'UIListLayout',
                FillDirection: 'Horizontal',
                HorizontalAlignment: 'Center',
                VerticalAlignment: 'Center',
                Padding: udim(0, 8),
              },
              {
                ClassName: 'TextButton',
                Name: 'Tab_Contacts',
                Size: udim2(0.3, 0, 0, 36),
                BackgroundTransparency: activePhoneTab === 'Contacts' ? 0 : 1,
                BackgroundColor3: color3(40, 44, 60),
                Text: '👤 Contacts',
                TextColor3: activePhoneTab === 'Contacts' ? color3(255, 255, 255) : color3(140, 145, 160),
                Font: 'GothamMedium',
                TextSize: 11,
                ZIndex: 23,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 18) }],
              },
              {
                ClassName: 'TextButton',
                Name: 'Tab_Keypad',
                Size: udim2(0.3, 0, 0, 36),
                BackgroundTransparency: activePhoneTab === 'Keypad' ? 0 : 1,
                BackgroundColor3: color3(40, 44, 60),
                Text: '🔢 Keypad',
                TextColor3: activePhoneTab === 'Keypad' ? color3(255, 255, 255) : color3(140, 145, 160),
                Font: 'GothamMedium',
                TextSize: 11,
                ZIndex: 23,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 18) }],
              },
              {
                ClassName: 'TextButton',
                Name: 'Tab_Recents',
                Size: udim2(0.32, 0, 0, 36),
                BackgroundColor3: color3(48, 54, 72),
                Text: '🕒 Recents',
                TextColor3: color3(255, 255, 255),
                Font: 'GothamBold',
                TextSize: 11,
                ZIndex: 23,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 18) }],
              },
            ],
          },
        ],
      },
      // 2. Messages App View
      {
        ClassName: 'Frame',
        Name: 'MessagesApp',
        Size: udim2(1, 0, 1, 0),
        BackgroundColor3: color3(14, 16, 24),
        BorderSizePixel: 0,
        ClipsDescendants: true,
        Visible: activeApp.toLowerCase() === 'messages',
        ZIndex: 17,
        Children: [
          { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
          {
            ClassName: 'Frame',
            Size: udim2(1, 0, 0, 60),
            Position: udim2(0, 0, 0, 44),
            BackgroundTransparency: 1,
            ZIndex: 18,
            Children: [
              {
                ClassName: 'TextLabel',
                Size: udim2(1, -32, 1, 0),
                Position: udim2(0, 16, 0, 0),
                BackgroundTransparency: 1,
                Text: 'Messages',
                TextColor3: color3(255, 255, 255),
                Font: 'GothamBold',
                TextSize: 28,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
            ],
          },
          // Conversation list
          {
            ClassName: 'ScrollingFrame',
            Size: udim2(1, 0, 1, -120),
            Position: udim2(0, 0, 0, 104),
            BackgroundTransparency: 1,
            BorderSizePixel: 0,
            ZIndex: 18,
            Children: [
              {
                ClassName: 'UIListLayout',
                FillDirection: 'Vertical',
                SortOrder: 'LayoutOrder',
                Padding: udim(0, 4),
              },
              ...[
                { name: 'Alex Rivera', preview: 'I left the car at the central garage. Meet you there?', time: '12:18' },
                { name: 'Franklin', preview: 'Everything is setup for the import tonight.', time: '10:45' },
                { name: 'Michael', preview: 'Check your billing app, latest invoice is in.', time: 'Yesterday' },
                { name: 'Bank of LS', preview: 'Direct deposit received: +$45,000.00', time: 'Monday' },
              ].map((msg, idx) => ({
                ClassName: 'TextButton',
                Name: `ChatRow_${idx}`,
                Size: udim2(1, 0, 0, 64),
                BackgroundColor3: color3(20, 22, 32),
                BackgroundTransparency: 0.4,
                BorderSizePixel: 0,
                Text: '',
                LayoutOrder: idx + 1,
                ZIndex: 19,
                Children: [
                  {
                    ClassName: 'Frame',
                    Size: udim2(0, 40, 0, 40),
                    Position: udim2(0, 16, 0.5, -20),
                    BackgroundColor3: color3(40, 44, 60),
                    ZIndex: 20,
                    Children: [
                      { ClassName: 'UICorner', CornerRadius: udim(1, 0) },
                      {
                        ClassName: 'TextLabel',
                        Size: udim2(1, 0, 1, 0),
                        BackgroundTransparency: 1,
                        Text: msg.name[0],
                        TextColor3: color3(255, 255, 255),
                        Font: 'GothamBold',
                        TextSize: 16,
                        ZIndex: 21,
                      },
                    ],
                  },
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0.6, 0, 0, 18),
                    Position: udim2(0, 68, 0, 12),
                    BackgroundTransparency: 1,
                    Text: msg.name,
                    TextColor3: color3(255, 255, 255),
                    Font: 'GothamBold',
                    TextSize: 14,
                    TextXAlignment: 'Left',
                    ZIndex: 20,
                  },
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0.7, 0, 0, 16),
                    Position: udim2(0, 68, 0, 32),
                    BackgroundTransparency: 1,
                    Text: msg.preview,
                    TextColor3: color3(142, 142, 147),
                    Font: 'Gotham',
                    TextSize: 12,
                    TextTruncate: 'AtEnd',
                    TextXAlignment: 'Left',
                    ZIndex: 20,
                  },
                  {
                    ClassName: 'TextLabel',
                    Size: udim2(0.2, 0, 0, 14),
                    Position: udim2(1, -70, 0, 12),
                    BackgroundTransparency: 1,
                    Text: msg.time,
                    TextColor3: color3(142, 142, 147),
                    Font: 'Gotham',
                    TextSize: 11,
                    TextXAlignment: 'Right',
                    ZIndex: 20,
                  },
                ],
              })),
            ],
          },
        ],
      },
      // 3. Calculator App View
      {
        ClassName: 'Frame',
        Name: 'CalculatorApp',
        Size: udim2(1, 0, 1, 0),
        BackgroundColor3: color3(0, 0, 0),
        BorderSizePixel: 0,
        Visible: activeApp.toLowerCase() === 'calculator',
        ZIndex: 17,
        Children: [
          { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
          {
            ClassName: 'TextLabel',
            Size: udim2(1, -32, 0, 60),
            Position: udim2(0, 16, 0, 110),
            BackgroundTransparency: 1,
            Text: '0',
            TextColor3: color3(255, 255, 255),
            Font: 'GothamLight',
            TextSize: 54,
            TextXAlignment: 'Right',
            ZIndex: 18,
          },
          {
            ClassName: 'Frame',
            Size: udim2(1, -24, 0, 340),
            Position: udim2(0, 12, 1, -360),
            BackgroundTransparency: 1,
            ZIndex: 18,
            Children: [
              {
                ClassName: 'UIGridLayout',
                CellSize: udim2(0, 64, 0, 64),
                CellPadding: udim2(0, 12, 0, 12),
                HorizontalAlignment: 'Center',
              },
              ...['C', '±', '%', '÷', '7', '8', '9', '×', '4', '5', '6', '-', '1', '2', '3', '+', '0', '.', '='].map(
                (btn) => ({
                  ClassName: 'TextButton',
                  Name: `CalcBtn_${btn}`,
                  BackgroundColor3: ['÷', '×', '-', '+', '='].includes(btn)
                    ? color3(255, 159, 10)
                    : ['C', '±', '%'].includes(btn)
                    ? color3(165, 165, 165)
                    : color3(51, 51, 51),
                  Text: btn,
                  TextColor3: ['C', '±', '%'].includes(btn) ? color3(0, 0, 0) : color3(255, 255, 255),
                  Font: 'GothamMedium',
                  TextSize: 24,
                  ZIndex: 19,
                  Children: [{ ClassName: 'UICorner', CornerRadius: udim(1, 0) }],
                }),
              ),
            ],
          },
        ],
      },
      // 4. Banking App View
      {
        ClassName: 'Frame',
        Name: 'BankingApp',
        Size: udim2(1, 0, 1, 0),
        BackgroundColor3: color3(10, 12, 18),
        BorderSizePixel: 0,
        ClipsDescendants: true,
        Visible: activeApp.toLowerCase() === 'banking',
        ZIndex: 17,
        Children: [
          { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
          {
            ClassName: 'TextLabel',
            Size: udim2(1, -32, 0, 32),
            Position: udim2(0, 16, 0, 52),
            BackgroundTransparency: 1,
            Text: 'Maze Bank',
            TextColor3: color3(255, 255, 255),
            Font: 'GothamBold',
            TextSize: 26,
            TextXAlignment: 'Left',
            ZIndex: 18,
          },
          // Card Balance Frame
          {
            ClassName: 'Frame',
            Size: udim2(1, -32, 0, 160),
            Position: udim2(0, 16, 0, 96),
            BackgroundColor3: color3(22, 28, 48),
            ZIndex: 18,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0, 20) },
              {
                ClassName: 'UIStroke',
                Color: color3(58, 92, 160),
                Thickness: 1.5,
              },
              {
                ClassName: 'TextLabel',
                Size: udim2(1, -32, 0, 18),
                Position: udim2(0, 16, 0, 16),
                BackgroundTransparency: 1,
                Text: 'TOTAL BALANCE',
                TextColor3: color3(140, 165, 210),
                Font: 'GothamBold',
                TextSize: 11,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
              {
                ClassName: 'TextLabel',
                Size: udim2(1, -32, 0, 36),
                Position: udim2(0, 16, 0, 38),
                BackgroundTransparency: 1,
                Text: '$1,284,950.00',
                TextColor3: color3(255, 255, 255),
                Font: 'GothamBold',
                TextSize: 30,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
              {
                ClassName: 'TextLabel',
                Size: udim2(1, -32, 0, 18),
                Position: udim2(0, 16, 1, -32),
                BackgroundTransparency: 1,
                Text: '•••• •••• •••• 4829  ·  PLATINUM',
                TextColor3: color3(180, 200, 235),
                Font: 'Gotham',
                TextSize: 12,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
            ],
          },
        ],
      },
      // 5. Generic/Fallback App View for other apps
      {
        ClassName: 'Frame',
        Name: 'GenericAppView',
        Size: udim2(1, 0, 1, 0),
        BackgroundColor3: color3(16, 18, 26),
        BorderSizePixel: 0,
        Visible: !['home', 'phone', 'messages', 'calculator', 'banking'].includes(activeApp.toLowerCase()),
        ZIndex: 17,
        Children: [
          { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
          {
            ClassName: 'TextLabel',
            Size: udim2(1, -32, 0, 40),
            Position: udim2(0, 16, 0, 60),
            BackgroundTransparency: 1,
            Text: activeApp.toUpperCase(),
            TextColor3: color3(255, 255, 255),
            Font: 'GothamBold',
            TextSize: 24,
            TextXAlignment: 'Left',
            ZIndex: 18,
          },
          {
            ClassName: 'TextLabel',
            Size: udim2(1, -32, 0, 20),
            Position: udim2(0, 16, 0, 102),
            BackgroundTransparency: 1,
            Text: 'Pure Luau ModuleScript Engine View',
            TextColor3: color3(142, 142, 147),
            Font: 'Gotham',
            TextSize: 12,
            TextXAlignment: 'Left',
            ZIndex: 18,
          },
          {
            ClassName: 'Frame',
            Size: udim2(1, -32, 0, 200),
            Position: udim2(0, 16, 0, 140),
            BackgroundColor3: color3(24, 28, 40),
            ZIndex: 18,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0, 16) },
              {
                ClassName: 'TextLabel',
                Size: udim2(1, -24, 0, 30),
                Position: udim2(0, 12, 0, 12),
                BackgroundTransparency: 1,
                Text: `Roblox UI Instance: ${activeApp}App`,
                TextColor3: color3(220, 235, 255),
                Font: 'GothamBold',
                TextSize: 14,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
              {
                ClassName: 'TextLabel',
                Size: udim2(1, -24, 0, 80),
                Position: udim2(0, 12, 0, 46),
                BackgroundTransparency: 1,
                Text: `Active app running in RobloxRenderer instance tree.\nZero pre-baked GUI (GEMINI.md Rule 10).\nTap the Home Bar below to return to the Springboard.`,
                TextColor3: color3(160, 170, 190),
                Font: 'Gotham',
                TextSize: 12,
                TextWrapped: true,
                TextXAlignment: 'Left',
                ZIndex: 19,
              },
            ],
          },
        ],
      },
    ],
  }

  // ==========================================
  // HARDWARE CHASSIS, BEZEL, SCREEN VIEWPORT
  // ==========================================
  return {
    ClassName: 'ScreenGui',
    Name: 'SkyPhoneGui',
    Children: [
      {
        ClassName: 'Frame',
        Name: 'PhoneChassis',
        AnchorPoint: { X: 0.5, Y: 0.5 },
        Position: udim2(0.5, 0, 0.5, 0),
        Size: udim2(1, 0, 0.94, 0),
        BackgroundColor3: color3(34, 36, 42),
        BorderSizePixel: 0,
        ZIndex: 1,
        Children: [
          { ClassName: 'UIAspectRatioConstraint', AspectRatio: 0.4387 },
          { ClassName: 'UICorner', CornerRadius: udim(0.145, 0) },
          // Titanium Chamfer Stroke
          {
            ClassName: 'UIStroke',
            Color: color3(255, 255, 255),
            Thickness: 2.4,
          },
          // Chassis Metallic Gradient
          {
            ClassName: 'UIGradient',
            Rotation: 90,
            Color: [
              { Time: 0.0, Value: color3(52, 56, 64) },
              { Time: 0.5, Value: color3(28, 30, 36) },
              { Time: 1.0, Value: color3(48, 52, 60) },
            ],
          },
          // Inner Bezel
          {
            ClassName: 'Frame',
            Name: 'InnerBezel',
            AnchorPoint: { X: 0.5, Y: 0.5 },
            Position: udim2(0.5, 0, 0.5, 0),
            Size: udim2(1, -6, 1, -6),
            BackgroundColor3: color3(12, 13, 16),
            BorderSizePixel: 0,
            ZIndex: 2,
            Children: [{ ClassName: 'UICorner', CornerRadius: udim(0.14, 0) }],
          },
          // Screen Viewport Frame
          {
            ClassName: 'Frame',
            Name: 'Screen',
            AnchorPoint: { X: 0.5, Y: 0.5 },
            Position: udim2(0.5, 0, 0.5, 0),
            Size: udim2(1, -12, 1, -12),
            BackgroundColor3: color3(0, 0, 0),
            BorderSizePixel: 0,
            ClipsDescendants: true,
            ZIndex: 3,
            Children: [
              { ClassName: 'UICorner', CornerRadius: udim(0.136, 0) },
              // Wallpaper ImageLabel (Official Deep Space Nebula Wallpaper)
              {
                ClassName: 'ImageLabel',
                Name: 'Wallpaper',
                Size: udim2(1, 0, 1, 0),
                Position: udim2(0, 0, 0, 0),
                BackgroundColor3: color3(12, 14, 28),
                Image: 'rbxassetid://82226915452893',
                ScaleType: 'Crop',
                BorderSizePixel: 0,
                ZIndex: 3,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0.136, 0) }],
              },
              // Status Bar
              {
                ClassName: 'Frame',
                Name: 'StatusBar',
                Size: udim2(1, 0, 0, 44),
                Position: udim2(0, 0, 0, 0),
                BackgroundTransparency: 1,
                ZIndex: 25,
                Children: [
                  // Time
                  {
                    ClassName: 'TextLabel',
                    Name: 'TimeText',
                    Size: udim2(0, 60, 0, 20),
                    Position: udim2(0, 28, 0, 13),
                    BackgroundTransparency: 1,
                    Text: timeText,
                    TextColor3: color3(255, 255, 255),
                    Font: 'GothamBold',
                    TextSize: 14,
                    TextXAlignment: 'Left',
                    ZIndex: 26,
                  },
                  // Cellular & Wifi & Battery Indicators
                  {
                    ClassName: 'TextLabel',
                    Name: 'StatusIcons',
                    Size: udim2(0, 70, 0, 20),
                    Position: udim2(1, -88, 0, 13),
                    BackgroundTransparency: 1,
                    Text: '📶 ⩥ 🔋',
                    TextColor3: color3(255, 255, 255),
                    Font: 'GothamMedium',
                    TextSize: 11,
                    TextXAlignment: 'Right',
                    ZIndex: 26,
                  },
                ],
              },
              // Dynamic Island Pill
              {
                ClassName: 'TextButton',
                Name: 'DynamicIsland',
                AnchorPoint: { X: 0.5, Y: 0 },
                Position: udim2(0.5, 0, 0, 11),
                Size: dynamicIslandExpanded ? udim2(0, 340, 0, 80) : udim2(0, 126, 0, 35),
                BackgroundColor3: color3(0, 0, 0),
                BorderSizePixel: 0,
                Text: '',
                AutoButtonColor: false,
                ZIndex: 28,
                Children: [
                  { ClassName: 'UICorner', CornerRadius: udim(1, 0) },
                  // Camera aperture dot
                  {
                    ClassName: 'Frame',
                    Name: 'CameraDot',
                    AnchorPoint: { X: 1, Y: 0.5 },
                    Position: udim2(1, -12, 0.5, 0),
                    Size: udim2(0, 11, 0, 11),
                    BackgroundColor3: color3(18, 20, 28),
                    ZIndex: 29,
                    Children: [{ ClassName: 'UICorner', CornerRadius: udim(1, 0) }],
                  },
                ],
              },
              // Home Screen (Pages, Widgets, Dock)
              homeScreenTree,
              // Apps Container
              appContainerTree,
              // Home Indicator (Bottom Pill)
              {
                ClassName: 'TextButton',
                Name: 'HomeIndicator',
                AnchorPoint: { X: 0.5, Y: 1 },
                Position: udim2(0.5, 0, 1, -8),
                Size: udim2(0, 140, 0, 5),
                BackgroundColor3: color3(255, 255, 255),
                BorderSizePixel: 0,
                Text: '',
                AutoButtonColor: false,
                ZIndex: 30,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(1, 0) }],
              },
            ],
          },
          // 3D Machined Side Hardware Buttons
          {
            ClassName: 'Frame',
            Name: 'SideButtons',
            Size: udim2(1, 0, 1, 0),
            BackgroundTransparency: 1,
            ZIndex: 1,
            Children: [
              // Mute switch
              {
                ClassName: 'Frame',
                Name: 'MuteSwitch',
                Position: udim2(0, -3, 0.12, 0),
                Size: udim2(0, 4, 0, 26),
                BackgroundColor3: color3(45, 48, 56),
                ZIndex: 1,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 2) }],
              },
              // Volume Up
              {
                ClassName: 'Frame',
                Name: 'VolumeUp',
                Position: udim2(0, -3, 0.18, 0),
                Size: udim2(0, 4, 0, 50),
                BackgroundColor3: color3(45, 48, 56),
                ZIndex: 1,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 2) }],
              },
              // Volume Down
              {
                ClassName: 'Frame',
                Name: 'VolumeDown',
                Position: udim2(0, -3, 0.26, 0),
                Size: udim2(0, 4, 0, 50),
                BackgroundColor3: color3(45, 48, 56),
                ZIndex: 1,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 2) }],
              },
              // Power Button
              {
                ClassName: 'Frame',
                Name: 'PowerBtn',
                Position: udim2(1, -1, 0.2, 0),
                Size: udim2(0, 4, 0, 75),
                BackgroundColor3: color3(45, 48, 56),
                ZIndex: 1,
                Children: [{ ClassName: 'UICorner', CornerRadius: udim(0, 2) }],
              },
            ],
          },
        ],
      },
    ],
  }
}
