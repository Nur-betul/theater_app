import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_app/screens/theaters.dart';

User? globaluser;

class LoginPage extends StatefulWidget {
  final SupabaseClient client;

  const LoginPage({required this.client});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> signUp() async {
    try {
      final AuthResponse response = await widget.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signed up successfully!")),
        );

        // Navigate to the Dashboard page after successful sign-up
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventWidget(
              eventData: {},
            ),
          ),
        );
        //await createPersonalDatabase(_emailController.text);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Signed up failed")));
      }
    } catch (e) {
      if (e is AuthException) {
        print("Sign Up/In failed: ${e.message}, statusCode: ${e.statusCode}");
        if (e.statusCode == 429) {
          // Handle rate limit exceeded error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Too many sign-up attempts. Try again later.")),
          );
        } else if (e.statusCode == 400) {
          // Handle invalid credentials error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Invalid credentials. Please check your email and password.")),
          );
        } else {
          // Handle other errors if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Sign Up/In failed. Please try again later.")),
          );
        }
      } else {
        // Handle other types of exceptions if needed
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An error occurred. Please try again later.")),
        );
      }
    }
  }

  Future<void> signIn(BuildContext context) async {
    try {
      final response = await widget.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signed in successfully!")));
        globaluser = response.user;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TheaterList()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Signed in failed")));
      }
    } catch (e) {
      if (e is AuthException) {
        print("Sign Up/In failed: ${e.message}, statusCode: ${e.statusCode}");
        if (e.statusCode == 429) {
          // Handle rate limit exceeded error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Too many sign-up attempts. Try again later.")),
          );
        } else if (e.statusCode == 400) {
          // Handle invalid credentials error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Invalid credentials. Please check your email and password.")),
          );
        } else {
          // Handle other errors if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Sign Up/In failed. Please try again later.")),
          );
        }
      } else {
        // Handle other types of exceptions if needed
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An error occurred. Please try again later.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Ekranı")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => signIn(context), child: const Text('Login')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: signUp, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
