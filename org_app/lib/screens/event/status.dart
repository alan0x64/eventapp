import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:org/models/event.dart';
import 'package:org/utilities/shared.dart';
import 'package:org/widgets/future_builder.dart';
import 'package:theme_provider/theme_provider.dart';

class Status extends StatefulWidget {
  String eventId;
  List<String> scanStatus = ['Check In', 'Check Out'];

  Status({Key? key, required this.eventId}) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  late MobileScannerController cameraController;
  late Event eventdata;
  Color boxColor = const Color.fromARGB(255, 44, 42, 42);
  Color textColor = const Color.fromARGB(255, 226, 221, 221);
  int scan = 0;

  @override
  void initState() {
    cameraController = MobileScannerController();
    cameraController.isStarting ? cameraController.start():Null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String st = widget.scanStatus[scan];
    if (ThemeProvider.themeOf(context).id == "default_dark_theme") {
      boxColor = const Color.fromARGB(255, 226, 225, 225);
      textColor = const Color.fromARGB(255, 19, 18, 18);
    }
    return BuildFuture(
      callback: () async => await getEventInfo(widget.eventId),
      mapper: (resData) => toEvent(resData.data),
      builder: (data) {
        eventdata = data;
        int attenders = eventdata.attenders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan QRs'),
            actions: [
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
                  builder: (context, state, child) {
                    switch (state) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off);
                      case TorchState.on:
                        return const Icon(Icons.flash_on);
                    }
                  },
                ),
                onPressed: () => cameraController.toggleTorch(),
              ),
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                onPressed: () => cameraController.switchCamera(),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: boxColor,
                      width: 1,
                    ),
                  ),
                  child: MobileScanner(
                    controller: cameraController,
                    startDelay: true,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      Console.log(barcodes[0].rawValue);
                      setState(() {
                        
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Attenders: $attenders",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Scan Status: ",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                st,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        scan == 0 ? scan = 1 : scan = 0;
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 168, 150, 44),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text("Toggle Scan Status"),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
