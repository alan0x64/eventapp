import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';

import '../models/user.dart';
import '../net/HTTP.dart';
import '../utilities/shared.dart';
import '../widgets/dialog.dart';
import 'users/qr.dart';
import 'password.dart';
import 'users/edit_user.dart';
import 'users/user_view.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Response res = Response();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Settings", button: const BackButton()),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Account'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                onPressed: (context) {
                  goto(context, const UserProfilePage());
                },
                leading: const Icon(Icons.person),
                title: const Text('Account Information'),
              ),
              SettingsTile.navigation(
                onPressed: (context) {
                  goto(context, QRScreen());
                },
                leading: const Icon(Icons.qr_code),
                title: const Text('QR Account Info'),
              ),
              SettingsTile.navigation(
                onPressed:(context) {
                  goto(context, EditUser());
                },
                leading: const Icon(Icons.edit),
                title: const Text('Edit Account'),
              ),
              SettingsTile.navigation(
                onPressed: (context) => {goto(context, const UpdatePassword())},
                leading: const Icon(Icons.password),
                title: const Text('Chnage Password'),
              ),
              SettingsTile.navigation(
                onPressed: (context) {
                  showDialog(
                      context: context,
                      builder: ((context) => const CustomDialog(
                            quit: true,
                            bigText: "Sure You Wanna Delete Account?",
                            smallerText:
                                "Please be advised that executing this action will permanently delete all data, excluding any data associated with the Certificates. This operation cannot be undone",
                            fun: deleteAccount,
                          )));
                },
                leading: const Icon(Icons.delete),
                title: const Text('Delete Account'),
              ),
              SettingsTile.navigation(
                onPressed: (context) => {
                  showDialog(
                      context: context,
                      builder: ((context) => const CustomDialog(
                            quit: true,
                            bigText: "Are you sure you want to sing out?",
                            smallerText:
                                "You Need To Log In Again In Order To Use The App",
                            fun: logout,
                            bc: Colors.red,
                          )))
                },
                leading: const Icon(Icons.exit_to_app),
                title: const Text('SingOut'),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
