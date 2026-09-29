import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/catalog_repository.dart';
import '../models/title.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => MockCatalogRepository(),
);
final catalogProvider = FutureProvider<List<CatalogTitle>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchCatalog(),
);
