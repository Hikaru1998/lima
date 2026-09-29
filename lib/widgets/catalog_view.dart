import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_provider.dart';
import '../models/title.dart';

class CatalogView extends ConsumerWidget {
  const CatalogView({super.key, required this.builder});
  final Widget Function(List<CatalogTitle>) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(catalogProvider)
      .when(
        data: builder,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The catalog could not load.'),
              TextButton(
                onPressed: () => ref.invalidate(catalogProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}
