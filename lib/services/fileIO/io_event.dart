/// This file defines the FileBloc, which handles the business logic related to
/// file picking and file formatting. It processes file picking events and
/// manages the state transitions accordingly.
library io_event_bloc;

import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class FileIoEvent {
  const FileIoEvent();
}

class PickFileEvent extends FileIoEvent {
  const PickFileEvent();
}

class PickFolderEvent extends FileIoEvent {
  const PickFolderEvent();
}

class ReadFileEvent extends FileIoEvent {
  final String filePath;
  final ProjectType projectType;

  const ReadFileEvent(this.filePath, this.projectType);
}

class TriggerErrorEvent extends FileIoEvent {
  final Object error;
  const TriggerErrorEvent(this.error);
}
