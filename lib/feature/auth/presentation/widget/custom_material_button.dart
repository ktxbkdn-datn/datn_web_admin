
import 'package:flutter/material.dart';

class KtxButton extends StatelessWidget {
  Color buttonColor;
  Color textColor, boderSideColor;
  String nameButton;
  double width;
  final Function()? onTap;
  KtxButton({
    super.key,
    this.buttonColor = Colors.white,
    required this.nameButton,
    this.textColor = Colors.black,
    this.boderSideColor = Colors.black,
    this.onTap,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: width,
      onPressed: onTap,
      height: 60,
      color: buttonColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: boderSideColor,
        ),
        borderRadius: BorderRadius.circular(50),
      ),

      child: Text(
        nameButton,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}