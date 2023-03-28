import 'package:flutter/material.dart';

import '../utilities/shared.dart';

class StatusFilter extends StatefulWidget {
  final int selectedbutton;
  final void Function(int selectbutton) state;

  const StatusFilter({super.key, required this.selectedbutton, required this.state});

  @override
  State<StatusFilter> createState() => _StatusFilterState();
}

class _StatusFilterState extends State<StatusFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(5),
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
                child: const Text("Upcoming"),
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
                child: const Text("Open"),
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
                    widget.selectedbutton == 2
                        ? Colors.blue
                        : getTheme(context) == 0
                            ? const Color.fromARGB(255, 199, 197, 197)
                            : const Color.fromARGB(228, 26, 25, 25),
                  ),
                ),
                onPressed: () {
                  widget.state(2);
                },
                child: const Text("Passed"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
