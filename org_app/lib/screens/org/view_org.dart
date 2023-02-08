// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:org/models/org.dart';
import 'package:org/screens/org/edit.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/profile_widget.dart';
import 'package:org/widgets/screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  Org orgdata = const Org();
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List orgtypes = ['Organization', 'University', 'Company'];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.orgdata =  mapOrg( await runFun(context, getProfile));
        setState(() {});
      },
      child: Screen(
        ab: buildAppBar(context, "Account Information",
            button: const BackButton()),
        builder: (data) {
          widget.orgdata = data;
          return FormBuilder(
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
                  height: 24,
                ),
                buildName(data),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        child: const Text(
                          "View Headquarters On Mapps",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () async {
                          Console.log(widget.orgdata.location.toString());
                          try {
                            List<String> l = getLocationList(
                                context, widget.orgdata.location);
                            String lat = l[0];
                            String lng = l[1];
                            Console.log(
                                "https://www.google.com/maps?q=$lat,$lng");
                            launchUrl(Uri.parse(
                                'https://www.google.com/maps?q=$lat,$lng'));
                          } catch (e) {
                            Console.log(widget.orgdata.location.toString());
                            Console.logError(e.toString());
                            snackbar(context, "Error Opping Mapps", 2);
                          }
                        }),
                    ElevatedButton(
                        child: const Text(
                          "Open Website",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () async {
                          try {
                            String website = widget.orgdata.website;
                            launchUrl(Uri.parse("https://$website"),
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            Console.logError(e.toString());
                            snackbar(context, "Error Opping Website", 2);
                          }
                        }),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo("Phone Number", widget.orgdata.phoneNumber),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo("Website", widget.orgdata.website),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo("Soical Media", widget.orgdata.socialMedia),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo(
                    "Organization Type", orgtypes[widget.orgdata.orgtype]),
                const SizedBox(
                  height: 30,
                ),
                buildViewInfo("Bio", widget.orgdata.bio),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  buildName(data) {
    return Column(
      children: [
        Text(
          data.orgName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          data.email,
          style: const TextStyle(color: Colors.grey),
        )
      ],
    );
  }

  Widget buildViewInfo(String name, dynamic text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            text.toString(),
            style: const TextStyle(fontSize: 18, height: 1.4),
          )
        ],
      ),
    );
  }
}