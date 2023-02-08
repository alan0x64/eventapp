// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppTextbox extends StatefulWidget {
  bool ob;
  bool border;
  bool isSecret;
  String name;
  String lt;
  String? ht;
  String? init;
  int ml;
  TextInputType? keyboard;
  TextEditingController? txt = TextEditingController();
  bool hideinit;

  List<String? Function(String?)> valis;

  AppTextbox(
      {super.key,
      required this.name,
      required this.valis,
      this.ht,
      this.ml = 1,
      this.init,
      this.lt = "",
      this.border = true,
      this.ob = false,
      this.keyboard,
      this.txt,
      this.hideinit = false,
      this.isSecret = false});

  @override
  State<AppTextbox> createState() => _AppTextboxState();
}

class _AppTextboxState extends State<AppTextbox> {
  @override
  Widget build(BuildContext context) {
    InputDecoration deco =
        InputDecoration(hintText: widget.ht, suffix: obscurebutton());

    if (widget.hideinit) {
      widget.init = "";
    }

    if (widget.border) {
      deco = InputDecoration(
          hintText: widget.ht,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)));
    }
    if (widget.isSecret) {
      deco = InputDecoration(
          suffix: obscurebutton(),
          hintText: widget.ht,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)));
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
            FormBuilderTextField(
              controller: widget.txt,
              keyboardType: widget.keyboard,
              maxLines: widget.ml,
              initialValue: widget.init,
              validator: FormBuilderValidators.compose(widget.valis),
              obscureText: widget.ob,
              name: widget.name,
              decoration: deco,
            ),
          ],
        );
      },
    );
  }

  Widget obscurebutton() {
    return IconButton(
      onPressed: () {
        widget.ob == true ? widget.ob = false : widget.ob = true;
        setState(() {});
      },
      icon: Icon(widget.ob ? Icons.visibility : Icons.visibility_off),
    );
  }
}