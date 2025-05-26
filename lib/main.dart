import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_page.dart';
import 'chat_session_provider.dart';
import 'firebase_options.dart';
import 'theme_provider.dart';
import 'home_page.dart';


// UserProvider for managing login state
class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _profilePicUrl;
  bool _isLoggedIn = false;

  String? get userId => _userId;
  String? get profilePicUrl => _profilePicUrl;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');
      _profilePicUrl = prefs.getString('profilePicUrl');
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> login(String userId, String profilePicUrl) async {
    final prefs = await SharedPreferences.getInstance();
    _userId = userId;
    _profilePicUrl = profilePicUrl;
    _isLoggedIn = true;
    await prefs.setString('userId', userId);
    await prefs.setString('profilePicUrl', profilePicUrl);
    await prefs.setBool('isLoggedIn', true);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = null;
    _profilePicUrl = null;
    _isLoggedIn = false;
    await prefs.clear();
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final userProvider = UserProvider();
  await userProvider.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeProvider),
        ChangeNotifierProvider(create: (context) => userProvider),
        ChangeNotifierProvider(create: (_) => ChatSessionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MV Bot',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, foregroundColor: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final nextPage = userProvider.isLoggedIn ? const ChatPage(sessionTitle: '',sessionIndex: 0) : LandingPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/Logo.png', height: 200.0),
            const SizedBox(height: 20.0),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}