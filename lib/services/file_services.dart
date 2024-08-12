/// File Services class handles the Late Payment Report provided by the user.
/// It is responsible for parsing through the file and creating a list of 
/// contacts for a Robo Talker job. It also removes contacts that are apart of
/// the 'No Call Agreement' and contacts that have no number. It writes them 
/// to a report.xlsx file located in the folder specified by the user.
library file_servies;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';

class FileServices {
  final Excel _latePaymentFile; // user provided file
  final Excel _reportFile; // contains no nums and duplicate nums
  final String _reportFileLocation;
  final String _projectFile;

  FileServices(String filePath, String folderPath)
      : _latePaymentFile = Excel.decodeBytes(File(filePath).readAsBytesSync()),
        _reportFile = Excel.createExcel(),
        _reportFileLocation = p.join(folderPath, REPORT_FILE_NAME),
        _projectFile = p.join(folderPath, PROJECT_DATA_FILE_NAME) {
    //look for input errors
    if (!File(filePath).existsSync()) {
      throw ArgumentError(
          'This file doesn\'t exist. Was it moved? -> $filePath');
    } else if (p.extension(filePath) == '.xls') {
      throw ArgumentError(
          'Excel file outdate. Make sure the file extension is .xlsx (Excel 2007 or newer)');
    } else if (p.extension(filePath) != '.xlsx') {
      throw ArgumentError(
          'Invalid File Type. Make sure the file extension is .xlsx');
    }
  }

  /// Returns a list of 'contacts' in json format. This is used for REST post.
  /// Removes contacts that are on the No Call Agreement and bad numbers to
  /// a report file located in 'folderPath.'
  /// @throws - Incorrect sheet name,
  Future<String> handleLatePayment() async {
    List<Map<String, dynamic>> contactList = [];
    String groupname = getGroupName();
    String sheetName = _latePaymentFile.getDefaultSheet() ??
        (throw Exception('Cannot access default sheet'));
    Sheet sheet = _latePaymentFile[sheetName];

    //save job name to project data file
    saveData(Keys.groupName.toLocalizedString(), groupname,
        path: PROJECT_DATA_PATH);

    //traverse excel file looking for NCA's and bad phone #'s
    outerLoop: // columns
    for (int x = 2; x < sheet.rows.length; ++x) {
      bool createContact = true;
      var row = sheet.rows[x];
      innerLoop: // rows
      for (var cell in row) {
        int? columnIndex = cell?.columnIndex;

        //Agent Name at column 0
        if (columnIndex == 0) {
          createContact = true;
          if (await _noCallAgreement(company: cell?.value.toString())) {
            createContact = false;
            _writeRowToFile(row);
            break innerLoop;
          } 
        }

        //Agent Code
        if (columnIndex == 1) {
        }
        
        //Phone number
        else if (columnIndex == 5) {
          createContact = true;
          if (_noNumber(cell?.value.toString())) {
            createContact = false;
            _writeRowToFile(row);
            break innerLoop;
          } else if (await _isDuplicate(row, contactList)) {
            createContact = false;
            break innerLoop;
          }
        }
      }

      // if no exceptions were found, create the contact
      if (createContact == true) {
        contactList.add({
          'name': _formatName(row[4]?.value.toString()), //insured name
          'phone': row[5]?.value.toString(), //phone number
          'var1': _formatName(row[0]?.value.toString()), //agent name
          'var2': _removeDollar(row[8]?.value.toString()), //payment amount
          'var3': _formatDate(row[6]?.value.toString()), //due date
          'var4': _addSpaces(row[3]?.value.toString()), //contract number
          'groupname': groupname,
        });
      }

    }
    return json.encode(contactList);
  }

  /// Creates a job name based on the header of the input file
  String getGroupName() {
    String sheetName = _latePaymentFile.getDefaultSheet() ??
        (throw Exception('Cannot access default sheet'));
    Sheet sheet = _latePaymentFile[sheetName];
    String? row = sheet.rows[0][0]?.value.toString();

    if (row != null) {
      row = row.substring(24);
      return 'LP $row';
    } else {
      return '';
    }
  }

  String get getProjectFile {
    return _projectFile;
  }

  ///Remove dollar signs. This is because of how robotalker.com reads them.
  String _removeDollar(String? dollar) {
    if (dollar == null) {
      throw Exception('Null value found but not expected in _removeDollar');
    } else {
      return dollar.replaceAll('\$', '');
    }
  }

