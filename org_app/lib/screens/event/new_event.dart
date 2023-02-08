import 'package:flutter/material.dart';
import 'package:org/widgets/screen.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  @override
  Widget build(BuildContext context) {
    return Screen(ab: AppBar(),builder:(data) => const Text("Add"),);
  }
}