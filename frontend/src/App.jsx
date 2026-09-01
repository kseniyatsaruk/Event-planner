import { useMemo } from 'react'
import { CssBaseline, ThemeProvider } from '@mui/material'
import { createTheme } from '@mui/material/styles'
import { enUS, ruRU } from '@mui/material/locale'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { baseThemeOptions } from './theme'
import { AuthProvider } from './context/AuthContext'
import ProtectedRoute from './components/layout/ProtectedRoute'
import AppShell from './components/layout/AppShell'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import EventsListPage from './pages/EventsListPage'
import EventDetailLayout from './pages/event/EventDetailLayout'
import EventOverviewPage from './pages/event/EventOverviewPage'
import ChecklistPage from './pages/event/ChecklistPage'
import VendorsPage from './pages/event/VendorsPage'
import GuestsPage from './pages/event/GuestsPage'
import SeatingPage from './pages/event/SeatingPage'

function useAppTheme() {
  const { i18n } = useTranslation()
  return useMemo(
    () => createTheme(baseThemeOptions, i18n.language === 'ru' ? ruRU : enUS),
    [i18n.language],
  )
}

function App() {
  const theme = useAppTheme()

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<Navigate to="/events" replace />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route element={<ProtectedRoute />}>
              <Route element={<AppShell />}>
                <Route path="/events" element={<EventsListPage />} />
                <Route path="/events/:eventId" element={<EventDetailLayout />}>
                  <Route index element={<Navigate to="overview" replace />} />
                  <Route path="overview" element={<EventOverviewPage />} />
                  <Route path="checklist" element={<ChecklistPage />} />
                  <Route path="vendors" element={<VendorsPage />} />
                  <Route path="guests" element={<GuestsPage />} />
                  <Route path="seating" element={<SeatingPage />} />
                </Route>
              </Route>
            </Route>
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  )
}

export default App
