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
