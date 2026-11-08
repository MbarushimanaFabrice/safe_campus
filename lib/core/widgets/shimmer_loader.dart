import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]!
          : Colors.grey[700]!,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[100]!
          : Colors.grey[500]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerListLoader extends StatelessWidget {
  final int itemCount;

  const ShimmerListLoader({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const ShimmerLoader(width: 60, height: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoader(
                          width: double.infinity,
                          height: 16,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 8),
                        ShimmerLoader(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 14,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 8),
                        ShimmerLoader(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 12,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
