import 'package:deligo/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PortfolioItem extends StatelessWidget {
  final String imageUrl;

  const PortfolioItem({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PhotoView(imageProvider: CachedImageProvider(imageUrl)),
          ),
        ),
        child: CachedImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
