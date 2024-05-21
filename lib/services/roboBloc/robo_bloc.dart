/// Manages user inputs and integrates data with robotalker.com REST API
library robo_bloc;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'robo_event.dart';
import 'robo_state.dart';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http;
import 'robo_services.dart';

class RoboBloc extends Bloc<RoboEvent, RoboState> {
  RoboBloc() : super(RoboInitialState()) {
    on<RoboInitializeEvent>((event, emit) {
      emit(RoboLoadingState());
      //TODO generate a job name and send it to RoboView
      emit(RoboInitialState());
    });

    ///Triggered when the user attempts to submit a job. Checks for good input
    on<RoboSubmitJobEvent>((event, emit) async {
      try {
        String jobName = event.jobName;
        bool goodInput;

        //checking job name
        if (jobName.length < 50) {
          goodInput = true;
        } else {
          goodInput = false;
        }

        //checking start/stop times
        //if(event.startDate < event.stopTime)

        //call roboServices to update JSON body
        emit(RoboGoodInputState(jobName: goodInput));
      } catch (e) {
        emit(RoboErrorState('Something went wrong'));
      }
      // if(all fields are good) then emit RoboGoodInputState
      // else emit RoboErrorState
      //
      // limit name to under 50chars

      emit(RoboGoodInputState());
    });

    ///This event triggers a REST post to robotalker.com
    on<RoboMultiJobEvent>((event, emit) async {
      emit(RoboLoadingState());
      RoboServices roboServices = RoboServices();
      RequestType multiJobPost = RequestType.multiJobPost;
      try {
        final url = roboServices.getUrl(multiJobPost);
        final header = await roboServices.getHeader();
        final body = roboServices.getBody(multiJobPost);

        final http.Response response = await http.post(
          url,
          headers: header,
          body: body, // Encode the request body as JSON
        );
        //200 -> success
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          emit(RoboCallsActiveState());
          //TODO
        } else {
          throw Exception(
              '${response.statusCode} ${response.headers} ${response.body}');
        }
      } catch (e) {
        emit(RoboErrorState(e));
      }
      // make REST API post
      //await Job Post
      await Future.delayed(const Duration(seconds: 3));
      emit(RoboCallsActiveState());
    });
  }
}
