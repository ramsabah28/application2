import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImageFromNetwork extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double shimmerBottomInset;
  final BoxFit fit;

  const ShimmerImageFromNetwork({
    required this.imageUrl,
    required this.height,
    required this.width,
    this.shimmerBottomInset = 16.0,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  State<ShimmerImageFromNetwork> createState() => _ShimmerImageNetworkState();
}

class _ShimmerImageNetworkState extends State<ShimmerImageFromNetwork> {
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
          Align(
            alignment: Alignment.topCenter,
            child: Shimmer(
              gradient: _shimmerGradient,
              period: const Duration(milliseconds: 500),
              child: SizedBox(
                width: widget.width,
                height: (widget.height - widget.shimmerBottomInset).clamp(0.0, double.infinity),
                child: Container(color: Colors.white),
              ),
            ),
          ),
        Image.network(
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
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
