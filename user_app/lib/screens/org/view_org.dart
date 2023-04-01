// ignore_for_file: must_be_immutable

import 'package:EventLink/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/org.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';
import '../../widgets/profile_widget.dart';

class OrgView extends StatefulWidget {
  Org orgdata = const Org();
  String orgId;
  OrgView({super.key, required this.orgId});

  @override
  State<OrgView> createState() => _OrgViewState();
}

class _OrgViewState extends State<OrgView> {
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
        callback: () {
          return getOrg(orgId: widget.orgId);
        },
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
                    onClick: () {},
                    isEdit: false,
                    onClickbg: () {},
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  buildTitle(
                      icon: Icons.email,
                      widget.orgdata.orgName,
                      widget.orgdata.email,
                      context),
                  const SizedBox(
                    height: 10,
                  ),
                  Button(
                    color: Colors.blueAccent,
                    text: 'Open Website',
                    cb: () {
                      String website = widget.orgdata.website;
                      launchUrl(Uri.parse("https://$website"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        buildViewInfo(
                            titleicon: Icons.phone_android,
                            context: context,
                            "Phone Number",
                            widget.orgdata.phoneNumber),
                        const SizedBox(
                          height: 13,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildViewInfo(
                                titleicon: Icons.web,
                                context: context,
                                "Website",
                                widget.orgdata.website),
                            const SizedBox(
                              height: 13,
                            ),
                            buildViewInfo(
                                titleicon: Icons.chat,
                                context: context,
                                "Soical Media",
                                widget.orgdata.socialMedia),
                          ],
                        ),
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Button(
                            color: Colors.deepOrange,
                            text: 'View Headquarters On Mapps',
                            cb: () {
                              showOnMap(context, widget.orgdata.location);
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
                          height: 10,
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
