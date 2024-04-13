import 'package:flutter/material.dart';
import 'package:robo_talker_pro/auxillary/enums.dart';
import 'package:robo_talker_pro/auxillary/error_popup.dart';
import 'package:robo_talker_pro/services/fileIO/io_bloc.dart';
import 'package:robo_talker_pro/services/fileIO/io_event.dart';
import 'package:robo_talker_pro/services/fileIO/io_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectFileView extends StatefulWidget {
  final ProjectType projectType;
  const SelectFileView({super.key, required this.projectType});

  @override
  _SelectFileViewState createState() => _SelectFileViewState();
}

class _SelectFileViewState extends State<SelectFileView> {
  late final ProjectType projectType;
  String filePath = "";
  String folderPath = "";

  @override
  void initState() {
    super.initState();
    projectType = widget.projectType;
  }

  void goBack() {
    Navigator.pop(context);
  }

  void goNext() {
    if (projectType == ProjectType.latePayment) {
      Navigator.pushNamed(context, '/late_payment/robo_input');
    } else if (projectType == ProjectType.returnMail) {
      Navigator.pushNamed(context, '/return_mail/progress_view');
    } else {
      setState(() {
        filePath = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FileIoBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(projectNames[projectType.index]),
        ),
        body: BlocBuilder<FileIoBloc, FileIoState>(
          builder: (context, state) {
            if (state is FileInitialState) {
              // TODO implement logic for the initial selct file state
            } else if (state is FilePickedSuccessState) {
              // begin parsing the file in accordance with project type
              filePath = state.filePath;
              context
                  .read<FileIoBloc>()
                  .add(ReadFileEvent(state.filePath, projectType));
            } else if (state is FolderPickedSuccessState) {
              folderPath = state.folderPath;
            } else if (state is FileIoLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FileIoErrorState) {
              showSnackBarAfterBuild(context, state.error);
            } else if (state is FileReadSuccessState) {
              /** TODO implement some sort of indicator that the file was read
               * successfully. Allow the user to proceed to the next step.
              */
            } else {
              showSnackBarAfterBuild(context, 'Error');
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FileIoBloc>().add(const PickFileEvent()),
                    child: const Text("Select File"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    filePath,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FileIoBloc>().add(const PickFolderEvent()),
                    child: const Text("Select Folder"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    folderPath,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: goBack,
                        child: const Text("Back"),
                      ),
                      ElevatedButton(
                        onPressed: goNext,
                        child: const Text("Next"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
