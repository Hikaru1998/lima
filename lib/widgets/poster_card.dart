import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/title.dart';
import 'artwork.dart';

class PosterCard extends StatelessWidget {
  const PosterCard(this.title, {super.key});
  final CatalogTitle title;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Open ${title.name.replaceAll('\n', ' ')}',
    button: true,
    child: InkWell(
      onTap: () => context.push('/title/${title.id}'),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Artwork(title.image, width: 400),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 8,
                    bottom: 16,
                    child: Text(
                      title.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title.name.replaceAll('\n', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            '${title.year} · ${title.genre}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
