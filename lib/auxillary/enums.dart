// ignore_for_file: constant_identifier_names

enum ProjectType { latePayment, returnMail }

enum RequestType { multiJobPost, jobDetails, login, config }

enum Update { chrome, chromium, software }

enum Keys {
  roboUsername,
  z_token,
  contactlist,
  groupName,
  runDateTime,
  endDateTime,
  caller_id,
  teUsername,
  tePassword,
  ncaList,
  company,
  agentCode,
  projectType,
  jobID,
  userID,
  jobName,
  callData,
  chrome_path,
  request_body,
  software_version
}

extension KeyExtension on Keys {
  String toLocalizedString() {
    switch (this) {
      case Keys.roboUsername:
        return 'roboUsername';
      case Keys.z_token:
        return 'z_token';
      case Keys.contactlist:
        return 'contactlist';
      case Keys.groupName:
        return 'groupname';
      case Keys.runDateTime:
        return 'rundatetime';
      case Keys.endDateTime:
        return 'enddatetime';
      case Keys.caller_id:
        return 'caller_id';
      case Keys.teUsername:
        return 'Third Eye Username';
      case Keys.tePassword:
        return 'Third Eye Password';
      case Keys.ncaList:
        return 'nca_list';
      case Keys.company:
        return 'company';
      case Keys.agentCode:
        return 'code';
      case Keys.projectType:
        return 'projecttype';
      case Keys.jobID:
        return 'jobId';
      case Keys.userID:
        return 'userId';
      case Keys.callData:
        return 'calldata';
      case Keys.chrome_path:
        return 'chrome_path';
      case Keys.request_body:
        return 'requestbody';
      case Keys.software_version:
        return 'software_version';
      default:
        throw ArgumentError('Unknown key: $this');
    }
  }
}

List<String> projectNames = ['Late Payment', 'Return Mail'];
