/// This library defines the states for handling File IO operations in the application.
/// It includes different state classes representing the various stages of File IO,
/// such as loading, success, and error states. These states can be used in conjunction
/// with a BLoC to manage and respond to File IO events in a structured manner.
///
/// The library helps abstract the complexities of File IO management by providing
/// clear state definitions that the rest of the application can respond to.
/// For instance, it can be used to track the progress of a file upload or download,
/// as well as to handle potential errors during these operations.
library io_state_bloc;

abstract class FileIoState {}

class FileInitialState extends FileIoState {}

class FileIoLoadingState extends FileIoState {}

class FilePickedSuccessState extends FileIoState {
  final String filePath;
  FilePickedSuccessState(this.filePath);
}

class FolderPickedSuccessState extends FileIoState {
  final String folderPath;
  FolderPickedSuccessState(this.folderPath);
}

class FileReadSuccessState extends FileIoState {}

class FileIoErrorState extends FileIoState {
  final Object error;
  FileIoErrorState(this.error);
}
