// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:org/models/event.dart';
import 'package:org/models/org.dart';
import 'package:org/models/user.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/utilities/notofocation.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/dialog.dart';
import 'package:org/widgets/future_builder.dart';

import '../../models/cert.dart';
import '../../widgets/button.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String eventId;
  final bool blacklist;
  late int eventStatus;

  UserProfilePage({
    super.key,
    required this.userId,
    required this.eventId,
    required this.blacklist,
  });
  @override
  State<UserProfilePage> createState() {
    return _UserProfilePageState();
  }
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isDarkMode = false;
  User? userx;
  Event event = const Event();

  @override
  Widget build(BuildContext context) {
    return BuildFuture(
      callback: () async {
        event = toEvent((await getEventInfo(widget.eventId)).data);
        return getUser(widget.userId);
      },
      mapper: (resData) => toUser(resData.data),
      builder: (data) {
        Console.log(event.status);
        widget.eventStatus = event.status;
        userx = data;
        String fullName = userx!.fullName;
        return Scaffold(
            appBar: buildAppBar(context, "$fullName's Profile",
                button: const BackButton()),
            body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          height: 200,
                        ),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                userx!.profilePic,
                              ),
                              fit: BoxFit.cover,
                            ),
                            // border: Border.all(
                            //   color: Colors.white,
                            //   width: 1,
                            // ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                userx!.profilePic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userx!.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.email,
                                      style: const TextStyle(),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Phone Number',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.phoneNumber,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Department',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.department,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Faculty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.faculty,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Scientific Title',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.scientificTitle,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'University',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.university,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Date Of Birth',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userx!.dateOfBirth.substring(0, 10),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Bio',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      userx!.bio,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          if (widget.eventStatus != 0 &&
                              widget.blacklist == false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Button(
                                  color: Colors.lightBlue,
                                  text:"Genrate Certificate" , cb:() async {
                                   showDialog(
                                        context: context,
                                        builder: (context) {
                                          return CustomDialog(
                                            bigText:
                                                "Sure Wanna Genrate Cetificate For this user ?",
                                            smallerText:
                                                "This will be considered an exception for this user",
                                            fun: () async {
                                              Response res = await runFun(
                                                context,
                                                () => genUserCert(
                                                    userx!.id, widget.eventId),
                                              );
                                              if (res.data['msg'] == null) {
                                                snackbar(context,
                                                    "Somthing Went Wrong", 2);
                                              }
                                              snackbar(
                                                  context, res.data['msg'], 2);
                                              Navigator.pop(context);
                                              return Future.value(res);
                                            },
                                          );
                                        },
                                      );
                                }, ),
                              ],
                            ),
                          if (widget.eventStatus != 2 &&
                              widget.blacklist == false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Button(
                                  color: const Color.fromARGB(255, 6, 107, 28),
                                  text: "Remove User",
                                  cb: ()async {
                                      showDialog(
                                          context: context,
                                          builder: (context) => CustomDialog(
                                                bigText:
                                                    "You Sure Wanna Remove This User?",
                                                smallerText:
                                                    "User will need to register again",
                                                fun: () async {
                                                  Response res = await runFun(
                                                      context,
                                                      () => removeUser(
                                                          userx!.id,
                                                          widget.eventId));
                                                  snackbar(context,
                                                      res.data['msg'], 3);
                                                  if (res.statusCode == 200) {
                                                    await unsubscribeFromTopic(
                                                        widget.eventId);
                                                    moveBack(context, 3);
                                                  } else {
                                                    Navigator.pop(context);
                                                  }
                                                  return Future.value(res);
                                                },
                                              ));
                                  },
                                ),
                                Button(
                                  text:"Block" , 
                                color: const Color.fromARGB(255, 128, 19, 11),
                                cb: () async{
                                   showDialog(
                                          context: context,
                                          builder: (context) => CustomDialog(
                                                bigText:
                                                    "You Sure Wanna Block This User?",
                                                smallerText:
                                                    "Blokcing This User Will Remove Him From The Event",
                                                fun: () async {
                                                  Response res = await runFun(
                                                      context,
                                                      () => blockUser(userx!.id,
                                                          widget.eventId));
                                                  snackbar(context,
                                                      res.data['msg'], 3);
                                                  if (res.statusCode == 200) {
                                                    await unsubscribeFromTopic(
                                                        widget.eventId);
                                                    moveBack(context, 3);
                                                  }
                                                  return Future.value(res);
                                                },
                                              ));
                                },),
                              ],
                            ),
                          if (widget.blacklist == true &&
                              widget.eventStatus != 2)
                              Button(
                                color: const Color.fromARGB(255, 172, 27, 17),
                                text: "Unblock",
                                cb: () async{
                                 showDialog(
                                      context: context,
                                      builder: (context) => CustomDialog(
                                            bigText:
                                                "You Sure Wanna Unblock This User?",
                                            smallerText:
                                                "By unblocking this user, they will be able to join and check in",
                                            fun: () async {
                                              Response res = await runFun(
                                                  context,
                                                  () => unblockUser(userx!.id,
                                                      widget.eventId));
                                              snackbar(
                                                  context, res.data['msg'], 3);
                                              if (res.statusCode == 200) {
                                                moveBack(context, 3);
                                              }
                                              return Future.value(res);
                                            },
                                          ));
                              },)
                        ]),
                  ]),
            ));
      },
    );
  }
}
