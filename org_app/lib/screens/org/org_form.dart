// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/screens/map.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/button.dart';
import 'package:provider/provider.dart';

import '../../models/org.dart';
import '../../widgets/textfield.dart';

class OrgForm extends StatefulWidget {
  Org orgdata;
  String mainButtonText;
  bool singupMode;
  bool hideinit;
  bool showReset;
  VoidCallback mainButton;
  VoidCallback resetSelectors;

  OrgForm({
    super.key,
    this.orgdata = const Org(),
    required this.mainButton,
    required this.resetSelectors,
    this.mainButtonText = "Save",
    this.singupMode = false,
    this.hideinit = false,
    this.showReset = true,
  });

  @override
  State<OrgForm> createState() => _OrgFormState();
}

class _OrgFormState extends State<OrgForm> {
  @override
  Widget build(BuildContext context) {
    List orgtypes = ['Organization', 'University', 'Company'];
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        if (widget.showReset)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Button(
              color: Colors.cyan,
              text: "Reset Image Selection",
              cb: () async {
                widget.resetSelectors;
              },
            ),
          ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Button(
            color: const Color.fromARGB(255, 73, 73, 204),
            text: "Set Headquarters",
            cb: () async {
              goto(context, Mapx(
                setLocationButton: (setLocationButton) {
                  Provider.of<LocationProvider>(context, listen: false)
                      .setOrgLocation(setLocationButton as LatLng);
                },
              ));
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        AppTextbox(
            name: 'name',
            lt: "Name",
            ht: "Organization Name",
            hideinit: widget.hideinit,
            init: widget.orgdata.orgName,
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(3),
            ]),
        const SizedBox(
          height: 25,
        ),
        if (widget.singupMode)
          AppTextbox(
              name: 'password',
              lt: "Password",
              ht: "Password",
              hideinit: widget.hideinit,
              valis: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(8),
              ]),
        if (widget.singupMode)
          const SizedBox(
            height: 25,
          ),
        AppTextbox(
            name: 'email',
            lt: "Email",
            ht: "Organization Email",
            init: widget.orgdata.email,
            hideinit: widget.hideinit,
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.min(0),
              FormBuilderValidators.email(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'phoneNumber',
            lt: "Phone Number",
            ht: "Organization Phone Number",
            hideinit: widget.hideinit,
            keyboard: TextInputType.number,
            init: widget.orgdata.phoneNumber.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'socialMedia',
            lt: "SocialMedia",
            ht: "socialMedia",
            ml: 3,
            hideinit: widget.hideinit,
            init: widget.orgdata.socialMedia.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'website',
            lt: "Website",
            ht: "Website",
            hideinit: widget.hideinit,
            init: widget.orgdata.website.toString(),
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5)
            ]),
        const SizedBox(
          height: 25,
        ),
        AppTextbox(
            name: 'bio',
            ml: 10,
            lt: "Bio",
            ht: "Bio",
            init: widget.orgdata.bio,
            hideinit: widget.hideinit,
            valis: [
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(5),
              FormBuilderValidators.min(0),
            ]),
        const SizedBox(
          height: 25,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Organization Type",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
              height: 7,
            ),
            FormBuilderDropdown(
                initialValue: widget.orgdata.orgtype,
                name: 'org_type',
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(orgtypes[0]),
                  ),
                  DropdownMenuItem(value: 1, child: Text(orgtypes[1])),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(orgtypes[2]),
                  ),
                ]),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Button(
                color: Colors.lime,
                text: widget.mainButtonText,
                cb: ()async {
                  widget.mainButton();
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
