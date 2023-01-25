import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
        image: AssetImage(images[4]),
        fit: BoxFit.cover,
      ))),
      SizedBox(
        width: 250.0,
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 30.0,
            fontFamily: 'Agne',
          ),
          child: AnimatedTextKit(
            repeatForever: true,
            animatedTexts: [
              TypewriterAnimatedText('Discipline is the best tool'),
              TypewriterAnimatedText('Design first, then code'),
              TypewriterAnimatedText('Do not patch bugs out, rewrite them'),
              TypewriterAnimatedText('Do not test bugs out, design them out'),
            ],
            onTap: () {
            },
          ),
        ),
      )
    ]);
  }
}
