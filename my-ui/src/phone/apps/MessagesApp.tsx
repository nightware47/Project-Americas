import React, { useState, useEffect, useMemo, useRef, useCallback } from 'react'
import {
  ArrowUpCircle, Ban, Camera, Check, ChevronRight, Ellipsis, ImagePlay, Images,
  Mail, MessageCircle, Mic, Phone as PhoneIcon, Plus, SquarePen, Trash2, ContactRound, Video, X
} from 'lucide-react'

import MessageAttachmentBubble from '@/components/MessageAttachmentBubble'
import MessageContactBubble from '@/components/MessageContactBubble'
import SharedContentCard from '@/components/SharedContentCard'
import FullEmojiPicker from '@/components/FullEmojiPicker'
import VoiceMessageBubble from '@/components/VoiceMessageBubble'
import { parseDatabaseDate } from '@/utils/date'
import { handleEnterAction } from '@/utils/keyboard'
import { normalizeMailAddress } from '@/utils/mail'
import { compressWaveformSamples } from '@/utils/mediaRecorder'
import { sortContactsByMessageRecency } from '@/utils/messages'
import {
  SkyAppPage, SkyButton, SkyDialog, SkyDialogButton, SkyDropdown, SkyEmptyState,
  SkyFab, SkyField, SkyGlass, SkyLink, SkyList, SkyListItem, SkyMessage, SkyMessagebar,
  SkyMessages, SkyMessagesTitle, SkyNavbar, SkyPillNavigation, SkyScrollArea,
  SkySearchbar, SkySettingsGroup, SkySettingsRow, SkySheet, SkySpinner,
  SkyNotification, SkyToolbar
} from '@/ui'
import './MessagesApp.css'

const VOICE_MAX_DURATION_MS = 30_000
const VOICE_MAX_BYTES = 135_000
const WAVEFORM_SAMPLES = 48
const MAX_PENDING_ATTACHMENTS = 6

type MessagesMediaContext = {
  draft: string
  pendingAttachments: any[]
  shareDraft: any | null
}

type ConversationSort = 'newest' | 'oldest'

// Mock Nerve bindings
declare const window: any
const nerve = window.nerve || {
  GetService: <T extends unknown>(name: string): T => ({
    loadConversations: async () => {},
    loadContacts: async () => {},
    openThread: async () => true,
    closeThread: () => {},
    deleteConversations: async () => true,
    send: async () => ({ success: true }),
    searchGifs: async () => ({ success: true, data: { results: [], hasMore: false, nextOffset: 0 } }),
    blockNumber: async () => ({ success: true }),
    dial: async () => ({ success: true }),
    saveContact: async () => ({ success: true }),
    consumeChatDraft: () => null,
    consumeMany: () => null,
    begin: () => {},
    messages: [],
    conversations: [],
    contacts: [],
    activeNumber: null,
    loading: false,
    device: { sim: true },
    lang: 'en-US',
    isDarkMode: false,
    t: (key: string, args?: any) => key,
  } as unknown as T)
}

