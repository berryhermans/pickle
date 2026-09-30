enum PickMethod { random, tournament, kingOfTheHill }

extension PickMethodLabel on PickMethod {
  String get label => switch (this) {
    PickMethod.random => 'Random',
    PickMethod.tournament => 'Tournament',
    PickMethod.kingOfTheHill => 'King of the hill',
  };

  String get description => switch (this) {
    PickMethod.random => 'Let fate pick one for you.',
    PickMethod.tournament => 'Choose your way through a bracket.',
    PickMethod.kingOfTheHill => 'Keep your favorite. Face a new challenger.',
  };
}
