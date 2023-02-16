// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/org.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/screens/org/org_form.dart';
import 'package:org/server.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/profile_widget.dart';

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
  void initState() {
    super.initState();
    if (getFromProvider<LocationProvider>(context, (provider) => provider[0]) !=
        null) {
      getFromProvider<LocationProvider>(
          context, (provider) => provider.setOrgLocation(LatLng(0, 0)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    return Scaffold(
      appBar: buildAppBar(context, "Sing Up", button: const BackButton(),showdialog: false),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              if (widget.profileImage == null || widget.backgroundImage == null)
                TextButton(
                    onPressed: () async {
                      widget.profileImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    child: const Text("Choose Profile Picture")),
              if (widget.profileImage == null || widget.backgroundImage == null)
                TextButton(
                    onPressed: () async {
                      widget.backgroundImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    child: const Text("Choose Background Picture")),
              if (widget.profileImage != null && widget.backgroundImage != null)
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
              Container(
                margin: const EdgeInsets.all(15),
                child: OrgForm(
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
                      create: true,
                      org_event_user: 0,
                      formKey: _formKey,
                      context: context,
                      location: getLocationString(context, 0),
                      setState: () => setState(() {}),
                      formdata: getOrgFromForm(context, _formKey),
                      requestHandler: (data, res) async {
                        Response resx = await multipartRequest(
                          token: "0",
                          data: data,
                          method: "POST",
                          filefield1: "orgPic",
                          filefield2: "orgBackgroundPic",
                          file: widget.profileImage,
                          file2: widget.backgroundImage,
                          url: "$devServer/org/register",
                          addFields: (req, data) =>
                              addOrgFields(request: req, data: data),
                        );
                        if (resx.statusCode == 200) {
                          widget.profileImage = null;
                          widget.backgroundImage = null;
                          getFromProvider<LocationProvider>(
                              context,
                              (provider) =>
                                  provider.setOrgLocation(LatLng(0, 0)));
                          _formKey.currentState!.reset();
                          
                        }
                        return resx;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
