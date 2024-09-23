
import 'package:robo_talker_pro/auxillary/enums.dart';

abstract class SettingsEvent{}

class FetchSettingsEvent extends SettingsEvent {}

class CheckForUpdatesEvent extends SettingsEvent {}

class UpdateEvent extends SettingsEvent {
  Update update;
  UpdateEvent(this.update);
}

