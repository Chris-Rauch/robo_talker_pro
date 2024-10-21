/// Robo Services is going to:
///   1) Handle the HTTP requests specifically for the RoboTalker website.
///   2) Validate user inputs

/// This class is going to hold all the information needed to post a job to
/// RoboTalker. It will also vet the information to make sure it will be
/// received without any errors
library robo_services;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/settings_services.dart';

class RoboServices {
  // auth elems
  String? _userName, _zKey;

  // header elems
  final String _contentType = 'application/json';
  String? _auth, _cookie;

  // body elems
  String? _body;
  final String _whatToDo = 'SendTtsMessage',
      _messageId = '0',
      _customerName = 'Chris Rauch',
      _extraReportEmail = 'rauch.christopher13@gmail.com';
  String? _jobName, _optCallerId, _messageText;
  List<dynamic>? _contactList;
  DateTime? _runDateTime, _endDateTime;

  // ashx request params
  final String _userId = '2402';
  String? _jobId;

  // url's and endpoints
  final String _domain = 'https://robotalker.com';
  final String _subDir = '/REST/api';
  final String _jobDetails = 'https://robotalker.com/GetJobDetail.ashx?';
  final String _multiJobPost = "/MultiJob";
  final String _login = "/Login";
  final String _config = "/Config";

  // getters
  Future<String?> get userName async {
    _userName ??= await load(Keys.roboUsername.name);
    return _userName;
  }

  Future<String?> get zKey async {
    _zKey ??= await load(Keys.z_token.name);
    return _zKey;
  }

  String? get auth {
    if (_userName != null && _zKey != null) {
      _auth = 'Basic ${base64Encode(utf8.encode('$_userName:$_zKey'))}';
    } else {
      _auth = null;
    }
    return _auth;
  }

  String? get cookie {
    return _cookie;
  }

  Future<String?> get jobName async {
    _jobName ??= await load(Keys.jobName.name, path: PROJECT_DATA_PATH);
    return _jobName;
  }

  Future<String?> get callerID async {
    _optCallerId ??= await load(Keys.caller_id.name);
    return _optCallerId;
  }

  String? get message {
    _messageText = LATE_PAYMENT_MESSAGE;
    return _messageText;
  }

  Future<List<dynamic>?> get contactList async {
    _contactList ??= await load(Keys.contactlist.name, path: PROJECT_DATA_PATH);
    return _contactList;
  }

  Future<DateTime?> get runDateTime async {
    _runDateTime ??= await load(Keys.runDateTime.name, path: PROJECT_DATA_PATH);
    _runDateTime?.subtract(const Duration(hours: 3));
    return _runDateTime;
  }

  Future<DateTime?> get endDateTime async {
    _endDateTime ??= await load(Keys.endDateTime.name, path: PROJECT_DATA_PATH);
    _endDateTime?.subtract(const Duration(hours: 3));
    return _endDateTime;
  }

  Future<String?> get jobID async {
    _jobId ??= await load(Keys.jobID.name, path: PROJECT_DATA_PATH);
    return _jobId;
  }

  // setters
  Future<void> setJobName(String? jobName) async {
    await save(Keys.jobName.name, jobName, path: PROJECT_DATA_PATH);
    _jobName = jobName;
  }

  Future<void> setRunDateTime(DateTime? dateTime) async {
    dateTime = dateTime!.subtract(const Duration(hours: 3));
    await save(Keys.runDateTime.name, dateTime, path: PROJECT_DATA_PATH);
    _runDateTime = dateTime;
  }

  Future<void> setEndDateTime(DateTime? dateTime) async {
    dateTime = dateTime!.subtract(const Duration(hours: 3));
    await save(Keys.endDateTime.name, dateTime, path: PROJECT_DATA_PATH);
    _endDateTime = dateTime;
  }

  Future<void> setJobID(String? jobID) async {
    await save(Keys.jobID.name, jobID, path: PROJECT_DATA_PATH);
    _jobId = jobID;
  }

  Future<void> setBody(RequestType request) async {
    String? body = jsonEncode(getBody(request));
    await save(Keys.request_body.name, body, path: PROJECT_DATA_PATH);
    _body = body;
  }

  /// Description: Attempts to fetch data data that is saved outside of the
  ///   program. This data is necessary to make HTTP requests to the robotalker
  ///   website (robotalker.com)
  Future<void> init() async {
    await jobName;
    await runDateTime;
    await endDateTime;
    await callerID;
    message;
    await contactList;
    await userName;
    await zKey;
    auth;
  }

