/// This class is going to hold all the information needed to post a job to 
/// RoboTalker. It will also vet the information to make sure it will be 
/// received without any errors
library robo_services;

import 'package:flutter/material.dart';

class RoboServices {
  final String jobName;
  final DateTime startDate;
  final TimeOfDay endDate;
  final String message;
  final String contacts;

  //add all the url endpoints
  final String _url = 'https://robotalker.com/api/rest/'; 

  RoboServices(this.jobName, this.startDate, this.endDate, this.message, this.contacts) {

    // check times. Make sure it's during the day, not too many go out at once

    // check contacts -> phone must be 10 digits without a '1' or a '+'
    //                -> var 1-4 plus the message can't be longer than 250

    // check unit balance

  }

  String get url {return _url;}

}