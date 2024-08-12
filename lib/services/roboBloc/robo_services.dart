/*

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

///Handles getting all the data ready for a REST post.
///Body ex. {
///    "whattodo": "SendTtsMessage",
///    "jobname": "LP May6 thru May10",
///    "optcallerid": "9494709674",
///    "messageid": "0",
///    "messagetext": "Hi, this message is from General Agents and is for #name#. We’re calling in regards to your contract, #var4#. This is just a courtesy reminder that your payment of, $#var2#, was due on, #var3#, for your insurance policy with, #var1#. You can make payments online at mygaac.com. If you've already made a payment please disregard this message. Thankyou.",
///    "customername": "Chris Rauch",
///    "extrareportemail": "rauch.christopher13@gmail.com",
///    "phonelistgroupname": "LP May6 thru May10",
///    "contactlist": [
///       {
///       "name":"SB TRUCKS INC",
///       "phone":"(559) 878-7505",
///       "var1":"MALWA FINANCIAL AND INSURANCE ",
///       "var2":"3676.58",
///       "var3":"May 6",
///       "var4":"M W F 1 4 2 8 9 4",
///       "groupname":"LP May6 thru May10"
///       }
///    ],
///    "rundatetime": "2024/05/15 15:15:00"

class RoboServices {
  ///Returns the body of the
  String createJsonBody() {
    return '';
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
    return Uri.parse(getAuthority() + endPoint);
  }

  String getAuthority() => 'https://robotalker.com/REST/api';

  Future<Map<String, String>> getHeader() async {
    // Create a base64 encoded string of 'username:token' for Basic Auth
    final username = await loadData(Keys.roboUsername.toLocalizedString());
    final token = await loadData(Keys.zToken.toLocalizedString());
    var credentials = base64Encode(utf8.encode('$username:$token'));
    return {
      'Authorization': 'Basic $credentials',
      //'Content-Type': 'application/json',
    };
  }

  ///Returns the body for the REST request
  Future<Map<String, String>> getBody(RequestType requestType) async {
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

  //TODO Implement
  String getEndTime() {
    return '';
  }
}


*/