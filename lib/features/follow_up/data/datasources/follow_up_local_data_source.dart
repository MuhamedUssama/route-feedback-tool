import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/follow_up_config_model.dart';

abstract interface class FollowUpLocalDataSource {
  Future<FollowUpConfigModel?> getFollowUpConfig();
  Future<void> saveFollowUpConfig(FollowUpConfigModel config);
}

@LazySingleton(as: FollowUpLocalDataSource)
class FollowUpLocalDataSourceImpl implements FollowUpLocalDataSource {
  final SharedPrefsService _prefsService;
  static const String _configKey = 'follow_up_config';

  FollowUpLocalDataSourceImpl(this._prefsService);

  @override
  Future<FollowUpConfigModel?> getFollowUpConfig() async {
    try {
      final jsonString = _prefsService.getData(key: _configKey) as String?;
      if (jsonString == null) return null;
      return FollowUpConfigModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException('Failed to get follow up config');
    }
  }

  @override
  Future<void> saveFollowUpConfig(FollowUpConfigModel config) async {
    try {
      await _prefsService.saveData(
        key: _configKey,
        value: jsonEncode(config.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to save follow up config');
    }
  }
}
