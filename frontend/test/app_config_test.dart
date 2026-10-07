import 'package:flutter_test/flutter_test.dart';
import 'package:pickle/app/app_config.dart';

void main() {
  test('local flavor defaults to the local backend', () {
    final config = AppConfig.fromValues(flavorName: 'local');

    expect(config.flavor, AppFlavor.local);
    expect(config.searchEndpoint, Uri.parse('http://localhost:8080/search'));
  });

  test('develop flavor uses its configured backend', () {
    final config = AppConfig.fromValues(
      flavorName: 'develop',
      backendUrl: 'https://pickle-api-develop.example.com/',
    );

    expect(config.flavor, AppFlavor.develop);
    expect(
      config.searchEndpoint,
      Uri.parse('https://pickle-api-develop.example.com/search'),
    );
  });

  test('non-local flavors require a non-loopback backend URL', () {
    expect(
      () => AppConfig.fromValues(flavorName: 'production'),
      throwsStateError,
    );
    expect(
      () => AppConfig.fromValues(
        flavorName: 'production',
        backendUrl: 'http://localhost:8080',
      ),
      throwsArgumentError,
    );
  });

  test('unknown flavors are rejected', () {
    expect(
      () => AppConfig.fromValues(flavorName: 'staging'),
      throwsArgumentError,
    );
  });
}
