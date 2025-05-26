import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';
import 'signup.dart';
import 'theme_provider.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _loginUserWithEmailAndPassword() async {
    final stopwatch = Stopwatch()..start();
    try {
      setState(() => _isLoading = true);

      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please fill in both email and password",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        setState(() => _isLoading = false);
        return;
      }

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String profilePicUrl = userCredential.user?.photoURL ?? 'https://via.placeholder.com/150';

      // Measure how long this part takes
      print("Firebase Auth done in ${stopwatch.elapsedMilliseconds}ms");

      // Optional: Enable after confirming performance is good
      // final userProvider = Provider.of<UserProvider>(context, listen: false);
      // await userProvider.login(email, profilePicUrl);
      // print("UserProvider login took ${stopwatch.elapsedMilliseconds}ms");

      Fluttertoast.showToast(
        msg: "Login Successful!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage(sessionTitle: '', sessionIndex: 0)),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'user-not-found' => "No user found with this email",
        'wrong-password' => "Wrong password. Please try again.",
        'invalid-email' => "Invalid email format",
        'network-request-failed' => "Network error. Check your connection.",
        _ => e.message ?? "An error occurred. Please try again.",
      };

      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() => _isLoading = false);
      print("Total login process took ${stopwatch.elapsedMilliseconds}ms");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Log-in',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme(
                themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/Logo.png', height: 150.0),
              const SizedBox(height: 30.0),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginUserWithEmailAndPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Log In', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                ),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
