import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:org/widgets/animated_texts.dart';

class LoginScreen extends StatefulWidget {
  final int mode;
  const LoginScreen(int userOrOrgMode, {super.key, this.mode = 1});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> images = [
    'assets/backgrounds/con_1.jpg',
    'assets/backgrounds/con_2.jpg',
    'assets/backgrounds/con_3.jpg',
    'assets/backgrounds/con_4.jpg',
    'assets/backgrounds/con_5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    int randomImage = Random().nextInt(5);
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
        image: AssetImage(images[randomImage]),
        fit: BoxFit.cover,
      ))),
      Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(15),
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                      fontSize: 27, fontWeight: FontWeight.bold),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: texts,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  color: (Colors.grey[900])!.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(12),
                width: 500,
                height: 100,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Column(children: const [

                    ]),
                  ),
                ),
              )),
        ],
      )
    ]);
  }
}
