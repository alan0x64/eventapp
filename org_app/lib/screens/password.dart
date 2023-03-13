
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/login.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/textfield.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final _formKey = GlobalKey<FormBuilderState>();
  TextEditingController newpassordCon = TextEditingController();

  List<String? Function(String?)> valis = [
    FormBuilderValidators.required(),
    FormBuilderValidators.minLength(3),
    // FormBuilderValidators.match(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    //     errorText: "Must contain at least one letter and one number")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Change Password"),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Change Password',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 20.0,
                ),
                AppTextbox(
                  name: "currentPassword",
                  border: false,
                  ht: "Current Password",
                  ob: true,
                  valis: [
                    valis[0],
                    valis[1],
                  ],
                ),
                const SizedBox(height: 16.0),
                AppTextbox(
                  name: "newPassword",
                  border: false,
                  ht: "New Password",
                  valis: valis,
                  txt: newpassordCon,
                  ob: true,
                ),
                const SizedBox(height: 16.0),
                AppTextbox(
                  name: "conPassword",
                  border: false,
                  ht: "Conform Password",
                  ob: true,
                  valis: [
                    ...valis,
                    ((p0) {
                      if (p0 != newpassordCon.text) {
                        return "Password Do Not Match";
                      }
                      return null;
                    })
                  ],
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  child: const Text('Save Password'),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    Map<String, dynamic> data = {
                      "cuurentPassword": _formKey
                          .currentState!.fields['currentPassword']!.value,
                      "newPassword":
                          _formKey.currentState!.fields['newPassword']!.value,
                    };

                    Response res = await runFun(
                      context,
                      () async {
                        return await runFun(
                          context,
                          () async => await updatePassword(data),
                        );
                      },
                    );

                    logout();
                    clearTokens();
                    gotoClear(context, const LoginScreen());
                    snackbar(context, res.data['msg'], 2);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
