import 'downloads_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_provider.dart';
import '../widgets/catalog_view.dart';
import '../widgets/poster_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your collection'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'My List'),
              Tab(text: 'Continue'),
              Tab(text: 'History'),
              Tab(text: 'Downloads'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (var tab = 0; tab < 3; tab++)
              CatalogView(
                builder: (titles) {
                  final selected = titles
                      .where(
                        (t) => tab == 0
                            ? library.saved.contains(t.id)
                            : library.progress.keys.any(
                                (k) => k == t.id || k.startsWith('${t.id}-'),
                              ),
                      )
                      .toList();
                  return selected.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bookmark_border,
                                size: 44,
                                color: Colors.white30,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tab == 0
                                    ? 'Make room for your favorites.'
                                    : 'Your story starts with a play.',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Explore the catalog to get started.',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(22),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 190,
                                mainAxisExtent: 270,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 14,
                              ),
                          itemCount: selected.length,
                          itemBuilder: (_, i) => PosterCard(selected[i]),
                        );
                },
              ),
            const DownloadsView(),
          ],
        ),
      ),
    );
  }
}
