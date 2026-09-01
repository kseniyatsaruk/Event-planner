export function formatDate(dateString, language) {
  if (!dateString) return ''
  const locale = language === 'ru' ? 'ru-RU' : 'en-US'
  return new Intl.DateTimeFormat(locale, { dateStyle: 'medium' }).format(new Date(dateString))
}
