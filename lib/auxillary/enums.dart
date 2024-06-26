enum ProjectType { latePayment, returnMail }

enum RequestType { multiJobPost }

enum Keys {
  roboUsername,
  zKey,
  contactList,
  groupName,
  startTime,
  endTime,
  callerId,
  teUsername,
  tePassword
}

extension KeyExtension on Keys {
  String toLocalizedString() {
    switch (this) {
      case Keys.roboUsername:
        return 'roboUsername';
      case Keys.zKey:
        return 'z_key';
      case Keys.contactList:
        return 'contactList';
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
      default:
        throw ArgumentError('Unknown key: $this');
    }
  }
}

List<String> projectNames = ['Late Payment', 'Return Mail'];
