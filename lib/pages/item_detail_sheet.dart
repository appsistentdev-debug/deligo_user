import 'package:deligo/config/assets.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:flutter/material.dart';

class ItemDetailSheet extends StatelessWidget {
  final Product product;
  const ItemDetailSheet({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImage(
                imageUrl: product.imageUrls?.firstOrNull,
                height: MediaQuery.of(context).size.width * 0.24,
                width: MediaQuery.of(context).size.width * 0.24,
              ),
              const SizedBox(width: 16),
              SizedBox(
                //height: MediaQuery.of(context).size.width * 0.20,
                width: MediaQuery.of(context).size.width * 0.60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (product.foodType != null)
                          Image.asset(
                            product.foodType == "veg"
                                ? Assets.foodFoodVeg
                                : Assets.foodFoodNonveg,
                            height: 16,
                          ),
                        if (product.foodType != null) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.detail,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
