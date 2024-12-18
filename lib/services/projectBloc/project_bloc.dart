import 'dart:io';
import 'package:provider/provider.dart';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/file_services.dart';
import 'package:robo_talker_pro/services/robo_services.dart';
import 'package:robo_talker_pro/services/settings_services.dart';
import 'project_event.dart';
import 'project_state.dart';
import 'package:bloc/bloc.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitialState()) {
    on<InitializeProjectEvent>((event, emit) {
      // pop up indicating lost progress
      // reset .project.json data
      emit(ChooseProjectState());
    });

    on<ProjectSelectedEvent>((event, emit) {
      if (event.projectType == ProjectType.latePayment) {
        emit(ChooseFilePathsState()); //TODO include arguments in State
      } else {
        emit(ChooseFilePathsState());
      }
    });

    /// The user has chosen a Late Payment File and a directory for the
    /// project. Parse the file to get contact info and save necessary data
    /// for the project.
    on<FilePathSelectedEvent>((event, emit) async {
      emit(ProjectLoadingState());
      String? filePath = event.filePath;
      String? folderPath = event.folderPath;
      ProjectType projectType = event.projectType;
      String contacts = '';

      try {
        // check user input
        if (filePath == null || folderPath == null) {
          throw Exception('Please make your selections');
        }

        // File Service object will handle all file operations
        List<dynamic> nca =
            await loadData(Keys.ncaList.toLocalizedString()) ?? [];
        var fileServices = FileServices(filePath, folderPath, nca);

        // set global variable
        PROJECT_DATA_PATH = fileServices.getProjectFileLocation;

        // parse file
        String projectTypeAsString = '';
        if (projectType == ProjectType.latePayment) {
          contacts = await fileServices.handleLatePayment();
          projectTypeAsString = 'Late Payment';
        } else if (projectType == ProjectType.returnMail) {
          // call python process
          projectTypeAsString = 'Return Mail';
        }

        // save contacts, groupName and project type
        String jobName = fileServices.getGroupName();
        String key = Keys.contactlist.name;
        await saveData(key, contacts, path: PROJECT_DATA_PATH);
        key = Keys.groupname.name;
        await saveData(key, jobName, path: PROJECT_DATA_PATH);
        key = Keys.projectType.toLocalizedString();
        await saveData(key, projectTypeAsString, path: PROJECT_DATA_PATH);

        emit(ChooseCallInfoState(jobName));
      } catch (e) {
        if (e == PathAccessException) {
          emit(ProjectErrorState('The file you selected is already open.'));
        } else {
          emit(ProjectErrorState(e));
        }
      }
    });

    /// All necessary information has been received. Make HTTP request
    on<PostJobEvent>((event, emit) async {
      emit(ProjectLoadingState());
      RoboServices job = RoboServices();
      // TODO use settings class to initialize python process rather than all
      // those laodData calls
      SettingsServices settings = SettingsServices();
      DateTime timeFinished = event.endTime;
      int exitCode = -1;

      try {
        // TODO when would init return false?
        // initilaize data from save file into job object. Acts as constructor
        if (await job.init(event.jobName, event.startTime, event.endTime)) {}

        // post to RoboTalker website. Exceptions are thrown on errors
        await job.multiJobPost();

        // pad end time by 5 min for debugging


        // display to the user the estimated completion time
        // poll the resource to check for completion
        // incrementing by 5 min until completion
        do {
          emit(PollingResourceState(timeFinished));
          timeFinished = timeFinished.add(const Duration(minutes: 5));
        } while (!(await job.getJobDetails()));

        // TODO wrap this in robo services or create new TE library
        // start memo'ing accounts
        PROJECT_DATA_PATH;
        String pythonFile = await loadData(Keys.memo_path.name);
        String userName = await loadData(Keys.teUsername.toLocalizedString());
        String pWord = await loadData(Keys.tePassword.toLocalizedString());
        String chromeExe = await loadData(Keys.chrome_path.toLocalizedString());
        const String memoMessage =
            "RoboCall went out. Left a message,RoboCall went out. Insured answered,RoboCall attempted. Insured did not answer and didn't leave a message,RoboCall attempted. Invalid phone number";
        Process process = await Process.start('python', [
          pythonFile,
          PROJECT_DATA_PATH!,
          'head',
          userName,
          pWord,
          memoMessage,
          chromeExe
        ]);

        // handle stdout
        await for (final output in process.stdout) {
          String pipe = String.fromCharCodes(output);
          List<String> pipeSections = pipe.split('~');

          if (pipeSections.length == 4) {
            double percent = double.parse(pipeSections[0]); // 1.0
            //double estimatedTime = double.parse(pipeSections[1]); // 10 (in minutes)
            //String success = pipeSections[2]; // success/failed
            //String row = pipeSections[3]; // ['Me', '7143290331', 'Answering Machine', '1', '9494709674', '8/26/2024 5:35:00 PM', '80', '8/26/2024 5:36:37 PM', '3021657', '', '', '8/26/2024 5:35:17 PM', '28', '1008603', 'My agency', '1763.46', 'Aug 12, 2024', 'M W F 1 0 1 3 1 4']
            emit(ProgressState(percent));
          } else {
            print(pipe);
          }
        }

        exitCode = await process.exitCode;
        if (exitCode == 0) {
          emit(JobCompleteState());
        } else {
          throw Exception('Python memo.py failed.');
        }
      } catch (e) {
        emit(ProjectErrorState(e));
      }
    });

    on<LoadingEvent>((event, emit) {
      try {
        emit(ProjectLoadingState());
      } catch (e) {
        emit(ProjectErrorState(e));
      }
    });
  }
}

// TODO process.stdout should return jobID
// save jobID to .project.json

// TODO poll the resource
/*
            JOB DETAILS MAY BE REQUESTED:
            You can get JSON details for each Job accessing: GetJobDetail.ashx
            By groupName :https://robotalker.com/GetJobDetail.ashx?groupName=xxxxxxxxx(hipaa
            requires “&token=xxxxxx”) By jobId and userId
            https://robotalker.com/GetJobDetail.ashx?jobId=XXXXX&userId=xxxxxx(hipaa requires
            “&token=xxxxxx”)
            You may also get details about any job here:
            https://robotalker.com/GetJobDetail.ashx?jobId=1006601&userId=2402

            timeTzOffset	-04:00:00
          */
