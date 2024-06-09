import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theater/screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://ltuangxwymejnflvtrws.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0dWFuZ3h3eW1lam5mbHZ0cndzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE1OTk5NjEsImV4cCI6MjAxNzE3NTk2MX0.rrXCL3xldFvbEuOXhbu_icQrxncrkY9Wv4ZccpB2_GY');
  final client = SupabaseClient('https://ltuangxwymejnflvtrws.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0dWFuZ3h3eW1lam5mbHZ0cndzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE1OTk5NjEsImV4cCI6MjAxNzE3NTk2MX0.rrXCL3xldFvbEuOXhbu_icQrxncrkY9Wv4ZccpB2_GY');
  runApp(MyApp(client: client));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final SupabaseClient client;

  const MyApp({super.key, required this.client});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Supabase Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: LoginPage(client: client),
    );
  }
}
