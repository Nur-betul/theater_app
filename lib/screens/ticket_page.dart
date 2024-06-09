import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theater/home/tickets.dart';
import 'package:theater/home/app_color.dart' as AppColors;
import 'package:theater/screens/login.dart';
import 'package:uuid/uuid.dart';

class TicketWidget extends StatelessWidget {
  final TicketData ticketData;
  final String saloon;
  final List<String> selectedSeats;
  final Map<String, dynamic> eventData;

  const TicketWidget({
    super.key,
    required this.eventData,
    required this.ticketData,
    required this.saloon,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    addTicketToDatabase();
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Information'),
        backgroundColor: AppColors.bluntOrange,
      ),
      backgroundColor: AppColors.menuColor,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: AppColors.subtitleText, width: 2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildTicketDetails(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTicketDetails() {
    return [
      const SizedBox(height: 16.0),
      Center(
        child: Transform.rotate(
          angle: -0.1,
          child: const Icon(
            Icons.theater_comedy,
            size: 45,
            color: Color(0xff0077b6),
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      Text(
        'Etkinlik Adı: ${ticketData.eventData['event_name']}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.bluntOrange,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'Etkinlik Tarihi: ${ticketData.eventData['event_date']}',
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
      const SizedBox(height: 8.0),
      Text(
        'Salon: ${ticketData.selectedSalon}',
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
      const SizedBox(height: 8.0),
      Text(
        'Rezerve Edilen Koltuklar: ${ticketData.reservedSeats.join(", ")}',
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
      const SizedBox(height: 8.0),
      Text(
        'Bilet Kodu: ${ticketData.ticketCode}',
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
      const SizedBox(height: 16.0),
      Center(
        child: Container(
          width: 150,
          height: 100,
          child: Image.network(
            ticketData.eventData['event_image'] ??
                'https://ltuangxwymejnflvtrws.supabase.co/storage/v1/object/public/profiller/robot.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          _sendEmail();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.subtitleText, // Button background color
          foregroundColor: AppColors.cream, // Text color
        ),
        child: const Text('E-posta Gönder'),
      ),
    ];
  }

  void addTicketToDatabase() async {
    String event_id = eventData['event_id'].toString();
    String eventDateString =
        eventData['event_date']; // Veritabanından gelen tarih string'i
    DateTime event_date =
        DateTime.parse(eventDateString); // String'i DateTime'a dönüştürme

    if (event_id == null || event_date == null) {
      print('Error: event_id or event_date is null');
      return;
    }
    if (globaluser?.email == null) {
      print('Error: email is null');
      return;
    }
    try {
      String ticket_id = Uuid().v4();
      String formattedDate = DateFormat('yyyy-MM-dd').format(event_date);
      final rsp = await Supabase.instance.client.from('tickets').insert({
        'ticket_id': ticket_id,
        'ticket_type': 2,
        'event_id': event_id,
        'price': '700',
        'ticket_date': formattedDate,
        'tevent_name': ticketData.eventData['event_name'] ?? '...',
        'tvenue': ticketData.eventData['venue'] ?? '...',
        'tevent_image': ticketData.eventData['event_image'] ?? '...',
        'user_mail': globaluser?.email ?? '...',
        'ticket_no': ticketData.ticketCode,
        'salon': ticketData.selectedSalon,
        'reserved_seats': ticketData.reservedSeats.join(", "),
      }).execute();
      print(' mesaj 1: $ticket_id');
      print(ticketData.eventData['event_name']);
    } catch (e) {
      print('Eklemede hata var $e');
    }
  }

  Future<void> _sendEmail() async {
    final String apiKey = 're_HcAyr7AU_pV1c3X4QUWMqfViToHA6eLzD';
    final Uri url = Uri.parse('https://api.resend.com/emails');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final String emailAddress = globaluser?.email ?? 'default@example.com';

    final Map<String, dynamic> body = {
      'from': 'onboarding@resend.dev',
      'to': 'ogmenbetul@gmail.com',
      'subject': 'Tiyatro Koltuk Seçimi Bilgileri',
      'html': '''
<p>Etkinlik Adı: ${ticketData.eventData['event_name']}</p>
<p>Salon: ${ticketData.selectedSalon}</p>
<p>Seçilen Koltuklar: ${ticketData.reservedSeats.join(', ')}</p>
''',
    };

    final http.Response response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully!');
    } else {
      print('Failed to send email: ${response.body}');
    }
  }
}

class TicketData {
  final String ticketCode;
  final Map<String, dynamic> eventData;
  final String selectedSalon;
  final List<String> reservedSeats;

  TicketData({
    required this.ticketCode,
    required this.eventData,
    required this.selectedSalon,
    required this.reservedSeats,
  });
}

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  _TicketListState createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  final Future<List<Map<String, dynamic>>> _future = Supabase.instance.client
      .from('tickets')
      .select<List<Map<String, dynamic>>>();
  String? _imageUrl;
  bool _hasPermissionToCreateTicket = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionToCreateTicket();
  }

  Future<void> _checkPermissionToCreateTicket() async {
    final hasPermission = await hasPermissionToCreateTicket();
    setState(() {
      _hasPermissionToCreateTicket = hasPermission;
    });
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
            'BİLET',
            style: TextStyle(color: Color(0xFFFFF3D9)),
          ),
          backgroundColor: AppColors.bluntOrange,
        ),
      )),
    );
  }
}
