import 'package:flutter/material.dart';
import 'package:org/models/org.dart';
import 'package:org/screens/org/edit_org.dart';
import 'package:org/screens/org/view_org.dart';
import 'package:org/screens/password.dart';
import 'package:org/utilities/shared.dart';
import 'package:settings_ui/settings_ui.dart';

import '../widgets/dialog.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context,"Settings", button: const BackButton()),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Account'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                onPressed: (context) => goto(context,  ProfileScreen()),
                leading: const Icon(Icons.person),
                title: const Text('Account Information'),
              ),
              SettingsTile.navigation(
                onPressed: (context) => goto(context,EditOrg()),
                leading: const Icon(Icons.edit),
                title: const Text('Edit Account'),
              ),
                SettingsTile.navigation(
                onPressed: (context) => {
                  goto(context, const UpdatePassword())
                },
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
                onPressed: (context) => showDialog(
                    context: context,
                    builder: ((context) => const CustomDialog(
                        quit: true,
                          bigText: "Are you sure you want to sing out?",
                          smallerText: "You Need To Log In Again In Order To Use The App",
                          fun: logout,
                          bc: Colors.red,
                        ))),
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
