import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/title.dart';
import '../providers/library_provider.dart';
import '../widgets/catalog_view.dart';
import '../widgets/catalog_section.dart';
import '../widgets/featured_hero.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(libraryProvider).progress;
    return SafeArea(
      child: CatalogView(
        builder: (titles) => ListView(
          children: [
            FeaturedHero(titles.first),
            if (progress.isNotEmpty)
              CatalogSection(
                'Continue Watching',
                titles
                    .where(
                      (t) => progress.keys.any(
                        (k) => k == t.id || k.startsWith('${t.id}-'),
                      ),
                    )
                    .toList(),
              )
            else
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 14, 24, 18),
                child: Text(
                  'Your next great watch starts here.',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            CatalogSection('Trending Now', titles),
            CatalogSection(
              'Popular Movies',
              titles.where((t) => t.kind == TitleKind.movie).toList(),
            ),
            CatalogSection(
              'Popular TV Shows',
              titles.where((t) => t.kind == TitleKind.series).toList(),
            ),
            CatalogSection('Recently Added', titles.reversed.toList()),
          ],
        ),
      ),
    );
  }
}
