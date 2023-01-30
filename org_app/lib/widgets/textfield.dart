// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AppTextbox extends StatelessWidget {
  bool ob;
  String name;
  String ht;
  String lt;
  Icon? icon;
  Color color;
  String? init;

  List<String? Function(String?)> valis;

  AppTextbox(
      {super.key,
      required this.name,
      required this.ht,
      required this.lt,
      required this.valis,
      this.init,
      this.icon,
      this.ob = false,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
            width: 300,
            child: FormBuilderTextField(
                initialValue: init,
                validator: FormBuilderValidators.compose(valis),
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
// // FormBuilderValidators.match(
                    //     r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
                    //     errorText:
                    //         "Must contain at least one letter and one number")