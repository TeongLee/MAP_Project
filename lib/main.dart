// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_clone/cores/firebase_options.dart';
import 'package:youtube_clone/features/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "map project",
    options: DefaultFirebaseOptions.currentPlatform
  );

  // Because using Riverpod: so change the argument MyApp()
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(
        
      ),
    );
  }
}
