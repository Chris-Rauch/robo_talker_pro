abstract class SettingsState {}

class ViewSettingsState extends SettingsState {
  String? version;
  String? collectionsPath;
  String? pythonPath;
  ViewSettingsState(this.version, this.collectionsPath, this.pythonPath);
}

class ErrorState extends SettingsState {
  final Object e;
  ErrorState(this.e);
}

class LoadingSettingsState extends SettingsState {}
