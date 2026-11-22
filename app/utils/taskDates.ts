export type TaskDueFilter = 'all' | 'overdue' | 'week'

export function localDateKey(date: Date): string {
  const year = String(date.getFullYear()).padStart(4, '0')
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return [year, month, day].join('-')
}

export function taskDateWindow(date: Date) {
  const start = new Date(date)
  start.setDate(date.getDate() - (date.getDay() + 6) % 7)
  const end = new Date(start)
  end.setDate(start.getDate() + 6)
  return { today: localDateKey(date), start: localDateKey(start), end: localDateKey(end) }
}

export function isCompletedStatus(name: string): boolean {
  const normalized = name.toLowerCase()
  return normalized.includes('completado') || normalized.includes('done')
}

export function matchesTaskDueFilter(
  dueDate: string | null | undefined,
  filter: TaskDueFilter,
  dates: ReturnType<typeof taskDateWindow>,
  completed: boolean,
): boolean {
  if (filter === 'all') return true
  if (!dueDate) return false
  if (filter === 'overdue') return !completed && dueDate < dates.today
  return dates.start <= dueDate && dueDate <= dates.end
}

export function formatTaskDate(date: string, locale: string): string {
  return new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'short', timeZone: 'UTC' })
    .format(new Date(date + 'T00:00:00Z'))
}
