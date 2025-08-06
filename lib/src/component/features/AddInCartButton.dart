import 'package:flutter/material.dart';
import '../../data/CustomColors.dart';

class AddInCartButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const AddInCartButton({Key? key, this.onPressed, this.label = 'In den Einkaufswagen'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.primery,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            textStyle: TextStyle(
              fontSize: 14,
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
