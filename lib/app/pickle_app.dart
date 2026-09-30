import 'package:flutter/material.dart';

import '../features/collections/screens/collections_page.dart';
import 'pickle_theme.dart';

class PickleApp extends StatelessWidget {
  const PickleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pickle',
    debugShowCheckedModeBanner: false,
    theme: pickleTheme,
    home: const CollectionsPage(),
  );
}
