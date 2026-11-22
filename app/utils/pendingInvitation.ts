const storageKey = 'zboard.pending-invitation'
const tokenPattern = /^[a-f0-9]{64}$/

export function isInvitationToken(value: string): boolean {
  return tokenPattern.test(value)
}

export function getPendingInvitation(): string | null {
  if (import.meta.server) return null
  try {
    const token = localStorage.getItem(storageKey)
    return token && isInvitationToken(token) ? token : null
  } catch {
    return null
  }
}

export function setPendingInvitation(token: string | null): void {
  if (import.meta.server) return
  try {
    if (token && isInvitationToken(token)) localStorage.setItem(storageKey, token)
    else localStorage.removeItem(storageKey)
  } catch {
    // The original invitation link can be opened again if storage is unavailable.
  }
}
