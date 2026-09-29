import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luma/app.dart';
import 'package:luma/providers/library_provider.dart';
import 'package:luma/routing/router.dart';

void main() {
  test('Library survives a new provider container', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final first = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    final library = first.read(libraryProvider.notifier);
    library.toggle('wild');
    library.remember('ocean-s1e2', 42);
    library.search('Ocean');
    library.autoplay(false);
    first.dispose();
    final second = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
    );
    final state = second.read(libraryProvider);
    expect(state.saved, ['wild']);
    expect(state.progress['ocean-s1e2'], 42);
    expect(state.recent, ['Ocean']);
    expect(state.autoplay, false);
    second.read(libraryProvider.notifier).clearHistory();
    expect(second.read(libraryProvider).progress, isEmpty);
    expect(second.read(libraryProvider).saved, ['wild']);
    second.dispose();
  });
  testWidgets('Search filters, details and watchlist work on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
        child: const LumaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('L U M A   S E L E C T'), findsOneWidget);
    router.go('/search');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'DEEP');
    await tester.pumpAndSettle();
    expect(find.text('DEEP BLUE'), findsWidgets);
    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();
    expect(find.text('No matches. Try another title.'), findsOneWidget);
    await tester.tap(find.text('TV Shows'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DEEP BLUE').first);
    await tester.pumpAndSettle();
    expect(find.text('Season 1'), findsOneWidget);
    await tester.ensureVisible(find.text('My List'));
    await tester.tap(find.text('My List'));
    await tester.pumpAndSettle();
    router.go('/library');
    await tester.pumpAndSettle();
    expect(find.text('DEEP BLUE'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
