import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:robo_talker_pro/auxillary/constants.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/shared_preferences.dart';
import 'package:robo_talker_pro/services/fileBloc/file_services.dart';
import 'package:robo_talker_pro/views/main_view/project_view.dart';
import 'file_event.dart';
import 'file_state.dart';
import 'package:bloc/bloc.dart';
import 'package:path/path.dart' as p;

class FileBloc extends Bloc<FileEvent, FileState> {
  FileBloc() : super(FileInitialState()) {
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

    on<FilePathSelectedEvent>((event, emit) async {
      String? filePath = event.filePath;
      String? folderPath = event.folderPath;
      ProjectType projectType = event.projectType;

      try {
        // check user input
        if (filePath == null || folderPath == null) {
          // no input
          throw Exception('Please make your selections');
        } else if (!File(filePath).existsSync() ||
            !Directory(folderPath).existsSync()) {
          // input file moved
          throw Exception('File or Directory does not exist');
        }

        // File Service object will handle all file operations
        var fileServices = FileServices(filePath, folderPath);

        // check to see if a project already exists
        String projectFile = fileServices.getProjectFile;
        if (File(projectFile).existsSync()) {
          throw Exception('Project already exists in this directory');
        } else {
          PROJECT_DATA_PATH = projectFile;
        }

        // parse file
        String contacts = '';
        if (projectType == ProjectType.latePayment) {
          contacts = await fileServices.handleLatePayment();

          // save project type
          await saveData(Keys.projectType.toLocalizedString(), 'Late Payment',
              path: PROJECT_DATA_PATH);
        }

        // save contacts
        if (contacts.isNotEmpty) {
          String key = Keys.contactList.toLocalizedString();
          await saveData(key, contacts, path: PROJECT_DATA_PATH);
        } else {
          throw Exception('Late Payment Report is empty');
        }

        // move to Call Info View
        String jobName = fileServices.getGroupName();
        emit(ChooseCallInfoState(jobName));
      } catch (e) {
        if (e == PathAccessException) {
          emit(ProjectErrorState(
              'The file you selected is already open. Close it and try again'));
        } /*else if (e == PathAccessException) {
          emit(ProjectErrorState(
              '$e Something might be wrong with the file format'));
        } */
        else {
          emit(ProjectErrorState(e));
        }
      }
    });

    on<PostJobEvent>((event, emit) {
      // check inputs
        /* Make sure time is NOT at night
           time cant be in the past
           if it's during working hours and not at lunch, warn user
        */

      // post to RoboTalker API

           
    });
  }
}
