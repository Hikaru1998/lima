import 'package:flutter/material.dart';

import '../models/title.dart';
import 'poster_card.dart';

class CatalogSection extends StatelessWidget {
  const CatalogSection(this.label, this.titles, {super.key});
  final String label;
  final List<CatalogTitle> titles;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Text(
            label,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 235,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            itemCount: titles.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                SizedBox(width: 138, child: PosterCard(titles[i])),
          ),
        ),
      ],
    ),
  );
}
