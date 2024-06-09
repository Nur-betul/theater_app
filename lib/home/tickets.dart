import 'package:flutter/material.dart';
import 'package:theater/main.dart';
import 'package:theater/screens/login.dart';
import 'package:uuid/uuid.dart';
import 'package:theater/home/app_color.dart' as AppColors;

class Ticket extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const Ticket({Key? key, required this.eventData}) : super(key: key);

  @override
  _TicketState createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  final _formKey = GlobalKey<FormState>();
  String ticket_id = Uuid().v4();
  String ticket_type = '';
  String price = '700';
  String event_id = Uuid().v4();
  String user_id = const Uuid().v4();
  DateTime ticket_date = DateTime.now();
  late String tevent_name;
  String tvenue = '';
  String tevent_image = '';

  bool _hasPermissionToCreateTicket = true;

  @override
  void initState() {
    super.initState();
    _checkPermissinToCreateTicket();
  }

  Future<void> _checkPermissinToCreateTicket() async {
    final hasPermission = await hasPermissionToCreateTicket();
    setState(() {
      //_hasPermissionToCreateTicket = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuColor,
      appBar: AppBar(
        title: const Text('Bilet Oluşturr'),
        backgroundColor: AppColors.menuColor,
      ),
      body: _hasPermissionToCreateTicket
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(
                            10), // İçerik ve çerçeve arasında boşluk bırakır
                        margin: const EdgeInsets.all(
                            10), // Widget çevresinde boşluk bırakır
                        decoration: BoxDecoration(
                          color: Colors.white, // Kutunun arka plan rengi
                          border: Border.all(
                              color: Colors
                                  .blueAccent), // Kutunun çevresinde mavi bir çerçeve oluşturur
                          borderRadius: BorderRadius.circular(
                              5), // Köşeleri yuvarlaklaştırır
                        ),
                        child: const Text(
                          '?????', // Görüntülemek istediğiniz metin
                          style:
                              TextStyle(fontSize: 16), // Metin stilini ayarlar
                        ),
                      )
                    ],
                  )),
            )
          : const Center(
              child: Text('You do not have permission to buy a ticket.'),
            ),
    );
  }
}

Future<bool> hasPermissionToCreateTicket() async {
  final user = globaluser?.email;
  bool isAdmin = true;
  if (user != null) {
    final response = await supabase
        .from('admins')
        .select('email')
        .eq('email', user)
        .execute();

    for (var mail in response.data) {
      if (mail['email'] == globaluser?.email) {
        isAdmin = true;
      } else {
        isAdmin = false;
      }
    }
  }
  return isAdmin;
}
