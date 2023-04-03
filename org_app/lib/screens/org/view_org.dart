// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:org/models/org.dart';
import 'package:org/screens/org/edit_org.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/button.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:org/widgets/profile_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  Org orgdata = const Org();
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List orgtypes = ['Organization', 'University', 'Company'];
  List<IconData> orgTypeIcons = [Icons.group, Icons.school, Icons.business];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.orgdata = toOrg(await runFun(context, getOrg));
        setState(() {});
      },
      child: BuildFuture(
        callback: getOrg,
        mapper: toOrg,
        builder: (data) {
          widget.orgdata = data;
          return Scaffold(
            appBar: buildAppBar(context, "Account Information",
                button: const BackButton()),
            body: FormBuilder(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ProfileWidget(
                    bgPath: widget.orgdata.orgBackgroundPic,
                    imagepath: widget.orgdata.orgPic,
                    onClick: () {
                      goto(context, EditOrg());
                    },
                    isEdit: false,
                    onClickbg: () {
                      goto(context, EditOrg());
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  buildTitle(
                      icon: Icons.email,
                      widget.orgdata.orgName,
                      widget.orgdata.email,
                      context),
                  const SizedBox(
                    height: 5,
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Button(
                          color: Colors.blueAccent,
                          text: 'Open Website',
                          cb: () async {
                            String website = widget.orgdata.website;
                            launchUrl(Uri.parse(website),
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Button(
                          color: const Color.fromARGB(255, 37, 139, 19),
                          text: 'Open Soical Media ',
                          cb: () async{
                            String socialMedia = widget.orgdata.socialMedia;
                            launchUrl(Uri.parse(socialMedia),
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        buildViewInfo(
                          select: true,
                            titleicon: Icons.phone_android,
                            context: context,
                            "Phone Number",
                            widget.orgdata.phoneNumber),
                        const SizedBox(
                          height: 13,
                        ),
                        buildViewInfo(
                            select: true,
                            titleicon: Icons.web,
                            context: context,
                            "Website",
                            widget.orgdata.website),
                        const SizedBox(
                          height: 13,
                        ),
                        buildViewInfo(
                            icon: orgTypeIcons[widget.orgdata.orgtype],
                            context: context,
                            "Organization Type",
                            orgtypes[widget.orgdata.orgtype]),
                        const SizedBox(
                          height: 13,
                        ),
                        buildViewInfo(
                          select: true,
                            titleicon: Icons.chat,
                            context: context,
                            "Soical Media",
                            widget.orgdata.socialMedia),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Button(
                            color: const Color.fromARGB(255, 234, 195, 37),
                            text: 'View Headquarters On Mapps',
                            cb: () async {
                              try {
                                showOnMap(context, widget.orgdata.location);
                              } catch (e) {
                                Console.log(widget.orgdata.location.toString());
                                Console.logError(e.toString());
                                snackbar(context, "Error Opping Mapps", 2);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        buildViewInfo(
                            titleicon: Icons.description,
                            context: context,
                            "Bio",
                            widget.orgdata.bio),
                        const SizedBox(
                          height: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
