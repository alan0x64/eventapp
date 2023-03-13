import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utilities/shared.dart';

class ProfileWidget extends StatefulWidget {
  final String imagepath;
  final String bgPath;
  final VoidCallback onClick;
  final VoidCallback onClickbg;
  final bool isEdit;
  final XFile? profile;
  final XFile? background;

  const ProfileWidget(
      {super.key,
      required this.bgPath,
      required this.imagepath,
      required this.onClick,
      required this.onClickbg,
      required this.isEdit,
      this.profile,
      this.background});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildcoverimage(widget.background, widget.bgPath),
        buildImage(profile: widget.profile, imagepath: widget.imagepath),
      ],
    );
  }

  Widget buildcoverimage2(context, url) {
    return Container(
      color: Colors.grey,
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildImage2() {
    return Container(
      margin: const EdgeInsets.fromLTRB(160, 140, 0, 0),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: NetworkImage(widget.imagepath),
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            child: InkWell(
              onTap: widget.onClick,
            ),
          ),
        ),
      ),
    );
  }
}
