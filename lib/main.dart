import 'package:allen_hicham/home_page.dart';
import 'package:allen_hicham/pallete.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Allen',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
         appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.whiteColor,
      ),),

      home: const HomePage(),
    );
  }
}
