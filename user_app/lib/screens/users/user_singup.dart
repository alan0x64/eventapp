
// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../net/HTTP.dart';
import '../../server.dart';
import '../../utilities/shared.dart';
import 'user_avatar.dart';
import 'user_form.dart';

class NewUser extends StatefulWidget {
  XFile? profile;

  NewUser({Key? key}) : super(key: key);

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final ImagePicker picker = ImagePicker();
  FORMKEY formkey = FORMKEY();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a New User Account"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FormBuilder(
          key: formkey,
          child: Column(
            children: [
              if (widget.profile == null)
                Center(
                  child: TextButton(
                    onPressed: () async {
                      widget.profile =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    child: const Text("Choose Profile Picture"),
                  ),
                ),
              if (widget.profile != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 120, 0),
                  child: UserAvatar(
                    editButton: () async {
                      widget.profile =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    image: widget.profile,
                    isEdit: true,
                    netPath: "",
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(10),
                child: UserForm(
                  mainButtonText: "Sing Up",
                  singupMode: true,
                  showReset: false,
                  resetSelectors: () {},
                  mainButton: () {
                    if (widget.profile == null ||
                        widget.profile!.name.isEmpty) {
                      return snackbar(context, "Select A Profile Image", 2);
                    }
                    if (!formkey.currentState!.validate()) return;

                    FormRequestHandler(
                      create: true,
                      org_event_user: 2,
                      formKey: formkey,
                      context: context,
                      setState: () => setState(() {}),
                      formdata: getUserFromForm(context, formkey),
                      requestHandler: (data, res) async {
                        Response resx = await multipartRequest(
                          token: "0",
                          data: data,
                          method: "POST",
                          filefield1: "profilePic",
                          filefield2: "",
                          file: widget.profile,
                          file2: null,
                          url: "$devServer/user/register",
                          addFields: (req, data) =>
                              addUserFields(request: req, data: data),
                        );

                        if (resx.statusCode == 200) {
                          widget.profile = null;
                          formkey.currentState!.reset();
                          snackbar(context, resx.data['msg'], 4);
                          moveBack(context, 1);
                        }
                        return resx;
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
