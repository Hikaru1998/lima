import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/title.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';

class FeaturedHero extends ConsumerWidget {
  const FeaturedHero(this.title, {super.key});
  final CatalogTitle title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(libraryProvider).saved.contains(title.id);
    return SizedBox(
      height: 550,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Artwork(title.backdrop ?? title.image, width: 1600),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, .35, 1],
                colors: [Colors.black54, Colors.transparent, Color(0xFF0C0D10)],
              ),
            ),
          ),
          Positioned(
            top: 22,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'luma',
                  style: TextStyle(
                    fontSize: 30,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/search'),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 22,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'L U M A   S E L E C T',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title.name,
                  style: const TextStyle(
                    fontSize: 42,
                    height: 1.02,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title.metadata,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  title.tagline,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: title.playable
                          ? () => context.push('/play/${title.id}')
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        title.playable ? 'Play' : 'Not available to play',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(libraryProvider.notifier).toggle(title.id),
                      icon: Icon(saved ? Icons.check : Icons.add),
                      label: const Text('My List'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 22, height: 4, color: accent),
                      const SizedBox(width: 5),
                      Container(width: 5, height: 4, color: Colors.white24),
                      const SizedBox(width: 5),
                      Container(width: 5, height: 4, color: Colors.white24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
