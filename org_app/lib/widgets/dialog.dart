// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/net/auth.dart';
import 'package:org/screens/login.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:provider/provider.dart';

class CustomDialog extends StatelessWidget {
  final String bigText;
  final String smallerText;
  final ResCallback fun;
  final Color bc;

  const CustomDialog({
    super.key,
    required this.bigText,
    required this.smallerText,
    required this.fun,
    this.bc = const Color.fromARGB(255, 182, 31, 21),
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Text(bigText),
        actionsOverflowButtonSpacing: 20,
        actions: [
          ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Color.fromARGB(255, 14, 192, 20)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel")),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(bc),
              ),
              onPressed: () async {
                await runFun(
                  context,
                  fun,
                );
                Provider.of<LocationProvider>(context,listen: false).setOrgLocation(LatLng(0,0));
                await clearTokens();
                gotoClear(context, const LoginScreen());
              },
              child: const Text("Continue")),
        ],
        content: Text(smallerText));
  }
}

// CupertinoAlertDialog(
        //   title: const Text("Sure You Wanna Delete Account?"),
        //   actions: [
        //     CupertinoDialogAction(
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //         child: const Text("Go Back")),
        //     CupertinoDialogAction(
        //         onPressed: () async {
        //           await runFun(context, widget.deleteFun);
        //           await clearTokens();
        //           gotoClear(context, LoginScreen());
        //         },
        //         child: const Text("Continue")),
        //   ],
        //   content: const Text(
        //       "This Will Cause All Your Data To Be Deleted But Data Such As Certifacte Will Remain,This Action Is Unreviersible"),
        // );