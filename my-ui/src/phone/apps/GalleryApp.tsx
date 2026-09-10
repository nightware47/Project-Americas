// React imports
import React, { useState, useEffect, useMemo, useCallback, useRef } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';

// UI components
import {
  SkyBlock, SkyDialog, SkyLink, SkyList, SkyField, SkyListItem, SkyNavbarBackLink,
  SkyAppPage, SkySpinner, SkyNotification, SkyButton, SkyDropdown, SkyNavbar,
  SkyTabBar, SkyTabButton, SkyToolbar, SkyToolbarPane
} from '@/ui';

// Icons
import {
  ChevronLeft, ChevronRight, Download, Globe2, Heart, Image, Images, Link2,
  ListFilter, Play, Share2, Trash2, Video
} from 'lucide-react';

// Utilities & Stores
import { useMessageMediaStore } from '@/stores/messageMedia';
import { usePhoneStore } from '@/stores/phone';
import { useEasyShareStore } from '@/stores/easyshare';
import {
  bottomRightGridPosition,
  hasNextMediaPage,
  MEDIA_PAGE_SIZE,
  mediaErrorKey,
  mergeMedia,
  orderMedia,
} from '@/utils/media';

// Types
import type {
  DeleteManyResult, DeleteResult, FavoriteResult, GalleryCounts, GalleryFilter,
  GallerySortOrder, MediaImportSource, MediaImportSources, MediaType, PhoneMedia,
} from '@/types/media';

// Import the CSS
import './GalleryApp.css';

// Nerve mock bindings
declare const nerve: any;

const isDevelopment = import.meta.env?.DEV || true;
const developmentParameters = isDevelopment ? new URLSearchParams(window.location.search) : null;
const developmentApiEnabled = Boolean(developmentParameters?.has('apiPort'));
const developmentGalleryState = developmentParameters?.get('galleryMock') ?? null;

