import 'package:flutter/material.dart';
import '../../data/CustomColors.dart';

class Rating extends StatefulWidget {
  final int ratingCount;
  final double ratingValue;

  const Rating({
    super.key,
    required this.ratingCount,
    required this.ratingValue,
  });

  @override
  State<Rating> createState() => _Rating();
}

class _Rating extends State<Rating> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < widget.ratingValue.floor()) {
              // Full star
              return Icon(
                Icons.star,
                color: CustomColors.primaryRating,
                size: 20,
              );
            } else if (index < widget.ratingValue &&
                widget.ratingValue - index >= 0.5) {
              return Icon(
                Icons.star_half,
                color: CustomColors.primaryRating,
                size: 20,
              );
            } else {
              return Icon(
                Icons.star_border,
                color: CustomColors.primaryRating,
                size: 20,
              );
            }
          }),
        ),
        const SizedBox(width: 6),
        Text(
          '(${widget.ratingCount})',
          style: TextStyle(fontSize: 14, color: CustomColors.secondaryRating),
        ),
      ],
    );
  }
}
