import 'package:flutter_test/flutter_test.dart';
import 'package:pickle/app/app_config.dart';

void main() {
  test('local flavor defaults to the local backend', () {
    final config = AppConfig.fromFlavorName('local');

    expect(config.backendBaseUrl, 'http://localhost:8080');
  });

  test('develop flavor uses the develop backend', () {
    final config = AppConfig.fromFlavorName('develop');

    expect(config.backendBaseUrl, 'https://pickle-dev.up.railway.app');
  });

  test('production flavor uses the production backend', () {
    final config = AppConfig.fromFlavorName('production');

    expect(config.backendBaseUrl, 'https://pickle-prod.up.railway.app');
  });

  test('unknown flavors are rejected', () {
    expect(() => AppConfig.fromFlavorName('staging'), throwsArgumentError);
  });

  test('AppConfig exposes the active flavor directly', () {
    expect(AppConfig.flavor, AppFlavor.local);
    expect(AppConfig.backendBaseUrl, Uri.parse('http://localhost:8080'));
    expect(AppConfig.searchEndpoint, Uri.parse('http://localhost:8080/search'));
  });
}
