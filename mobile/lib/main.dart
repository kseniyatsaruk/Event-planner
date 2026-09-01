import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'api/auth_api.dart';
import 'api/checklist_api.dart';
import 'api/events_api.dart';
import 'api/guests_api.dart';
import 'api/tables_api.dart';
import 'api/vendors_api.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/events_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'state/auth_store.dart';
import 'state/settings_store.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final settingsStore = SettingsStore();
  final authStore = AuthStore();
  final apiClient = ApiClient(
    settings: settingsStore,
    auth: authStore,
    onUnauthorized: () {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (route) => false);
    },
  );
  final authApi = AuthApi(apiClient.dio);
  final eventsApi = EventsApi(apiClient.dio);
  final checklistApi = ChecklistApi(apiClient.dio);
  final vendorsApi = VendorsApi(apiClient.dio);
  final guestsApi = GuestsApi(apiClient.dio);
  final tablesApi = TablesApi(apiClient.dio);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsStore),
        ChangeNotifierProvider.value(value: authStore),
        Provider.value(value: authApi),
        Provider.value(value: eventsApi),
        Provider.value(value: checklistApi),
        Provider.value(value: vendorsApi),
        Provider.value(value: guestsApi),
        Provider.value(value: tablesApi),
      ],
      child: const EventPlannerApp(),
    ),
  );
}

class EventPlannerApp extends StatelessWidget {
  const EventPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<SettingsStore>().languageCode;
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      locale: languageCode != null ? Locale(languageCode) : null,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/events': (context) => const EventsListScreen(),
      },
    );
  }
}
