import 'package:flutter/material.dart';
import 'package:org/net/HTTP.dart';
import 'package:org/utilities/shared.dart';

class BuildFuture extends StatefulWidget {
  final ResCallback callback;
  final Function(Response resData) mapper;
  final Function(dynamic data) builder;

  const BuildFuture({
    super.key,
    required this.callback,
    required this.mapper,
    required this.builder,
  });

  @override
  State<BuildFuture> createState() => _BuildFutureState();
}

class _BuildFutureState extends State<BuildFuture> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: runFun(context, widget.callback),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            dynamic maped = widget.mapper(snapshot.data);
            return widget.builder(maped);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        return const Center(child: LinearProgressIndicator());
      },
    );
  }
}