  /// Returns the HTTP body based on the request type
  Map<String, dynamic> getBody(RequestType requestType) {
    Map<String, dynamic> body;
    switch (requestType) {
      case RequestType.multiJobPost:
        body = {
          'whattodo': _whatToDo,
          'jobname': _jobName,
          'optcallerid': _optCallerId ?? '',
          'messageid': _messageId,
          'messagetext': _messageText ?? '',
          'customername': _customerName,
          'extrareportemail': _extraReportEmail,
          'phonelistgroupname': _jobName,
          'contactlist': _contactList,
          'rundatetime': _runDateTime.toString(),
          'enddatetime': _endDateTime.toString()
        };
        break;
      case RequestType.jobDetails:
        body = {'jobID': _jobId, 'userId': _userId};
        break;
      default:
        throw Exception('Unknown request');
    }
    return body;
  }

  /// Return the HTTP header. Checks to see if cookie exists
  Map<String, String> getHeader() {
    Map<String, String> header = {};
    header['Content-Type'] = _contentType;
    if (_cookie != null) {
      header['Cookie'] = _cookie!;
    } else if (_auth != null) {
      header['Authorization'] = _auth!;
    }
    return header;
  }

  /// Return the the HTTP url based on the request type
  Uri getUrl(RequestType requestType) {
    String url = _domain;
    switch (requestType) {
      case RequestType.login:
        url += _subDir + _login;
        break;
      case RequestType.config:
        url += _subDir + _config;
        break;
      case RequestType.multiJobPost:
        url += _subDir + _multiJobPost;
        break;
      case RequestType.jobDetails:
        url = _jobDetails;
        break;
      default:
        throw Exception('Endpoint not found');
    }
    return Uri.parse(url);
  }

  /// Description: Makes an HTTP post to robotalker.com to schedule a job for
  ///   automated phone calls. Upon a successful post, the robotalker servers
  ///   should return a json string containing the JobID, SmsID and CallerID.
  ///   these values are saved to the appropriate data members. The Data Manager
  ///   functions 'save' and 'load' also handle this data.
  /// Returns:
  /// Throws:
  /// - Exception('Python process request.py exited with $statusCode')
  /// - Exception('Could not post job to RoboTalker website')
  /// - Exception('Could not locate the request path. These can be changed in the Settings Tab');
  Future<void> multiJobPost() async {
    SettingsServices settings = SettingsServices();
    String? requestPath = await settings.requestPath;
    if (requestPath == null) {
      throw Exception(
          'Could not locate the request path. These can be changed in the Settings Tab');
    }

    Process process = await Process.start('python', [
      requestPath,
      'POST',
      getUrl(RequestType.multiJobPost).toString(),
      jsonEncode(getHeader()),
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
      String? jobId = responseJson['callId'];
      //responseJson['smsId'];
      //responseJson['callId'];
      setJobID(jobId);
    });

    // Handle stderr
    stderrStream.listen((data) {});

    if (await process.exitCode != 0) {
      throw Exception('Could not post job to RoboTalker website');
    }
  }

