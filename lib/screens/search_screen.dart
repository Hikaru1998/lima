import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/title.dart';
import '../providers/library_provider.dart';
import '../widgets/catalog_view.dart';
import '../widgets/poster_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final controller = TextEditingController();
  int filter = 0;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find your next obsession.',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            onSubmitted: (q) => ref.read(libraryProvider.notifier).search(q),
            decoration: InputDecoration(
              hintText: 'Movies, shows, a little escape…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: List.generate(
              3,
              (i) => ChoiceChip(
                label: Text(['All', 'Movies', 'TV Shows'][i]),
                selected: filter == i,
                onSelected: (_) => setState(() => filter = i),
              ),
            ),
          ),
          if (controller.text.isEmpty &&
              ref.watch(libraryProvider).recent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Wrap(
                spacing: 8,
                children: ref
                    .watch(libraryProvider)
                    .recent
                    .map(
                      (q) => ActionChip(
                        label: Text(q),
                        onPressed: () => setState(() => controller.text = q),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 18),
          Expanded(
            child: CatalogView(
              builder: (titles) {
                final results = titles
                    .where(
                      (t) =>
                          t.name
                              .toLowerCase()
                              .replaceAll('\n', ' ')
                              .contains(controller.text.trim().toLowerCase()) &&
                          (filter == 0 ||
                              (filter == 1
                                  ? t.kind == TitleKind.movie
                                  : t.kind == TitleKind.series)),
                    )
                    .toList();
                return results.isEmpty
                    ? const Center(
                        child: Text('No matches. Try another title.'),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 190,
                              mainAxisExtent: 270,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 14,
                            ),
                        itemCount: results.length,
                        itemBuilder: (_, i) => PosterCard(results[i]),
                      );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
