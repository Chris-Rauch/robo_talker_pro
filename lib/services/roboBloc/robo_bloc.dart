/// Manages user inputs and integrates data with robotalker.com REST API
library robo_bloc;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'robo_event.dart';
import 'robo_state.dart';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http;
import 'robo_services.dart';

class RoboBloc extends Bloc<RoboEvent, RoboState> {
  RoboBloc() : super(RoboInitialState('')) {
    on<RoboInitializeEvent>((event, emit) async {
      emit(RoboLoadingState());
      String jobName = await loadData(Keys.groupName.toLocalizedString(),
          path: PROJECT_DATA_PATH);
      emit(RoboInitialState(jobName));
    });

    ///Triggered when the user attempts to submit a job. Checks for good input
    on<RoboSubmitJobEvent>((event, emit) async {
      try {
        String jobName = event.jobName;
        String startTime = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
          event.startTime.hour,
          event.startTime.minute,
        ).toString();
        //'${event.startDate} ${event.startTime}';
        String endTime = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
          event.stopTime.hour,
          event.stopTime.minute,
        ).toString();
        //'${event.startDate} ${event.stopTime}';
        bool goodInput;

        //checking job name
        if (jobName.length < 50) {
          goodInput = true;
        } else {
          goodInput = false;
        }

        //TODO if(event.startDate < event.stopTime)
        await saveData(Keys.startTime.toLocalizedString(), startTime,
            path: PROJECT_DATA_PATH);
        await saveData(Keys.endTime.toLocalizedString(), endTime,
            path: PROJECT_DATA_PATH);

        //call roboServices to update JSON body
        if (goodInput) {
          emit(RoboGoodInputState());
        } else {
          //TODO emit bad state
          emit(RoboErrorState('Bad Input'));
        }
      } catch (e) {
        emit(RoboErrorState('Something went wrong'));
      }
    });

    ///This event triggers a REST post to robotalker.com
    on<RoboMultiJobEvent>((event, emit) async {
      emit(RoboLoadingState());
      RoboServices roboServices = RoboServices();
      RequestType multiJobPost = RequestType.multiJobPost;
      try {
        final url = roboServices.getUrl(multiJobPost);
        final header = await roboServices.getHeader();
        final body = await roboServices.getBody(multiJobPost);
        final endTime = roboServices.getEndTime();

        final http.Response response = await http.post(
          url,
          headers: header,
          body: body, // Encode the request body as JSON
        );

        //200 -> success
        if (response.statusCode == 200) {
          emit(RoboCallsActiveState(endTime));
          //TODO emit a loading screen indicating when the calls will be done
        } else if (response.statusCode == 307) {
          emit(RoboErrorState('Temporary redirect: HTTP Response 307'));
        } else if (response.statusCode == 401) {
          //TODO handle invalid login credentials
          emit(RoboErrorState('Invalid login credentials: HTTP Response 401'));
        } else {
          emit(RoboErrorState('HTTP Response: ${response.statusCode}'));
        }
      } catch (e) {
        emit(RoboErrorState(e));
      }
    });
  }
}
