import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/library_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(
          radius: 38,
          backgroundColor: Color(0xFF302A21),
          child: Icon(Icons.person_outline, size: 40, color: accent),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Your own little cinema',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Guest profile · stored on this device',
            style: TextStyle(color: Colors.white38),
          ),
        ),
        const SizedBox(height: 36),
        ListTile(
          leading: const Icon(Icons.bookmark_border),
          title: const Text('My List & watch history'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/library'),
        ),
        SwitchListTile(
          title: const Text('Autoplay next episode'),
          subtitle: const Text('Keep the story going'),
          value: ref.watch(libraryProvider).autoplay,
          onChanged: ref.read(libraryProvider.notifier).autoplay,
        ),
        const ListTile(
          leading: Icon(Icons.high_quality_outlined),
          title: Text('Streaming quality'),
          subtitle: Text('Automatic · adapts to your connection'),
        ),
        const ListTile(
          leading: Icon(Icons.network_check),
          title: Text('Stream buffer'),
          subtitle: Text(
            'Android aims for 5–10 minutes ahead. Available buffering depends on your connection, video quality and memory.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Clear watch history'),
          onTap: () {
            ref.read(libraryProvider.notifier).clearHistory();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Watch history cleared.')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('About & support'),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Luma',
            applicationVersion: '0.1.0 · Preview',
            children: [
              const Text(
                'Video: Big Buck Bunny, Blender Foundation (CC BY 3.0). Artwork: Unsplash. Apple streaming test media. Catalog titles are illustrative.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Account sign-in will be available with the future API.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
