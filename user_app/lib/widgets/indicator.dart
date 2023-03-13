import 'package:flutter/material.dart';

class Indicator extends StatefulWidget {
  final bool failed;
  const Indicator({super.key, this.failed = true});

  @override
  State<Indicator> createState() => IndicatorState();
}

class IndicatorState extends State<Indicator> {
 late MaterialColor color;
late IconData icon;
  @override
  Widget build(BuildContext context) {
    color = widget.failed ? Colors.red : Colors.green;
    icon = widget.failed ? Icons.close : Icons.check;
    return Center(
      child: CircleAvatar(
        child: Icon(
          icon,
          color:color,
        ),
      ),
    );
  }
}
