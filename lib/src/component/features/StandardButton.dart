import 'package:flutter/material.dart';

class StandardButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;
  final Color backgroundColor;

  const StandardButton({Key? key, this.onPressed, required this.icon, required this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColorLight,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: onPressed,
          child: icon
        ),
      ),
    );
  }
}
