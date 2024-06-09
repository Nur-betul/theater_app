import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theater/home/app_color.dart' as AppColors;
import 'package:theater/home/ticket_style.dart';

class MyApp extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String saloon;

  final List<String> selectedSeats;
  const MyApp(
      {Key? key,
      required this.eventData,
      required this.saloon,
      required this.selectedSeats})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: AppColors.background, // This uses your custom color from AppColors
      title: 'Tiyatro Koltuk Seçimi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TheaterScreen(
        eventData: eventData,
        saloon: saloon,
        selectedSeats: selectedSeats,
      ),
    );
  }
}

class TheaterScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String saloon;
  final List<String> selectedSeats;
  const TheaterScreen(
      {Key? key,
      required this.eventData,
      required this.saloon,
      required this.selectedSeats})
      : super(key: key);

  @override
  _TheaterScreenState createState() => _TheaterScreenState();
}

class _TheaterScreenState extends State<TheaterScreen> {
  late List<List<SeatStatus>> theaterLayout;
  List<String> selectedSeats = [];

  String get salon_no => widget.saloon;

  @override
  void initState() {
    super.initState();
    // Initialize the theater layout

    theaterLayout = List.generate(
      10,
      (_) => List.generate(22, (_) => SeatStatus.available),
    );
    _loadOccupiedSeats();
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width / 2;
    final windowHeight = MediaQuery.of(context).size.height / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saloon + ' Koltuk Seçimii'),
        backgroundColor: AppColors.bluntOrange,
        titleTextStyle: const TextStyle(color: AppColors.cream, fontSize: 20),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Koltuk Seçiniz',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                _addSeatToDatabase();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketStyle(
                      eventData: widget.eventData,
                      saloon: widget.saloon,
                      selectedSeats: selectedSeats,
                    ),
                  ),
                );
                for (var element in selectedSeats) {
                  print(element);
                  print(' ');
                }
              },
              child: const Text('YER AYIRT'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: InteractiveViewer(
                panEnabled: true, // Enable panning
                boundaryMargin: const EdgeInsets.all(80),
                minScale: 0.5,
                maxScale: 4,
                child: TheaterLayout(
                  layout: theaterLayout,
                  onSeatTap: (row, col) {
                    // final seatNo = (row * theaterLayout[0].length) + col + 1;
                    // final eventDate = widget.eventData['event_date'];
                    setState(() {
                      if (theaterLayout[row][col] == SeatStatus.available) {
                        theaterLayout[row][col] = SeatStatus.selected;
                        selectedSeats.add('$row-$col');
                      } else if (theaterLayout[row][col] ==
                          SeatStatus.selected) {
                        theaterLayout[row][col] = SeatStatus.available;
                        selectedSeats.remove('$row-$col');
                      }
                    });
                  },
                ),
              ),
            ),
            Text(
              'Seçilen Koltuklar: ${selectedSeats.join(', ')}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.menuColor,
    );
  }

  void _addSeatToDatabase() async {
    String eventDateString = widget.eventData['event_date'];
    DateTime event_date = DateTime.parse(eventDateString);

    try {
      for (var seat in selectedSeats) {
        List<String> parts = seat.split('-');
        int seatNo = (int.parse(parts[0]) * theaterLayout[0].length) +
            int.parse(parts[1]) +
            1;
        String sln =
            (salon_no == 'SALON 2') ? 'saloontwo_duplicate' : 'saloonone';

        final rsp = await Supabase.instance.client.from(salon_no).insert({
          'event_name': widget.eventData['event_name'],
          'seat_no': seatNo,
          //'${String.fromCharCode(int.parse(parts[0]) + 65)}${int.parse(parts[1]) + 1}',
          'event_date': eventDateString,
          'seat_state': true,
        }).execute();
        print('Event added to database: $rsp');
      }
    } catch (e) {
      if (e is PostgrestException &&
          e.message
              .contains('duplicate key value violates unique constraint')) {
        print('Bu koltuk zaten seçilmiş.');
        // Burada kullanıcıya uygun bir mesaj gösterebilirsiniz.
      } else {
        print('Eklemede hata var $e');
      }
    }
  }

  Future<void> _loadOccupiedSeats() async {
    List<String> occupiedSeats = await getOccupiedSeats(
      widget.eventData['event_name'],
      widget.eventData['event_date'],
      widget.saloon == 'SALON 2' ? 'salontwo_duplicate' : 'saloonone',
    );
    setState(() {
      for (String seat in occupiedSeats) {
        int seatNo = int.parse(seat);
        int row = (seatNo - 1) ~/ theaterLayout[0].length;
        int col = (seatNo - 1) % theaterLayout[0].length;
        theaterLayout[row][col] = SeatStatus.occupied;
      }
    });
  }

  Future<List<String>> getOccupiedSeats(
      String eventName, String eventDate, String tableName) async {
    final response = await Supabase.instance.client
        .from(tableName)
        .select('seat_no')
        .eq('event_name', eventName)
        .eq('event_date', eventDate)
        .execute();

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => e['seat_no'].toString()).toList();
  }
}

enum SeatStatus {
  available,
  selected,
  occupied,
}

class TheaterLayout extends StatelessWidget {
  final List<List<SeatStatus>> layout;
  final Function(int, int) onSeatTap;

  const TheaterLayout({
    Key? key,
    required this.layout,
    required this.onSeatTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 16,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: layout.length * layout[0].length,
      itemBuilder: (context, index) {
        int rowIndex = index ~/ layout[0].length;
        int colIndex = index % layout[0].length;
        int seatNumber =
            rowIndex * layout[0].length + colIndex + 1; // Calculate seat number

        return GestureDetector(
          onTap: () => onSeatTap(rowIndex, colIndex),
          child: Seat(
            status: layout[rowIndex][colIndex],
            seatNumber: seatNumber,
          ),
        );
      },
    );
  }
}

class Seat extends StatelessWidget {
  final SeatStatus status;
  final int seatNumber;

  const Seat({Key? key, required this.status, required this.seatNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case SeatStatus.available:
        color = const Color.fromARGB(255, 27, 66, 28);
        break;
      case SeatStatus.selected:
        color = Colors.red;

        break;
      case SeatStatus.occupied:
        color = Colors.red;
    }
    final seatNumberText = seatNumber.toString();
    final fontSize = seatNumberText.length > 2
        ? 10.0
        : 14.0; // Adjust font size based on number of digits

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color, // Apply the seat's color to the Container's background
        borderRadius: BorderRadius.circular(4), // Optional: Add rounded corners
      ),
      child: Center(
        child: Text(
          seatNumberText, // You can place seat labels or other identifiers here
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ), // Adjust text style as needed
        ),
      ),
    );
  }
}
