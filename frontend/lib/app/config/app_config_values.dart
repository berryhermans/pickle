class AppConfigValues {
  const AppConfigValues({required this.backendBaseUrl});

  final String backendBaseUrl;

  AppConfigValues apply(AppConfigOverrides overrides) => AppConfigValues(
    backendBaseUrl: overrides.backendBaseUrl ?? backendBaseUrl,
  );
}

class AppConfigOverrides {
  const AppConfigOverrides({this.backendBaseUrl});

  final String? backendBaseUrl;
}