  /// Description: Fetches job details from the Robo Talker server in JSON
  ///   format after a job has completed. The function waits until the scheduled
  ///   job end time before making a GET request. If job details aren't
  ///   available immediately, it retries every five minutes until successful.
  ///   On successful retrieval, the function processes the response and saves
  ///   the job details locally.
  /// Returns:
  ///   [bool] true if the job details were successfully fetched,
  ///   otherwise `false`.
  Future<bool> getJobDetails() async {
    DateTime now = DateTime.now();
    Duration timeToWait = (await endDateTime)!.difference(now);
    bool success = false;

    // if difference is negative, the job should be over
    if (timeToWait.isNegative) {
      timeToWait = const Duration(minutes: 5);
    }
    // Wait the specified amount of time and then try and grab job details
    await Future.delayed(timeToWait, () async {
      String getPath = await loadData(Keys.get_path.name);
      Process process = await Process.start('python', [
        getPath,
        'GET',
        getUrl(RequestType.jobDetails).toString(),
        jsonEncode(getHeader()),
        jsonEncode(getBody(RequestType.jobDetails))
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
        int startIndex;
        //print('stdout: $data');
        if (data.contains(statusCode)) {
          startIndex = data.indexOf(statusCode);
          startIndex += statusCode.length;
          statusCode = data.substring(startIndex, startIndex + 3);
        }

        if (data.contains(response)) {
          startIndex = data.indexOf(response);
          startIndex += response.length;
          response = data.substring(startIndex);
        }

        if (statusCode != '200') {
          throw Exception('Python process request.py exited with $statusCode');
        }

        if (!response.contains('No record found.')) {
          //print('Response: $response');
          success = true;
          String contactList = await loadData(
              Keys.contactlist.toLocalizedString(),
              path: PROJECT_DATA_PATH);
          String detailedReport = _getVars(response, contactList);
          await saveData(Keys.callData.toLocalizedString(), detailedReport,
              path: PROJECT_DATA_PATH);
        } else {
          success = false;
        }
      });

      // Handle stderr
      stderrStream.listen((data) {
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

  /// Makes an HTTP request to Robo Talker. If successful, returns the response
  /// as json. Otherwise, null.
  /// Returns:
  /// {
  ///   "jobid" : ""
  ///   "smsid" : ""
  ///   "callid" : ""
  /// }
  Future<Map<String, String>?> multiJob() async {
    // prep the data
    var header = getHeader();
    var body = getBody(RequestType.multiJobPost);
    var url = getUrl(RequestType.multiJobPost);

    // POST MultiJob
    var request = http.Request('POST', url);
    request.body = jsonEncode(body);
    request.headers.addAll(header);
    final response = await request.send();

    // Check the status code and handle the response
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    }

    // If the request failed, return null
    return null;
  }

  /// Description: Custom Data Management class. Used to save user and program
  ///   data. Current implementation saves data to disk.
  Future<void> save(String key, dynamic data, {String? path}) async {
    await saveData(key, data, path: path);
  }

  /// Description: Custom Data Management class. Used to load user and program
  ///   data. Current implementation loads data to disk.
  Future<dynamic> load(String key, {String? path}) async {
    return await loadData(key);
  }
}

/*
var headers = {
  'Content-Type': 'application/json',
  'Authorization': '••••••',
  
};
var data = json.encode({
  "whattodo": "SendTtsMessage",
  "jobname": "LP 05/20/2024 to 05/24/2024",
  "optcallerid": "9494709674",
  "messageid": "0",
  "messagetext": "Hi, this message is from General Agents and is for #name#. We’re calling in regards to your contract, #var4#. This is just a courtesy reminder that your payment of, $#var2#, was due on, #var3#, for your insurance policy with, #var1#. You can make payments online at mygaac.com. If you've already made a payment please disregard this message. Thankyou.",
  "customername": "Chris Rauch",
  "extrareportemail": "rauch.christopher13@gmail.com",
  "phonelistgroupname": "LP 05/20/2024 to 05/24/2024",
  "contactlist": [
    {
      "name": "S TOWN TRANSPORTATION INC",
      "phone": "(209) 513-7883",
      "var1": "MALWA FINANCIAL AND INSURANCE ",
      "var2": "2542.02",
      "var3": "May 20",
      "var4": "M W F 1 3 7 7 7 0",
      "groupname": "LP 05/20/2024 to 05/24/2024"
    },
    {
      "name": "Harmanpreet Transport Inc",
      "phone": "(559) 803-5062",
      "var1": "MALWA FINANCIAL AND INSURANCE ",
      "var2": "1267.53",
      "var3": "May 20",
      "var4": "M W F 1 4 2 0 0 7",
      "groupname": "LP 05/20/2024 to 05/24/2024"
    }
  ],
  "rundatetime": "2024/05/29 15:15:00"
});
var dio = Dio();
var response = await dio.request(
  'https://robotalker.com/REST/api/MultiJob',
  options: Options(
    method: 'POST',
    headers: headers,
  ),
  data: data,
);

if (response.statusCode == 200) {
  print(json.encode(response.data));
}
else {
  print(response.statusMessage);
}
*/

/*
{
    "whattodo": "SendTtsMessage",
    "jobname": "LP 05/20/2024 to 05/24/2024",
    "optcallerid": "9494709674",
    "messageid": "0",
    "messagetext": "Hi, this message is from General Agents and is for #name#. We’re calling in regards to your contract, #var4#. This is just a courtesy reminder that your payment of, $#var2#, was due on, #var3#, for your insurance policy with, #var1#. You can make payments online at mygaac.com. If you've already made a payment please disregard this message. Thankyou.",
    "customername": "Chris Rauch",
    //"messageidvm": "Robo Late Payment 1",
    //"imageurl": "",
    "extrareportemail": "rauch.christopher13@gmail.com",
    //"transfernumber": "",
    //"txtreportnumber": "",
    "phonelistgroupname": "LP 05/20/2024 to 05/24/2024",
    "contactlist": [
        {
            "name": "S TOWN TRANSPORTATION INC",
            "phone": "(209) 513-7883",
            "var1": "MALWA FINANCIAL AND INSURANCE ",
            "var2": "2542.02",
            "var3": "May 20",
            "var4": "M W F 1 3 7 7 7 0",
            "groupname": "LP 05/20/2024 to 05/24/2024"
        },
        {
            "name": "Harmanpreet Transport Inc",
            "phone": "(559) 803-5062",
            "var1": "MALWA FINANCIAL AND INSURANCE ",
            "var2": "1267.53",
            "var3": "May 20",
            "var4": "M W F 1 4 2 0 0 7",
            "groupname": "LP 05/20/2024 to 05/24/2024"
        }
        
    ],
    "rundatetime": "2024/05/29 15:15:00"
    //"enddatetime": "",
    //"calloptions": ""
}
*/
