import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.all(5),
      child: Stack(
        children: [
          buildcoverimage(),
          if (widget.isEdit)
            buildEditIcon(color, const EdgeInsets.fromLTRB(320, 155, 0, 0),
                widget.onClickbg),
          buildImage(),
          buildEditIcon(
              color, const EdgeInsets.fromLTRB(220, 180, 0, 0), widget.onClick),
        ],
      ),
    );
  }

  Widget buildImage() {
    return Container(
      margin: const EdgeInsets.fromLTRB(140, 80, 0, 0),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: widget.profile!=null? loadImageFile(widget.profile as XFile,profile: true):loadImageNet(widget.imagepath,profile:true),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color, EdgeInsets x, VoidCallback fun) {
    return Container(
      margin: x,
      height: 35,
      width: 35,
      child: buildCirle(
        color: Colors.white,
        all: 3,
        child: buildCirle(
          color: color,
          all: 3,
          child: IconButton(
            onPressed: fun,
            color: Colors.white,
            icon: Icon(
              widget.isEdit ? Icons.add_a_photo : Icons.edit,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCirle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          // padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildcoverimage() {
    return Material(
        color: Colors.transparent,
        child: widget.background != null
            ? loadImageFile(widget.background!)
            : loadImageNet(widget.bgPath));
  }

  Widget loadImageFile(XFile image, {bool profile = false}) {
    double hight = 180;
    double width = double.infinity;
    BoxFit fit = BoxFit.fill;

    if (profile) {
      hight = 128;
      width = 128;
      fit = BoxFit.cover;
    }

    return SizedBox(
        width: width,
        height: hight,
        child:
        FittedBox(fit: fit, child: Image.file(File(image.path))));
  }

  Ink loadImageNet(path,{bool profile = false}) {
    double hight = 180;
    double width = double.infinity;
    BoxFit fit = BoxFit.fill;

    if (profile) {
      hight = 128;
      width = 128;
      fit = BoxFit.cover;
    }

    return Ink.image(
      image: NetworkImage(path),
      fit:fit,
      width: width,
      height: hight,
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