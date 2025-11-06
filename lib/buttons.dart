import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color color;
  final Color textcolor;
  final String buttonText;
  final dynamic buttonTapped;

  const MyButton({required this.color,required this.textcolor, required this.buttonText,this.buttonTapped,Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Material(
      color: color, // background color of the button
      borderRadius: BorderRadius.circular(45),
      child: InkWell(
        borderRadius: BorderRadius.circular(45),
        splashColor: Colors.white.withOpacity(0.3), // customize splash color
        onTap: buttonTapped,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          alignment: Alignment.center,
          child: Text(
            buttonText,
            style: TextStyle(
              color: textcolor,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
}
