// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';


import '../../models/user.dart';
import '../../widgets/date_picker.dart';
import '../../widgets/textfield.dart';

class UserForm extends StatefulWidget {
  User userdata;
  String mainButtonText;
  bool singupMode;
  bool hideinit;
  bool showReset;
  VoidCallback mainButton;
  VoidCallback resetSelectors;

  UserForm({
    super.key,
    this.userdata = const User(),
    required this.mainButton,
    required this.resetSelectors,
    required this.singupMode,
    this.mainButtonText = "Save",
    this.hideinit = false,
    this.showReset = true,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (widget.showReset)
                ElevatedButton(
                    onPressed: widget.resetSelectors,
                    child: const Text(
                      "Reset Image Selection",
                      style: TextStyle(fontSize: 14),
                    )),
            ],
          ),
        ),
        AppTextbox(
            name: 'fullName',
            lt: "Name",
            ht: "User Name",
            hideinit: widget.hideinit,
            init: widget.userdata.fullName,
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(3),
            ]),
                    const SizedBox(
          height: 25,
        ),
            AppTextbox(
            name: 'email',
            lt: "Email",
            ht: "User Email",
            init: widget.userdata.email,
            hideinit: widget.hideinit,
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.min(0),
              FormBuilderValidators.email(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        if (widget.singupMode)
          AppTextbox(
              name: 'password',
              lt: "Password",
              ht: "Password",
              hideinit: widget.hideinit,
              valis: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(8),
              ]),
        if (widget.singupMode)
          const SizedBox(
            height: 25,
          ),
        AppTextbox(
            name: 'phoneNumber',
            lt: "Phone Number",
            ht: "User Phone Number",
            hideinit: widget.hideinit,
            keyboard: TextInputType.number,
            init: widget.userdata.phoneNumber.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'department',
            lt: "Department",
            ht: "Department",
            hideinit: widget.hideinit,
            init: widget.userdata.department.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'faculty',
            lt: "Faculty",
            ht: "Faculty",
            hideinit: widget.hideinit,
            init: widget.userdata.faculty.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'scientific_title',
            lt: "Scientific Title",
            ht: "Scientific Title",
            hideinit: widget.hideinit,
            init: widget.userdata.scientificTitle.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'university',
            lt: "University",
            ht: "University",
            hideinit: widget.hideinit,
            init: widget.userdata.university.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppDateTImePicker(
          init: widget.userdata.dateOfBirth,
          hideinit: widget.hideinit,
          ht: "Date Of Birth",
          lt: "Date Of Birth",
          name: 'date_of_birth',
          valis: [FormBuilderValidators.required()],
        ),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'bio',
            ml: 10,
            lt: "Bio",
            ht: "Bio",
            init: widget.userdata.bio,
            hideinit: widget.hideinit,
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5),
              FormBuilderValidators.min(0),
            ]),
        const SizedBox(
          height: 25,
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          height: 45,
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 1),
          child: ElevatedButton(
              onPressed: widget.mainButton,
              child: Text(
                widget.mainButtonText,
                style: const TextStyle(fontSize: 14),
              )),
        )
      ],
    );
  }
}
