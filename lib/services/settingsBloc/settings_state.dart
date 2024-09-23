abstract class SettingsState {}

class ViewSettingsState extends SettingsState {
  String version;
  String path;
  ViewSettingsState(this.version, this.path);
}

class ErrorState extends SettingsState {
  final Object e;
  ErrorState(this.e);
}

class LoadingSettingsState extends SettingsState {}
