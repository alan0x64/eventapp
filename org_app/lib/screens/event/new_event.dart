// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/event.dart';
import 'package:org/screens/event/event_form.dart';
import 'package:org/screens/event/event_form_header.dart';
import 'package:org/server.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/screen.dart';

import '../../net/HTTP.dart';
import '../../utilities/providers.dart';

class AddEvent extends StatefulWidget {
  XFile? eventPic;
  XFile? eventSig;
  Event eventdata = const Event();
  Map<String, dynamic>? formdata;

  bool createMod = true;
  bool editMode = false;
  bool hideinit = true;
  bool showReset = false;

  AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final ImagePicker picker = ImagePicker();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  Future<Map<String, dynamic>> pickImageAndaveState(
      Map<String, dynamic>? formdata, int picSig) async {
    picSig == 0
        ? widget.eventPic = await picker.pickImage(source: ImageSource.gallery)
        : widget.eventSig = await picker.pickImage(source: ImageSource.gallery);
    widget.hideinit = false;
    setState(() {});
    return getEventFromForm(context, _formKey);
  }

  @override
  void initState() {
    if (getFromProvider<LocationProvider>(
        context, (provider) => provider[1] != null)) {
      getFromProvider<LocationProvider>(
          context, (provider) => provider.setEventLocation(LatLng(0, 0)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      ab: buildAppBar(context, "Create New Event"),
      builder: (data) {
        return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: FormBuilder(
              key: _formKey,
              child: Column(children: [
                if (widget.eventPic == null)
                  TextButton(
                      onPressed: () async {
                        widget.formdata =
                            await pickImageAndaveState(widget.formdata, 0);
                      },
                      child: const Text("Choose Event Picture")),
                if (widget.eventPic != null)
                  EventFormImage(
                      eventPic: widget.eventPic,
                      eventPicPath: widget.eventdata.eventBackgroundPic,
                      onClick: () async {
                        widget.formdata =
                            await pickImageAndaveState(widget.formdata, 0);
                      },
                      isEdit: widget.editMode),
                const SizedBox(
                  height: 3,
                ),
                if (widget.eventPic != null)
                  const Text(
                    "Event Picture",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: EventForm(
                    eventdata: mapEvent(widget.formdata),
                    mainButtonText: "Create",
                    createMod: widget.createMod,
                    editMode: widget.editMode,
                    hideinit: widget.hideinit,
                    showReset: widget.showReset,
                    resetSelectors: () {},
                    resetForm: () {
                      widget.formdata!.clear();
                      _formKey.currentState!.reset();
                      getFromProvider<LocationProvider>(
                          context,
                          (provider) =>
                              provider.setEventLocation(LatLng(0, 0)));
                      setState(() {});
                    },
                    timeValidator: (timeInMin) {
                      DateTime start =
                          _formKey.currentState!.fields['startDateTime']!.value;
                      DateTime end =
                          _formKey.currentState!.fields['endDateTime']!.value;
                      if (int.parse(timeInMin) >
                          ((end.millisecondsSinceEpoch -
                                      start.millisecondsSinceEpoch) /
                                  1000) /
                              60) {
                        return "Attendance Time Is Bigger Then Event Time";
                      }
                      return null;
                    },
                  ),
                ),
                const Text(
                  "Digital Siginture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (widget.eventSig == null)
                  TextButton(
                      onPressed: () async {
                        widget.formdata =
                            await pickImageAndaveState(widget.formdata, 1);
                      },
                      child: const Text("Choose Digital Signiture")),
                const SizedBox(
                  height: 15,
                ),
                if (widget.eventSig != null)
                  EventFormImage(
                      eventPic: widget.eventSig,
                      eventPicPath: widget.eventdata.sig,
                      onClick: () async {
                        widget.formdata =
                            await pickImageAndaveState(widget.formdata, 1);
                      },
                      isEdit: widget.editMode),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  height: 45,
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  child: ElevatedButton(
                      onPressed: () {
                        if (widget.eventPic == null ||
                            widget.eventSig == null) {
                          return snackbar(
                              context, "Image Or Signiture Cannot Be Empty", 2);
                        }
                        FormRequestHandler(
                          create: true,
                          formdata: getEventFromForm(context, _formKey),
                          org_event_user: 1,
                          location: getLocationString(context, 1),
                          formKey: _formKey,
                          setState: () => setState(() {}),
                          context: context,
                          requestHandler: (data, res) async {
                            DateTime start = _formKey
                                .currentState!.fields['startDateTime']!.value;
                            DateTime end = _formKey
                                .currentState!.fields['endDateTime']!.value;

                            if (start.millisecondsSinceEpoch >=
                                end.millisecondsSinceEpoch) {
                              snackbar(
                                  context,
                                  "The start time should not be later than the end time, and the event time should not be earlier than the start time",
                                  2);
                              return Future.value(res);
                            }

                            Response resx = await multipartRequest(
                              data: data,
                              method: 'POST',
                              file: widget.eventPic,
                              file2: widget.eventSig,
                              filefield2: "sig",
                              filefield1: "eventBackgroundPic",
                              url: "$devServer/event/register",
                              addFields: (req, data) =>
                                  addEventFields(request: req, data: data),
                            );
                            if (resx.statusCode == 200) {
                              widget.eventPic = null;
                              widget.eventSig = null;
                              getFromProvider<LocationProvider>(
                                  context,
                                  (provider) =>
                                      provider.setEventLocation(LatLng(0, 0)));
                              widget.formdata!.clear();
                              _formKey.currentState!.reset();
                            }
                            return resx;
                          },
                        );
                      },
                      child: const Text(
                        "Create",
                        style: TextStyle(fontSize: 14),
                      )),
                )
              ]),
            ));
      },
    );
  }
}
