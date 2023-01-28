// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AppTextbox extends StatelessWidget {
  bool ob;
  String name;
  String ht;
  String lt;
  Icon? icon;
  Color color;

  String? Function(String?)? vali;
  List<String? Function(String?)>? valis;

  AppTextbox(
      {super.key,
      required this.name,
      required this.ht,
      required this.lt,
      this.icon,
      this.valis,
      this.vali,
      this.ob = false,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
            width: 300,
            child: FormBuilderTextField(
                validator: vali,
                obscureText: ob,
                name: name,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: color),
                        borderRadius: BorderRadius.circular(8)),
                    hintText: ht)));
      },
    );
  }
}
