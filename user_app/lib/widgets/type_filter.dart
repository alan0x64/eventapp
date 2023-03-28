import 'package:flutter/material.dart';

import '../utilities/shared.dart';

class TypeFilter extends StatefulWidget {
  final int selectedbutton;
  final void Function(int selectbutton) state;
  
  const  TypeFilter({super.key, required this.selectedbutton, required this.state});

  @override
  State<TypeFilter> createState() => _TypeFilterState();
}

class _TypeFilterState extends State<TypeFilter> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    getTheme(context) != 0 ? Colors.white : Colors.black),
                backgroundColor: MaterialStateProperty.all<Color>(
                  widget.selectedbutton == -1
                      ? Colors.blue
                      : getTheme(context) == 0
                          ? const Color.fromARGB(255, 199, 197, 197)
                          : const Color.fromARGB(228, 26, 25, 25),
                ),
              ),
              onPressed: () {
                widget.state(-1);
              },
              child: const Text("Any"),
            ),
          ),
        ),
        Expanded(
          flex: 0,
          child: Container(
            margin: const EdgeInsets.all(5),
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    getTheme(context) != 0 ? Colors.white : Colors.black),
                backgroundColor: MaterialStateProperty.all<Color>(
                  widget.selectedbutton == 0
                      ? Colors.blue
                      : getTheme(context) == 0
                          ? const Color.fromARGB(255, 199, 197, 197)
                          : const Color.fromARGB(228, 26, 25, 25),
                ),
              ),
              onPressed: () {
                widget.state(0);
              },
              child: const Text("Confrance"),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(5),
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    getTheme(context) != 0 ? Colors.white : Colors.black),
                backgroundColor: MaterialStateProperty.all<Color>(
                  widget.selectedbutton == 1
                      ? Colors.blue
                      : getTheme(context) == 0
                          ? const Color.fromARGB(255, 199, 197, 197)
                          : const Color.fromARGB(228, 26, 25, 25),
                ),
              ),
              onPressed: () {
                widget.state(1);
              },
              child: const Text("Seminer"),
            ),
          ),
        ),
      ],
    );
  }
}
