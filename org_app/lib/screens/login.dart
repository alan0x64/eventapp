// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/event/home.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(images[0]),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        body: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    alignment: Alignment.center,
                    child: Text(
                      "Login",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AppTextbox(
                    init: "patato@patato.com",
                    name: "email",
                    ht: "Email",
                    lt: "Email",
                    valis: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email()
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextbox(
                      init: "patato",
                      name: "password",
                      ht: "Password",
                      lt: "password",
                      ob: true,
                      valis: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.min(8),
                      ]),
                  const SizedBox(height: 40),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          if (!_formKey.currentState!.validate()) return;
                          String email =
                              _formKey.currentState!.fields['email']!.value;
                          String password =
                              _formKey.currentState!.fields['password']!.value;

                          Map<String, dynamic> data = {
                            "orgdata": {"email": email, "password": password}
                          };

                          Response res = await login(data);
                          if (res.statusCode == 400) {
                            snackbar(context, res.data['msg'], 3);
                            return;
                          }

                          await storeTokens(res.data['RT'], res.data['AT']);
                          gotoClear(context, const Home());
                        } catch (e) {
                          snackbar(context, e.toString(), 3);
                          Console.log(e);
                        }
                      },
                      child: const Text("Login")),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        if (kDebugMode) {
                          print(await isTokenExp("RT"));
                          print(await isTokenExp("AT"));
                        }
                        snackbar(context, "OMG WHAT HAVE YOU DONE!!", 2);
                      },
                      child: const Text("DO NOT TOUCH!!!")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
