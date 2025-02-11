abstract class SettingsState {}

class ViewSettingsState extends SettingsState {
  String? version;
  String? chromePath;
  String? memoPath;
  String? requestPath;
  String? getPath;
  String? collectionsPath;
  String? pythonPath;
  ViewSettingsState(this.version, this.chromePath, this.memoPath,
      this.requestPath, this.getPath, this.collectionsPath, this.pythonPath);
}

class ErrorState extends SettingsState {
  final Object e;
  ErrorState(this.e);
}

class LoadingSettingsState extends SettingsState {}
