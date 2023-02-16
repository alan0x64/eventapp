// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/event/home.dart';
import 'package:org/screens/org/org_sing_up.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/textfield.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool allowPress = true;
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
        appBar: buildAppBar(context, "Origanazation App",showdialog: false),
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
                    init: "kpop2@org.com",
                    name: "email",
                    ht: "Email",
                    lt: "Email",
                    valis: [
                      FormBuilderValidators.required(),
                      // FormBuilderValidators.email()
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextbox(
                      init: "kpopkpop",
                      name: "password",
                      lt: "Password",
                      ml: 1,
                      ob: true,
                      valis: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(8),
                      ]),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              goto(context, SingUp());
                            } catch (e) {
                              String errorMessage =
                                  e.toString().split('\n').take(5).join('\n');
                              snackbar(context, errorMessage, 2);
                            }
                          },
                          child: const Text("Sing Up")),
                      ElevatedButton(
                          onPressed: allowPress
                              ? () async {
                                  try {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    String email = _formKey
                                        .currentState!.fields['email']!.value;
                                    String password = _formKey.currentState!
                                        .fields['password']!.value;

                                    Map<String, dynamic> data = {
                                        "email": email,
                                        "password": password
                                    };

                                    Response res = await login(data);
                                    if (res.statusCode != 200) {
                                      snackbar(context, res.data['msg'], 3);
                                      setState(() {
                                        allowPress = true;
                                      });
                                      return;
                                    }

                                    await storeTokens(
                                        res.data['RT'], res.data['AT']);
                                    setState(() {
                                      allowPress = false;
                                    });
                                    gotoClear(context, const Home());
                                  } catch (e) {
                                    snackbar(context, e.toString(), 3);
                                    Console.log(e);
                                  }
                                }
                              : null,
                          child: const Text("Login")),
                    ],
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          !await launchUrl(
                              Uri.parse('https://youtu.be/dDFqbVG-Hsk'));
                        } catch (e) {
                          String errorMessage =
                              e.toString().split('\n').take(5).join('\n');
                          snackbar(context, errorMessage, 2);
                          Console.log(errorMessage);
                        }
                      },
                      child: const Text("DO NOT TOUCH!!!"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
