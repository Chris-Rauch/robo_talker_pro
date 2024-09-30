/// The FileServices class handles the Late Payment Report provided by the user.
/// It is responsible for the following tasks:
///
/// 1. Checking for valid input (i.e., verifying the file exists).
/// 2. Reading the file and returning a list of contacts in JSON format.
///    - The contact list is structured as follows:
///      ```json
///      [{
///        "name": "Chris",
///        "phone": "7143290331",
///        "var1": "Agent Name",
///        "var2": "1283.51",
///        "var3": "Jun 3, 2024",
///        "var4": "M W F 1 0 0 0 0 0",
///        "groupname": "LP 10/14/2000 to 10/14/2000"
///      }]
///      ```
///    - Contacts without a phone number are excluded from the list
///    - Contacts covered by GAAC's no-call agreement are excluded from the list
///    - Repeated phone numbers are exluded from the list
/// 3. Annotating and writing skipped contacts to a report file.
///    - The report file is saved in a user-specified folder.
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
  final String _projectFileLocation;
  final List<dynamic> _nca;

  FileServices(String filePath, String folderPath, List<dynamic> nca)
      : _latePaymentFile = Excel.decodeBytes(File(filePath).readAsBytesSync()),
        _reportFile = Excel.createExcel(),
        _reportFileLocation = p.join(folderPath, REPORT_FILE_NAME),
        _projectFileLocation = p.join(folderPath, PROJECT_DATA_FILE_NAME),
        _nca = nca {
    //look for input errors
    if (!File(filePath).existsSync()) {
      throw ArgumentError(
          'This file doesn\'t exist. Was it moved? -> $filePath');
    } else if (p.extension(filePath) == '.xls') {
      throw ArgumentError(
          'Make sure the file extension is .xlsx (Excel 2007 or newer)');
    } else if (p.extension(filePath) != '.xlsx') {
      throw ArgumentError(
          'Invalid File Type. Make sure the file extension is .xlsx');
    } else if (File(_projectFileLocation).existsSync()) {
      throw Exception('Project already exists in this directory');
    }
  }

  /// Description: This asynchronous function processes late payment contacts
  ///   and returns a list of these contacts in JSON format for use in a REST
  ///   POST request. It filters out contacts that are on the
  ///   "No Call Agreement" list or have invalid phone numbers, and logs these
  ///   exceptions to a report file.
  /// Returns:
  ///   [Future<String>] A JSON-encoded string representing a list of valid
  ///   contacts.
  Future<String> handleLatePayment() async {
    List<Map<String, dynamic>> contactList = [];
    String groupname = getGroupName();
    String sheetName = _latePaymentFile.getDefaultSheet()!;
    Sheet sheet = _latePaymentFile[sheetName];
    String? header;

    //save job name to project data file
    await saveData(Keys.groupName.name, groupname, path: PROJECT_DATA_PATH);

    //get all the exception cases. In this order
    List<List<Data?>> noCallAgreement = getNoCall(sheet);
    List<List<Data?>> noNums = getNoNums(sheet);
    List<List<Data?>> duplicates = getDuplicates(sheet);

    // write excpetions to file
    for (int x = 0; x < noCallAgreement.length; ++x) {
      header = ((x == 0) ? 'No Call Agreement' : null);
      _writeRowToFile(noCallAgreement[x], header: header);
    }
    for (int x = 0; x < noNums.length; ++x) {
      header = ((x == 0) ? 'No Phone Number' : null);
      _writeRowToFile(noNums[x], header: header);
    }
    for (int x = 0; x < duplicates.length; ++x) {
      header = ((x == 0) ? 'Duplicate Phone Number' : null);
      _writeRowToFile(duplicates[x], header: header);
    }

    // traverse excel file and create the contactList
    for (int x = 2; x < sheet.rows.length; ++x) {
      List<Data?> row = sheet.rows[x];

      // if no exceptions were found, create the contact
      bool exception = contains(noCallAgreement, row) ||
          contains(noNums, row) ||
          contains(duplicates, row);

      if (!exception) {
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

  /// Description: This function generates a job name based on the header of the
  ///   input file associated with late payments. It retrieves the name from the
  ///   first cell of the first row in the default sheet, formats it, and
  ///   returns it as a string.
  /// Returns:
  ///   [Stirng] A formatted job name, or an empty string if the header is not
  ///   found.
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

  /// Returns the file path to the project file as a string.
  String get getProjectFileLocation {
    return _projectFileLocation;
  }

  /// Returns directory in which _projectFileLocation resides
  String getProjectFolder() {
    return p.dirname(_projectFileLocation);
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
      return '';
    }
    DateTime time = DateTime.parse(date);
    return DateFormat('yMMMd').format(time);
  }

  /// Description: This function checks whether a given company, identified by
  ///   its agent code, is listed in the "No Call Agreement" (NCA) list. It
  ///   compares the provided agent code against the agent codes in the NCA list
  ///   to determine if a match exists.
  /// Params:
  ///   [agentCode] (String): The agent code provided by the user that will be
  ///     checked against the NCA list.
  /// Returns:
  ///   [bool] Returns true if the agent code is found in the NCA list;
  ///   otherwise, returns false.
  bool _noCallAgreement(String agentCode) {
    List<dynamic> nca = _nca;
    //await loadData(Keys.ncaList.toLocalizedString()) ?? [];
    for (var x in nca) {
      if (x[Keys.agentCode.toLocalizedString()].trim() == agentCode.trim()) {
        return true;
      }
    }
    return false;
  }

  /// Description: This function checks if the given phone number matches any
  ///   of several predefined invalid formats. It returns true if the number is
  ///   considered invalid, and false otherwise.
  /// Params:
  ///   [number] (String): The phone number string to be checked.
  /// Returns:
  ///   [bool] - Returns true if the number matches any of the invalid formats,
  ///     otherwise returns false.
  /// Invalid Formats:
  ///   1) '(000) 000-0000'
  ///   2) '0000000000'
  ///   3) '000-000-0000'
  ///   4) '(000)-000-0000'
  bool _noNumber(String number) {
    if ((number == '(000) 000-0000') ||
        (number == '0000000000') ||
        (number == '000-000-0000') ||
        (number == '(000)-000-0000')) {
      return true;
    } else {
      return false;
    }
  }

  /// Description: This function compares two date strings that may follow
  ///   various formats and returns the earlier of the two dates in the MMMM d,
  ///   yyyy format. It supports multiple input formats and ensures strict date
  ///   parsing for each.
  /// Parameters:
  ///   [date1] (String): The first date string to be compared.
  ///   [date2] (String): The second date string to be compared.
  /// Returns:
  ///   [String] The earlier of the two dates, formatted as MMMM d, yyyy.
  /// Accepted Input Formats:
  ///   'MMMM d, yyyy'
  ///   'MMM d, yyyy'
  ///   'MM/dd/yyyy'
  ///   'yyyy-MM-dd'
  ///   "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
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

  /// Description: This function takes two string representations of monetary
  ///   amounts, converts them to double, adds them together, and returns the
  ///   sum as a formatted string with two decimal places.
  /// Parameters:
  ///   [amount1] (String): The first monetary amount.
  ///   [amount2] (String): The second monetary amount.
  /// Returns:
  ///   [String] The sum of the two amounts, formatted to two decimal places.
  String _addPayments(String amount1, String amount2) {
    double x = double.parse(amount1);
    double y = double.parse(amount2);
    return ((x + y).toStringAsFixed(2));
  }

  /// Description: This function adds a space between each character in a
  ///   contract number string. It's specifically designed to format contract
  ///   numbers for better readability when read aloud by automated systems,
  ///   such as robotalker.com. If the input is null, the function returns an
  ///   empty string.
  /// Parameters:
  ///   [contractNumber] (String?): The contract number to be formatted.
  ///     It may be null.
  /// Returns:
  ///   [String] The contract number with spaces between each character. If the
  ///     input is null, an empty string is returned.
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

  /// Description: This function writes a list of Data objects to an Excel file
  ///   row. Optionally, it adds a header to the row if provided. The function
  ///   retrieves the default sheet from the Excel file, converts the Data
  ///   objects to CellValue, and appends the row to the sheet. It handles
  ///   exceptions and ensures the file is saved at the specified location
  ///   after writing.
  /// Params:
  ///   [row] (List<Data?>): A list of Data objects (or null) that represent the
  ///     row to be written to the Excel sheet.
  ///   [header] (String?, optional): An optional string header to be added at
  ///     the beginning of the row. If provided, it will be written in the first
  ///     column of the new row.
  void _writeRowToFile(List<Data?> row, {String? header}) {
    try {
      String sheetName = _reportFile.getDefaultSheet() ??
          (throw Exception(
              'Cannot access default sheet')); //get the default sheet name
      Sheet sheet = _reportFile[sheetName]; //initialize the sheet

      // if header is provided
      if (header != null) {
        int lastRow = sheet.maxRows;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRow))
            .value = TextCellValue(header);
      }

      // Convert List<Data> into List<CellValue>
      List<CellValue?> cellValues = [];
      for (var cell in row) {
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

  /// Description: This function deletes a specified row in an Excel sheet by
  ///   setting the values of all cells in that row to null. It effectively
  ///   clears the row, making it appear empty.
  /// Params:
  ///   [sheet] (Sheet): The Excel sheet from which the row will be deleted.
  ///   [rowIndex] (int): The index of the row to be deleted (0-based).
  ///   [numCols] (int): The number of columns in the row, indicating how many
  ///     cells to clear.
  void deleteRow(Sheet sheet, int rowIndex, int numCols) {
    for (var colIndex = 0; colIndex < numCols; colIndex++) {
      sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
          null);
    }
  }

  /// Description: This function formats a given name string by replacing any
  ///   ampersand (&) symbols with the word "AND" and removing apostrophes (').
  ///   It ensures the name is cleaned up for better readability or consistency
  ///   in output.
  /// Params:
  ///   [name] (String?): The name string to be formatted. It may be null.
  /// Returns:
  ///   [String] A formatted string where all & symbols are replaced with "AND"
  ///   and all apostrophes are removed. If the input is null, an empty string
  ///   is returned.
  String _formatName(String? name) {
    if (name == null) {
      return '';
    }
    String formattedString = name.replaceAll('&', ' AND ');
    formattedString = formattedString.replaceAll('\'', '');
    return formattedString;
  }

  /// Description: This function determines if two strings are similar enough to
  ///   be considered the same person. It performs multiple checks, including
  ///   substring matching, word similarity percentage, and Levenshtein
  ///   distance, to evaluate the similarity between the two input strings.
  /// Params:
  ///   [lhs] (String): The first string to compare.
  ///   [rhs] (String): The second string to compare.
  /// Returns:
  ///   [bool] Returns true if the strings are deemed similar, otherwise returns
  ///   false.
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

  /// Description: This function scans an Excel sheet for contracts that do not
  ///   have valid phone numbers and returns them as a list. It excludes
  ///   contracts that are also on the "No Call Agreement" (NCA) list. The
  ///   function uses the _noNumber function to identify invalid phone numbers
  ///   and the _noCallAgreement function to check if the contract is on the
  ///   NCA list.
  /// Params:
  ///   [sheet] (Sheet): The Excel sheet containing rows of contract data.
  ///   Phone numbers are located in a specific column, and agent codes are
  ///   used to check for NCA status.
  /// Returns:
  ///   [List<List<Data?>>] A list of rows (contracts) that do not have valid
  ///   phone numbers and are not part of the "No Call Agreement." Each row is
  ///   a list of Data? objects.
  List<List<Data?>> getNoNums(Sheet sheet) {
    List<List<Data?>> list = [];

    // traverse excel sheet
    for (int x = 2; x < sheet.rows.length; ++x) {
      List<Data?> row = sheet.rows[x];
      String phoneNumber = row[5]!.value.toString();
      String agentCode = row[1]!.value.toString();
      bool noNumber = _noNumber(phoneNumber);
      bool nca = _noCallAgreement(agentCode);
      if (noNumber == true && nca == false) {
        list.add(row);
      }
    }
    return list;
  }

  /// Description: This function scans through an Excel sheet and returns a
  ///   list of contracts that are on the "No Call Agreement" list. It checks
  ///   each row to determine if the contract’s agent code matches a predefined
  ///   set of conditions using the _noCallAgreement function.
  /// Parms:
  ///   [sheet] (Sheet): The Excel sheet containing rows of contract data.
  ///   Each row represents a contract, with the agent code located in a
  ///   specific column.
  /// Returns:
  ///  [List<List<Data?>>] A list of rows (contracts) that are marked as part
  ///  of the "No Call Agreement." Each row is a list of Data? objects.
  List<List<Data?>> getNoCall(Sheet sheet) {
    List<List<Data?>> list = [];

    // traverse excel sheet
    for (int x = 2; x < sheet.rows.length; ++x) {
      List<Data?> row = sheet.rows[x];
      String agentCode = row[1]!.value.toString();
      bool noCall = _noCallAgreement(agentCode);
      if (noCall == true) {
        list.add(row);
      }
    }
    return list;
  }

  /// Description: This function scans through an Excel sheet and identifies
  ///   rows (contracts) with duplicate phone numbers. It returns a list of
  ///   contracts where the same phone number appears more than once. The
  ///   function excludes invalid phone numbers (such as placeholders) based on
  ///   the _noNumber check, ensuring that only meaningful duplicates are
  ///   captured. This is crucial to avoid data loss when using robotalker.com,
  ///   which automatically removes duplicate phone numbers.
  /// Params:
  ///   [sheet] (Sheet): The Excel sheet containing rows of contract data,
  ///   with phone numbers stored in a specific column.
  /// Returns:
  ///   [List<List<Data?>>] A list of rows (contracts) where phone numbers
  ///   appear more than once in the sheet. Each row is a list of Data?
  ///   objects.
  List<List<Data?>> getDuplicates(Sheet sheet) {
    Map<String, List<List<Data?>>> hashMap = {};
    List<List<Data?>> duplicates = [];

    // loop through excel sheet and add each row to a hash map. Use phone number
    // as key
    for (int x = 2; x < sheet.rows.length; ++x) {
      List<Data?> row = sheet.rows[x];
      String key = row[5]!.value.toString();

      // if the key doesn't exist, create a new list and append to key
      if (hashMap[key] == null) {
        List<List<Data?>> data = [];
        data.add(row);
        hashMap[key] = data;
      } else {
        hashMap[key]!.add(row);
      }
    }

    // loop through hash map and look for keys with multiple values (ignore no
    // no numbers)
    for (var key in hashMap.keys) {
      List<List<Data?>> value = hashMap[key]!;
      if (value.length > 1 && !_noNumber(key)) {
        duplicates.addAll(value);
      }
    }
    return duplicates;
  }

  /// Description: This function checks if a specific row of Data objects is
  ///   present in a given list of rows. It mimics checking if a row exists in
  ///   an Excel file by comparing the string values of each Data.value in the
  ///   row. The function returns true if the row is found in the list and false
  ///   otherwise. If the row contains any null values, it returns false
  ///   immediately.
  /// Params:
  ///   [list] (List<List<Data?>>): A list of rows, where each row is a list of
  ///   Data? objects.
  ///   [row] (List<Data?>): The row of Data? objects to check for in the list.
  /// Returns:
  ///   [bool] The function returns true if all Data.value entries in a row
  ///   match, and false otherwise.
  bool contains(List<List<Data?>> list, List<Data?> row) {
    if (row.contains(null)) {
      return false;
    }
    bool isEqual = false;

    // loop through list
    for (int x = 0; x < list.length; ++x) {
      isEqual = true;
      List<Data?> listItem = list[x];

      // loop through both rows, comparing their cell values
      // don't loop if their lengths are different
      if (listItem.length == row.length) {
        innerLoop:
        for (int y = 0; y < row.length; ++y) {
          String val1 = listItem[y]?.value.toString() ?? '';
          String val2 = row[y]?.value.toString() ?? '';
          if (val1 != val2) {
            isEqual = false;
            break innerLoop;
          }
        }
        if (isEqual == true) {
          break;
        }
      }
    }
    return isEqual;
  }
}
