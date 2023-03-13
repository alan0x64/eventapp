// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../net/HTTP.dart';
import '../../server.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';
import 'user_avatar.dart';
import 'user_form.dart';

class EditUser extends StatefulWidget {
  XFile? profiePic;
  EditUser({super.key});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final ImagePicker picker = ImagePicker();
  FORMKEY formkey = FORMKEY();
  Map<String, dynamic> fromdata = {};
  Response resx = Response();

  Future<Map<String, dynamic>> pickImageAndSaveState() async {
    widget.profiePic = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
    return getUserFromForm(context, formkey);
  }

  @override
  Widget build(BuildContext context) {
    return BuildFuture(
      callback: () => getUser(),
      mapper: (resData) => toUser(resData.data),
      builder: (data) {
        User userx = data;
        return Scaffold(
          appBar: buildAppBar(context, "Edit Account"),
          body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FormBuilder(
                key: formkey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 120, 0),
                      child: UserAvatar(
                          image: widget.profiePic,
                          netPath: userx.profilePic,
                          editButton: () async {
                            fromdata = await pickImageAndSaveState();
                          },
                          isEdit: true),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: UserForm(
                        hideinit: false,
                        userdata: userx,
                        singupMode: false,
                        resetSelectors: () {
                          widget.profiePic = null;
                          setState(() {});
                        },
                        mainButton: () async {
                          if (!formkey.currentState!.validate()) return;

                          if (widget.profiePic == null) {
                            resx = await runFun(
                              context,
                              () async {
                                return await updateUser(
                                    getUserFromForm(context, formkey));
                              },
                            );
                          } else {
                            FormRequestHandler(
                              create: false,
                              org_event_user: 2,
                              formKey: formkey,
                              context: context,
                              setState: () => setState(() {}),
                              formdata: getUserFromForm(context, formkey),
                              requestHandler: (data, res) async {
                                resx = await multipartRequest(
                                  token: "AT",
                                  data: data,
                                  method: "PUT",
                                  filefield1: "profilePic",
                                  filefield2: "",
                                  file: widget.profiePic,
                                  file2: null,
                                  url: "$devServer/user/update",
                                  addFields: (req, data) =>
                                      addUserFields(request: req, data: data),
                                );
                                return resx;
                              },
                            );
                          }
                          snackbar(context, resx.data['msg'], 4);
                        },
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}
