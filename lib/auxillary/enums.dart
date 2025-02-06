// ignore_for_file: constant_identifier_names

enum ProjectType { latePayment, returnMail, collections }

enum RequestType { multiJobPost, jobDetails, login, config }

enum Update { chrome, chromium, software }

enum Keys {
  roboUsername,
  z_token,
  contactlist,
  groupname,
  rundatetime,
  enddatetime,
  caller_id,
  teUsername,
  tePassword,
  ncaList,
  company,
  agentCode,
  projectType,
  jobID,
  userID,
  callData,
  chrome_path,
  request_body,
  software_version,
  memo_path,
  request_path,
  get_path,
  collections_path
}

extension KeyExtension on Keys {
  String toLocalizedString() {
    switch (this) {
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
      case Keys.memo_path:
        return 'memo_path';
      case Keys.request_path:
        return 'request_path';
      case Keys.get_path:
        return 'get_path';
      default:
        throw ArgumentError('Unknown key: $this');
    }
  }
}

List<String> projectNames = ['Late Payment', 'Return Mail'];
