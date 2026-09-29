import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/library_provider.dart';
import '../widgets/download_button.dart';
import '../widgets/artwork.dart';
import '../widgets/catalog_view.dart';
import '../widgets/catalog_section.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  int season = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: CatalogView(
      builder: (titles) {
        final matches = titles.where((t) => t.id == widget.id);
        if (matches.isEmpty) {
          return const Center(child: Text('Title unavailable'));
        }
        final t = matches.first;
        final library = ref.watch(libraryProvider);
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 330,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Artwork(t.backdrop ?? t.image, width: 1400),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF0C0D10)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: const TextStyle(
                        fontSize: 34,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t.metadata,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: t.playable
                              ? () => context.push('/play/${t.id}')
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            t.playable ? 'Play' : 'Not available to play',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ref.read(libraryProvider.notifier).toggle(t.id),
                          icon: Icon(
                            library.saved.contains(t.id)
                                ? Icons.check
                                : Icons.add,
                          ),
                          label: const Text('My List'),
                        ),
                        TextButton.icon(
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text('Trailer unavailable'),
                              content: Text(
                                'A trailer is not available for this title.',
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.movie_outlined),
                          label: const Text('Trailer'),
                        ),
                        if (t.playable && t.episodes.isEmpty)
                          DownloadButton(titleId: t.id, name: t.name),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (t.episodes.isNotEmpty) ...[
                      DropdownButton<int>(
                        value: season,
                        items: t.episodes
                            .map((e) => e.season)
                            .toSet()
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text('Season $s'),
                              ),
                            )
                            .toList(),
                        onChanged: (s) => setState(() => season = s!),
                      ),
                      ...t.episodes
                          .where((e) => e.season == season)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: SizedBox(
                                  width: 90,
                                  height: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Artwork(t.image, width: 200),
                                  ),
                                ),
                                title: Text('${e.number}. ${e.name}'),
                                subtitle: Text(
                                  '${e.description}\n${library.progress.containsKey(e.id) ? 'Resume · ${(library.progress[e.id]! / 60).floor()} min watched' : 'Episode'}',
                                ),
                                trailing: DownloadButton(
                                  titleId: t.id,
                                  name: '${t.name} · ${e.name}',
                                  episodeId: e.id,
                                ),
                                onTap: () => context.push(
                                  '/play/${t.id}?episode=${e.id}',
                                ),
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CatalogSection(
                'More to discover',
                titles.where((other) => other.id != t.id).toList(),
              ),
            ),
          ],
        );
      },
    ),
  );
}
