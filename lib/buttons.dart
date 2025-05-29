import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color color;
  final Color textcolor;
  final String buttonText;
  final dynamic buttonTapped;

  const MyButton({required this.color,required this.textcolor, required this.buttonText,this.buttonTapped,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttonTapped,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: color,
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(color: textcolor,fontSize: 23,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
