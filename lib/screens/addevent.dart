import 'package:flutter/material.dart';
import 'package:ticket_app/main.dart';
import 'package:ticket_app/screens/login.dart';
import 'package:ticket_app/screens/theaters.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  bool _hasPermissionToCreateEvent = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionToCreateEvent();
  }

  Future<void> _checkPermissionToCreateEvent() async {
    final hasPermission = await hasPermissionToCreateEvent();
    setState(() {
      _hasPermissionToCreateEvent = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: const Center(
        child: Text('Add Event Page Content'),
      ),
    );
  }
}

Future<bool> hasPermissionToCreateEvent() async {
  final user = globaluser?.email;

  if (user != null) {
    final response = await supabase
        .from('admins')
        .select('email')
        .eq('email', user)
        .execute();

    for (var mail in response.data) {
      if (mail['email'] == globaluser?.email) {
        return true;
      } else {
        return false;
      }
    }
  }
  return false;
}
