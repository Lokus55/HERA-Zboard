import { messages, type MessageKey } from '~/utils/interfaceMessages'

type InterfaceLanguage = 'en' | 'es'
type MessageValues = Record<string, string | number>

const storageKey = 'zboard.interface-language'

const starterStatuses: ReadonlyMap<string, MessageKey> = new Map([
  ['Por hacer', 'todo'],
  ['En progreso', 'inProgress'],
  ['En revisión', 'inReview'],
  ['Completado', 'done'],
])

const priorities: ReadonlyMap<string, MessageKey> = new Map([
  ['low', 'low'],
  ['medium', 'medium'],
  ['high', 'high'],
  ['urgent', 'urgent'],
])

export function useInterfaceLanguage() {
  const language = useState<InterfaceLanguage>('interface-language', () => {
    if (import.meta.server) return 'en'

    try {
      const saved = localStorage.getItem(storageKey)
      if (saved === 'en' || saved === 'es') return saved
    } catch {
      // The language selector can still work when storage is unavailable.
    }

    return navigator.language.toLowerCase().startsWith('es') ? 'es' : 'en'
  })

  const setLanguage = (value: string) => {
    if (value !== 'en' && value !== 'es') return
    language.value = value
    if (import.meta.client) {
      try {
        localStorage.setItem(storageKey, value)
      } catch {
        // Keep the current selection for this visit.
      }
    }
  }

  const locale = computed(() => language.value === 'es' ? 'es' : 'en')
  const t = (key: MessageKey, values: MessageValues = {}) =>
    messages[key][language.value].replace(/\{(\w+)\}/g, (placeholder, name) =>
      Object.hasOwn(values, name) ? String(values[name]) : placeholder,
    )

  const countProjects = (count: number) => t(count === 1 ? 'projectCountOne' : 'projectCountOther', { count })
  const countTasks = (count: number) => t(count === 1 ? 'taskCountOne' : 'taskCountOther', { count })

  // These names are reserved for the four columns seeded by the database.
  const statusLabel = (name: string) => {
    const key = starterStatuses.get(name)
    return key ? t(key) : name
  }
  const priorityLabel = (priority: string) => {
    const key = priorities.get(priority)
    return key ? t(key) : priority
  }

  const relativeTime = (value: number, unit: Intl.RelativeTimeFormatUnit) =>
    new Intl.RelativeTimeFormat(locale.value, { numeric: 'auto' }).format(value, unit)

  return {
    language,
    setLanguage,
    locale,
    t,
    countProjects,
    countTasks,
    statusLabel,
    priorityLabel,
    isStarterStatus: (name: string) => starterStatuses.has(name),
    relativeTime,
  }
}
