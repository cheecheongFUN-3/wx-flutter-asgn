import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_modify.dart';
import 'homepage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SideMenuData {
  final List<MenuItem> menu = [
    MenuItem('Navigation', LineIcons.compass),
    MenuItem('Add/Modify Assignment', LineIcons.edit),
    MenuItem('To-Do List', LineIcons.list),
    MenuItem('Calendar', LineIcons.calendar),
    MenuItem('Settings', LineIcons.cog),
  ];
}

class MenuItem {
  final String title;
  final IconData icon;

  const MenuItem(this.title, this.icon);
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _events = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('assignments').get();

      setState(() {
        _events.clear();

        for (var doc in querySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          Timestamp timestamp = data['deadline'] as Timestamp;
          DateTime deadline = timestamp.toDate();
          String assignmentTitle = data['title'] as String? ?? 'Untitled Assignment';

          if (_events[deadline] == null) {
            _events[deadline] = [];
          }
          _events[deadline]!.add(assignmentTitle);
        }
      });
    } catch (e) {
      logger.e('Error loading assignments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load assignments. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Homepage().buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                const SizedBox(width: 15),
                _buildMainContent(),
                const SizedBox(width: 15),
                Expanded(
                  flex: 1,
                  child: _buildUpcomingEventsSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
        ),
        child: ListView.builder(
          itemCount: SideMenuData().menu.length,
          itemBuilder: (context, index) {
            final item = SideMenuData().menu[index];
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () {
                if (item.title == 'Add/Modify Assignment') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddModifyAssignment()),
                  ).then((_) => _loadAssignments());
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      flex: 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            _buildCalendarWidget(),
            if (_selectedDay != null) _buildEventsForSelectedDay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarWidget() {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: (day) {
        final normalizedDay = DateTime.utc(day.year, day.month, day.day);
        return _events[normalizedDay] ?? [];
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildEventsForSelectedDay() {
    final dayEvents = _events[_selectedDay];

    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              'Events of The Day:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          if (dayEvents != null && dayEvents.isNotEmpty)
            ...dayEvents.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "• $event",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ))
          else
            const Text(
              'No events for this day.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• No upcoming events yet.', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

