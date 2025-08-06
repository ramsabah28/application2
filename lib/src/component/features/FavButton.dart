import 'package:flutter/material.dart';
import '../../data/CustomColors.dart';

class FavButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const FavButton({Key? key, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 65,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.secondary,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: onPressed,
          child: Icon(Icons.favorite, color: Colors.white),
        ),
      ),
    );
  }
}
