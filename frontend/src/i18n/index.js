import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

import en from './locales/en.json'
import ru from './locales/ru.json'

export const LANG_STORAGE_KEY = 'eventplanner_lang'

const SUPPORTED_LANGUAGES = ['en', 'ru']

function detectInitialLanguage() {
  const stored = localStorage.getItem(LANG_STORAGE_KEY)
  if (stored && SUPPORTED_LANGUAGES.includes(stored)) {
    return stored
  }

  const browserLang = navigator.language?.split('-')[0]
  return SUPPORTED_LANGUAGES.includes(browserLang) ? browserLang : 'en'
}

i18n.use(initReactI18next).init({
  resources: {
    en: en,
    ru: ru,
  },
  ns: Object.keys(en),
  defaultNS: 'common',
  lng: detectInitialLanguage(),
  fallbackLng: 'en',
  interpolation: {
    escapeValue: false,
  },
})

i18n.on('languageChanged', (lng) => {
  localStorage.setItem(LANG_STORAGE_KEY, lng)
})

export default i18n
