import 'config/app_config_values.dart';
import 'config/default_config.dart';
import 'config/develop_config.dart';
import 'config/local_config.dart';
import 'config/production_config.dart';

enum AppFlavor { local, develop, production }

class AppConfig {
  const AppConfig._();

  static const _flavorName = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'develop',
  );
  static const _flavorOverrides = <AppFlavor, AppConfigOverrides>{
    AppFlavor.local: localConfigOverrides,
    AppFlavor.develop: developConfigOverrides,
    AppFlavor.production: productionConfigOverrides,
  };

  static final flavor = _flavorFromName(_flavorName);
  static final values = _valuesForFlavor(flavor);

  static Uri get backendBaseUrl => Uri.parse(values.backendBaseUrl);

  static Uri get searchEndpoint {
    final baseUrl = backendBaseUrl.toString().replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/search');
  }

  static AppConfigValues fromFlavorName(String flavorName) =>
      _valuesForFlavor(_flavorFromName(flavorName));

  static AppFlavor _flavorFromName(String flavorName) => switch (flavorName) {
    'local' => AppFlavor.local,
    'develop' => AppFlavor.develop,
    'production' => AppFlavor.production,
    _ => throw ArgumentError.value(flavorName, 'flavorName', 'Unknown flavor'),
  };

  static AppConfigValues _valuesForFlavor(AppFlavor flavor) {
    final values = defaultConfig.apply(_flavorOverrides[flavor]!);
    _validate(flavor, Uri.parse(values.backendBaseUrl));
    return values;
  }

  static void validate() => _validate(flavor, backendBaseUrl);

  static void _validate(AppFlavor flavor, Uri backendBaseUrl) {
    if (!backendBaseUrl.hasAuthority ||
        !{'http', 'https'}.contains(backendBaseUrl.scheme) ||
        backendBaseUrl.host.isEmpty) {
      throw ArgumentError.value(
        backendBaseUrl,
        'backendBaseUrl',
        'Must be an absolute HTTP or HTTPS URL.',
      );
    }

    final host = backendBaseUrl.host.toLowerCase();
    final isLoopback =
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host == '0.0.0.0';
    if (flavor != AppFlavor.local && isLoopback) {
      throw ArgumentError.value(
        backendBaseUrl,
        'backendBaseUrl',
        'Non-local flavors cannot use a loopback URL.',
      );
    }
  }
}
