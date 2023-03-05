
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageDialog extends StatefulWidget {
  final String message;
  final String buttonOneText;
  final String buttonTwoText;
  final String buttonThreeText;

  final VoidCallback buttonOne;
  final VoidCallback buttonTwo;
  final VoidCallback buttonThree;

  final Widget icon;

  final bool showButtonThree;
  final bool cupertino;

  const MessageDialog(
      {super.key,
      required this.message,
      required this.buttonOneText,
      required this.buttonTwoText,
      required this.buttonThreeText,
      required this.buttonTwo,
      required this.buttonOne,
      required this.buttonThree,
      required this.icon,
      this.showButtonThree = true,
      this.cupertino = false});

  @override
  State<MessageDialog> createState() => MessageDialogState();
}

class MessageDialogState extends State<MessageDialog> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.5)),
        if (!widget.cupertino)
        Center(
            child:
              Dialog(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.icon,
                      const SizedBox(height: 20),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          
                          ElevatedButton(
                            onPressed: () => widget.buttonOne(),
                             child: Text(
                            widget.buttonOneText,
                            style: const TextStyle(color: Colors.white),
                          )),
                          
                          ElevatedButton(
                            onPressed: () => widget.buttonTwo(), 
                            child: Text(
                            widget.buttonTwoText,
                            style: const TextStyle(color: Colors.white),
                          ),),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                           if(widget.showButtonThree)
                          ElevatedButton(
                            onPressed: () => widget.buttonThree(), 
                            child: Text(
                            widget.buttonThreeText,
                            style: const TextStyle(color: Colors.white),),
                          
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
            if (widget.cupertino)
              Center(
                child: CupertinoAlertDialog(
                  title: widget.icon,
                  actions: [
                    CupertinoDialogAction(
                        onPressed: () => widget.buttonOne(),
                        child: Text(widget.buttonOneText)),
                    CupertinoDialogAction(
                        onPressed: () => widget.buttonTwo(),
                        child: Text(widget.buttonTwoText)),
                    if (widget.showButtonThree)
                      CupertinoDialogAction(
                          onPressed: () => widget.buttonThree(),
                          child: Text(widget.buttonThreeText))
                  ],
                  content: Text(widget.message),
                ),
              )
        ]
    );
  }
}
