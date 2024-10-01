import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class SettingsEvent {}

class FetchSettingsEvent extends SettingsEvent {}

class SaveDataEvent extends SettingsEvent {
  Keys key;
  String data;
  String? path;
  SaveDataEvent(this.key, this.data, {this.path});
}

class SelectFileEvent extends SettingsEvent {
  Keys key;
  String? path;
  SelectFileEvent(this.key, {this.path});
}

class CheckForUpdatesEvent extends SettingsEvent {}

class UpdateEvent extends SettingsEvent {
  Update update;
  UpdateEvent(this.update);
}
