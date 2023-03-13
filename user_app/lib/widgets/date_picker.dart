// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppDateTImePicker extends StatefulWidget {
  bool ob;
  bool border;
  bool isSecret;
  bool hideinit;
  String name;
  String lt;
  String? ht;
  int ml;
  String? init;
  List<String? Function(DateTime?)> valis;
  TextInputType? keyboard;
  TextEditingController? txt = TextEditingController();

  AppDateTImePicker({
    super.key,
    required this.name,
    this.ht,
    this.ml = 1,
    this.init,
    this.lt = "",
    this.border = true,
    this.ob = false,
    this.keyboard,
    this.txt,
    this.hideinit = false,
    this.isSecret = false,
    required this.valis,
  });

  @override
  State<AppDateTImePicker> createState() => _AppDateTImePickerState();
}

class _AppDateTImePickerState extends State<AppDateTImePicker> {
  @override
  Widget build(BuildContext context) {
    final latestDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    DateTime? initvalue = DateTime.tryParse(widget.init as String)?? latestDate ;
    InputDecoration deco = InputDecoration(
        hintText: widget.ht,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)));

    if (widget.hideinit) {
      initvalue = null;
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lt,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
              height: 7,
            ),
            FormBuilderDateTimePicker(
              validator: FormBuilderValidators.compose(widget.valis),
              initialValue:initvalue, 
              name: widget.name,
              inputType: InputType.date,
              decoration: deco,
              firstDate: DateTime(1850),
              lastDate: latestDate,
            ),
          ],
        );
      },
    );
  }
}
