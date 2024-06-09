import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theater/home/ticket_style.dart';
import 'package:theater/main.dart';
import 'package:theater/screens/addevent.dart';
import 'package:theater/home/app_color.dart' as AppColors;

class EventWidget extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventWidget({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    final imageUrl = eventData['event_image'] ??
        'https://ltuangxwymejnflvtrws.supabase.co/storage/v1/object/public/profiller/robot.png';

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resmi gösteren kısım
            Container(
              width: 150, // Resmin genişliği 400 piksel
              height: 100, // Resmin yüksekliği 300 piksel
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Resmi kutuya sığdır
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _builEventDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _builEventDetails() {
    return [
      Text(
        '${eventData['event_name']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text('${eventData['venue']}'),
      Text('${eventData['event_type']}'),
      Text('Producer: ${eventData['producer']}'),
      Text('Tarih: ${eventData['event_date']}'),
    ];
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
      .select<List<Map<String, dynamic>>>()
      .gte('event_date', DateTime.now());

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
    return Container(
        color: AppColors.background,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.menuColor,
            appBar: AppBar(
              title: const Text(
                'TİYATROLAR',
                style: TextStyle(color: Color(0xFFFFF3D9)),
              ),
              backgroundColor: AppColors.bluntOrange,
              actions: _hasPermissionToCreateEvent
                  ? [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddEvent()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cream, // Butonun rengi
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(0), // Dikdörtgen şekli
                          ),
                          // Butonun boyutunu ayarlamak için padding ekleyebilirsiniz
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'EKLE',
                          style: TextStyle(
                            color: Color(0xFF3B0918), // Metin rengi
                            fontWeight: FontWeight.bold, // Metin kalınlığı
                          ),
                        ),
                      )
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

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Adjust the number of items in each row
                    childAspectRatio: 3 / 4, // Aspect ratio of each grid item
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final eventData = events[index];

                    // Wrap each EventWidget with InkWell for click functionality
                    return InkWell(
                      onTap: () {
                        // Handle your tap action here
                        //print("Clicked on event: ${eventData['event_name']}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketStyle(
                              eventData: eventData,
                              selectedSeats: [],
                              saloon: '',
                            ),
                          ),
                        );
                      },
                      child: EventWidget(eventData: eventData),
                    );
                  },
                );
              },
            ),
          ),
        ));
  }
}
