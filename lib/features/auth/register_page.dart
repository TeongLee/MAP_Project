import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_clone/features/auth/login_page.dart';
import 'package:youtube_clone/providers/auth_provider.dart';
import 'package:youtube_clone/home_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showLoading(bool value){
    setState(() => isLoading = value);
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authServiceProvider);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    showLoading(true);

    try {
      await auth.registerWithEmail(email, password);
      showLoading(false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      showLoading(false);
      showSnack('Error: $e');
    }
  }

  Future<void> handleGoogleSignUp() async {
    final auth = ref.read(authServiceProvider);
    showLoading(true);

    try {
      await auth.signInWithGoogle();
      showLoading(false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      showLoading(false);
      showSnack('Error: $e');
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain at least one number';
    if (!RegExp(r'[!@#\$&*~%^()\-_=+{}[\]|;:\",.<>?/]').hasMatch(value)) {
    return 'Must contain at least one special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Scaffold(
        backgroundColor: const Color(0xFFA8DDF9),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 952,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 79),
                    Image.asset('assets/images/showla-logo.png', width: 350, height: 120),
                    const SizedBox(height: 44),
                
                    // Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Sign up',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00508F),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 140,
                        height: 3,
                        margin: const EdgeInsets.only(top: 6, right: 35),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 3, color: Color(0xFF00508F)),
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 20),
                
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                
                    //Email TextFormField
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 4),
                      child: TextFormField(
                        controller: emailController,
                        validator: validateEmail,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB3B3B3),
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 28),
                
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                
                    //Password TextFormField
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB3B3B3),
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 28),
                
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                
                    //Confirm Password TextFormField
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextFormField(
                        controller: confirmPasswordController,
                        validator: validateConfirmPassword,
                        obscureText: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Re-enter your password',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB3B3B3),
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 40),
                
                    // Continue Button
                    GestureDetector(
                      onTap: handleEmailSignUp,
                      child: Container(
                        width: 376,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00508F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 40),
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white, thickness: 1.6)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white, thickness: 1.6)),
                      ],
                    ),
                
                    const SizedBox(height: 30),
                
                    // Google Sign Up Button
                    ElevatedButton(
                      onPressed: handleGoogleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fixedSize: const Size(376, 56),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/google_logo.png', height: 24),
                          const SizedBox(width: 16),
                          const Text(
                            'Sign Up with Google',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 30),
                
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Already have an account? Sign in",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      if (isLoading)
        const Opacity(
          opacity: 0.7,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
      if (isLoading)
        const Center(child: CircularProgressIndicator(color: Colors.white)),
    ],
    );
  }
}