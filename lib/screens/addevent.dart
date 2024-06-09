import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theater/home/app_color.dart' as AppColors;
import 'package:theater/main.dart';
import 'package:theater/screens/login.dart';
import 'package:uuid/uuid.dart';
import 'package:date_format_field/date_format_field.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  String event_name = '';
  String event_id = Uuid().v4();
  DateTime event_date = DateTime.now();
  String event_type = '';
  String producer = '';
  String venue = '';
  String event_image = '';
  String event_bio = '';

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
      backgroundColor: AppColors.menuColor,
      appBar: AppBar(
        title: const Text(
          'ETKİNLİK EKLE',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.bluntOrange,
      ),
      body: _hasPermissionToCreateEvent
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    DateFormatField(
                      type: DateFormatType.type4,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                        label: Text(
                          "Etkinlik Tarihi",
                          style: TextStyle(color: Color(0xFF0A0A00)),
                        ),
                      ),
                      onComplete: (date) {
                        setState(() {
                          event_date = date!;
                        });
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Etkinlik İsmi',
                        labelStyle: TextStyle(
                          color: Color(0xFF0A0A00),
                          fontSize: 18,
                        ),
                      ),
                      onSaved: (value) => event_name = value ?? '',
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Etkinlik Tipi',
                        labelStyle: TextStyle(
                          color: Color(0xFF0A0A00),
                          fontSize: 18,
                        ),
                      ),
                      onSaved: (value) => event_type = value ?? '',
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Yapımcı',
                        labelStyle: TextStyle(
                          color: Color(0xFF0A0A00),
                          fontSize: 18,
                        ),
                      ),
                      onSaved: (value) => producer = value ?? '',
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Etkinlik Tanımı',
                        labelStyle: TextStyle(
                          color: Color(0xFF0A0A00),
                          fontSize: 18,
                        ),
                      ),
                      onSaved: (value) => event_bio = value ?? '',
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Yer',
                        labelStyle: TextStyle(
                          color: Color(0xFF0A0A00),
                          fontSize: 18,
                        ),
                      ),
                      onSaved: (value) => venue = value ?? '',
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bluntOrange),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          _formKey.currentState!.save();
                          _addEventToDatabase();
                        }
                      },
                      child: const Text(
                        'Etkinliği Kaydet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text('Etkinlik eklemeye yetkiniz bulunmamaktadır.'),
            ),
    );
  }

  void _addEventToDatabase() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(event_date);
    try {
      final rsp = await Supabase.instance.client.from('events').insert({
        'event_id': event_id,
        'event_name': event_name,
        'event_date': formattedDate,
        'event_type': event_type,
        'producer': producer,
        'venue': venue,
        'event_bio': event_bio,
        'event_image': event_image,
      }).execute();
    } catch (e) {
      print('Eklemede hata var $e');
    }
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
