import 'package:flutter/foundation.dart';
import 'package:org/models/org.dart';

class LogedInData extends ChangeNotifier {
  Org? data;

  void setLogedInData(Org data) {
    data = data;
    notifyListeners();
  }

  Org getLogedInData() {
    return data as Org;
  }

}

//Provider.of<LogedInData>(context,listen: false).setLogedInData(orgdata);