// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utilities/shared.dart';

class UserAvatar extends StatefulWidget {
  XFile? image;
  String netPath;
  VoidCallback editButton;

  bool isEdit;

  UserAvatar({
    super.key,
    required this.image,
    required this.netPath,
    required this.editButton,
    required this.isEdit,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      buildImage(profile: widget.image, imagepath: widget.netPath),
      buildEditIcon(
        Colors.red,
        const EdgeInsets.fromLTRB(230, 170, 0, 0),
        widget.isEdit,
        () => widget.editButton(),
      )
    ]);
  }
}