  ///Format dates for the REST robotalker.
  ///[2024-04-26T00:00:00.000Z] -> [April 26, 2024]
  String _formatDate(String? date) {
    if (date == null) {
      throw Exception('Null value found but not expected in _formatDate');
    }
    DateTime time = DateTime.parse(date);
    return DateFormat('yMMMd').format(time);
  }

  /// Checks if the company is in the No Call Agreement list. This function
  /// primarily uses the agent code for identification. It will also check the
  /// agent's name
  Future<bool> _noCallAgreement({String? company, String? agentCode}) async {
    if (company != null || agentCode != null) {
      List<dynamic> nca = await loadData(Keys.ncaList.toLocalizedString());
      for (var x in nca) {
        //check for agent code
        if (agentCode != null) {
          if (x[Keys.agentCode.toLocalizedString()].trim() ==
              agentCode.trim()) {
            return true;
          }
        }
        if (company != null) {
          if (x[Keys.company.toLocalizedString()].trim() == company.trim()) {
            return true;
          }
        }
      }
    }
    return false;
  }

  ///Returns true if the argument is all zero's.
  bool _noNumber(String? number) {
    if (number == null) {
      throw Exception('Null value found but not expected in _noNumber');
    } else if ((number == '(000) 000-0000') ||
        (number == '0000000000') ||
        (number == '000-000-0000') ||
        (number == '(000)-000-0000')) {
      return true;
    } else {
      return false;
    }
  }

  ///Returns true if a duplicate number is found. There are 3 outcomes:
  ///1) Matching phone numbers are under the same insured. Contact is combined.
  ///2) Matching phone numbers are under different insure. Contacts are written
  ///to the report file.
  ///3)Numbers don't match
  Future<bool> _isDuplicate(
      List<Data?> row, List<Map<String, dynamic>> contactList) async {
    for (int x = 0; x < 9; ++x) {
      if (row[x] == null) {
        throw (Exception('Null found but not expected in _isDuplicate'));
      }
    }
    var groupName = await loadData(Keys.groupName.toLocalizedString(),
        path: PROJECT_DATA_PATH);
    for (var contact in contactList) {
      String number = row[5]!.value.toString();
      if (contact['phone'] == number) {
        String name = _formatName(row[4]!.value.toString());
        String contract = _formatName(row[3]!.value.toString());
        String intentDate = row[6]!.value.toString();
        String paymentAmt = row[8]!.value.toString();
        if (_areSimilar(contact['name'], name)) {
          //same phone, same insured -> merge
          contactList.remove(contact);
          contactList.add({
            'name': contact['name'],
            'phone': contact['phone'],
            'var1': contact['var1'], //TODO what if they have different agents?
            'var2': _addPayments(paymentAmt, contact['var2']),
            'var3': _chooseSooner(intentDate, contact['var3']),
            'var4': '${contact['var4']} and ${_addSpaces(contract)}',
            'groupname': groupName,
          });
          return true;
        } else {
          //same phone, different insured -> write to file
          contactList.remove(contact);
          _writeContactToFile(contact['phone']);
          _writeRowToFile(row);

          return true;
        }
      }
    }
    //different phone
    return false;
  }

  /// Accepts the following inputs: 'MMMM d, yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'
  /// Returns the earlier date in MMMM d, yyyy format
  String _chooseSooner(String date1, String date2) {
    List<String> patterns = [
      'MMMM d, yyyy',
      'MMM d, yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    ];

    String? findMatchingPattern(String input, List<String> patterns) {
      for (String pattern in patterns) {
        try {
          DateFormat(pattern).parseStrict(input);
          return pattern;
        } catch (e) {
          // Ignore the error and try the next pattern
        }
      }
      return null;
    }

    String? matchingPatternDate1 = findMatchingPattern(date1, patterns);
    String? matchingPatternDate2 = findMatchingPattern(date2, patterns);

    if (matchingPatternDate1 == null || matchingPatternDate2 == null) {
      throw Exception('Could not parse the date in _chooseSooner');
    }

    DateTime dateTime1 = DateFormat(matchingPatternDate1).parse(date1);
    DateTime dateTime2 = DateFormat(matchingPatternDate2).parse(date2);

    if (dateTime1.isBefore(dateTime2)) {
      return DateFormat('MMMM d, yyyy').format(dateTime1);
    } else if (dateTime2.isBefore(dateTime2)) {
      return DateFormat('MMMM d, yyyy').format(dateTime2);
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime1);
    }
  }

  ///Adds the two arguments
  String _addPayments(String amount1, String amount2) {
    double x = double.parse(amount1);
    double y = double.parse(amount2);
    return ((x + y).toStringAsFixed(2));
  }

