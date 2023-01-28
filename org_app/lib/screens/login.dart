import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:org/models/org.dart';
import 'package:org/net/auth.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/text.dart';
import 'package:org/widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  final int mode;
  const LoginScreen(int userOrOrgMode, {super.key, this.mode = 1});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> images = [
    'assets/backgrounds/con_1.jpg',
    'assets/backgrounds/con_2.jpg',
    'assets/backgrounds/con_3.jpg',
    'assets/backgrounds/con_4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.bottomLeft,
                child: AppText(
                    text: "LogIn",
                    textStyle: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold, fontSize: 30)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.all(10),
                child: AppTextbox(
                  name: "email",
                  ht: "Email",
                  lt: "Email",
                  valis: [
                      FormBuilderValidators.required(errorText:"Required"),
                    FormBuilderValidators.email()
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(10),
                child: AppTextbox(
                    name: "password",
                    ht: "Password",
                    lt: "password",
                    valis: [
                      FormBuilderValidators.required(errorText:"Required"),
                      FormBuilderValidators.min(8),
                      FormBuilderValidators.match(
                          r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
                          errorText:
                              "Must contain at least one letter and one number")
                    ]),
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_formKey.currentState!.validate()) {
                        return;
                      }
                      String email =
                          _formKey.currentState!.fields['email']!.value;
                      String password =
                          _formKey.currentState!.fields['password']!.value;

                      Map<String, dynamic> data = {
                        "orgdata": {"email": "org@org.com", "password": "org"}
                      };

                      dynamic res = await login(data);
                      storeTokens(res.data['RT'], res.data['AT']);
                      Console.log(res['status']);
                    } catch (e) {
                      Console.log(e);
                    }
                  },
                  child: const Text("Login")),
            )
          ],
        ),
      )
    ]);
  }
}
