import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'services/api_service.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/search_screen.dart';
import 'screens/petrol_pump_details_screen.dart';
import 'services/bookmark_service.dart';
import 'models/petrol_pump_model.dart';
import 'package:provider/provider.dart';
import 'screens/cng_pump_details_screen.dart';
import 'screens/ev_station_details_screen.dart';
import 'screens/mechanic_details_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => BookmarkService(),
      child: const RefuelApp(),
    ),
  );
}
class RefuelApp extends StatelessWidget {
  const RefuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refuel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AppInitializer(),
        '/search': (context) => const SearchAndFilterScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/saved': (context) => const SavedScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const AuthScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic route for /details
        if (settings.name == '/details') {
          final pump = settings.arguments as PetrolPump;
          print('Pump Type: ${pump.serviceType}');

          switch (pump.serviceType) {
            case ServiceType.petrol:
              return MaterialPageRoute(
                builder: (_) => FuelStationDetailScreen(pump: pump),
              );
            case ServiceType.cng:
              return MaterialPageRoute(
                builder: (_) => CngStationDetailScreen(pump: pump),
              );
            case ServiceType.ev:
              return MaterialPageRoute(
                builder: (_) => EvStationDetailScreen(pump: pump),
              );
            case ServiceType.mechanic:
              return MaterialPageRoute(
                builder: (_) => MechanicDetailScreen(pump: pump),
              );
            default:
              return _errorRoute();
          }
        }

        // Fallback for unknown routes
        return _errorRoute();
      },
    );
  }

  /// Error route fallback widget
  MaterialPageRoute _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }

}


// ✅ This runs first and decides which screen to show
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const HomeScreen() : const WelcomeScreen();
      },
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
// 2. Onboarding Screen (Updated)
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
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 120,
                  fit: BoxFit.contain,
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
                        MaterialPageRoute(
                          builder: (_) => const AuthScreen(),
                          settings: const RouteSettings(arguments: false),
                        ),
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
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 15, color: Color(0xFF7B7B7B)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthScreen(),
                            settings: const RouteSettings(arguments: true),
                          ),
                        );
                      },
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFAF0505),
                          fontWeight: FontWeight.w700,
                        ),
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
// 3. Auth Screen (Updated with API integration)
// ----------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is bool) {
        setState(() {
          isSignIn = args;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (isSignIn) {
        // Login logic
        final response = await ApiService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.body}')),
          );
        }
      } else {
        // Register logic
        final response = await ApiService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response.statusCode == 201) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.body}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
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
                const SizedBox(height: 20),
                // SKIP Button (Updated color)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 189, 180),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.red, size: 22),
                    label: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                  color: isSignIn
                      ? const Color.fromARGB(255, 255, 189, 180)
                      : Colors.transparent,
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
                  color: !isSignIn
                      ? const Color.fromARGB(255, 255, 189, 180)
                      : Colors.transparent,
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
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3C3C3C),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 18),
          if (isSignIn) ...[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE9E9E9),
                hintText: "Email or Phone No.",
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE9E9E9),
                hintText: "Password....",
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ],
          if (!isSignIn) ...[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE9E9E9),
                hintText: "Name",
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE9E9E9),
                hintText: "Email or Phone No.",
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE9E9E9),
                hintText: "Password....",
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 189, 180),
                foregroundColor: const Color(0xFFAF0505),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isSignIn ? "Sign In" : "Sign Up",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(width: 8),
                  const Icon(Icons.login, size: 20),
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
          FaIcon(FontAwesomeIcons.facebook,
              color: Color.fromARGB(255, 45, 45, 45), size: 30),
          FaIcon(FontAwesomeIcons.google,
              color: Color.fromARGB(255, 45, 45, 45), size: 30),
          FaIcon(FontAwesomeIcons.twitter,
              color: Color.fromARGB(255, 45, 45, 45), size: 30),
        ],
      ),
    );
  }

}
