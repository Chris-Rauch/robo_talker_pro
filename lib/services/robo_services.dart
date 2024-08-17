/// This class is going to hold all the information needed to post a job to
/// RoboTalker. It will also vet the information to make sure it will be
/// received without any errors
library robo_services;

import 'dart:convert';
import 'package:http/http.dart';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class RoboServices {
  final String jobName;
  final DateTime startDate;
  final DateTime endDate;

  //add all the url endpoints
  final String _authority = 'https://robotalker.com/REST/api';
  final String _jobDetails = "https://robotalker.com/GetJobDetail.ashx?";
  final String _multiJobPost = "/MultiJob";
  final String _login = "/Login";

  RoboServices(this.jobName, this.startDate, this.endDate) {
    // check times. Make sure it's during the day, not too many go out at once

    // check contacts -> phone must be 10 digits without a '1' or a '+'
    //                -> var 1-4 plus the message can't be longer than 250

    // check unit balance
  }

  bool _isDuringLunch() {
    return true;
  }

  Future<Map<String, dynamic>> getBody(RequestType requestType) async {
    Map<String, String> body;
    switch (requestType) {
      case RequestType.multiJobPost:
        final String contactList = await loadData(
            Keys.contactList.toLocalizedString(),
            path: PROJECT_DATA_PATH);
        final String callerId =
            await loadData(Keys.callerId.toLocalizedString());
        final String groupName = await loadData(
            Keys.groupName.toLocalizedString(),
            path: PROJECT_DATA_PATH);
        final String startTime = await loadData(
            Keys.startTime.toLocalizedString(),
            path: PROJECT_DATA_PATH);
        final String endTime = await loadData(Keys.endTime.toLocalizedString(),
            path: PROJECT_DATA_PATH);

        body = {
          'whattodo': 'SendTtsMessage',
          'jobname': groupName,
          'optcallerid': callerId,
          'messageid': '0',
          'messagetext': LATE_PAYMENT_MESSAGE,
          'customername': 'Chris Rauch',
          'extrareportemail': 'rauch.christopher13@gmail.com',
          'phonelistgroupname': groupName,
          'contactlist': jsonEncode(contactList),
          'rundatetime': startTime,
          'enddatetime': endTime,
        };
        break;
      default:
        throw Exception('Could not load contact list from file');
    }
    return body;
  }

  Future<Map<String, dynamic>> getHeaders() async {
    final username = await loadData(Keys.roboUsername.toLocalizedString());
    final token = await loadData(Keys.zToken.toLocalizedString());
    var credentials = base64Encode(utf8.encode('$username:$token'));

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
      'Cookie': 'Cookie_1=value'
    };
  }

  Uri getUrl(RequestType requestType) {
    String endPoint;
    switch (requestType) {
      case RequestType.multiJobPost:
        endPoint = '/MultiJob';
        break;
      default:
        throw Exception('Endpoint not found');
    }
    return Uri.parse(authority + endPoint);
  }

  String get authority => 'https://robotalker.com/REST/api';
}