  /// Returns the argument but with spaces.
  /// Due to how robotalker.com reads numbers out loud to the user, it's
  /// neccessary to add spaces to the contract numbers.
  String _addSpaces(String? contractNumber) {
    String newString = '';
    if (contractNumber == null) {
      return '';
    }
    //add spaces
    for (int x = 0; x < contractNumber.length; ++x) {
      newString += '${contractNumber[x]} ';
    }
    //pop last char, which should be an extra space
    if (newString.isNotEmpty) {
      newString = newString.substring(0, newString.length - 1);
    }
    return newString;
  }

  String _removeSpaces(String contractNumber) {
    contractNumber = contractNumber.replaceAll(' ', '');
    return contractNumber.replaceAll('and', ' and ');
  }

  /// Appends argument 'row' to _reportFile
  void _writeRowToFile(List<Data?> row) {
    List<CellValue?> cellValues = [];
    try {
      String sheetName = _reportFile.getDefaultSheet() ??
          (throw Exception(
              'Cannot access default sheet')); //get the default sheet name
      Sheet sheet = _reportFile[sheetName]; //initialize the sheet

      for (var cell in row) {
        // Extract the value of each cell and add it to the list
        cellValues.add(cell?.value);
      }
      sheet.appendRow(cellValues);
    } catch (e) {
      log('In function _writeRowToFile:', error: e);
    } finally {
      // Save the Excel file to the specified location
      var file = File(_reportFileLocation);
      file.createSync(recursive: true);
      file.writeAsBytesSync(_reportFile.encode()!);
    }
  }

  /// Searches _file for any contacts that match number. It then writes that
  /// entire row to _reportFile
  void _writeContactToFile(String number) {
    try {
      //open _latePaymentFile
      String latePaymentSheet = _latePaymentFile.getDefaultSheet() ??
          (throw Exception('Cannot access default sheet'));
      Sheet sheet = _latePaymentFile[latePaymentSheet];

      for (var row in sheet.rows) {
        for (var cell in row) {
          if (cell?.value.toString() == number) {
            _writeRowToFile(row);
          }
        }
      }
    } catch (e) {
      log('In function _writeContactToFile:', error: e);
    }
  }

  /// Replaces any & symbols with the word 'AND' and removes apostrophes
  String _formatName(String? name) {
    if (name == null) {
      return '';
    }
    String formattedString = name.replaceAll('&', ' AND ');
    formattedString = formattedString.replaceAll('\'', '');
    return formattedString;
  }

  ///Determines if two strings are similar enough to be be the same person.
  ///Checks substrings, matching words and levenshtein's distance.
  bool _areSimilar(String lhs, String rhs) {
    try {
      //find bigger string
      String big, small;
      if (lhs.length < rhs.length) {
        big = rhs;
        small = lhs;
      } else {
        big = lhs;
        small = rhs;
      }

      //check if either one are substrings of the other
      if ((lhs == rhs) || big.contains(small)) {
        return true;
      }

      //check percentage of shared words
      List<String> list1 = big.split(' ');
      List<String> list2 = small.split(' ');
      double match = 0;
      for (int i = 0; i < list2.length; ++i) {
        for (int j = 0; j < list1.length; ++j) {
          if (list2[i].toLowerCase() == list1[j].toLowerCase()) {
            ++match;
          }
        }
      }
      if ((match / list2.length) > 0.50) {
        return true;
      }

      //levenshteins distance
      int t, track;
      List<List<int>> dist = List<List<int>>.generate(
        256,
        (i) => List<int>.generate(256, (int index) => 0, growable: false),
        growable: false,
      );

      int l1 = big.length;
      int l2 = small.length;

      for (int i = 0; i <= l1; ++i) {
        dist[0][i] = i;
      }
      for (int j = 0; j <= l2; ++j) {
        dist[j][0] = j;
      }
      for (int j = 1; j <= l1; ++j) {
        for (int i = 1; i <= l2; ++i) {
          if ((j < l2) && big[i - 1] == small[j - 1]) {
            track = 0;
          } else {
            track = 1;
          }
          t = MIN((dist[i - 1][j] + 1), (dist[i][j - 1] + 1));
          dist[i][j] = MIN(t, (dist[i - 1][j - 1] + track));
        }
      }

      int lDist = dist[l2][l1];
      double percent = ((big.length - lDist) / big.length);
      if (percent > 0.50) {
        return true;
      }

      return false;
    } catch (e) {
      print('$e in function _areSimilar');
      return false;
    }
  }

  int MIN(int x, int y) => ((x) < (y) ? (x) : (y));
}
