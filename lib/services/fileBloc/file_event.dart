/// This file defines the FileBloc, which handles the business logic related to
/// file picking and file formatting. It processes file picking events and
/// manages the state transitions accordingly.
library file_event_bloc;

import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class FileEvent {
  const FileEvent();
}

class SelectFileViewEvent extends FileEvent {
  const SelectFileViewEvent();
}

class PickFileEvent extends FileEvent {
  const PickFileEvent();
}

class PickFolderEvent extends FileEvent {
  const PickFolderEvent();
}

class ReadFileEvent extends FileEvent {
  final String filePath;
  final String folderPath;
  final ProjectType projectType;

  const ReadFileEvent(this.filePath, this.folderPath, this.projectType);
}

/*
class TriggerErrorEvent extends FileIoEvent {
  final Object error;
  const TriggerErrorEvent(this.error);
}
*/
