# Pickle random-selection policy: implementation facts

## Reduced-motion preference

- Flutter exposes separate signals for different platform settings.
  `AccessibilityFeatures.reduceMotion` reports that the platform requests
  simplified animations and removed parallax effects; Flutter documents it as
  iOS-only.
  [Flutter API: `AccessibilityFeatures.reduceMotion`](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html)
- `PlatformDispatcher.accessibilityFeatures` provides platform accessibility
  features, so the iOS signal can be read from
  `PlatformDispatcher.instance.accessibilityFeatures.reduceMotion`.
  [Flutter API: `PlatformDispatcher.accessibilityFeatures`](https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/accessibilityFeatures.html)
- For Android's "Remove animations" setting, Flutter exposes
  `MediaQueryData.disableAnimations`. `MediaQuery.disableAnimationsOf(context)`
  reads this property and rebuilds when it changes. Flutter documents iOS
  reduced motion separately; it does not set this flag.
  [Flutter API: `MediaQueryData.disableAnimations`](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)
  [Flutter API: `MediaQuery.disableAnimationsOf`](https://api.flutter.dev/flutter/widgets/MediaQuery/disableAnimationsOf.html)
- Implementation implication: to respect reduced motion on both platforms,
  check the platform-appropriate signal rather than assuming one property
  covers both.

## Local persistence with `shared_preferences`

- The plugin targets simple persistent data, but writes may not have reached
  disk when the call returns. Its README says there is no guarantee writes are
  persisted to disk after returning and advises against using it for critical
  data. Supported values include `int`, `double`, `bool`, `String`, and
  `List<String>`.
  [Official package README](https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences/README.md)
- Since version 2.3.0, the package offers `SharedPreferencesAsync` and
  `SharedPreferencesWithCache` in addition to the legacy `SharedPreferences`
  API. The README says the legacy API will be deprecated and recommends the
  newer APIs for new users.
  [Official package README](https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences/README.md)
- `SharedPreferencesAsync` reads and writes through the platform without a
  local cache; the README says this provides the latest platform-stored value
  regardless of which process stored it, at a possible performance cost.
  `SharedPreferencesWithCache` supports synchronous cached reads, but cache
  values can be stale when another isolate, engine, or native code changes
  preferences.
  [Official package README](https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences/README.md)
  [API: `SharedPreferencesAsync`](https://pub.dev/documentation/shared_preferences/latest/shared_preferences/SharedPreferencesAsync-class.html)
- The README's async examples await preference reads and writes. Missing
  values are nullable in its legacy read example.
  [Official package README](https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences/README.md)
- For migration from legacy `SharedPreferences`, the README documents
  `migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary` and
  says it may run on each launch without data loss if
  `migrationCompletedKey` is not altered or deleted. Changing/removing the key
  prefix can make existing values inaccessible unless transformed or read
  using the old prefix.
  [Official package README](https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences/README.md)
- Implementation implication: use this plugin only if losing a recent policy
  write is acceptable; define stable keys, handle absent values, consider
  cache freshness, and preserve the current key mapping during any migration.
