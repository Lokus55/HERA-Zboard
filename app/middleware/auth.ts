export default defineNuxtRouteMiddleware(async (to, from) => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()
  
  // Esperar a que Supabase recupere la sesión del localStorage
  if (!user.value) {
    const { data: { session } } = await supabase.auth.getSession()
    
    if (!session) {
      return navigateTo('/auth/login')
    }
  }
})