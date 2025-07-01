import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

void main() => runApp(RefuelApp());

class RefuelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refuel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ----------------------------
// 1. Welcome Screen
// ----------------------------
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/intro3.png'),
          fit: BoxFit.contain,
        ),
      ),
      
    );
  }
}

// ----------------------------
// 2. Onboarding Screen
// ----------------------------
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'assets/images/intro2.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
           padding: const EdgeInsets.fromLTRB(20, 20, 24, 36),
  child: Column(
    children: [
      Image.asset(
        'assets/images/Brand.png', 
        // width: 200,
        // fit: BoxFit.contain,
      ),
      const SizedBox(height: 15),
      const Text(
        'A Map That helps you find\nFuel Station',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 23,
          color: Color(0xFF383838),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 36),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF725E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'SIGN UP',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Already have an account? ',
            style: TextStyle(fontSize: 15, color: Color(0xFF7B7B7B)),
          ),
          Text(
            'SIGN IN',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFAF0505),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  ),
),

        ],
      ),
    );
  }
}

// ----------------------------
// 3. Auth Screen (Signin / Signup)
// ----------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Text(
                isSignIn ? "Welcome Back!" : "Create your account",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFAF0505),
                ),
              ),
              const SizedBox(height: 24),
              buildToggleTabs(),
              const SizedBox(height: 30),
              buildFormCard(),
              if (isSignIn)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text("Forgot Password?",
                      style: TextStyle(color: Color(0xFF7B7B7B))),
                ),
              const SizedBox(height: 24),
              const Text("OR", style: TextStyle(color: Color(0xFF7B7B7B))),
              const SizedBox(height: 12),
              buildSocialIcons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToggleTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSignIn = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSignIn ? const Color.fromARGB(255, 255, 189, 180) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("Sign In",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSignIn = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isSignIn ? const Color.fromARGB(255, 255, 189, 180) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("Sign Up",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE9E9E9)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.login_outlined, size: 18, color: Color(0xFF383838)),
              SizedBox(width: 8),
              Text("Enter Details",
                  style: TextStyle(  fontSize: 15, color: Color(0xFF3C3C3C), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 18),

          if (isSignIn) ...[
            signInTextField(
              "Email or Phone No.",
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            signInTextField(
              "Password....",
              obscureText: true,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ],

          if (!isSignIn) ...[
            signUpTextField(
              "Email or Phone No.",
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            signUpTextField(
              "Password....",
              obscureText: true,
             borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 12),
            signUpTextField(
              "Confirm Password....",
              obscureText: true,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: 
              ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 189, 180),
                foregroundColor: const Color(0xFFAF0505),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isSignIn ? "Sign In" : "Sign Up",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                      ),
                  const SizedBox(width: 8),
                  const Icon(Icons.login ,
                  size:20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget buildSocialIcons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE9E9E9)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          FaIcon(
            FontAwesomeIcons.facebook,
            color: Color.fromARGB(255, 45, 45, 45),
            size: 30,
          ),
          FaIcon(
            FontAwesomeIcons.google,
            color: Color.fromARGB(255, 45, 45, 45),
            size: 30,
          ),
          FaIcon(
            FontAwesomeIcons.twitter,
            color: Color.fromARGB(255, 45, 45, 45),
            size: 30,
          ),
        ],
      ),
    );
  }


  // ----------------------------
  // Sign In TextField
  // ----------------------------
  Widget signInTextField(
    String hint, {
    bool obscureText = false,
    required BorderRadius borderRadius,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE9E9E9),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ----------------------------
  // Sign Up TextField
  // ----------------------------
  Widget signUpTextField(
    String hint, {
    bool obscureText = false,
    required BorderRadius borderRadius,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE9E9E9),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}