function mockGalleryImage(title: string, sky: string, landscape: string, accent: string): string {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 1200"><defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop stop-color="${sky}"/><stop offset="1" stop-color="${accent}"/></linearGradient><linearGradient id="land" x1="0" y1="0" x2="1" y2="1"><stop stop-color="${landscape}"/><stop offset="1" stop-color="#101114"/></linearGradient></defs><rect width="900" height="1200" fill="url(#sky)"/><circle cx="690" cy="260" r="105" fill="#fff" opacity=".72"/><path d="M0 690 210 440 390 650 585 360 900 720V1200H0Z" fill="${landscape}" opacity=".84"/><path d="M0 790 230 620 410 765 650 525 900 770V1200H0Z" fill="url(#land)"/><path d="M360 1200 475 690 560 690 690 1200Z" fill="${accent}" opacity=".48"/><text x="54" y="1100" fill="#fff" font-family="system-ui,sans-serif" font-size="62" font-weight="700">${title}</text><text x="57" y="1160" fill="#fff" opacity=".72" font-family="system-ui,sans-serif" font-size="30">Sky Phone test media</text></svg>`;
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`;
}

function mockMedia(): PhoneMedia[] {
  const media: PhoneMedia[] = [
    { createdAt: Date.now() - 4 * 60_000, favorite: false, id: 1, mediaType: 'photo', url: mockGalleryImage('City Night', '#172554', '#111827', '#7c3aed') },
    {
      createdAt: Date.now() - 18 * 60_000,
      favorite: true,
      id: 2,
      mediaType: 'video',
      thumbnailUrl: mockGalleryImage('Flower Video', '#7f1d1d', '#365314', '#fb7185'),
      url: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
    },
  ];

  const additionalPhotos = [
    ['Airport Lights', '#172554', '#1e3a8a', '#38bdf8'],
	['Desert Route', '#fb923c', '#7c2d12', '#fde047'],
  ] as const;

  return [
    ...media,
    ...additionalPhotos.map(([title, sky, landscape, accent], index) => ({
      createdAt: Date.now() - (6 + index) * 86_400_000,
      favorite: index % 7 === 0,
      id: 3 + index,
      mediaType: 'photo' as const,
      url: mockGalleryImage(title, sky, landscape, accent),
    })),
  ];
}

const developmentMedia = isDevelopment ? mockMedia() : [];

export default function GalleryApp() {
  const phone = usePhoneStore()
  const easyShare = useEasyShareStore()
  const messageMedia = useMessageMediaStore()
  const location = useLocation()
  const navigate = useNavigate()
  
  const queryParams = new URLSearchParams(location.search)
  const requestedMessageMedia = useMemo<MediaType | null>(() => {
    const value = queryParams.get('mediaAttachment') ?? queryParams.get('messageAttachment')
    return value === 'photo' || value === 'video' ? (value as MediaType) : null
  }, [location.search])

  const multipleSelection = useMemo(() => 
    requestedMessageMedia !== null && (messageMedia.request?.maxSelection ?? 1) > 1,
  [requestedMessageMedia, messageMedia.request])

  const [selectedMediaIds, setSelectedMediaIds] = useState<number[]>([])
  const [selectionMode, setSelectionMode] = useState(false)
  const [media, setMedia] = useState<PhoneMedia[]>([])
  const [counts, setCounts] = useState<GalleryCounts>({
    all: 0, favoritePhotos: 0, favorites: 0, favoriteVideos: 0, photos: 0, videos: 0
  })
  const [filter, setFilter] = useState<GalleryFilter>(requestedMessageMedia ?? 'all')
  const [favoritesOnly, setFavoritesOnly] = useState(false)
  const [sortOrder, setSortOrder] = useState<GallerySortOrder>('newest')
  const [sortMenuOpened, setSortMenuOpened] = useState(false)
  const [sortMenuTarget, setSortMenuTarget] = useState<HTMLElement | null>(null)
  
  const [loading, setLoading] = useState(true)
  const [fetching, setFetching] = useState(false)
  const [hasMore, setHasMore] = useState(true)
  const [loadError, setLoadError] = useState('')
  const [selected, setSelected] = useState<PhoneMedia | null>(null)
  
  const [importMode, setImportMode] = useState<'form' | 'gallery' | 'sources'>('gallery')
  const [importSources, setImportSources] = useState<MediaImportSource[]>([])
  const [importSource, setImportSource] = useState<MediaImportSource | null>(null)
  const [importUrl, setImportUrl] = useState('')
  const [importError, setImportError] = useState('')
  const [importing, setImporting] = useState(false)
  
  const [deleteDialogOpened, setDeleteDialogOpened] = useState(false)
  const [deleteManyDialogOpened, setDeleteManyDialogOpened] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const [deletingMany, setDeletingMany] = useState(false)
  const [favoriting, setFavoriting] = useState(false)
  
  const [toastOpened, setToastOpened] = useState(false)
  const [toastText, setToastText] = useState('')
  
  const loadTriggerRef = useRef<HTMLElement | null>(null)
  const galleryContentRef = useRef<HTMLElement | null>(null)
  const [imageZoom, setImageZoom] = useState(1)
  const [imagePan, setImagePan] = useState({ x: 0, y: 0 })
  const [dragging, setDragging] = useState(false)
  const [videoPlaybackError, setVideoPlaybackError] = useState(false)
  const [dragStart, setDragStart] = useState({ panX: 0, panY: 0, x: 0, y: 0 })
  
  const dragTargetRef = useRef<HTMLElement | null>(null)
  const dragPointerIdRef = useRef<number | null>(null)
  const observerRef = useRef<IntersectionObserver | null>(null)
  const galleryReturnScrollTop = useRef(0)
  const toastTimerRef = useRef<number | undefined>()
  const pendingDeleteCorrelation = useRef('')
  const pendingDeleteManyCorrelation = useRef('')

  // UI state and helpers
  const imageStyle = useMemo(() => ({
    cursor: imageZoom > 1 ? (dragging ? 'grabbing' : 'grab') : 'zoom-in',
    transform: `translate3d(${imagePan.x}px, ${imagePan.y}px, 0) scale(${imageZoom})`,
  }), [imageZoom, dragging, imagePan])

  const orderedMedia = useMemo(() => orderMedia(media, sortOrder), [media, sortOrder])
  
  const sortMenuItems = useMemo(() => [
    { checked: sortOrder === 'newest', group: 'sort', groupLabel: phone.t('Apps.photos.sorting.title'), id: 'sort-newest', label: phone.t('Apps.photos.sorting.newestFirst') },
    { checked: sortOrder === 'oldest', group: 'sort', groupLabel: phone.t('Apps.photos.sorting.title'), id: 'sort-oldest', label: phone.t('Apps.photos.sorting.oldestFirst') },
    { checked: !favoritesOnly, group: 'show', groupLabel: phone.t('Apps.photos.sorting.show'), id: 'show-all', label: phone.t('Apps.photos.sorting.allItems'), separatorBefore: true },
    { checked: favoritesOnly, group: 'show', groupLabel: phone.t('Apps.photos.sorting.show'), id: 'show-favorites', label: phone.t('Apps.photos.sorting.favorites') }
  ], [sortOrder, favoritesOnly, phone])

  const countText = useMemo(() => {
    if (favoritesOnly) {
      const favoriteCount = filter === 'photo' ? counts.favoritePhotos : filter === 'video' ? counts.favoriteVideos : counts.favorites
      return phone.t(`Apps.photos.counts.${favoriteCount === 1 ? 'favorite' : 'favorites'}`, { count: new Intl.NumberFormat(phone.lang).format(favoriteCount) })
    }
    const countKey = filter === 'all' ? 'all' : `${filter}s`
    const count = counts[countKey as keyof GalleryCounts] || 0
    const translationKey = count === 1 ? (filter === 'all' ? 'allOne' : filter) : countKey
    return phone.t(`Apps.photos.counts.${translationKey}`, { count: new Intl.NumberFormat(phone.lang).format(count) })
  }, [favoritesOnly, filter, counts, phone])

  const selectedMedia = useMemo(() => selectedMediaIds.flatMap(id => {
    const entry = media.find(item => item.id === id)
    return entry ? [entry] : []
  }), [selectedMediaIds, media])

  const selectedCountText = useMemo(() => phone.t('Apps.photos.selection.selected', {
    count: new Intl.NumberFormat(phone.lang).format(selectedMediaIds.length)
  }), [phone, selectedMediaIds.length])

  const selectedCaptureDay = useMemo(() => {
    if (!selected) return ''
    const captured = new Date(selected.createdAt)
    const today = new Date()
    const capturedDay = new Date(captured.getFullYear(), captured.getMonth(), captured.getDate()).getTime()
    const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime()
    const difference = Math.round((capturedDay - todayStart) / 86_400_000)
    if (difference === 0) return phone.t('Apps.photos.today')
    if (difference === -1) return phone.t('Apps.photos.yesterday')
    return new Intl.DateTimeFormat(phone.lang, { day: 'numeric', month: 'long', weekday: 'long' }).format(captured)
  }, [selected, phone])

  const selectedCaptureTime = useMemo(() => 
    selected ? new Intl.DateTimeFormat(phone.lang, { hour: '2-digit', minute: '2-digit' }).format(new Date(selected.createdAt)) : ''
  , [selected, phone])

  function showToast(text: string) {
    if (toastTimerRef.current !== undefined) window.clearTimeout(toastTimerRef.current)
    setToastText(text)
    setToastOpened(true)
    toastTimerRef.current = window.setTimeout(() => setToastOpened(false), 3000)
  }

  // Bind to Nerve Server
  const galleryService = useMemo(() => window.nerve?.GetService('GalleryService'), [])
  
  const loadImportSources = useCallback(async () => {
    if (isDevelopment && !developmentApiEnabled) return
    const response = await galleryService?.importSources() // MOCK NERVE BINDING
    if (!response?.success || !response.data) return
    const requestedType = requestedMessageMedia
    const sources = requestedType ? response.data.sources.filter((s: MediaImportSource) => s.mediaTypes.includes(requestedType)) : response.data.sources
    setImportSources(sources)
    if (queryParams.get('wallpaperUpload') === '1' && requestedType === 'photo' && sources.length > 0) {
      openImport()
    }
  }, [galleryService, requestedMessageMedia, queryParams])

  const selectImportSource = (source: MediaImportSource) => {
    setImportSource(source)
    setImportMode('form')
    setImportUrl('')
    setImportError('')
  }

  const openImport = () => {
    if (importSources.length === 1) {
      selectImportSource(importSources[0])
      return
    }
    setImportMode('sources')
  }

  const closeImport = () => {
    setImportMode('gallery')
    setImportSource(null)
    setImportUrl('')
    setImportError('')
  }

  const backFromImportForm = () => {
    if (importSources.length > 1) {
      setImportMode('sources')
      setImportSource(null)
      setImportUrl('')
      setImportError('')
      return
    }
    closeImport()
  }

  const updateImportUrl = (event: React.ChangeEvent<HTMLInputElement>) => {
    setImportUrl(event.target.value)
    setImportError('')
  }

  const commitUrlImport = async () => {
    const url = importUrl.trim()
    if (!importSource || !url || importing) return
    setImporting(true)
    setImportError('')
    
    // MOCK NERVE BINDING
    const response = await galleryService?.importUrl({ sourceId: importSource.id, url })
    setImporting(false)
    if (!response?.success || !response.data) {
      setImportError(phone.t(`Apps.photos.errors.${mediaErrorKey(response?.error)}`))
      return
    }
    setMedia(prev => mergeMedia(prev, [response.data]))
    fetchCounts()
    if (queryParams.get('wallpaperUpload') === '1' && requestedMessageMedia === 'photo') {
      const returnPath = messageMedia.complete(response.data)
      if (returnPath) {
        navigate(returnPath)
        return
      }
    }
    closeImport()
    showToast(phone.t('Apps.photos.import.linkCompleted'))
  }

  const fetchMore = useCallback(async () => {
    if (fetching || !hasMore) return
    setFetching(true)
    const offset = media.length
    if (isDevelopment && !developmentApiEnabled) {
      setMedia(developmentMedia.filter(entry => (filter === 'all' || entry.mediaType === filter) && (!favoritesOnly || entry.favorite)))
      setHasMore(false)
      setFetching(false)
      return
    }
    
    const previousScrollHeight = galleryContentRef.current?.scrollHeight ?? 0
    const previousScrollTop = galleryContentRef.current?.scrollTop ?? 0
    
    // MOCK NERVE BINDING
    const response = await galleryService?.list({
      limit: MEDIA_PAGE_SIZE,
      favoriteOnly: favoritesOnly || undefined,
      mediaType: filter === 'all' ? undefined : filter,
      mockState: developmentGalleryState ?? undefined,
      offset,
    })
    
    if (response?.success && Array.isArray(response.data)) {
      setMedia(prev => mergeMedia(prev, response.data))
      setHasMore(hasNextMediaPage(response.data.length))
      if (offset > 0) {
        setTimeout(() => {
          if (galleryContentRef.current) {
            galleryContentRef.current.scrollTop = previousScrollTop + galleryContentRef.current.scrollHeight - previousScrollHeight
          }
        }, 0)
      }
    } else if (isDevelopment && developmentGalleryState !== 'error' && offset === 0) {
      const mock = developmentMedia.filter(entry => (filter === 'all' || entry.mediaType === filter) && (!favoritesOnly || entry.favorite))
      setMedia(mock)
      setHasMore(false)
    } else {
      if (offset === 0) {
        setLoadError(phone.t(`Apps.photos.errors.${mediaErrorKey(response?.error)}`))
      }
      setHasMore(false)
    }
    setFetching(false)
  }, [fetching, hasMore, media.length, filter, favoritesOnly, galleryService, phone])

  const fetchCounts = useCallback(async () => {
    if (isDevelopment && !developmentApiEnabled) {
      setCounts({
        all: developmentMedia.length,
        favoritePhotos: developmentMedia.filter(entry => entry.mediaType === 'photo' && entry.favorite).length,
        favorites: developmentMedia.filter(entry => entry.favorite).length,
        favoriteVideos: developmentMedia.filter(entry => entry.mediaType === 'video' && entry.favorite).length,
        photos: developmentMedia.filter(entry => entry.mediaType === 'photo').length,
        videos: developmentMedia.filter(entry => entry.mediaType === 'video').length,
      })
      return
    }
    
    // MOCK NERVE BINDING
    const response = await galleryService?.counts()
    if (response?.success && response.data) {
      setCounts(response.data)
      return
    }
    
    if (isDevelopment && developmentGalleryState !== 'error') {
      setCounts({
        all: developmentMedia.length,
        favoritePhotos: developmentMedia.filter(entry => entry.mediaType === 'photo' && entry.favorite).length,
        favorites: developmentMedia.filter(entry => entry.favorite).length,
        favoriteVideos: developmentMedia.filter(entry => entry.mediaType === 'video' && entry.favorite).length,
        photos: developmentMedia.filter(entry => entry.mediaType === 'photo').length,
        videos: developmentMedia.filter(entry => entry.mediaType === 'video').length,
      })
      return
    }
    setLoadError(phone.t(`Apps.photos.errors.${mediaErrorKey(response?.error)}`))
  }, [galleryService, phone])

  const loadGallery = useCallback(async () => {
    setMedia([])
    setHasMore(true)
    setLoadError('')
    setLoading(true)
    await Promise.all([fetchMore(), fetchCounts()])
    setLoading(false)
    setTimeout(() => {
      if (galleryContentRef.current) {
        galleryContentRef.current.scrollTop = galleryContentRef.current.scrollHeight
      }
    }, 0)
    observeMore()
  }, [fetchMore, fetchCounts])
  
  const observeMore = useCallback(() => {
    observerRef.current?.disconnect()
    observerRef.current = null
    if (!hasMore || !loadTriggerRef.current) return
    observerRef.current = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) fetchMore()
    }, { root: galleryContentRef.current, rootMargin: '180px 0px 0px' })
    observerRef.current.observe(loadTriggerRef.current)
  }, [hasMore, fetchMore])
  
  useEffect(() => { observeMore() }, [hasMore, observeMore])
  useEffect(() => { loadGallery() }, [filter, loadGallery])

  const selectSortOrder = async (value: GallerySortOrder) => {
    setSortOrder(value)
    setSortMenuOpened(false)
    setTimeout(() => {
      if (galleryContentRef.current) galleryContentRef.current.scrollTop = galleryContentRef.current.scrollHeight
      observeMore()
    }, 0)
  }

  const openSortMenu = (event: React.MouseEvent) => {
    setSortMenuTarget(event.currentTarget as HTMLElement)
    setSortMenuOpened(true)
  }
  const selectSortMenuItem = (id: string) => {
    if (id === 'sort-newest') selectSortOrder('newest')
    else if (id === 'sort-oldest') selectSortOrder('oldest')
    else if (id === 'show-all') { setFavoritesOnly(false); loadGallery(); setSortMenuOpened(false); }
    else if (id === 'show-favorites') { setFavoritesOnly(true); loadGallery(); setSortMenuOpened(false); }
  }

  const enterSelectionMode = () => { setSelectedMediaIds([]); setSelectionMode(true) }
  const exitSelectionMode = () => { setSelectedMediaIds([]); setSelectionMode(false); setDeleteManyDialogOpened(false) }

  const toggleMediaSelection = (entry: PhoneMedia, maximum = 50) => {
    setSelectedMediaIds(prev => {
      const idx = prev.indexOf(entry.id)
      if (idx >= 0) {
        const newIds = [...prev]
        newIds.splice(idx, 1)
        return newIds
      }
      if (prev.length >= maximum) {
        showToast(phone.t('Apps.photos.selection.limit'))
        return prev
      }
      return [...prev, entry.id]
    })
  }

  const openMedia = (entry: PhoneMedia) => {
    if (selectionMode) {
      toggleMediaSelection(entry)
      return
    }
    if (requestedMessageMedia) {
      if (multipleSelection) {
        toggleMediaSelection(entry, messageMedia.request?.maxSelection ?? 1)
        return
      }
    }
    galleryReturnScrollTop.current = galleryContentRef.current?.scrollTop ?? 0
    observerRef.current?.disconnect()
    observerRef.current = null
    phone.setCameraLandscape(false)
    setSelected(entry)
    setVideoPlaybackError(false)
    setImageZoom(1)
    setImagePan({ x: 0, y: 0 })
  }

  const completeSingleSelection = () => {
    if (!selected) return
    const returnPath = messageMedia.complete(selected)
    if (returnPath) navigate(returnPath, { replace: true })
  }

  const completeMultipleSelection = () => {
    const returnPath = messageMedia.completeMany(selectedMedia)
    if (returnPath) navigate(returnPath, { replace: true })
  }

  const cancelMessageSelection = () => navigate(messageMedia.cancel(), { replace: true })
  const closeMedia = () => {
    phone.setCameraLandscape(false)
    setSelected(null)
    setVideoPlaybackError(false)
    setDeleteDialogOpened(false)
    stopDragging()
    setTimeout(() => {
      if (galleryContentRef.current) galleryContentRef.current.scrollTop = galleryReturnScrollTop.current
      observeMore()
    }, 0)
  }
  
  const shareSelected = () => {
    if (!selected) return
    const mediaKind = selected.mediaType
    easyShare.open({
      appId: 'photos',
      copyText: selected.url,
      id: selected.id,
      imageUrl: selected.url,
      kind: mediaKind,
      link: `skyphone://media/${selected.id}`,
      subtitle: new Intl.DateTimeFormat(phone.lang, { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(selected.createdAt)),
      title: phone.t(mediaKind === 'video' ? 'Apps.photos.video' : 'Apps.photos.photo'),
    })
  }

  const toggleFavorite = async () => {
    if (!selected || favoriting) return
    setFavoriting(true)
    const nextFavorite = !selected.favorite
    
    // MOCK NERVE BINDING
    const response = await galleryService?.favorite({ favorite: nextFavorite, id: selected.id })
    setFavoriting(false)
    if (!response?.success || !response.data) {
      showToast(phone.t(`Apps.photos.errors.${mediaErrorKey(response?.error)}`))
      return
    }
    setSelected(prev => prev ? { ...prev, favorite: response.data.favorite } : prev)
    setMedia(prev => {
      const n = [...prev]
      const it = n.find(x => x.id === response.data.id)
      if (it) it.favorite = response.data.favorite
      if (favoritesOnly && !response.data.favorite) return n.filter(x => x.id !== response.data.id)
      return n
    })
    fetchCounts()
  }

  const shareSelection = () => {
    if (!selectedMedia.length) return
    const count = String(selectedMedia.length)
    easyShare.open({
      appId: 'photos',
      copyText: phone.t('Apps.photos.selection.shareCopy', { count }),
      imageUrl: selectedMedia[0].url,
      kind: 'media',
      meta: { mediaIds: selectedMedia.map(entry => entry.id) },
      subtitle: selectedCountText,
      title: phone.t('Apps.photos.selection.shareTitle', { count }),
    })
  }

  const deleteSelection = async () => {
    if (!selectedMediaIds.length || deletingMany) return
    setDeletingMany(true)
    setDeleteManyDialogOpened(false)
    const ids = [...selectedMediaIds]
    
    // MOCK NERVE BINDING
    const response = await galleryService?.deleteMany({ ids })
    setDeletingMany(false)
    if(response?.success) {
      const deletedIds = response.deletedIds ?? []
      setMedia(prev => prev.filter(e => !deletedIds.includes(e.id)))
      fetchCounts()
      showToast(phone.t('Apps.photos.selection.deleted', { count: String(deletedIds.length) }))
      exitSelectionMode()
    } else {
      showToast(phone.t("Apps.photos.errors.default"))
    }
  }
  
  const deleteSelected = async () => {
    if (!selected || deleting) return
    setDeleting(true)
    setDeleteDialogOpened(false)
    const selectedId = selected.id
    // MOCK NERVE BINDING
    const response = await galleryService?.delete({ id: selectedId })
    setDeleting(false)
    if(response?.success) {
      setMedia(prev => prev.filter(e => e.id !== selectedId))
      fetchCounts()
      closeMedia()
      showToast(phone.t('Apps.photos.deleted'))
    } else {
      showToast(phone.t("Apps.photos.errors.default"))
    }
  }

  const setZoomInner = (value: number) => {
    const val = Math.min(4, Math.max(1, value))
    setImageZoom(val)
    if (val === 1) setImagePan({ x: 0, y: 0 })
  }
  const zoomImageWithWheel = (e: React.WheelEvent) => {
    if (e.deltaY === 0) return
    e.preventDefault()
    const nextZoom = Math.min(4, Math.max(1, imageZoom + (e.deltaY < 0 ? 0.25 : -0.25)))
    if (nextZoom === imageZoom) return
    const mediaNode = (e.currentTarget as HTMLImageElement).parentElement
    if(!mediaNode) return
    const bounds = mediaNode.getBoundingClientRect()
    const pointerX = (e.clientX - bounds.left - bounds.width / 2) * (mediaNode.clientWidth / bounds.width)
    const pointerY = (e.clientY - bounds.top - bounds.height / 2) * (mediaNode.clientHeight / bounds.height)
    const zoomRatio = nextZoom / imageZoom
    if (nextZoom > 1) {
      setImagePan({ x: pointerX - (pointerX - imagePan.x) * zoomRatio, y: pointerY - (pointerY - imagePan.y) * zoomRatio })
    }
    setZoomInner(nextZoom)
  }

  const startDragging = (e: React.PointerEvent<HTMLElement>) => {
    if (imageZoom === 1) { setZoomInner(2); return }
    dragTargetRef.current = e.currentTarget
    dragPointerIdRef.current = e.pointerId
    e.currentTarget.setPointerCapture(e.pointerId)
    setDragging(true)
    setDragStart({ panX: imagePan.x, panY: imagePan.y, x: e.clientX, y: e.clientY })
  }
  const moveImage = (e: React.PointerEvent<HTMLElement>) => {
    if (!dragging) return
    setImagePan({
      x: dragStart.panX + e.clientX - dragStart.x,
      y: dragStart.panY + e.clientY - dragStart.y
    })
  }
  const stopDragging = (e?: React.PointerEvent<HTMLElement>) => {
    setDragging(false)
    if (dragTargetRef.current && dragPointerIdRef.current !== null && dragTargetRef.current.hasPointerCapture(dragPointerIdRef.current)) {
      dragTargetRef.current.releasePointerCapture(dragPointerIdRef.current)
    }
    dragTargetRef.current = null
    dragPointerIdRef.current = null
  }
  const moveImageWithKeyboard = (e: React.KeyboardEvent) => {
    if (imageZoom <= 1) return
    const step = e.shiftKey ? 48 : 24
    const offsets: Record<string, {x:number, y:number}> = { ArrowDown: {x:0, y:-step}, ArrowLeft: {x:step, y:0}, ArrowRight: {x:-step, y:0}, ArrowUp: {x:0, y:step} }
    const offset = offsets[e.key]
    if (!offset) return
    e.preventDefault()
    e.stopPropagation()
    setImagePan({ x: imagePan.x + offset.x, y: imagePan.y + offset.y })
  }
  
  useEffect(() => {
    loadGallery()
    loadImportSources()
    return () => {
      phone.setCameraLandscape(false)
      observerRef.current?.disconnect()
      stopDragging()
      if (toastTimerRef.current !== undefined) clearTimeout(toastTimerRef.current)
    }
  }, [loadGallery, loadImportSources, phone]) 

  return (
    <>
      {importMode === 'sources' ? (
        <SkyAppPage className="gallery-import-page !pt-[44px]" aria-label={phone.t('Apps.photos.import.chooseSource')}>
          <SkyNavbar title={phone.t('Apps.photos.import.title')}
            left={<SkyNavbarBackLink component="button" text={phone.t('Common.back')} onClick={closeImport} />}
          />
          <SkyBlock className="gallery-import-intro">{phone.t('Apps.photos.import.chooseSource')}</SkyBlock>
          <SkyList inset strong>
            {importSources.map(source => (
              <SkyListItem key={source.id} link chevron={false} title={source.label} 
                subtitle={source.mediaTypes.map(type => phone.t(type === 'photo' ? 'Apps.photos.filters.photos' : 'Apps.photos.filters.videos')).join(' · ')}
                onClick={() => selectImportSource(source)}
                media={<Globe2 size={22} />}
                after={<ChevronRight size={18} />}
              />
            ))}
          </SkyList>
        </SkyAppPage>
      ) : importMode === 'form' && importSource ? (
        <SkyAppPage className="gallery-import-page !pt-[44px]" aria-label={phone.t('Apps.photos.import.title')}>
          <SkyNavbar title={importSource.label} left={<SkyNavbarBackLink component="button" text={phone.t('Common.back')} onClick={backFromImportForm} />} />
          <div className="gallery-import-form">
            <div className="gallery-import-form-icon"><Link2 size={34} /></div>
            <h2>{phone.t('Apps.photos.import.linkTitle')}</h2>
            <p>{phone.t('Apps.photos.import.linkBody')}</p>
            <SkyList inset strong className="gallery-import-url-list">
              <SkyField outline inputId="gallery-import-url" inputMode="url" maxLength={2048} error={importError || undefined}
                label={phone.t('Apps.photos.import.linkLabel')} placeholder={phone.t('Apps.photos.import.linkPlaceholder')}
                type="url" value={importUrl} onChange={updateImportUrl} onKeyUp={e => e.key === 'Enter' && commitUrlImport()} />
            </SkyList>
            <SkyButton className="gallery-import-submit" large rounded disabled={!importUrl.trim() || importing} onClick={commitUrlImport}>
              {importing && <SkySpinner className="mr-2" />}
              {phone.t('Apps.photos.import.action')}
            </SkyButton>
          </div>
        </SkyAppPage>
      ) : !selected ? (
        <SkyAppPage className={`gallery-page ${requestedMessageMedia ? '!pt-[44px]' : ''}`} aria-label={phone.t('Apps.photos.name')}>
          {requestedMessageMedia ? (
            <SkyNavbar title={phone.t('Apps.photos.name')} left={<SkyNavbarBackLink component="button" text={phone.t('Common.back')} onClick={cancelMessageSelection} />}
              right={multipleSelection && <SkyLink component="button" disabled={!selectedMediaIds.length} onClick={completeMultipleSelection}>{phone.t('Common.done')}</SkyLink>} />
          ) : (
            <SkyNavbar className="gallery-library-navbar" scrollEl={null} subtitle={countText} title={phone.t('Apps.photos.library')} transparent variant="large"
              right={selectionMode ? (
                <div className="gallery-header-actions sky-ui-provider sky-ui-provider--dark">
                  <SkyToolbarPane className="gallery-header-tool gallery-header-tool--text">
                    <SkyButton clear className="gallery-header-action" onClick={exitSelectionMode}>{phone.t('Common.cancel')}</SkyButton>
                  </SkyToolbarPane>
                </div>
              ) : (
                <div className="gallery-header-actions sky-ui-provider sky-ui-provider--dark">
                  <SkyToolbarPane className="gallery-header-tool gallery-header-tool--icon">
                    <SkyButton clear iconOnly rounded className="gallery-header-action" aria-label={phone.t('Apps.photos.sorting.action')} aria-expanded={sortMenuOpened} aria-haspopup="menu" title={phone.t('Apps.photos.sorting.action')} onClick={openSortMenu}>
                      <ListFilter size={21} aria-hidden="true" />
                    </SkyButton>
                  </SkyToolbarPane>
                  {importSources.length > 0 && (
                    <SkyToolbarPane className="gallery-header-tool gallery-header-tool--icon">
                      <SkyButton clear iconOnly rounded className="gallery-header-action" onClick={openImport}><Download size={21} aria-hidden="true" /></SkyButton>
                    </SkyToolbarPane>
                  )}
                  <SkyToolbarPane className="gallery-header-tool gallery-header-tool--text">
                    <SkyButton clear className="gallery-header-action" onClick={enterSelectionMode}>{phone.t('Apps.photos.selection.action')}</SkyButton>
                  </SkyToolbarPane>
                </div>
              )} />
          )}

          <div ref={galleryContentRef} className="gallery-content">
            {loading ? (
              <div className="gallery-state"><SkySpinner /><span>{phone.t('Apps.photos.loading')}</span></div>
            ) : loadError ? (
              <SkyBlock strong inset className="gallery-error">{loadError}</SkyBlock>
            ) : !media.length ? (
              <div className="gallery-state gallery-empty"><strong>{phone.t('Apps.photos.emptyTitle')}</strong><span>{phone.t('Apps.photos.emptyBody')}</span></div>
            ) : (
              <div className={`gallery-grid ${media.length >= 13 ? 'gallery-grid--fill' : ''}`}>
                {hasMore && <span ref={loadTriggerRef} className="gallery-load-trigger"></span>}
                {orderedMedia.map((entry, index) => {
                  const pos = bottomRightGridPosition(index, orderedMedia.length)
                  return (
                    <button key={entry.id} type="button" className={`gallery-tile ${selectedMediaIds.includes(entry.id) ? 'gallery-tile--selected' : ''}`}
                      style={{ gridColumnStart: pos.column, gridRowStart: pos.row }} aria-pressed={selectionMode || multipleSelection ? selectedMediaIds.includes(entry.id) : undefined}
                      aria-label={phone.t(entry.mediaType === 'video' ? 'Apps.photos.videoAlt' : 'Apps.photos.photoAlt')}
                      onClick={() => openMedia(entry)}>
                      {entry.mediaType === 'photo' ? <img src={entry.url} alt="" loading="lazy" /> : <video src={entry.url} poster={entry.thumbnailUrl} muted playsInline preload="metadata"></video>}
                      {entry.mediaType === 'video' && <span className="gallery-video-badge"><Play size={16} fill="currentColor" /></span>}
                      {(selectionMode || multipleSelection) && selectedMediaIds.includes(entry.id) && (
                        <span className="gallery-selection-badge">{selectedMediaIds.indexOf(entry.id) + 1}</span>
                      )}
                    </button>
                  )
                })}
              </div>
            )}
          </div>

          {!requestedMessageMedia && !selectionMode && (
            <SkyTabBar icons labels className="gallery-filter-tabbar" label={phone.t('Apps.photos.name')}>
              <SkyTabButton active={filter === 'all'} label={phone.t('Apps.photos.filters.all')} onClick={() => setFilter('all')} icon={<Images size={21} />} />
              <SkyTabButton active={filter === 'photo'} label={phone.t('Apps.photos.filters.photos')} onClick={() => setFilter('photo')} icon={<Image size={21} />} />
              <SkyTabButton active={filter === 'video'} label={phone.t('Apps.photos.filters.videos')} onClick={() => setFilter('video')} icon={<Video size={21} />} />
            </SkyTabBar>
          )}

          {selectionMode && (
            <SkyToolbar aria-label={phone.t('Apps.photos.selection.action')} className={`gallery-selection-toolbar sky-ui-provider ${phone.isDarkMode ? 'sky-ui-provider--dark' : ''}`} component="nav">
              <SkyToolbarPane className="gallery-selection-count">{selectedCountText}</SkyToolbarPane>
              <div className="gallery-selection-actions">
                <SkyToolbarPane className="gallery-selection-action">
                  <SkyButton iconOnly rounded clear aria-label={phone.t('Apps.photos.selection.share')} disabled={!selectedMediaIds.length} onClick={shareSelection}><Share2 size={20} aria-hidden="true" /></SkyButton>
                </SkyToolbarPane>
                <SkyToolbarPane className="gallery-selection-action">
                  <SkyButton iconOnly rounded clear variant="danger" aria-label={phone.t('Apps.photos.selection.delete')} disabled={!selectedMediaIds.length || deletingMany} onClick={() => setDeleteManyDialogOpened(true)}><Trash2 size={20} aria-hidden="true" /></SkyButton>
                </SkyToolbarPane>
              </div>
            </SkyToolbar>
          )}
        </SkyAppPage>
      ) : (
        <SkyAppPage className="gallery-detail sky-ui-provider sky-ui-provider--dark">
          <SkyNavbar className="gallery-detail-navbar" scrollEl={null} subtitle={selectedCaptureTime} title={selectedCaptureDay}
            left={<SkyButton iconOnly rounded clear className="gallery-detail-back" aria-label={phone.t('Common.back')} onClick={closeMedia}><ChevronLeft size={24} aria-hidden="true" /></SkyButton>}
            right={requestedMessageMedia && <SkyButton rounded tonal onClick={completeSingleSelection}>{phone.t('Common.use')}</SkyButton>}
          />
          <div className="gallery-detail-stage">
            <div className="gallery-detail-media">
              {selected.mediaType === 'photo' ? (
                <img src={selected.url} alt={phone.t('Apps.photos.photoAlt')} style={imageStyle} draggable="false" tabIndex={0}
                  onPointerDown={startDragging} onPointerMove={moveImage} onPointerUp={stopDragging} onPointerCancel={stopDragging} onLostPointerCapture={stopDragging}
                  onKeyDown={moveImageWithKeyboard} onDoubleClick={() => setZoomInner(imageZoom === 1 ? 2 : 1)} onWheel={zoomImageWithWheel} />
              ) : (
                <video src={selected.url} poster={selected.thumbnailUrl} controls playsInline onLoadedMetadata={e => { setVideoPlaybackError(false); e.currentTarget.play().catch(()=>{}) }} onError={() => setVideoPlaybackError(true)} />
              )}
              {selected.mediaType === 'video' && videoPlaybackError && (
                <SkyBlock strong inset className="gallery-error" role="alert">{phone.t('Apps.photos.errors.unsupported')}</SkyBlock>
              )}
            </div>
          </div>
          
          {!requestedMessageMedia && (
            <SkyToolbar aria-label={phone.t('Apps.photos.name')} className="gallery-detail-toolbar" component="nav">
              <SkyToolbarPane className="gallery-detail-action">
                <SkyButton iconOnly rounded clear aria-label={phone.t('Apps.easyShare.name')} onClick={shareSelected}><Share2 size={21} aria-hidden="true" /></SkyButton>
              </SkyToolbarPane>
              <SkyToolbarPane className="gallery-detail-tools">
                <SkyButton iconOnly rounded clear aria-label={phone.t(selected.favorite ? 'Apps.photos.removeFavorite' : 'Apps.photos.addFavorite')} disabled={favoriting} onClick={toggleFavorite}>
                  <Heart size={20} fill={selected.favorite ? 'currentColor' : 'none'} aria-hidden="true" />
                </SkyButton>
              </SkyToolbarPane>
              <SkyToolbarPane className="gallery-detail-action">
                <SkyButton iconOnly rounded clear variant="danger" aria-label={phone.t('Apps.photos.delete')} disabled={deleting} onClick={() => setDeleteDialogOpened(true)}><Trash2 size={21} aria-hidden="true" /></SkyButton>
              </SkyToolbarPane>
            </SkyToolbar>
          )}
        </SkyAppPage>
      )}

      <SkyDropdown className={`gallery-sort-dropdown sky-ui-provider ${phone?.isDarkMode ? 'sky-ui-provider--dark' : ''}`} items={sortMenuItems} label={phone.t('Apps.photos.sorting.title')} opened={sortMenuOpened} target={sortMenuTarget} onBackdropClick={() => setSortMenuOpened(false)} onEscape={() => setSortMenuOpened(false)} onSelect={selectSortMenuItem} />

      <SkyDialog opened={deleteManyDialogOpened} onBackdropClick={() => setDeleteManyDialogOpened(false)}
        title={phone.t('Apps.photos.selection.deleteTitle')}
        buttons={
          <>
            <SkyButton large rounded variant="secondary" onClick={() => setDeleteManyDialogOpened(false)}>{phone.t('Common.cancel')}</SkyButton>
            <SkyButton large rounded variant="danger" onClick={deleteSelection}>{phone.t('Common.delete')}</SkyButton>
          </>
        }>
        <p>{phone.t('Apps.photos.selection.deleteBody')}</p>
      </SkyDialog>

      <SkyDialog opened={deleteDialogOpened} onBackdropClick={() => setDeleteDialogOpened(false)}
        title={phone.t('Apps.photos.deleteTitle')}
        buttons={
          <>
            <SkyButton large rounded variant="secondary" onClick={() => setDeleteDialogOpened(false)}>{phone.t('Common.cancel')}</SkyButton>
            <SkyButton large rounded variant="danger" onClick={deleteSelected}>{phone.t('Common.delete')}</SkyButton>
          </>
        }>
        <p>{phone.t('Apps.photos.deleteBody')}</p>
      </SkyDialog>

      <SkyNotification opened={toastOpened} text={toastText} onClick={() => setToastOpened(false)} />
    </>
  )
}
