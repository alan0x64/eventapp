// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:latlong2/latlong.dart';
import 'package:org/models/event.dart';
import 'package:org/screens/map.dart';
import 'package:org/utilities/providers.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/date_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/textfield.dart';

class EventForm extends StatefulWidget {
  Event eventdata;
  bool createMod;
  bool editMode;
  bool hideinit;
  bool showReset;
  bool showResetSelector;
  int eventStatus;
  VoidCallback resetSelectors;
  VoidCallback resetForm;
  dynamic Function(String timeInMin) timeValidator;

  EventForm({
    super.key,
    this.eventdata = const Event(),
    this.createMod = true,
    this.hideinit = true,
    this.showReset = false,
    this.showResetSelector = false,
    this.editMode = true,
    this.eventStatus=0,
    required this.resetSelectors,
    required this.resetForm,
    required this.timeValidator,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  List eventType = ['Conference', 'Seminar'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.showResetSelector)
              ElevatedButton(
                  onPressed: widget.resetSelectors,
                  child: const Text(
                    "Reset Image Selection",
                    style: TextStyle(fontSize: 14),
                  )),
            ElevatedButton(
                onPressed: () {
                  goto(context, Mapx(
                    setLocationButton: (setLocation) {
                      Provider.of<LocationProvider>(context, listen: false)
                          .setEventLocation(setLocation as LatLng);
                    },
                  ));
                },
                child: const Text(
                  "Set Event Location",
                  style: TextStyle(fontSize: 14),
                )),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  launchUrl(
                      Uri.parse(
                          'https://signaturely.com/online-signature/draw/'),
                      mode: LaunchMode.externalApplication);
                },
                child: const Text("Draw Digital Signiture")),
            ElevatedButton(
                onPressed: () {
                  launchUrl(
                      Uri.parse(
                          'https://signaturely.com/online-signature/type/'),
                      mode: LaunchMode.externalApplication);
                },
                child: const Text("Type Digital Signiture")),
          ],
        ),
        if (widget.showReset)
          ElevatedButton(
              onPressed: widget.resetForm,
              child: const Text(
                "Reset Form",
                style: TextStyle(fontSize: 14),
              )),
        const SizedBox(
          height: 25,
        ),
        Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextbox(
                  name: 'title',
                  lt: "Event Title Name",
                  ht: "Event Title Name",
                  hideinit: widget.hideinit,
                  init: widget.eventdata.title,
                  valis: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                    FormBuilderValidators.maxLength(20),
                  ]),
              const SizedBox(
                height: 25,
              ),
              AppTextbox(
                  name: 'description',
                  ml: 10,
                  lt: "Event Description",
                  ht: "Event Description",
                  init: widget.eventdata.description,
                  hideinit: widget.hideinit,
                  valis: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(5),
                  ]),
              const SizedBox(
                height: 25,
              ),
              if(widget.eventStatus==0)
              const Text(
                "Event Type",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if(widget.eventStatus==0)
              const SizedBox(
                height: 7,
              ),
              if(widget.eventStatus==0)
              FormBuilderDropdown(
                  initialValue: widget.eventdata.eventType,
                  name: 'eventType',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(Event.eventTypeList[0]),
                    ),
                    DropdownMenuItem(
                        value: 1, child: Text(Event.eventTypeList[1])),
                  ]),
              const SizedBox(
                height: 25,
              ),
              if(widget.eventStatus==0)
              AppDateTImePicker(
                init: getTimeInMin(widget.eventdata.startDateTime) <
                        getTimeInMin(DateTime.now().toString())
                    ? DateTime.now()
                    : DateTime.tryParse(widget.eventdata.startDateTime),
                hideinit: widget.hideinit,
                ht: "Start Date And Time",
                lt: "Start Date And Time",
                name: 'startDateTime',
                valis: [FormBuilderValidators.required()],
              ),
              if(widget.eventStatus==0)
              const SizedBox(
                height: 25,
              ),
              if(widget.eventStatus==0)
              AppDateTImePicker(
                init: getTimeInMin(widget.eventdata.endDateTime) <
                        getTimeInMin(DateTime.now().toString())
                    ? DateTime.now()
                    : DateTime.tryParse(widget.eventdata.endDateTime),
                hideinit: widget.hideinit,
                ht: "End Date And Time",
                lt: "End Date And Time",
                name: 'endDateTime',
                valis: [FormBuilderValidators.required()],
              ),
              if(widget.eventStatus==0)
              const SizedBox(
                height: 25,
              ),
              if(widget.eventStatus==0)
              AppTextbox(
                  name: 'minAttendanceTime',
                  lt: "Minium Attendance Time",
                  ht: "Minium Attendance Time In Minutes",
                  hideinit: widget.hideinit,
                  init: widget.eventdata.minAttendanceTime.toString() == "0"
                      ? ""
                      : widget.eventdata.minAttendanceTime.toString(),
                  keyboard: TextInputType.number,
                  valis: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                    FormBuilderValidators.min(0),
                    (p0) {
                      return widget.timeValidator(p0 as String);
                    }
                  ]),
              const SizedBox(
                height: 20,
              ),
              AppTextbox(
                  name: 'seats',
                  lt: "Number Of Total Seats",
                  ht: "Number Of Total Seats",
                  hideinit: widget.hideinit,
                  init: widget.eventdata.seats.toString() == "0"
                      ? ""
                      : widget.eventdata.seats.toString(),
                  keyboard: TextInputType.number,
                  valis: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                    FormBuilderValidators.min(0)
                  ]),
            ],
          ),
        )
      ],
    );
  }
}
