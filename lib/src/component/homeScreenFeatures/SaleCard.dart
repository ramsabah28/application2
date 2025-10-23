import 'package:flutter/material.dart';

class SaleCards extends StatefulWidget {
  const SaleCards({Key? key}) : super(key: key);

  @override
  State<SaleCards> createState() => _SaleCardsState();
}

class _SaleCardsState extends State<SaleCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true); // Loops forever
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              image: AssetImage('lib/assets/3dGirl.png'),
              fit: BoxFit.cover,
              alignment: Alignment(0.0, -0.96),
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _controller,
              child: const Text(
                '30% Off',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
