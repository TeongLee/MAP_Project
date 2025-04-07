import 'package:flutter/material.dart';
import 'package:path/path.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 25),
                child: Container(
                  width: 300, // Set the width of the container wider than the image
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 50, // Adjust the blur radius
                        spreadRadius: 10, // Spread radius to make the shadow wider
                        offset: const Offset(0, 4), // Vertical offset
                      ),
                    ],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      "assets/images/youview-signin.jpg",
                      height: 150,
                      width: 250, // Set the image width
                      fit: BoxFit.cover, // Ensure the image fills the container
                    ),
                  ),
                ),
              ),
              const Text(
                "Welcome to YouView👋👋👋",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 11, 132, 192),
                    shadows: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5,
                        offset: Offset(1, 1),
                      )
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
