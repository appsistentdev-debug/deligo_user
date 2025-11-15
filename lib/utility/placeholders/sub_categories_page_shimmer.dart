import 'package:deligo/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubCategoriesPageShimmer extends StatelessWidget {
  final int itemCount;

  const SubCategoriesPageShimmer({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return index == 0
            ? Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  _buildCategoriesShimmer(context),
                  const SizedBox(height: 24),
                  _buildSectionTitleShimmer(context),
                  const SizedBox(height: 16),
                  _buildVendorItemShimmer(context),
                ],
              )
            : _buildVendorItemShimmer(context);
      },
    );
  }

  Widget _buildCategoriesShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? darkGradientColor2 : Colors.grey[100]!,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? darkGradientColor2 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 60,
              decoration: BoxDecoration(
                color: isDark ? darkGradientColor2 : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitleShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? darkGradientColor1 : lightGradientColor1,
      highlightColor: isDark ? darkGradientColor2 : lightGradientColor2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 20,
          width: 200,
          decoration: BoxDecoration(
            color: isDark ? darkGradientColor2 : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorItemShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? darkGradientColor1 : lightGradientColor1,
      highlightColor: isDark ? darkGradientColor2 : lightGradientColor2,
      child: Row(
        children: [
          // Image placeholder
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: isDark ? darkGradientColor2 : Colors.white,
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
                      color: isDark ? darkGradientColor2 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Address
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: isDark ? darkGradientColor2 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Preparation time and distance
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: isDark ? darkGradientColor2 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  // Divider
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: isDark ? darkGradientColor2 : Colors.white,
                  ),
                  const Spacer(),
                  // Rating section
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isDark ? darkGradientColor2 : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: isDark ? darkGradientColor2 : Colors.white,
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
      ),
    );
  }
}
