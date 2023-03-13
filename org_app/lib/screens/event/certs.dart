import 'package:flutter/material.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/cert.dart';
import '../../widgets/user_card_two.dart';

class CertsView extends StatefulWidget {
  final String eventId;
  const CertsView({super.key, required this.eventId});
  @override
  State<CertsView> createState() => _CertsViewState();
}

class _CertsViewState extends State<CertsView> {
  @override
  Widget build(BuildContext context) {
    return BuildFuture(
      callback: () async {
        return await getCerts(widget.eventId);
      },
      mapper: (resData) => mapObjs(resData.data['certs'], toCert),
      builder: (data) {
        List<dynamic> certs = data;
        return Scaffold(
          appBar: buildAppBar(context, "Certs", button: const BackButton()),
          body: ListView.builder(
              itemCount: certs.length,
              itemBuilder: (context, index) {
                Cert cert = certs[index];
                if (cert.allowCert == false) return Container();
                return CustomListItem(
                  onT: () => launchUrlString(cert.cert,
                      mode: LaunchMode.externalApplication),
                  imageUrl: cert.user.profilePic,
                  title: cert.user.fullName,
                  subtitle1: "Attended Minutes",
                  subtitle2: cert.attendedMins.toString(),
                );
              }),
        );
      },
    );
  }
}
