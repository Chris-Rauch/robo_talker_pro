enum ProjectType { latePayment, returnMail }

enum RequestType { multiJobPost }

enum Key { username, zKey, contactList, groupName, phoneListGroupName }

extension KeyExtension on Key {
  String toLocalizedString() {
    switch (this) {
      case Key.username:
        return 'username';
      case Key.zKey:
        return 'z_key';
      case Key.contactList:
        return 'contactList';
      case Key.groupName:
        return 'groupname';
      case Key.phoneListGroupName:
        return 'phonelistgroupname';
      default:
        throw ArgumentError('Unknown key: $this');
    }
  }
}

List<String> projectNames = ['Late Payment', 'Return Mail'];