export default function MessagesApp() {
  const phone = nerve.GetService<any>('PhoneService')
  const calls = nerve.GetService<any>('CallsService')
  const easyShare = nerve.GetService<any>('EasyShareService')
  const messages = nerve.GetService<any>('MessagesService')
  const messageMedia = nerve.GetService<any>('MessageMediaService')
  
  const router = { push: async (route: any) => {} }

  const [search, setSearch] = useState('')
  const [showUnreadOnly, setShowUnreadOnly] = useState(false)
  const [conversationSort, setConversationSort] = useState<ConversationSort>('newest')
  const [editingList, setEditingList] = useState(false)
  const [selectedNumbers, setSelectedNumbers] = useState<string[]>([])
  const [inboxMenuOpened, setInboxMenuOpened] = useState(false)
  const [inboxMenuTarget, setInboxMenuTarget] = useState<HTMLElement | null>(null)
  
  const [composerNumber, setComposerNumber] = useState('')
  const [draft, setDraft] = useState('')
  const [queuedSharePayload, setQueuedSharePayload] = useState<any | null>(null)
  const [shareDraft, setShareDraft] = useState<any | null>(null)
  const [composing, setComposing] = useState(false)
  const [sending, setSending] = useState(false)
  
  const [toastOpened, setToastOpened] = useState(false)
  const [toastText, setToastText] = useState('')
  const [emojiOpen, setEmojiOpen] = useState(false)
  const [attachmentMenuOpen, setAttachmentMenuOpen] = useState(false)
  const [attachmentPicker, setAttachmentPicker] = useState<'contacts' | 'gifs' | null>(null)
  const [pendingAttachments, setPendingAttachments] = useState<any[]>([])
  const [contactDetailsOpen, setContactDetailsOpen] = useState(false)
  const [blockDialogOpened, setBlockDialogOpened] = useState(false)
  const [blockingContact, setBlockingContact] = useState(false)
  
  const [gifQuery, setGifQuery] = useState('')
  const [gifResults, setGifResults] = useState<any[]>([])
  const [gifLoading, setGifLoading] = useState(false)
  const [gifError, setGifError] = useState<string | null>(null)
  const [gifHasMore, setGifHasMore] = useState(true)
  const [gifNextOffset, setGifNextOffset] = useState(0)
  
  const [recording, setRecording] = useState(false)
  const [recordingStarting, setRecordingStarting] = useState(false)
  const [recordingElapsedMs, setRecordingElapsedMs] = useState(0)
  const [recordingLevels, setRecordingLevels] = useState<number[]>(Array(32).fill(0.16))
  
  const threadBottom = useRef<HTMLElement | null>(null)
  
  const toastTimer = useRef<any>(undefined)
  const gifSearchTimer = useRef<any>(undefined)
  const recordingTimer = useRef<any>(undefined)
  
  const mediaRecorder = useRef<MediaRecorder | undefined>(undefined)
  const mediaStream = useRef<MediaStream | undefined>(undefined)
  const audioContext = useRef<AudioContext | undefined>(undefined)
  const analyser = useRef<AnalyserNode | undefined>(undefined)
  
  const recordingStartedAt = useRef(0)
  const recordingChunks = useRef<Blob[]>([])
  const recordingSamples = useRef<number[]>([])
  const recordingBytes = useRef(0)
  const discardRecording = useRef(false)
  const recordingRequestId = useRef(0)
  const hasSim = useMemo(() => Boolean(phone.device?.sim), [phone.device?.sim])
  
  const filteredConversations = useMemo(() => {
    const query = search.trim().toLocaleLowerCase(phone.lang)
    return messages.conversations
      .filter((conversation: any) => {
        if (showUnreadOnly && conversation.unread === 0) return false
        if (!query) return true
        return `${contactName(conversation.phoneNumber)} ${conversation.phoneNumber} ${conversationPreview(conversation)}`
          .toLocaleLowerCase(phone.lang)
          .includes(query)
      })
      .sort((left: any, right: any) => {
        const direction = conversationSort === 'newest' ? -1 : 1
        return (
          direction *
          (parseDatabaseDate(left.lastMessageAt).getTime() -
            parseDatabaseDate(right.lastMessageAt).getTime())
        )
      })
  }, [search, phone.lang, messages.conversations, showUnreadOnly, conversationSort])

  const knownContactNumbers = useMemo(
    () => new Set(calls.contacts.map((contact: any) => contact.phone_number)),
    [calls.contacts]
  )
  
  const contactAvatarUrls = useMemo(
    () =>
      new Map(
        calls.contacts
          .filter((contact: any) => Boolean(contact.avatar_url))
          .map((contact: any) => [contact.phone_number, contact.avatar_url as string]),
      ),
    [calls.contacts]
  )

  const contactSuggestions = useMemo(() => {
    const query = composerNumber.trim().toLocaleLowerCase(phone.lang)
    const contacts = sortContactsByMessageRecency(
      calls.contacts.filter((contact: any) => contact.canMessage !== false),
      messages.conversations,
    )
    if (!query) return contacts.slice(0, 8)
    return contacts
      .filter((contact: any) =>
        `${contact.name} ${contact.phone_number}`
          .toLocaleLowerCase(phone.lang)
          .includes(query),
      )
      .slice(0, 8)
  }, [composerNumber, phone.lang, calls.contacts, messages.conversations])

  const activeTitle = useMemo(() =>
    messages.activeNumber ? contactName(messages.activeNumber) : '',
    [messages.activeNumber]
  )

  const activeContact = useMemo(() =>
    calls.contacts.find(
      (contact: any) => contact.phone_number === messages.activeNumber,
    ),
    [calls.contacts, messages.activeNumber]
  )

  const activeCanMessage = useMemo(
    () => activeContact?.canMessage !== false,
    [activeContact]
  )

  const activeServiceLine = useMemo(
    () => activeContact?.source === 'company',
    [activeContact]
  )

  const activeContactEmail = useMemo(() =>
    normalizeMailAddress(activeContact?.email ?? ''),
    [activeContact]
  )

  const inboxMenuItems = useMemo(() => [
    {
      checked: conversationSort === 'newest',
      group: 'sort',
      groupLabel: phone.t('Apps.messages.sortLabel'),
      id: 'sort-newest',
      label: phone.t('Apps.messages.sortNewest'),
    },
    {
      checked: conversationSort === 'oldest',
      group: 'sort',
      groupLabel: phone.t('Apps.messages.sortLabel'),
      id: 'sort-oldest',
      label: phone.t('Apps.messages.sortOldest'),
    },
    {
      checked: !showUnreadOnly,
      group: 'filter',
      groupLabel: phone.t('Apps.messages.filterLabel'),
      id: 'filter-all',
      label: phone.t('Apps.messages.allMessages'),
      separatorBefore: true,
    },
    {
      checked: showUnreadOnly,
      group: 'filter',
      groupLabel: phone.t('Apps.messages.filterLabel'),
      id: 'filter-unread',
      label: phone.t('Apps.messages.unreadMessages'),
    },
    {
      id: 'edit',
      label: phone.t('Common.edit'),
      separatorBefore: true,
    },
  ], [conversationSort, showUnreadOnly, phone])

  const attachmentPanelOpen = useMemo(
    () =>
      emojiOpen ||
      (!activeServiceLine && attachmentPicker !== null),
    [emojiOpen, activeServiceLine, attachmentPicker]
  )

  const composerHasContent = useMemo(
    () =>
      Boolean(draft.trim()) ||
      (!activeServiceLine &&
        (Boolean(shareDraft) || pendingAttachments.length > 0)),
    [draft, activeServiceLine, shareDraft, pendingAttachments]
  )

  const gifColumns = useMemo(() => {
    const columns: [any[], any[]] = [[], []]
    const columnHeights = [0, 0]

    for (const gif of gifResults) {
      const columnIndex = columnHeights[0] <= columnHeights[1] ? 0 : 1
      columns[columnIndex].push(gif)
      columnHeights[columnIndex] +=
        Math.max(1, gif.height) / Math.max(1, gif.width)
    }

    return columns
  }, [gifResults])

  function contactName(number: string): string {
    return (
      calls.contacts.find((contact: any) => contact.phone_number === number)?.name ??
      number
    )
  }

  function conversationLabel(conversation: any): string {
    const name = contactName(conversation.phoneNumber)
    return conversation.unread > 0
      ? phone.t('Apps.messages.unreadConversation', {
          count: String(conversation.unread),
          name,
        })
      : name
  }

  function conversationPreview(conversation: any): string {
    if (conversation.lastMessageType === 'image') return `📷 ${phone.t('Apps.messages.photo')}`
    if (conversation.lastMessageType === 'gif') return `GIF ${phone.t('Apps.messages.gif')}`
    if (conversation.lastMessageType === 'video') return `▶️ ${phone.t('Apps.messages.video')}`
    if (conversation.lastMessageType === 'contact') return `👤 ${phone.t('Apps.messages.contact')}`
    if (conversation.lastMessageType === 'share') return `🔗 ${conversation.lastMessage}`
    return conversation.lastMessageType === 'voice'
      ? `🎙️ ${phone.t('Apps.messages.voiceMessage')}`
      : conversation.lastMessage
  }

  function contactInitials(number: string): string {
    const contact = calls.contacts.find((entry: any) => entry.phone_number === number)
    if (!contact) return ''
    return contact.name
      .split(/\s+/)
      .filter(Boolean)
      .slice(0, 2)
      .map((part: string) => part[0]?.toUpperCase())
      .join('')
  }
  function formatConversationDate(value: any): string {
    const date = parseDatabaseDate(value)
    if (Number.isNaN(date.getTime())) return String(value)
    const today = new Date()
    if (date.toDateString() === today.toDateString()) {
      return new Intl.DateTimeFormat(phone.lang, {
        hour: '2-digit',
        hourCycle: 'h23',
        minute: '2-digit',
      }).format(date)
    }
    const yesterday = new Date(today)
    yesterday.setDate(today.getDate() - 1)
    if (date.toDateString() === yesterday.toDateString()) {
      return phone.t('Apps.messages.yesterday')
    }
    const daysAgo = Math.floor((today.getTime() - date.getTime()) / 86_400_000)
    if (daysAgo < 7) {
      return new Intl.DateTimeFormat(phone.lang, { weekday: 'long' }).format(date)
    }
    return new Intl.DateTimeFormat(phone.lang, {
      day: 'numeric',
      month: 'numeric',
    }).format(date)
  }

  function dayLabel(value: any): string {
    const date = parseDatabaseDate(value)
    if (Number.isNaN(date.getTime())) return String(value)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(today.getDate() - 1)
    if (date.toDateString() === today.toDateString()) {
      return phone.t('Apps.messages.today')
    }
    if (date.toDateString() === yesterday.toDateString()) {
      return phone.t('Apps.messages.yesterday')
    }
    return new Intl.DateTimeFormat(phone.lang, {
      day: 'numeric',
      month: 'long',
      year: date.getFullYear() === today.getFullYear() ? undefined : 'numeric',
    }).format(date)
  }

  function timeLabel(value: any): string {
    const date = parseDatabaseDate(value)
    if (Number.isNaN(date.getTime())) return ''
    return new Intl.DateTimeFormat(phone.lang, {
      hour: '2-digit',
      hourCycle: 'h23',
      minute: '2-digit',
    }).format(date)
  }

  function formatRecordingTime(milliseconds: number): string {
    const seconds = Math.floor(milliseconds / 1000)
    return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`
  }

  function startsDay(message: any, index: number): boolean {
    if (index === 0) return true
    return (
      parseDatabaseDate(
        messages.messages[index - 1].created_at,
      ).toDateString() !== parseDatabaseDate(message.created_at).toDateString()
    )
  }

  function messageFooter(message: any, index: number): string | undefined {
    if (message.direction !== 'sent' || index !== messages.messages.length - 1) {
      return undefined
    }
    if (message.delivery_status === 'sending') {
      return phone.t('Apps.messages.sending')
    }
    if (message.delivery_status === 'failed') {
      return phone.t('Apps.messages.notDelivered')
    }
    return phone.t('Apps.messages.delivered')
  }

  function showToast(message: string): void {
    if (toastTimer.current) clearTimeout(toastTimer.current)
    setToastText(message)
    setToastOpened(true)
    toastTimer.current = setTimeout(() => setToastOpened(false), 2800)
  }

  function errorText(error?: string): string {
    const known = [
      'invalid_number', 'invalid_message', 'invalid_voice', 'invalid_attachment',
      'invalid_contact', 'contact_not_found', 'media_provider_unconfigured',
      'capture_provider_unavailable', 'capture_failed', 'gif_provider_unconfigured',
      'gif_provider_unauthorized', 'gif_provider_rate_limited', 'gif_provider_failed',
      'self_message', 'recipient_not_found', 'messaging_unavailable',
      'service_line_text_only', 'no_sim', 'rate_limited', 'blocked', 'request_failed',
    ]
    return phone.t(
      `Apps.messages.errors.${error && known.includes(error) ? error : 'default'}`,
    )
  }

  const scrollToBottom = useCallback(async (animate = true) => {
    await new Promise((r) => requestAnimationFrame(r))
    threadBottom.current?.scrollIntoView({
      block: 'end',
      behavior: animate ? 'smooth' : 'auto',
    })
  }, [])
  async function openConversation(conversation: any): Promise<void> {
    if (editingList) {
      if (selectedNumbers.includes(conversation.phoneNumber)) {
        setSelectedNumbers(prev => prev.filter(n => n !== conversation.phoneNumber))
      } else {
        setSelectedNumbers(prev => [...prev, conversation.phoneNumber])
      }
      return
    }
    if (!(await messages.openThread(conversation.phoneNumber))) {
      showToast(errorText())
      return
    }
    setComposing(false)
    setShareDraft(queuedSharePayload)
    setQueuedSharePayload(null)
    await scrollToBottom(false)
  }

  const openEasyShareDraft = useCallback(async () => {
    const shared = easyShare.consumeChatDraft('messages')
    if (!shared) return
    if (!shared.targetId) {
      messages.closeThread()
      setComposing(false)
      setQueuedSharePayload(shared.payload)
      setDraft('')
      return
    }
    if (!(await messages.openThread(shared.targetId))) {
      showToast(errorText('invalid_number'))
      return
    }
    setComposing(false)
    setQueuedSharePayload(null)
    setShareDraft(shared.payload)
    setDraft('')
    await scrollToBottom(false)
  }, [easyShare, messages, scrollToBottom])

  function toggleListEditing(): void {
    setEditingList(prev => !prev)
    setSelectedNumbers([])
    setInboxMenuOpened(false)
  }

  function openInboxMenu(event: any): void {
    setInboxMenuTarget(event.currentTarget)
    setInboxMenuOpened(true)
  }
  
  function dismissInboxMenu(): void {
    setInboxMenuOpened(false)
  }

  function selectInboxMenuItem(id: string): void {
    dismissInboxMenu()
    if (id === 'sort-newest' || id === 'sort-oldest') {
      setConversationSort(id === 'sort-newest' ? 'newest' : 'oldest')
      return
    }
    if (id === 'filter-all' || id === 'filter-unread') {
      setShowUnreadOnly(id === 'filter-unread')
      return
    }
    if (id === 'edit') toggleListEditing()
  }

  async function deleteSelectedConversations(): Promise<void> {
    if (!selectedNumbers.length) return
    const deleted = await messages.deleteConversations(selectedNumbers)
    if (!deleted) {
      showToast(errorText())
      return
    }
    setEditingList(false)
    setSelectedNumbers([])
  }

  function beginCompose(): void {
    messages.closeThread()
    setComposing(true)
    setComposerNumber('')
    setDraft('')
    setPendingAttachments([])
  }

  async function chooseRecipient(number: string): Promise<void> {
    const contact = calls.contacts.find(
      (candidate: any) => candidate.phone_number === number,
    )
    if (contact?.canMessage === false) {
      showToast(phone.t('Apps.messages.messagingUnavailable'))
      return
    }
    setComposerNumber(number)
    if (!(await messages.openThread(number))) {
      showToast(errorText('invalid_number'))
      return
    }
    setComposing(false)
    setShareDraft(queuedSharePayload)
    setQueuedSharePayload(null)
    await scrollToBottom(false)
  }

  function goBack(): void {
    if (contactDetailsOpen) {
      setContactDetailsOpen(false)
      return
    }
    cancelVoiceRecording()
    if (messages.activeNumber) messages.closeThread()
    setComposing(false)
    setComposerNumber('')
    setDraft('')
    setShareDraft(null)
    setPendingAttachments([])
    setEmojiOpen(false)
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
  }

  function appendEmoji(emoji: string): void {
    setDraft(prev => prev + emoji)
  }

  function openContactDetails(): void {
    if (!messages.activeNumber) return
    setContactDetailsOpen(true)
  }

  async function openActiveContactInPhone(): Promise<void> {
    if (!messages.activeNumber) return
    await router.push({
      path: '/apps/phone',
      query: activeContact
        ? { contactId: activeContact.id }
        : { newContactNumber: messages.activeNumber },
    })
  }

  async function mailActiveContact(): Promise<void> {
    if (!activeContactEmail) return
    await router.push({
      path: '/apps/mail',
      query: { compose: '1', to: activeContactEmail },
    })
  }
  function confirmBlockActiveContact(): void {
    if (!messages.activeNumber) return
    setBlockDialogOpened(true)
  }

  async function blockActiveContact(): Promise<void> {
    if (!messages.activeNumber || blockingContact) return
    setBlockingContact(true)
    const response = await calls.blockNumber(messages.activeNumber)
    setBlockingContact(false)
    if (!response.success) {
      showToast(phone.t('Apps.messages.blockContactFailed'))
      return
    }
    setBlockDialogOpened(false)
    setContactDetailsOpen(false)
    messages.closeThread()
    await messages.loadConversations()
    showToast(phone.t('Apps.messages.contactBlocked'))
  }

  async function callActiveContact(): Promise<void> {
    if (!messages.activeNumber || activeContact?.canCall === false) return
    const response = await calls.dial(messages.activeNumber)
    if (!response.success) showToast(phone.t('Apps.messages.callFailed'))
  }

  function toggleAttachmentMenu(): void {
    if (activeServiceLine) return
    setAttachmentMenuOpen(prev => !prev)
    setEmojiOpen(false)
    setAttachmentPicker(null)
  }

  function openGifPicker(): void {
    setAttachmentMenuOpen(false)
    setAttachmentPicker('gifs')
    setEmojiOpen(false)
    if (!gifResults.length) void loadGifs(true)
  }

  function openContactPicker(): void {
    setAttachmentMenuOpen(false)
    setAttachmentPicker('contacts')
    setEmojiOpen(false)
  }

  function closeAttachmentPicker(): void {
    setAttachmentPicker(null)
  }

  function openEmojiPicker(): void {
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
    setEmojiOpen(true)
  }

  function openMediaApp(app: 'camera' | 'photos', mediaType: 'photo' | 'video'): void {
    if (!messages.activeNumber || activeServiceLine) return
    const remainingSlots = MAX_PENDING_ATTACHMENTS - pendingAttachments.length
    if (remainingSlots < 1) {
      showToast(
        phone.t('Apps.messages.attachmentLimit', {
          count: String(MAX_PENDING_ATTACHMENTS),
        }),
      )
      return
    }
    setAttachmentMenuOpen(false)
    messageMedia.begin(
      messages.activeNumber,
      mediaType,
      '/apps/messages',
      app === 'photos' && mediaType === 'photo' ? remainingSlots : 1,
      {
        draft,
        pendingAttachments: [...pendingAttachments],
        shareDraft,
      } as MessagesMediaContext,
    )
    void router.push({
      path: `/apps/${app}`,
      query: { messageAttachment: mediaType },
    })
  }

  function removePendingAttachment(id: number): void {
    if (sending) return
    setPendingAttachments(prev => prev.filter(media => media.id !== id))
  }

  function restoreMediaSelection(selection: any | null): void {
    if (!selection) return
    setDraft(selection.context?.draft ?? '')
    setShareDraft(selection.context?.shareDraft ?? null)
    const combined = [
      ...(selection.context?.pendingAttachments ?? []),
      ...selection.media,
    ]
    const seen = new Set<number>()
    setPendingAttachments(
      combined
        .filter((media) => {
          if (seen.has(media.id)) return false
          seen.add(media.id)
          return true
        })
        .slice(0, MAX_PENDING_ATTACHMENTS)
    )
  }
  async function sendAttachment(messageType: SmsAttachmentType, mediaAssetId: string, mediaDurationMs?: number): Promise<void> {
    if (!messages.activeNumber || !activeCanMessage || activeServiceLine || sending) {
      return
    }
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
    setSending(true)
    const response = await messages.send({
      mediaAssetId,
      mediaDurationMs,
      messageType,
    })
    setSending(false)
    if (!response.success) showToast(errorText(response.error))
    await scrollToBottom()
  }

  async function sendContact(contact: PhoneContact): Promise<void> {
    if (!messages.activeNumber || activeServiceLine || sending) return
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
    setSending(true)
    const response = await messages.send({
      contact: {
        avatar_url: contact.avatar_url ?? null,
        name: contact.name,
        organization: contact.organization ?? null,
        phone_number: contact.phone_number,
      },
      contactId: contact.id,
      messageType: 'contact',
    })
    setSending(false)
    if (!response.success) showToast(errorText(response.error))
    await scrollToBottom()
  }

  async function messageSharedContact(contact: SmsSharedContact): Promise<void> {
    if (!(await messages.openThread(contact.phone_number))) {
      showToast(errorText('invalid_number'))
      return
    }
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
    setEmojiOpen(false)
    await scrollToBottom(false)
  }

  async function saveSharedContact(contact: SmsSharedContact): Promise<void> {
    if (knownContactNumbers.has(contact.phone_number)) return
    const response = await calls.saveContact({
      name: contact.name,
      organization: contact.organization ?? '',
      phoneNumber: contact.phone_number,
    })
    showToast(
      response.success
        ? phone.t('Apps.messages.contactSaved')
        : phone.t('Apps.messages.contactSaveFailed'),
    )
  }

  async function loadGifs(reset = false): Promise<void> {
    if (gifLoading || (!reset && !gifHasMore)) return
    setGifError(null)
    setGifLoading(true)
    const response = await messages.searchGifs(
      gifQuery,
      reset ? 0 : gifNextOffset,
    )
    setGifLoading(false)
    if (!response.success || !response.data) {
      if (reset) setGifResults([])
      setGifError(response.error ?? 'gif_provider_failed')
      showToast(errorText(response.error))
      return
    }
    const existingIds = new Set(
      reset ? [] : gifResults.map((result: any) => result.id),
    )
    const uniqueResults = response.data.results.filter((result: any) => {
      if (existingIds.has(result.id)) return false
      existingIds.add(result.id)
      return true
    })
    setGifResults(reset ? uniqueResults : [...gifResults, ...uniqueResults])
    setGifHasMore(response.data.hasMore)
    setGifNextOffset(response.data.nextOffset)
  }

  function queueGifSearch(): void {
    if (gifSearchTimer.current) clearTimeout(gifSearchTimer.current)
    gifSearchTimer.current = setTimeout(() => void loadGifs(true), 320)
  }

  async function sendTextMessage(): Promise<void> {
    if (!messages.activeNumber || !activeCanMessage || !composerHasContent || sending) {
      return
    }
    const body = draft
    const shared = shareDraft
    const queuedAttachments = [...pendingAttachments]
    setEmojiOpen(false)
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
    setSending(true)
    await scrollToBottom()
    let sendError: string | undefined
    for (let index = 0; index < queuedAttachments.length; index++) {
      const media = queuedAttachments[index]
      const response = await messages.send(
        {
          body: !shared && index === queuedAttachments.length - 1 ? body : undefined,
          mediaAssetId: String(media.id),
          messageType: media.mediaType === 'photo' ? 'image' : 'video',
        },
        { discardFailedOptimistic: true },
      )
      if (!response.success) {
        sendError = response.error ?? 'request_failed'
        break
      }
      setPendingAttachments(prev => prev.filter(pending => pending.id !== media.id))
    }

    if (!sendError && shared) {
      const response = await messages.send({
        body,
        messageType: 'share',
        sharePayload: shared,
      })
      if (!response.success) sendError = response.error ?? 'request_failed'
    } else if (!sendError && queuedAttachments.length === 0) {
      const response = await messages.send({ body, messageType: 'text' })
      if (!response.success) sendError = response.error ?? 'request_failed'
    }

    setSending(false)
    if (sendError) {
      showToast(errorText(sendError))
    } else {
      setDraft('')
      setShareDraft(null)
    }
    await scrollToBottom()
  }

  function recordingMime(): string | null {
    if (MediaRecorder.isTypeSupported('audio/webm;codecs=opus')) {
      return 'audio/webm;codecs=opus'
    }
    if (MediaRecorder.isTypeSupported('audio/webm')) return 'audio/webm'
    return null
  }

  const sampleMicrophone = useCallback(() => {
    if (!analyser.current) return
    const values = new Uint8Array(analyser.current.fftSize)
    analyser.current.getByteTimeDomainData(values)
    let total = 0
    for (const value of values) total += Math.abs(value - 128) / 128
    const level = Math.max(0.08, Math.min(1, (total / values.length) * 4.5))
    recordingSamples.current.push(level)
    setRecordingLevels(prev => [...prev.slice(1), level])
    setRecordingElapsedMs(performance.now() - recordingStartedAt.current)
    if (performance.now() - recordingStartedAt.current >= VOICE_MAX_DURATION_MS) {
      stopVoiceRecording()
    }
  }, [])

  async function startVoiceRecording(): Promise<void> {
    if (!activeCanMessage || activeServiceLine || recording || recordingStarting) {
      return
    }
    setEmojiOpen(false)
    if (!navigator.mediaDevices?.getUserMedia || typeof MediaRecorder === 'undefined') {
      showToast(phone.t('Apps.messages.microphoneUnavailable'))
      return
    }
    const mime = recordingMime()
    if (!mime) {
      showToast(phone.t('Apps.messages.microphoneUnavailable'))
      return
    }
    recordingRequestId.current += 1
    const requestId = recordingRequestId.current
    setRecordingStarting(true)
    let requestedStream: MediaStream | undefined
    try {
      requestedStream = await navigator.mediaDevices.getUserMedia({
        audio: {
          autoGainControl: true,
          echoCancellation: true,
          noiseSuppression: true,
        },
      })
      if (requestId !== recordingRequestId.current) {
        requestedStream.getTracks().forEach((track) => track.stop())
        return
      }
      mediaStream.current = requestedStream
      requestedStream = undefined
      recordingChunks.current = []
      recordingSamples.current = []
      recordingBytes.current = 0
      discardRecording.current = false
      mediaRecorder.current = new MediaRecorder(mediaStream.current, {
        audioBitsPerSecond: 24_000,
        mimeType: mime,
      })
      mediaRecorder.current.addEventListener('dataavailable', (event) => {
        if (!event.data.size) return
        recordingChunks.current.push(event.data)
        recordingBytes.current += event.data.size
        if (recordingBytes.current > VOICE_MAX_BYTES) stopVoiceRecording()
      })
      mediaRecorder.current.addEventListener('stop', () => void finishVoiceRecording())
      audioContext.current = new window.AudioContext()
      analyser.current = audioContext.current!.createAnalyser()
      analyser.current.fftSize = 128
      audioContext.current!.createMediaStreamSource(mediaStream.current).connect(analyser.current)
      recordingStartedAt.current = performance.now()
      setRecordingElapsedMs(0)
      setRecordingLevels(Array(32).fill(0.16))
      setRecording(true)
      mediaRecorder.current.start(250)
      recordingTimer.current = setInterval(sampleMicrophone, 100)
    } catch (error) {
      requestedStream?.getTracks().forEach((track) => track.stop())
      if (requestId !== recordingRequestId.current) return
      console.error('[Messages] Could not start audio recording:', error)
      cleanupRecorder()
      showToast(phone.t('Apps.messages.microphoneUnavailable'))
    } finally {
      if (requestId === recordingRequestId.current) setRecordingStarting(false)
    }
  }

  function stopVoiceRecording(): void {
    if (!mediaRecorder.current || mediaRecorder.current.state === 'inactive') return
    mediaRecorder.current.stop()
  }

  function cancelVoiceRecording(): void {
    discardRecording.current = true
    if (mediaRecorder.current && mediaRecorder.current.state !== 'inactive') mediaRecorder.current.stop()
    else cleanupRecorder()
  }

  function cleanupRecorder(): void {
    recordingRequestId.current += 1
    setRecordingStarting(false)
    if (recordingTimer.current) clearInterval(recordingTimer.current)
    recordingTimer.current = undefined
    mediaStream.current?.getTracks().forEach((track) => track.stop())
    void audioContext.current?.close()
    mediaRecorder.current = undefined
    mediaStream.current = undefined
    audioContext.current = undefined
    analyser.current = undefined
    setRecording(false)
  }

  function compressedWaveform(): number[] {
    return compressWaveformSamples(recordingSamples.current, WAVEFORM_SAMPLES)
  }

  async function blobBase64(blob: Blob): Promise<string> {
    const buffer = await blob.arrayBuffer()
    const bytes = new Uint8Array(buffer)
    let binary = ''
    for (let offset = 0; offset < bytes.length; offset += 0x8000) {
      binary += String.fromCharCode(...bytes.subarray(offset, offset + 0x8000))
    }
    return btoa(binary)
  }
  async function finishVoiceRecording(): Promise<void> {
    const duration = Math.min(
      VOICE_MAX_DURATION_MS,
      Math.max(300, performance.now() - recordingStartedAt.current),
    )
    const mime = mediaRecorder.current?.mimeType ?? 'audio/webm'
    const chunks = recordingChunks.current
    const waveform = compressedWaveform()
    const shouldDiscard = discardRecording.current
    cleanupRecorder()
    if (shouldDiscard || !activeCanMessage) return
    const blob = new Blob(chunks, { type: mime })
    if (!blob.size || blob.size > VOICE_MAX_BYTES) {
      showToast(phone.t('Apps.messages.recordingTooLarge'))
      return
    }
    const payload = await blobBase64(blob)
    setSending(true)
    const response = await messages.send({
      mediaDurationMs: Math.floor(duration),
      mediaMime: mime,
      mediaPayload: payload,
      mediaWaveform: waveform,
      messageType: 'voice',
    })
    setSending(false)
    if (!response.success) showToast(errorText(response.error))
    await scrollToBottom()
  }

  useEffect(() => {
    async function init() {
      await Promise.all([messages.loadConversations(), calls.loadContacts()])
      await openEasyShareDraft()
      if (messages.activeNumber) {
        restoreMediaSelection(
          messageMedia.consumeMany(messages.activeNumber),
        )
        await scrollToBottom(false)
      }
    }
    init()
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (easyShare.chatDraft?.appId === 'messages') void openEasyShareDraft()
  }, [easyShare.chatDraft, openEasyShareDraft])

  useEffect(() => {
    if (!activeServiceLine) return
    const discarded = Boolean(
      shareDraft || pendingAttachments.length || recording || recordingStarting
    )
    setAttachmentMenuOpen(false)
    setAttachmentPicker(null)
    setShareDraft(null)
    setPendingAttachments([])
    if (recording) {
      discardRecording.current = true
      cancelVoiceRecording()
    } else if (recordingStarting) {
      cleanupRecorder()
    }
    if (discarded) showToast(errorText('service_line_text_only'))
  }, [activeServiceLine]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    return () => {
      discardRecording.current = true
      cleanupRecorder()
      if (toastTimer.current) clearTimeout(toastTimer.current)
      if (gifSearchTimer.current) clearTimeout(gifSearchTimer.current)
    }
  }, [])

  return (
    <>
      {!hasSim ? (
        <SkyAppPage
          className="messages-sky-page"
          label={phone.t('Apps.messages.name')}
          dark={phone.isDarkMode}
          accent="#34c759"
          accent-soft="rgba(52, 199, 89, 0.16)"
        >
          <SkyNavbar variant="large" title={phone.t('Apps.messages.name')} />
          <SkyScrollArea padded className="messages-sky-state-scroll">
            <SkyEmptyState
              title={phone.t('Apps.messages.noSim')}
              body={phone.t('Apps.messages.noSimBody')}
              icon={<MessageCircle size={35} />}
            />
          </SkyScrollArea>
        </SkyAppPage>
      ) : !messages.activeNumber && !composing ? (
        <SkyAppPage
          className="messages-sky-page messages-sky-inbox"
          label={phone.t('Apps.messages.name')}
          dark={phone.isDarkMode}
          accent="#34c759"
          accent-soft="rgba(52, 199, 89, 0.16)"
        >
          <SkyNavbar
            variant="large"
            title={
              editingList
                ? phone.t('Apps.messages.selectedCount', {
                    count: String(selectedNumbers.length),
                  })
                : phone.t('Apps.messages.name')
            }
            right={
              editingList ? (
                <SkyLink className="messages-sky-edit" onClick={toggleListEditing}>
                  {phone.t('Common.done')}
                </SkyLink>
              ) : (
                <SkyLink
                  icon-only
                  className="messages-sky-inbox-menu-trigger"
                  aria-haspopup="menu"
                  aria-expanded={inboxMenuOpened}
                  aria-controls="messages-inbox-menu"
                  aria-label={phone.t('Apps.messages.inboxActions')}
                  onClick={openInboxMenu}
                >
                  <Ellipsis size={22} />
                </SkyLink>
              )
            }
          />
          <SkyScrollArea
            padded
            with-tabbar={editingList}
            className="messages-sky-inbox-scroll"
          >
            {filteredConversations.length ? (
              <SkyList flush className="messages-sky-conversation-list">
                {filteredConversations.map((conversation: any) => (
                  <SkyListItem
                    key={conversation.phoneNumber}
                    link
                    link-component="button"
                    chevron={false}
                    active={selectedNumbers.includes(conversation.phoneNumber)}
                    link-props={
                      editingList
                        ? {
                            'aria-pressed': selectedNumbers.includes(
                              conversation.phoneNumber,
                            ),
                          }
                        : {}
                    }
                    aria-label={conversationLabel(conversation)}
                    className={`messages-sky-conversation ${conversation.unread > 0 ? 'messages-sky-conversation--unread' : ''}`}
                    onClick={() => openConversation(conversation)}
                    media={
                      <span className="messages-conversation-media" aria-hidden="true">
                        <span
                          className={`messages-sky-unread-slot ${!editingList && conversation.unread > 0 ? 'is-visible' : ''}`}
                        />
                        <span
                          className={`messages-avatar ${!knownContactNumbers.has(conversation.phoneNumber) ? 'messages-avatar--unknown' : ''}`}
                        >
                          {contactAvatarUrls.get(conversation.phoneNumber) ? (
                            <img
                              className="messages-avatar__image"
                              src={contactAvatarUrls.get(conversation.phoneNumber)}
                              alt=""
                            />
                          ) : knownContactNumbers.has(conversation.phoneNumber) ? (
                            <span className="messages-avatar__initials">
                              {contactInitials(conversation.phoneNumber)}
                            </span>
                          ) : (
                            <span className="messages-avatar__placeholder">
                              <i />
                              <b />
                            </span>
                          )}
                          {editingList && (
                            <span
                              className={`messages-sky-selection ${selectedNumbers.includes(conversation.phoneNumber) ? 'is-selected' : ''}`}
                            >
                              {selectedNumbers.includes(conversation.phoneNumber) && (
                                <Check size={13} />
                              )}
                            </span>
                          )}
                        </span>
                      </span>
                    }
                    title={contactName(conversation.phoneNumber)}
                    after={
                      <span className="messages-sky-conversation-time">
                        <time>{formatConversationDate(conversation.lastMessageAt)}</time>
                        <ChevronRight size={15} />
                      </span>
                    }
                    subtitle={conversationPreview(conversation)}
                  />
                ))}
              </SkyList>
            ) : (
              <SkyEmptyState
                className="messages-sky-empty"
                title={phone.t(
                  search || showUnreadOnly
                    ? 'Apps.messages.noResults'
                    : 'Apps.messages.noMessages',
                )}
                body={
                  search || showUnreadOnly
                    ? ''
                    : phone.t('Apps.messages.noMessagesBody')
                }
                icon={<MessageCircle size={32} />}
                actions={
                  !search && !showUnreadOnly ? (
                    <SkyButton rounded onClick={beginCompose}>
                      {phone.t('Apps.messages.compose')}
                    </SkyButton>
                  ) : null
                }
              />
            )}
          </SkyScrollArea>

          {!editingList && (
            <SkyToolbar
              className="messages-sky-inbox-toolbar"
              component="footer"
              aria-label={phone.t('Apps.messages.search')}
            >
              <SkySearchbar
                value={search}
                onInput={(e: any) => setSearch(e.target.value)}
                className="messages-sky-search"
                label={phone.t('Apps.messages.search')}
                placeholder={phone.t('Apps.messages.search')}
                clear-label={phone.t('Common.clear')}
              />
              <SkyFab
                variant="glass"
                aria-label={phone.t('Apps.messages.compose')}
                onClick={beginCompose}
                icon={<SquarePen size={21} />}
              />
            </SkyToolbar>
          )}

          {editingList && (
            <SkyPillNavigation
              layout="compact"
              align="center"
              className="messages-sky-edit-navigation"
              label={phone.t('Apps.messages.deleteSelected')}
            >
              <SkyButton
                rounded
                variant="danger"
                disabled={!selectedNumbers.length}
                onClick={deleteSelectedConversations}
              >
                <Trash2 size={18} />
                {phone.t('Apps.messages.deleteSelected')}
              </SkyButton>
            </SkyPillNavigation>
          )}

          <SkyDropdown
            id="messages-inbox-menu"
            items={inboxMenuItems}
            label={phone.t('Apps.messages.inboxActions')}
            opened={inboxMenuOpened}
            target={inboxMenuTarget}
            onBackdropclick={dismissInboxMenu}
            onEscape={dismissInboxMenu}
            onPositionerror={dismissInboxMenu}
            onSelect={(e: any) => selectInboxMenuItem(e.detail)}
          />
        </SkyAppPage>
      ) : composing ? (
        <SkyAppPage
          className="messages-sky-page messages-sky-compose"
          label={phone.t('Apps.messages.compose')}
          dark={phone.isDarkMode}
          accent="#34c759"
          accent-soft="rgba(52, 199, 89, 0.16)"
        >
          <SkyNavbar
            title={phone.t('Apps.messages.compose')}
            right={
              <SkyLink onClick={goBack}>
                {phone.t('Common.cancel')}
              </SkyLink>
            }
          />
          <SkyScrollArea padded className="messages-sky-compose-scroll">
            <SkyList className="messages-recipient-field" density="compact" flush>
              <SkyField
                value={composerNumber}
                onInput={(e: any) => setComposerNumber(e.target.value)}
                label={phone.t('Apps.messages.to')}
                layout="inline"
                input-mode="tel"
                type="tel"
                clear-button={true}
                clear-label={phone.t('Common.clear')}
                onClear={() => setComposerNumber('')}
                onKeyDown={(e: any) => { if (e.key === 'Enter') chooseRecipient(composerNumber) }}
              />
            </SkyList>
            {contactSuggestions.length ? (
              <SkyList className="messages-contact-list" flush>
                {contactSuggestions.map((contact: any) => (
                  <SkyListItem
                    key={contact.id}
                    link
                    link-component="button"
                    strong-title="auto"
                    title={contact.name}
                    subtitle={contact.phone_number}
                    onClick={() => chooseRecipient(contact.phone_number)}
                    media={
                      <span className="messages-avatar messages-avatar--small">
                        {contact.avatar_url ? (
                          <img
                            className="messages-avatar__image"
                            src={contact.avatar_url}
                            alt=""
                          />
                        ) : (
                          <span className="messages-avatar__initials">
                            {contactInitials(contact.phone_number)}
                          </span>
                        )}
                      </span>
                    }
                  />
                ))}
              </SkyList>
            ) : messages.loading ? (
              <div className="messages-sky-loading">
                <SkySpinner label={phone.t('Common.loading')} />
              </div>
            ) : composerNumber.trim() ? (
              <SkyButton
                rounded
                tonal
                className="messages-number-action"
                onClick={() => chooseRecipient(composerNumber)}
              >
                <MessageCircle size={17} />
                {composerNumber}
              </SkyButton>
            ) : null}
          </SkyScrollArea>
        </SkyAppPage>
      ) : (
        <SkyAppPage
          className={`messages-sky-page messages-sky-thread ${attachmentPanelOpen ? 'messages-sky-thread--panel' : ''} ${shareDraft ? 'messages-sky-thread--share' : ''}`}
          label={activeTitle}
          dark={phone.isDarkMode}
          accent="#34c759"
          accent-soft="rgba(52, 199, 89, 0.16)"
        >
          <SkyNavbar
            className="messages-sky-thread-navbar"
            aria-hidden={contactDetailsOpen}
            inert={contactDetailsOpen || undefined}
            title={
              <button
                type="button"
                className="messages-sky-thread-contact"
                aria-label={phone.t('Apps.messages.contactDetails')}
                onClick={openContactDetails}
              >
                <span
                  className={`messages-avatar messages-avatar--thread ${!activeContact ? 'messages-avatar--unknown' : ''}`}
                >
                  {activeContact?.avatar_url ? (
                    <img
                      className="messages-avatar__image"
                      src={activeContact.avatar_url}
                      alt=""
                    />
                  ) : activeContact ? (
                    <span className="messages-avatar__initials">
                      {contactInitials(messages.activeNumber ?? '')}
                    </span>
                  ) : (
                    <span className="messages-avatar__placeholder" aria-hidden="true">
                      <i />
                      <b />
                    </span>
                  )}
                </span>
                <span>{activeTitle}</span>
                <ChevronRight size={13} />
              </button>
            }
            show-back
            back-appearance="surface"
            back-label={phone.t('Common.back')}
            onBack={goBack}
          />
          {contactDetailsOpen && (
            <SkyAppPage
              className="messages-contact-overlay"
              component="section"
              label={phone.t('Apps.messages.contactDetails')}
              dark={phone.isDarkMode}
              accent="#34c759"
              accent-soft="rgba(52, 199, 89, 0.16)"
            >
              <SkyNavbar
                title={phone.t('Apps.messages.contactDetails')}
                show-back
                back-appearance="surface"
                back-label={phone.t('Common.back')}
                onBack={() => setContactDetailsOpen(false)}
              />
              <SkyScrollArea padded className="messages-contact-overlay__scroll">
                <div className="messages-contact-profile__hero">
                  <span
                    className={`messages-avatar messages-avatar--contact ${!activeContact ? 'messages-avatar--unknown' : ''}`}
                  >
                    {activeContact?.avatar_url ? (
                      <img
                        className="messages-avatar__image"
                        src={activeContact.avatar_url}
                        alt=""
                      />
                    ) : activeContact ? (
                      <span className="messages-avatar__initials">
                        {contactInitials(messages.activeNumber ?? '')}
                      </span>
                    ) : (
                      <span className="messages-avatar__placeholder" aria-hidden="true">
                        <i />
                        <b />
                      </span>
                    )}
                  </span>
                  <h2>{activeTitle}</h2>
                  {activeContact?.readonly && (
                    <small>{phone.t('Apps.phone.officialContact')}</small>
                  )}
                </div>
                <div className="messages-contact-profile__actions">
                  {activeContact?.canCall !== false && (
                    <SkyButton
                      icon-only
                      rounded
                      tonal
                      aria-label={phone.t('Apps.messages.call')}
                      onClick={callActiveContact}
                    >
                      <PhoneIcon size={22} />
                    </SkyButton>
                  )}
                  {activeCanMessage && (
                    <SkyButton
                      icon-only
                      rounded
                      tonal
                      aria-label={phone.t('Apps.messages.messageAction')}
                      onClick={() => setContactDetailsOpen(false)}
                    >
                      <MessageCircle size={22} />
                    </SkyButton>
                  )}
                  {activeContactEmail && (
                    <SkyButton
                      icon-only
                      rounded
                      tonal
                      aria-label={phone.t('Apps.phone.mail')}
                      onClick={mailActiveContact}
                    >
                      <Mail size={22} />
                    </SkyButton>
                  )}
                </div>
                <SkySettingsGroup
                  className="messages-contact-profile__details"
                  title={phone.t('Apps.messages.details')}
                >
                  <SkySettingsRow
                    title={phone.t('Apps.phone.mobile')}
                    value={messages.activeNumber ?? ''}
                  />
                  {activeContact?.organization && (
                    <SkySettingsRow
                      title={phone.t('Apps.messages.company')}
                      value={activeContact.organization}
                    />
                  )}
                  {activeContactEmail && (
                    <SkySettingsRow
                      title={phone.t('Apps.phone.mail')}
                      value={activeContactEmail}
                    />
                  )}
                  {activeContact?.notes && (
                    <SkySettingsRow
                      title={phone.t('Apps.phone.notes')}
                      description={activeContact.notes}
                    />
                  )}
                </SkySettingsGroup>
                <SkySettingsGroup
                  className="messages-contact-profile__options"
                  aria-label={phone.t('Apps.messages.contactActions')}
                >
                  <SkySettingsRow
                    kind="navigation"
                    title={phone.t(
                      activeContact
                        ? 'Apps.messages.showInContacts'
                        : 'Apps.messages.addContact',
                    )}
                    onActivate={openActiveContactInPhone}
                    leading={<ContactRound size={20} />}
                  />
                  <SkySettingsRow
                    kind="action"
                    tone="danger"
                    title={phone.t('Apps.messages.blockContact')}
                    onActivate={confirmBlockActiveContact}
                    leading={<Ban size={20} />}
                  />
                </SkySettingsGroup>
              </SkyScrollArea>
            </SkyAppPage>
          )}

          <SkyScrollArea
            padded
            className="messages-sky-thread-scroll"
            aria-hidden={contactDetailsOpen}
            inert={contactDetailsOpen || undefined}
          >
            <SkyMessages className="messages-bubbles">
              {messages.messages.map((message: any, index: number) => (
                <React.Fragment key={message.client_id ?? message.id}>
                  {startsDay(message, index) && (
                    <SkyMessagesTitle>
                      <span className="messages-thread-timestamp">
                        <span>{phone.t('Apps.messages.smsLabel')}</span>
                        <b>{dayLabel(message.created_at)}, {timeLabel(message.created_at)}</b>
                      </span>
                    </SkyMessagesTitle>
                  )}
                  <SkyMessage
                    className={`${message.delivery_status === 'sending' ? 'messages-message--sending' : ''} ${message.delivery_status === 'failed' ? 'messages-message--failed' : ''}`}
                    type={message.direction}
                    text={message.message_type === 'text' ? message.body : undefined}
                    text-footer={messageFooter(message, index)}
                  >
                    {message.message_type !== 'text' && (
                      message.message_type === 'voice' ? (
                        <VoiceMessageBubble message={message} />
                      ) : message.message_type === 'contact' && message.contact ? (
                        <MessageContactBubble
                          add-label={phone.t('Apps.messages.addContact')}
                          contact={message.contact}
                          message-label={phone.t('Apps.messages.messageAction')}
                          saved={knownContactNumbers.has(message.contact.phone_number)}
                          saved-label={phone.t('Apps.messages.contactSaved')}
                          onMessage={() => messageSharedContact(message.contact)}
                          onSave={() => saveSharedContact(message.contact)}
                        />
                      ) : message.message_type === 'share' && message.share ? (
                        <SharedContentCard
                          payload={message.share}
                          variant="messages"
                        />
                      ) : (
                        <MessageAttachmentBubble message={message} />
                      )
                    )}
                  </SkyMessage>
                </React.Fragment>
              ))}
            </SkyMessages>
            <span
              ref={threadBottom}
              className="messages-thread-bottom"
              aria-hidden="true"
            />
          </SkyScrollArea>
          {activeCanMessage && !activeServiceLine && attachmentMenuOpen && (
            <section
              className="messages-attachment-menu"
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
            >
              <SkyGlass
                component="button"
                type="button"
                onClick={() => openMediaApp('photos', 'photo')}
              >
                <span><Images size={20} /></span>
                {phone.t('Apps.messages.attachPhoto')}
              </SkyGlass>
              <SkyGlass
                component="button"
                type="button"
                onClick={() => openMediaApp('camera', 'photo')}
              >
                <span><Camera size={20} /></span>
                {phone.t('Apps.messages.takePhoto')}
              </SkyGlass>
              <SkyGlass component="button" type="button" onClick={openEmojiPicker}>
                <span className="messages-action-emoji">😀</span>
                {phone.t('Apps.messages.emoji')}
              </SkyGlass>
              <SkyGlass component="button" type="button" onClick={openContactPicker}>
                <span><ContactRound size={20} /></span>
                {phone.t('Apps.messages.shareContact')}
              </SkyGlass>
              <SkyGlass component="button" type="button" onClick={openGifPicker}>
                <span><ImagePlay size={20} /></span>
                {phone.t('Apps.messages.attachGif')}
              </SkyGlass>
              <SkyGlass
                component="button"
                type="button"
                onClick={() => openMediaApp('photos', 'video')}
              >
                <span><Video size={20} /></span>
                {phone.t('Apps.messages.attachVideo')}
              </SkyGlass>
            </section>
          )}

          <SkySheet
            className="messages-media-picker-sheet"
            opened={activeCanMessage && !activeServiceLine && attachmentPicker !== null}
            aria-label={phone.t(
              attachmentPicker === 'contacts'
                ? 'Apps.messages.contacts'
                : 'Apps.messages.gifs',
            )}
            swipe-to-close
            grabber-clickable
            grabber-label={phone.t('Common.close')}
            onBackdropclick={closeAttachmentPicker}
            onEscape={closeAttachmentPicker}
            onGrabberclick={closeAttachmentPicker}
            onSwipeclose={closeAttachmentPicker}
          >
            <section
              className="messages-media-picker"
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
            >
              <header>
                <strong>
                  {phone.t(
                    attachmentPicker === 'contacts'
                      ? 'Apps.messages.contacts'
                      : 'Apps.messages.gifs',
                  )}
                </strong>
                <SkyLink onClick={closeAttachmentPicker}>
                  {phone.t('Common.done')}
                </SkyLink>
              </header>
              {attachmentPicker === 'contacts' ? (
                <SkyList inset strong className="messages-media-picker__contacts">
                  {calls.contacts.map((contact: any) => (
                    <SkyListItem
                      key={contact.id}
                      link
                      link-component="button"
                      title={contact.name}
                      subtitle={contact.organization || contact.phone_number}
                      onClick={() => sendContact(contact)}
                      media={
                        <span className="messages-avatar messages-avatar--small">
                          {contact.avatar_url ? (
                            <img
                              className="messages-avatar__image"
                              src={contact.avatar_url}
                              alt=""
                            />
                          ) : (
                            <span className="messages-avatar__initials">
                              {contactInitials(contact.phone_number)}
                            </span>
                          )}
                        </span>
                      }
                    />
                  ))}
                  {!calls.contacts.length && (
                    <p className="messages-media-picker__empty">
                      {phone.t('Apps.messages.noContactsToShare')}
                    </p>
                  )}
                </SkyList>
              ) : (
                <div className="messages-media-picker__gifs messages-media-picker__gifs--masonry">
                  <SkySearchbar
                    value={gifQuery}
                    onInput={(e: any) => { setGifQuery(e.target.value); queueGifSearch(); }}
                    onClear={() => { setGifQuery(''); queueGifSearch(); }}
                    className="messages-gif-search"
                    label={phone.t('Apps.messages.searchGifs')}
                    placeholder={phone.t('Apps.messages.searchGifs')}
                    clear-label={phone.t('Common.clear')}
                  />
                  {gifResults.length > 0 && (
                    <div className="messages-gif-grid">
                      {gifColumns.map((column, columnIndex) => (
                        <div key={columnIndex} className="messages-gif-column">
                          {column.map((gif) => (
                            <button
                              key={gif.id}
                              type="button"
                              className="messages-gif-result"
                              aria-label={gif.title}
                              style={{
                                aspectRatio: `${Math.max(1, gif.width)} / ${Math.max(1, gif.height)}`,
                              }}
                              onClick={() => sendAttachment('gif', gif.url)}
                            >
                              <img src={gif.previewUrl} alt={gif.title} loading="lazy" />
                            </button>
                          ))}
                        </div>
                      ))}
                    </div>
                  )}
                  {gifResults.length > 0 && gifHasMore && !gifLoading && (
                    <button
                      type="button"
                      className="messages-gif-more"
                      onClick={() => loadGifs()}
                    >
                      {phone.t('Apps.messages.loadMore')}
                    </button>
                  )}
                  {gifError && !gifLoading && (
                    <div className="messages-gif-error">
                      <ImagePlay size={24} />
                      <strong>{errorText(gifError)}</strong>
                      <button type="button" onClick={() => loadGifs(true)}>
                        {phone.t('Apps.messages.retryGifs')}
                      </button>
                    </div>
                  )}
                  {gifLoading && (
                    <SkySpinner
                      className="messages-gif-loading"
                      label={phone.t('Common.loading')}
                    />
                  )}
                </div>
              )}
            </section>
          </SkySheet>

          {activeCanMessage && emojiOpen && (
            <FullEmojiPicker
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
              onClose={() => setEmojiOpen(false)}
              onPick={appendEmoji}
            />
          )}
          {activeCanMessage && !activeServiceLine && shareDraft && !recording && (
            <div
              className="shared-composer-preview"
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
            >
              <SharedContentCard compact payload={shareDraft} variant="messages" />
              <SkyLink
                icon-only
                aria-label={phone.t('Common.close')}
                onClick={() => setShareDraft(null)}
              >
                <X size={15} />
              </SkyLink>
            </div>
          )}

          {activeCanMessage && !activeServiceLine && recording ? (
            <section
              className="messages-recorder"
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
            >
              <SkyLink
                icon-only
                className="messages-recorder__cancel"
                aria-label={phone.t('Apps.messages.cancelRecording')}
                onClick={cancelVoiceRecording}
              >
                <X size={20} />
              </SkyLink>
              <span className="messages-recorder__dot" />
              <time>{formatRecordingTime(recordingElapsedMs)}</time>
              <div className="messages-recorder__wave" aria-hidden="true">
                {recordingLevels.map((level, index) => (
                  <i
                    key={index}
                    style={{ height: `${Math.max(3, level * 24)}px` }}
                  />
                ))}
              </div>
              <SkyButton
                icon-only
                rounded
                tonal
                className="messages-recorder__send"
                aria-label={phone.t('Apps.messages.stopAndSend')}
                onClick={stopVoiceRecording}
              >
                <ArrowUpCircle size={27} strokeWidth={2.4} />
              </SkyButton>
            </section>
          ) : activeCanMessage ? (
            <div
              className="messages-sky-composer-shell"
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
            >
              {pendingAttachments.length > 0 && (
                <div
                  className="messages-pending-media"
                  role="list"
                  aria-label={phone.t('Apps.messages.attachmentPreview')}
                >
                  {pendingAttachments.map((media, index) => (
                    <div
                      key={media.id}
                      className="messages-pending-media__item"
                      role="listitem"
                    >
                      {media.mediaType === 'photo' || media.thumbnailUrl ? (
                        <img
                          src={media.thumbnailUrl ?? media.url}
                          alt={phone.t(
                            media.mediaType === 'video'
                              ? 'Apps.photos.videoAlt'
                              : 'Apps.photos.photoAlt',
                          )}
                        />
                      ) : (
                        <video
                          src={media.url}
                          aria-label={phone.t('Apps.photos.videoAlt')}
                          muted
                          playsInline
                          preload="metadata"
                        />
                      )}
                      <button
                        type="button"
                        disabled={sending}
                        aria-label={phone.t('Apps.messages.removeAttachment', {
                          number: String(index + 1),
                        })}
                        onClick={() => removePendingAttachment(media.id)}
                      >
                        <X size={13} strokeWidth={2.5} />
                      </button>
                    </div>
                  ))}
                </div>
              )}

              <div className="messages-sky-composer-row">
                {!activeServiceLine && (
                  <SkyGlass
                    component="button"
                    type="button"
                    className={`messages-sky-messagebar__action messages-sky-messagebar__plus ${attachmentMenuOpen || attachmentPanelOpen ? 'active' : ''}`}
                    disabled={sending}
                    aria-label={phone.t('Apps.messages.moreActions')}
                    onClick={toggleAttachmentMenu}
                  >
                    <Plus size={24} />
                  </SkyGlass>
                )}
                <SkyGlass
                  component="div"
                  highlight={false}
                  className="messages-sky-composer-pill"
                >
                  <SkyMessagebar
                    value={draft}
                    onInput={(e: any) => setDraft(e.target.value)}
                    className="messages-sky-messagebar"
                    embedded
                    outline={false}
                    placeholder={phone.t('Apps.messages.message')}
                    disabled={sending}
                    onKeyDown={(e: any) => {
                      if (e.key === 'Enter' && !e.shiftKey) {
                        handleEnterAction(e, sendTextMessage)
                      }
                    }}
                    right={
                      composerHasContent ? (
                        <SkyLink
                          icon-only
                          className="messages-sky-messagebar__send"
                          disabled={sending}
                          aria-label={phone.t('Apps.messages.send')}
                          onClick={sendTextMessage}
                        >
                          <ArrowUpCircle size={29} strokeWidth={2.4} />
                        </SkyLink>
                      ) : !activeServiceLine ? (
                        <SkyLink
                          icon-only
                          className="messages-sky-messagebar__send"
                          disabled={sending || recordingStarting}
                          aria-busy={recordingStarting}
                          aria-label={phone.t('Apps.messages.recordVoice')}
                          onClick={startVoiceRecording}
                        >
                          <Mic size={21} strokeWidth={2.3} />
                        </SkyLink>
                      ) : null
                    }
                  />
                </SkyGlass>
              </div>
            </div>
          ) : (
            <div
              className="messages-sky-unavailable"
              aria-hidden={contactDetailsOpen}
              inert={contactDetailsOpen || undefined}
            >
              {phone.t('Apps.messages.messagingUnavailable')}
            </div>
          )}
        </SkyAppPage>
      )}

      <SkyDialog
        opened={blockDialogOpened}
        onBackdropclick={() => setBlockDialogOpened(false)}
        onEscape={() => setBlockDialogOpened(false)}
        title={phone.t('Apps.messages.blockContactTitle')}
        buttons={
          <>
            <SkyDialogButton
              disabled={blockingContact}
              onClick={() => setBlockDialogOpened(false)}
            >
              {phone.t('Common.cancel')}
            </SkyDialogButton>
            <SkyDialogButton
              strong
              disabled={blockingContact}
              onClick={blockActiveContact}
            >
              {phone.t('Apps.messages.blockContact')}
            </SkyDialogButton>
          </>
        }
      >
        <p>
          {phone.t('Apps.messages.blockContactBody', {
            name: activeTitle,
          })}
        </p>
      </SkyDialog>

      <SkyNotification
        opened={toastOpened}
        text={toastText}
        onClick={() => setToastOpened(false)}
      />
    </>
  )
}

