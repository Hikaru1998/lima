import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Artwork extends StatelessWidget {
  const Artwork(this.image, {super.key, this.width = 800});
  final String image;
  final int width;
  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: image.startsWith('https://')
        ? image
        : image.isEmpty
        ? ''
        : 'https://images.unsplash.com/$image?w=$width&q=85&fit=crop',
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    placeholder: (_, url) => Container(color: const Color(0xFF20232B)),
    errorWidget: (_, url, error) => Container(
      color: const Color(0xFF20232B),
      child: const Center(
        child: Icon(Icons.landscape_outlined, color: Colors.white24, size: 44),
      ),
    ),
  );
}
