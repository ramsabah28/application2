import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter; // For backdrop blur

class SaleCards extends StatelessWidget {
  const SaleCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(top: 1, left: 10, right: 10),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/3dModels/3d-dragon.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment(0.0, -0.96),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
                    ),
                    child: _ModernTitle(text: 'Resin Modelle'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernTitle extends StatelessWidget {
  final String text;
  const _ModernTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    const fontSize = 30.0;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.black.withOpacity(0.55);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outline
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            foreground: strokePaint,
          ),
        ),
        // Gradient fill + subtle inner shadow impression using dark shadow
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFAFAFA),
              Color(0xFFE0E0E0),
              Color(0xFFBDBDBD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: const Text(
            'Resin Modelle',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
