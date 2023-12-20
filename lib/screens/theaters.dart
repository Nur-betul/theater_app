import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticket_app/main.dart';
import 'package:ticket_app/screens/addevent.dart';

class EventWidget extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventWidget({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Name: ${eventData['event_name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Event Data: ${eventData['event_data']}'),
            Text('Event Type: ${eventData['event_type']}'),
            Text('Producer: ${eventData['producer']}'),
          ],
        ),
      ),
    );
  }
}

class TheaterList extends StatefulWidget {
  const TheaterList({Key? key}) : super(key: key);

  @override
  _TheaterListState createState() => _TheaterListState();
}

class _TheaterListState extends State<TheaterList> {
  final Future<List<Map<String, dynamic>>> _future = Supabase.instance.client
      .from('events')
      .select<List<Map<String, dynamic>>>();

  bool _hasPermissionToCreateEvent = false;

  @override
  void initState() {
    super.initState();
    //_redirect();
    _checkPermissionToCreateEvent();
  }

  Future<void> _checkPermissionToCreateEvent() async {
    final hasPermission = await hasPermissionToCreateEvent();
    setState(() {
      _hasPermissionToCreateEvent = hasPermission;
    });
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/account');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THEATERS'),
        actions: _hasPermissionToCreateEvent
            ? [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEvent(),
                      ),
                    );
                  },
                ),
              ]
            : null, // Title displayed in the AppBar
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final eventData = events[index];
              return EventWidget(eventData: eventData);
            },
          );
        },
      ),
    );
  }
}
