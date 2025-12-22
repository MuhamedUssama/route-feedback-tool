import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/constants/app_constants.dart';
import 'package:mentor_assistant/core/errors/exceptions.dart';
import 'package:mentor_assistant/features/settings/data/models/cycle_config_model.dart';

abstract interface class CycleLocalDataSource {
  Future<void> saveConfig(CycleConfigModel config);
  Future<CycleConfigModel?> getConfig();
}

@LazySingleton(as: CycleLocalDataSource)
class CycleLocalDataSourceImpl implements CycleLocalDataSource {
  @override
  Future<void> saveConfig(CycleConfigModel config) async {
    try {
      final box = await Hive.openBox<CycleConfigModel>(
        AppConstants.kSettingsBox,
      );
      await box.put('cycle_config', config);
    } catch (e) {
      throw CacheException('Cache Error');
    }
  }

  @override
  Future<CycleConfigModel?> getConfig() async {
    try {
      final box = await Hive.openBox<CycleConfigModel>(
        AppConstants.kSettingsBox,
      );
      return box.get('cycle_config');
    } catch (e) {
      throw CacheException('Cache Error');
    }
  }
}
