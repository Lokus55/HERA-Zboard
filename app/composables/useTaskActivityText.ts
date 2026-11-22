interface TaskActivity {
  action: string
  field_name?: string | null
  old_value?: string | null
  new_value?: string | null
}

export function useTaskActivityText() {
  const { t, locale, priorityLabel, statusLabel } = useInterfaceLanguage()

  return ({ action, field_name, old_value, new_value }: TaskActivity, detailed = false) => {
    const before = old_value ?? '—'
    const after = new_value ?? '—'

    switch (action) {
      case 'created': return t('activityCreated')
      case 'deleted': return t('activityDeleted')
      case 'status_changed': return t('activityMoved', { from: statusLabel(before), to: statusLabel(after) })
      case 'assigned': return t('activityAssigned', { name: after })
      case 'unassigned': return t('activityUnassigned', { name: before })
      case 'label_added': return t('activityLabelAdded', { name: after })
      case 'label_removed': return t('activityLabelRemoved', { name: before })
      case 'updated':
        if (field_name === 'title') {
          return detailed
            ? t('activityTitleChangedDetails', { from: before, to: after })
            : t('activityTitleChanged')
        }
        if (field_name === 'description') return t('activityDescriptionChanged')
        if (field_name === 'priority') {
          return t('activityPriorityChanged', { from: priorityLabel(before), to: priorityLabel(after) })
        }
        if (field_name === 'due_date') {
          if (!new_value) return t('activityDueRemoved')
          const date = formatTaskDate(new_value, locale.value)
          return t('activityDueChanged', { date })
        }
        return t('activityUpdated')
      default: return t('activityUpdated')
    }
  }
}
