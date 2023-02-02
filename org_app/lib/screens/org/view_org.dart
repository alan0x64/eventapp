import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:org/models/org.dart';
import 'package:org/widgets/screen.dart';
import 'package:org/widgets/textfield.dart';

class ProfileScreen extends StatefulWidget {
  final Org data;

  const ProfileScreen({super.key, required this.data});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Screen(
        ab: AppBar(),
        wid: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppTextbox(
              name: "name",
              ht: "Organization Name",
              lt: "Organization Name",
              init: widget.data.orgName,
              valis: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(3),
              ],
            ),
            AppTextbox(
              name: "emai;",
              ht: "Eame",
              lt: "Eame",
              init: widget.data.email,
              valis: [
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
                FormBuilderValidators.minLength(5),
              ],
            ),
            ElevatedButton(onPressed: () {}, child: const Text("S"))
          ],
        ));
  }
}