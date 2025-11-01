import 'package:flutter/material.dart';
import 'package:myanmar_dictionary_mobile/config/config.dart';
import 'package:myanmar_dictionary_mobile/providers/app_provider.dart';
import 'package:myanmar_dictionary_mobile/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const MyanmarDictionary(),
    ),
  );
}

class MyanmarDictionary extends StatefulWidget {
  const MyanmarDictionary({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyanmarDictionaryState();
  }
}

class _MyanmarDictionaryState extends State<MyanmarDictionary> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(body: HomeScreen()),
        );
      },
    );
  }
}
