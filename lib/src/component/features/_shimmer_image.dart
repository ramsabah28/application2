import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage extends StatefulWidget {
  final String imageUrl;
  const ShimmerImage({required this.imageUrl, super.key});

  @override
  State<ShimmerImage> createState() => _ShimmerImageState();
}

class _ShimmerImageState extends State<ShimmerImage> {
  bool _isLoaded = false;

  static const _shimmerGradient = LinearGradient(
    colors: [Color(0xFFEBEBF4), Color(0xFFFFFF), Color(0xFFEBEBF4)],
    stops: [0.1, 0.2, 0.3],
    begin: Alignment(-1.0, -0.6),
    end: Alignment(1.0, 0.8),
    tileMode: TileMode.clamp,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isLoaded)
          Shimmer(
            gradient: _shimmerGradient,
            period: const Duration(milliseconds: 500),
            child: Container(
              width: 150,
              height: 150,
              color: Colors.white,
            ),
          ),
        Image.asset(
          widget.imageUrl,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -1),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null && !_isLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _isLoaded = true);
              });
            }
            return child;
          },
        ),
      ],
    );
  }
}
