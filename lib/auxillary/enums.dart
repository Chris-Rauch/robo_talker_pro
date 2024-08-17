enum ProjectType { latePayment, returnMail }

enum RequestType { multiJobPost , jobDetails }

enum Update { chrome, chromium, software }

enum Keys {
  roboUsername,
  zToken,
  contactList,
  groupName,
  startTime,
  endTime,
  callerId,
  teUsername,
  tePassword,
  ncaList,
  company,
  agentCode,
  projectType,
  jobID,
  jobName
}

extension KeyExtension on Keys {
  String toLocalizedString() {
    switch (this) {
      case Keys.roboUsername:
        return 'roboUsername';
      case Keys.zToken:
        return 'z_token';
      case Keys.contactList:
        return 'contactlist';
      case Keys.groupName:
        return 'groupname';
      case Keys.startTime:
        return 'rundatetime';
      case Keys.endTime:
        return 'enddatetime';
      case Keys.callerId:
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
        return 'jobid';
      default:
        throw ArgumentError('Unknown key: $this');
    }
  }
}

List<String> projectNames = ['Late Payment', 'Return Mail'];
