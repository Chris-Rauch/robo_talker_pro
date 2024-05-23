// ignore_for_file: constant_identifier_names, non_constant_identifier_names

///Part of the REST post to robotalker.com.
const String LATE_PAYMENT_MESSAGE =
    'Hi, this message is from General Agents and is for #name#. We\’re calling in regards to your contract, #var4#. This is just a courtesy reminder that your payment of, \$#var2#, was due on, #var3#, for your insurance policy with, #var1#. You can make payments online at mygaac.com. If you\'ve already made a payment please disregard this message. Thankyou.';

///Name of the file where all NCA's, no numbers, duplicate numbers and failed calls go.
const String REPORT_FILE_NAME = 'report.xlsx';

///Name of the file where the REST post data is stored
const String PROJECT_DATA_FILE_NAME = '.project.txt';

///Full path to the file where REST post data is stored. This is the user selected File.
String? PROJECT_DATA_PATH; //initialized in <ReadFileEvent>