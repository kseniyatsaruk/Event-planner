// Basic smoke test: the app boots to the splash screen without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/api/api_client.dart';
import 'package:mobile/api/auth_api.dart';
import 'package:mobile/api/events_api.dart';
import 'package:mobile/main.dart';
import 'package:mobile/state/auth_store.dart';
import 'package:mobile/state/settings_store.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    final settingsStore = SettingsStore();
    final authStore = AuthStore();
    final apiClient = ApiClient(settings: settingsStore, auth: authStore);
    final authApi = AuthApi(apiClient.dio);
    final eventsApi = EventsApi(apiClient.dio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsStore),
          ChangeNotifierProvider.value(value: authStore),
          Provider.value(value: authApi),
          Provider.value(value: eventsApi),
        ],
        child: const EventPlannerApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
