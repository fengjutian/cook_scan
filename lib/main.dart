import 'package:flutter/material.dart';
import 'pages/navigation_root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIRecipeApp());
}

class AIRecipeApp extends StatelessWidget {
  const AIRecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Cook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const NavigationRoot(),
    );
  }
}
