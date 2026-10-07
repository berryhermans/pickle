enum AppFlavor { local, develop, production }

class AppConfig {
  const AppConfig._({required this.flavor, required this.backendBaseUrl});

  static const _flavorName = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'local',
  );
  static const _backendUrl = String.fromEnvironment('BACKEND_URL');

  static final current = fromValues(
    flavorName: _flavorName,
    backendUrl: _backendUrl,
  );

  final AppFlavor flavor;
  final Uri backendBaseUrl;

  static AppConfig fromValues({
    required String flavorName,
    String backendUrl = '',
  }) {
    final flavor = switch (flavorName) {
      'local' => AppFlavor.local,
      'develop' => AppFlavor.develop,
      'production' => AppFlavor.production,
      _ => throw ArgumentError.value(
        flavorName,
        'flavorName',
        'Unknown flavor',
      ),
    };
    final url = backendUrl.trim().isNotEmpty
        ? Uri.tryParse(backendUrl.trim())
        : flavor == AppFlavor.local
        ? Uri.parse('http://localhost:8080')
        : null;

    if (url == null) {
      throw StateError(
        'Set BACKEND_URL when building the ${flavor.name} flavor.',
      );
    }

    final config = AppConfig._(flavor: flavor, backendBaseUrl: url);
    config.validate();
    return config;
  }

  Uri get searchEndpoint {
    final baseUrl = backendBaseUrl.toString().replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/search');
  }

  void validate() {
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
