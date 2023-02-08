
// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/org/form.dart';
import 'package:org/server.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/profile_widget.dart';
import 'package:provider/provider.dart';

class SingUp extends StatefulWidget {
  XFile? profileImage;
  XFile? backgroundImage;

  SingUp({super.key});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    return Scaffold(
      appBar: buildAppBar(context, "Sing Up", button: const BackButton()),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                if (widget.profileImage == null ||
                    widget.backgroundImage == null)
                  TextButton(
                      onPressed: () async {
                        widget.profileImage =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                      child: const Text("Choose Profile Picture")),
                if (widget.profileImage == null ||
                    widget.backgroundImage == null)
                  TextButton(
                      onPressed: () async {
                        widget.backgroundImage =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                      child: const Text("Choose Background Picture")),
                if (widget.profileImage != null &&
                    widget.backgroundImage != null)
                  ProfileWidget(
                    bgPath: "$devServer/uploads/plus2.png",
                    imagepath: "$devServer/uploads/plus.png",
                    onClick: () async {
                      widget.profileImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    onClickbg: () async {
                      widget.backgroundImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    isEdit: true,
                    profile: widget.profileImage,
                    background: widget.backgroundImage,
                  ),
                OrgForm(
                  singupMode: true,
                  hideinit: true,
                  showReset: false,
                  mainButtonText: "Sing Up",
                  resetSelectors: () {},
                  mainButton: () {
                    if (widget.profileImage == null ||
                        widget.backgroundImage == null) {
                      snackbar(context, "Images Cannot Be Empty", 2);
                      return;
                    }

                    FormRequestHandler(
                        singup: true,
                        formKey: _formKey,
                        requestHandler: (data, res) async {
                          Response resx = await formREQ(
                              data,
                              widget.profileImage,
                              widget.backgroundImage,
                              "$devServer/org/register",
                              "POST",
                              token: "0");

                          if (resx.statusCode == 200) {
                            widget.profileImage = null;
                            widget.backgroundImage = null;
                            Provider.of<LocationProvider>(context,listen: false).setOrgLocation(LatLng(0,0));
                            _formKey.currentState!.reset();
                          }
                            return resx;
                        },
                        setState: () => setState(() {}),
                        context: context,
                        profileImage: widget.profileImage,
                        backgroundImage: widget.backgroundImage);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void singUpButton(XFile? profileImage, XFile? backgroundImage) async {}
}