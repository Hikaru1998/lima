import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/details_screen.dart';
import '../screens/player_screen.dart';

final router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              label: 'My List',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, s) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/search', builder: (_, s) => const SearchScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/library', builder: (_, s) => const LibraryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, s) => const ProfileScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/title/:id',
      builder: (_, s) => DetailsScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/play/:id',
      builder: (_, s) => PlayerScreen(
        key: ValueKey(s.uri.toString()),
        id: s.pathParameters['id']!,
        episodeId: s.uri.queryParameters['episode'],
        offlineOnly: s.uri.queryParameters['offline'] == '1',
      ),
    ),
  ],
);
