import 'package:flutter/material.dart';
import 'package:youtube_clone/features/auth/login_page.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login page after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        );
    });
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffA8DDF9),
            Color(0xffE3F5FF)
          ],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/ShowLa_vertical_logo.png',
          width: 354,
          height: 354,
        ),
      ),
    ),
  );
}
}