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
import 'package:org/widgets/future_builder.dart';

import '../../net/HTTP.dart';
import '../../utilities/providers.dart';

class EditEvent extends StatefulWidget {
  Map<String, dynamic>? formdata;
  Future<Response>? eventdata;
  Event? event;
  XFile? eventPic;
  XFile? eventSig;
  String eventId;

  EditEvent({super.key, required this.eventId});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  bool getdataFromNetwork = true;
  final ImagePicker picker = ImagePicker();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  Future<Map<String, dynamic>> pickImageAndSaveState(
      Map<String, dynamic>? formdata, int picSig) async {
    picSig == 0
        ? widget.eventPic = await picker.pickImage(source: ImageSource.gallery)
        : widget.eventSig = await picker.pickImage(source: ImageSource.gallery);
    getdataFromNetwork = false;
    setState(() {});
    return getEventFromForm(context, _formKey, status: widget.event!.status);
  }

  @override
  void initState() {
    widget.eventdata = getEventInfo(widget.eventId);
    if (getFromProvider<LocationProvider>(
        context, (provider) => provider[1] != null)) {
      getFromProvider<LocationProvider>(
          context, (provider) => provider.setEventLocation(LatLng(0, 0)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context, "Edit Event",
            search: false, button: const BackButton()),
        body: BuildFuture(
            callback: () async {
              return await widget.eventdata!;
            },
            mapper: (resData) => toEvent(resData.data),
            builder: (data) {
              widget.event = data;
              if (getdataFromNetwork) widget.formdata = eventToMap(data);
              return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(children: [
                        EventFormImage(
                            eventPic: widget.eventPic,
                            eventPicPath: data.eventBackgroundPic,
                            onClick: () async {
                              widget.formdata = await pickImageAndSaveState(
                                  widget.formdata, 0);
                            },
                            isEdit: true),
                        const SizedBox(
                          height: 3,
                        ),
                        const Text(
                          "Event Picture",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        EventForm(
                          eventdata: mapEvent(widget.formdata),
                          createMod: false,
                          editMode: true,
                          hideinit: false,
                          eventStatus: widget.event!.status,
                          showResetSelector: true,
                          showReset: false,
                          resetSelectors: () {
                            if (widget.eventPic != null ||
                                widget.eventSig != null) {
                              widget.eventPic = null;
                              widget.eventSig = null;
                              setState(() {});
                              return;
                            }
                            snackbar(
                                context, "Nothing Is Selected To Reset", 2);
                          },
                          resetForm: () {},
                          timeValidator: (timeInMin) =>
                              validateAttendanceTime(timeInMin, _formKey),
                        ),
                        const Text(
                          "Digital Siginture",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        EventFormImage(
                            eventPic: widget.eventSig,
                            eventPicPath: data.sig,
                            onClick: () async {
                              widget.formdata = await pickImageAndSaveState(
                                  widget.formdata, 1);
                            },
                            isEdit: true),
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
                              onPressed: () async {
                                Response resx = Response();
                                if (widget.event!.status == 0 &&
                                    validateStartEnd(context, _formKey)) {
                                  return Future.value();
                                }

                                if (widget.eventPic == null &&
                                    widget.eventSig == null) {
                                  resx = await runFun(
                                    context,
                                    () async {
                                      return await updateEvent(
                                          widget.eventId,
                                          getEventFromForm(context, _formKey,
                                              location: widget.event!.location,
                                              status: widget.event!.status));
                                    },
                                  );
                                } else {
                                  FormRequestHandler(
                                      formdata: getEventFromForm(
                                          context, _formKey,
                                          status: widget.event!.status,
                                          location: widget.event!.location),
                                      org_event_user: 1,
                                      formKey: _formKey,
                                      setState: () => setState(() {}),
                                      context: context,
                                      requestHandler: (data, res) async {
                                        Console.log(data);
                                        resx = await runFun(
                                          context,
                                          () async {
                                            return await multipartRequest(
                                              data: data,
                                              method: 'PUT',
                                              file: widget.eventPic,
                                              file2: widget.eventSig,
                                              filefield2: "sig",
                                              filefield1: "eventBackgroundPic",
                                              url:
                                                  "$devServer/event/update/${widget.eventId}",
                                              addFields: (req, data) {
                                                if (widget.event!.status == 1) {
                                                  return addEventFields(
                                                    ispartialUpdate: true,
                                                    request: req,
                                                    data: data,
                                                  );
                                                } else {
                                                  return addEventFields(
                                                    request: req,
                                                    data: data,
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        );
                                        return resx;
                                      });
                                }
                                if (resx.statusCode == 200) {
                                  widget.eventPic = null;
                                  widget.eventSig = null;
                                  
                                  getFromProvider<LocationProvider>(
                                      context,
                                      (provider) => provider
                                          .setEventLocation(LatLng(0, 0)));

                                  widget.formdata!.clear();
                                  moveBack(context, 1);
                                  snackbar(context, "Chnages Saved", 2);
                                  return;
                                }
                                snackbar(context, resx.data['msg'], 2);
                              },
                              child: const Text(
                                "Save",
                                style: TextStyle(fontSize: 14),
                              )),
                        )
                      ]),
                    ),
                  ));
            }));
  }
}
