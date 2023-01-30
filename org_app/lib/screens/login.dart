// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/event/home.dart';
import 'package:org/screens/event/new_event.dart';
import 'package:org/screens/org/view_org.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/drawer.dart';
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
    return FormBuilder(
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
                init: "patato@patato.com",
                name: "email",
                ht: "Email",
                lt: "Email",
                valis: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email()
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(10),
              child: AppTextbox(
                  init: "patato",
                  name: "password",
                  ht: "Password",
                  lt: "password",
                  ob: true,
                  valis: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.min(8),
                  ]),
            ),
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
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

                    Org orgdata = mapOrg(await getProfile());

                    snackbar(context, "Login Sucessful", 3);

                    Console.log(orgdata.orgPic);

                    gotoClear(
                        context,
                        UserDrawer(
                          email: orgdata.email,
                          name: orgdata.orgName,
                          picURL: orgdata.orgPic,
                          profileScreen: const profileScreen(),
                          addEventScreen: const addEvent(),
                          homeScreen: const Home(),
                          boxColor: const Color.fromARGB(255, 192, 148, 46),
                        ));
                  } catch (e) {
                    Console.log(e);
                  }
                },
                child: const Text("Login")),
          ),
        ],
      ),
    );
  }
}
