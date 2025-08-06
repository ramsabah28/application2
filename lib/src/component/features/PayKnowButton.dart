import 'package:flutter/material.dart';


class PayKnowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const PayKnowButton({Key? key, this.onPressed, this.label = 'Jetzt Kaufen'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: onPressed,
          child: Text(label, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
