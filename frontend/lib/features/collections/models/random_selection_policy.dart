enum RandomSelectionPolicy {
  uniform,
  avoidPrevious,
  noRepeatUntilAllUsed;

  static RandomSelectionPolicy fromStorage(Object? value) =>
      RandomSelectionPolicy.values.firstWhere(
        (policy) => policy.name == value,
        orElse: () => RandomSelectionPolicy.uniform,
      );
}

extension RandomSelectionPolicyLabel on RandomSelectionPolicy {
  String get label => switch (this) {
    RandomSelectionPolicy.uniform => 'Uniform random',
    RandomSelectionPolicy.avoidPrevious => 'Avoid previous pick',
    RandomSelectionPolicy.noRepeatUntilAllUsed => 'No repeat until all used',
  };

  String get description => switch (this) {
    RandomSelectionPolicy.uniform => 'Every option has an equal chance.',
    RandomSelectionPolicy.avoidPrevious =>
      'Avoid the last option picked at random.',
    RandomSelectionPolicy.noRepeatUntilAllUsed =>
      'Pick each option once before starting over.',
  };
}
