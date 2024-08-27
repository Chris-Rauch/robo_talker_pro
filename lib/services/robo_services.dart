/// Robo Services is going to:
///   1) Handle the HTTP requests specifically for the RoboTalker website.
///   2) Validate user input such as start/end times,

/// This class is going to hold all the information needed to post a job to
/// RoboTalker. It will also vet the information to make sure it will be
/// received without any errors
library robo_services;

import 'dart:convert';
import 'dart:io';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class RoboServices {
  final String jobName;
  final DateTime _startDate;
  final DateTime _endDate;

  //add all the url endpoints
  final String _authority = 'https://robotalker.com/REST/api';
  final String _jobDetails = "https://robotalker.com/GetJobDetail.ashx?";
  final String _multiJobPost = "/MultiJob";
  final String _login = "/Login";

  RoboServices(this.jobName, DateTime startDate, DateTime endDate)
      : _startDate = startDate.add(const Duration(hours: 3)),
        _endDate = endDate.add(const Duration(hours: 3)) {
    // check times. Make sure it's during the day, not too many go out at once
    // also make sure it's at least 15 minutes in the future
    if (startDate.isAfter(endDate)) {
      throw Exception('Invalid times');
    }


    // check contacts -> phone must be 10 digits without a '1' or a '+'
    //                -> var 1-4 plus the message can't be longer than 250

    // check unit balance
  }

  // Check user input functions ===
  bool _isDuringLunch() {
    return true;
  }

  // Grabbing HTTP request info ===
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
          'contactlist': contactList,
          'rundatetime': startTime,
          'enddatetime': endTime,
        };
        break;
      case RequestType.jobDetails:
        body = {
          'jobID': await loadData(Keys.jobID.toLocalizedString(),
              path: PROJECT_DATA_PATH),
          'userId': await loadData(Keys.userID.toLocalizedString())
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
      case RequestType.jobDetails:
        return Uri.parse(_jobDetails);
      default:
        throw Exception('Endpoint not found');
    }
    return Uri.parse(authority + endPoint);
  }

  /// === Something else goes here ===
  Future<int> start() async {
    Process process = await Process.start('python', [
      "C:\\Users\\rauch\\Projects\\flutter\\robo_talker_pro\\lib\\scripts\\request.py",
      'POST',
      getUrl(RequestType.multiJobPost).toString(),
      jsonEncode(await getHeaders()),
      PROJECT_DATA_PATH!
    ]);

    // Stream stdout and stderr
    final stdoutStream =
        process.stdout.transform(utf8.decoder).asBroadcastStream();
    final stderrStream =
        process.stderr.transform(utf8.decoder).asBroadcastStream();

    // Handle stdout
    String statusCode = 'Status code: ';
    String response = 'Response: ';
    stdoutStream.listen((data) {
      print(data);
      int startIndex = data.indexOf(statusCode);
      startIndex += statusCode.length;
      statusCode = data.substring(startIndex, startIndex + 3);

      startIndex = data.indexOf(response);
      startIndex += response.length;
      response = data.substring(startIndex);

      if (statusCode != '200') {
        throw Exception('Python process request.py exited with $statusCode');
      }

      // json data that I want
      var responseJson = jsonDecode(response);
      String jobId = responseJson['callId'];
      //responseJson['smsId'];
      //responseJson['callId'];

      saveData(Keys.jobID.toLocalizedString(), jobId, path: PROJECT_DATA_PATH);

      print(data);
    });

    // Handle stderr
    stderrStream.listen((data) {
      print('STDERR: $data');
    });

    return await process.exitCode;
    //print('Python process exited with code: $exitCode');
  }

  /// Robo Talker server posts job details in JSON format when a job has
  /// completed. This function waits till the scheduled end time then attempts
  /// to GET that data. If the job details haven't been posted, then make GET
  /// request every five minutes
  Future<bool> getJobDetails() async {
    DateTime now = DateTime.now();
    Duration timeToWait = endDate.difference(now);
    bool success = false;

    // if difference is negative, the job should be over
    if (timeToWait.isNegative) {
      timeToWait = const Duration(minutes: 5);
    }
    // Wait the specified amount of time and then try and grab job details
    await Future.delayed(timeToWait, () async {
      Process process = await Process.start('python', [
        "C:\\Users\\rauch\\Projects\\flutter\\robo_talker_pro\\lib\\scripts\\get.py",
        'GET',
        getUrl(RequestType.jobDetails).toString(),
        jsonEncode(await getHeaders()),
        jsonEncode(await getBody(RequestType.jobDetails))
      ]);
      // Stream stdout and stderr
      final stdoutStream =
          process.stdout.transform(utf8.decoder).asBroadcastStream();
      final stderrStream =
          process.stderr.transform(utf8.decoder).asBroadcastStream();

      // Handle stdout
      String statusCode = 'Status code: ';
      String response = 'Response: ';
      stdoutStream.listen((data) async {
        int startIndex = data.indexOf(statusCode);
        startIndex += statusCode.length;
        statusCode = data.substring(startIndex, startIndex + 3);

        startIndex = data.indexOf(response);
        startIndex += response.length;
        response = data.substring(startIndex);

        if (statusCode != '200') {
          throw Exception('Python process request.py exited with $statusCode');
        }

        if (!response.contains('No record found.')) {
          print('Response: $response');
          success = true;
          String contactList = await loadData(
              Keys.contactList.toLocalizedString(),
              path: PROJECT_DATA_PATH);
          String detailedReport = _getVars(response, contactList);
          await saveData(Keys.callData.toLocalizedString(), detailedReport,
              path: PROJECT_DATA_PATH);
        }
      });

      // Handle stderr
      stderrStream.listen((data) {
        print(data);
        throw Exception(data);
      });
      await process.exitCode;
    });
    return success;
  }

  /// HTTP request 'GetJobDetails.ashx?' does not return the vars. This function
  /// is designed to append the vars to each entry in contactList.
  String _getVars(String detailedReport, String contactList) {
    List<dynamic> report = jsonDecode(detailedReport);
    List<dynamic> contacts = jsonDecode(contactList);
    Map<String, Map<String, dynamic>> map = {
      for (var item in contacts) item['name']!: item
    };
    List<Map<String, dynamic>> reportWithVars = [];

    for (var item in report) {
      String name = item['ContactName']!;
      Map<String, dynamic> otherItem = map[name]!;

      item['var1'] = otherItem['var1']!;
      item['var2'] = otherItem['var2']!;
      item['var3'] = otherItem['var3']!;
      item['var4'] = otherItem['var4']!;

      reportWithVars.add(item);
    }

    return jsonEncode(reportWithVars);
  }

  String get authority => 'https://robotalker.com/REST/api';
  DateTime get startDate => _startDate.subtract(const Duration(hours: 3));
  DateTime get endDate => _endDate.subtract(const Duration(hours: 3));

  String shortenList(String jsonString) {
    List<dynamic> trimmedInput = [];
    List<dynamic> mappedInput = jsonDecode(jsonString);
    for (Map<String, dynamic> map in mappedInput) {
      map['CallAttempts'] = '';
      map['CallerNumber'] = '';
      map['ScheduledTime'] = '';
      map['CallDuration'] = '';
      map['KeyHitByUser'] = '';
      map['AllKeysHitByUser'] = '';
      map['CallRingTime'] = '';
      map['var1'] = '';
      map['var2'] = '';
      map['var3'] = '';
      trimmedInput.add(map);
    }
    return jsonEncode(trimmedInput);
  }
}
