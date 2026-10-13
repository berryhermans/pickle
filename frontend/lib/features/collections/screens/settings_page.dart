import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';
import '../data/collection_storage.dart';
import '../models/random_selection_policy.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CollectionStorage _storage = CollectionStorage();
  late Future<RandomSelectionPolicy> _policyFuture;
  RandomSelectionPolicy? _policy;

  @override
  void initState() {
    super.initState();
    _policyFuture = _storage.loadGlobalRandomPolicy();
  }

  Future<void> _selectPolicy(RandomSelectionPolicy policy) async {
    await _storage.saveGlobalRandomPolicy(policy);
    if (!mounted) return;
    setState(() => _policy = policy);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Settings'),
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).pop(_policy),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: SafeArea(
      child: FutureBuilder<RandomSelectionPolicy>(
        future: _policyFuture,
        builder: (context, snapshot) {
          final policy = _policy ?? snapshot.data;
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load settings: ${snapshot.error}'),
            );
          }
          if (policy == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Choose how Random picks an option by default.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                initiallyExpanded: true,
                leading: const Icon(
                  Icons.casino_outlined,
                  color: PickleColors.forest,
                ),
                title: const Text('Random selection'),
                children: [
                  RadioGroup<RandomSelectionPolicy>(
                    groupValue: policy,
                    onChanged: (selected) {
                      if (selected != null) _selectPolicy(selected);
                    },
                    child: Column(
                      children: [
                        for (final option in RandomSelectionPolicy.values)
                          RadioListTile<RandomSelectionPolicy>(
                            key: ValueKey('random-policy-${option.name}'),
                            value: option,
                            title: Text(option.label),
                            subtitle: Text(option.description),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}
