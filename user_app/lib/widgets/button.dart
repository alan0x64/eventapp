import 'package:EventLink/utilities/shared.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.text,
    required this.cb,
    this.color=Colors.orange,
  }) : super(key: key);

  final String text;
  final VoidCallback cb;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var textcolor = getTheme(context) == 0 ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {
          try {
            return cb();
          } catch (e) {
            Console.log(e);
            snackbar(context, e.toString(), 3);
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: BorderSide(color: color),
            ),
          ),
          elevation: MaterialStateProperty.all<double>(0),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(textcolor),
        ),
        child: Text(text),
      ),
    );
  }
}
