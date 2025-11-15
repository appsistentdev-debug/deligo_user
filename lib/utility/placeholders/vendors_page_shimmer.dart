import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VendorsPageShimmer extends StatelessWidget {
  final bool showGrid;
  final bool showTitle;
  final int itemCount;

  const VendorsPageShimmer({
    super.key,
    this.showGrid = true,
    this.showTitle = true,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final containerColor = isDark ? Colors.grey[700]! : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        if (showTitle)
          _buildTitleShimmer(baseColor, highlightColor, containerColor),
        if (showTitle) const SizedBox(height: 16),
        Expanded(
          child: showGrid
              ? _buildGridShimmer(baseColor, highlightColor, containerColor)
              : _buildListShimmer(baseColor, highlightColor, containerColor),
        ),
      ],
    );
  }

  Widget _buildTitleShimmer(
      Color baseColor, Color highlightColor, Color containerColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 22,
        width: 200,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildGridShimmer(
      Color baseColor, Color highlightColor, Color containerColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.63,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildGridItemShimmer(containerColor),
      ),
    );
  }

  Widget _buildListShimmer(
      Color baseColor, Color highlightColor, Color containerColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 32),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) => _buildListItemShimmer(containerColor),
      ),
    );
  }

  Widget _buildGridItemShimmer(Color containerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              // Vendor name
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              // Address
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Time and distance
              Container(
                height: 11,
                width: 100,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: containerColor,
              ),
              const SizedBox(height: 8),
              // Rating section
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 50,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItemShimmer(Color containerColor) {
    return Row(
      children: [
        // Image placeholder
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor name
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                // Address
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Preparation time and distance
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                // Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  color: containerColor,
                ),
                const Spacer(),
                // Rating section
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 50,
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
