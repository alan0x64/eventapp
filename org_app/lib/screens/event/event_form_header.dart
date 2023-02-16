import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utilities/shared.dart';

class EventFormImage extends StatefulWidget {
  
  final String eventPicPath;
  final XFile? eventPic;

  final VoidCallback onClick;
  final bool isEdit;
  
  const EventFormImage({
    super.key, 
    required this.eventPicPath,
    required this.eventPic, 
    required this.onClick, 
    required this.isEdit, 
    });

  @override
  State<EventFormImage> createState() => _EventFormImageState();
}

class _EventFormImageState extends State<EventFormImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Stack(
        children: [
           buildcoverimage(widget.eventPic, widget.eventPicPath),
            buildEditIcon(
              Colors.blue, 
              const EdgeInsets.fromLTRB(300, 160, 0, 0),
              widget.isEdit,
              widget.onClick
              ),
        ]),
    );
  }
}