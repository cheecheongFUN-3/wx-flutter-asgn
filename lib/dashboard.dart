import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:line_icons/line_icons.dart';
import 'homepage.dart';
import 'package:logger/logger.dart';
import 'package:flutter/animation.dart';

List<Map<String, dynamic>> existingAsgn = [
  {
    'id': '1',
    'title': 'User Interface Presentation',
    'course': 'KQC7015 MACHINE LEARNING',
    'description': 'This is a dummy assignment for System Analysis and Design.',
    'deadline': DateTime.utc(2025, 1, 19).toLocal().toString().split(' ')[0],
  },
  {
    'id': '2',
    'title': 'MEMS Prototyping',
    'course': 'KQC7028 MEMS DESIGN',
    'description': 'This is a dummy assignment for MEMS Design.',
    'deadline': DateTime.utc(2025, 1, 31).toLocal().toString().split(' ')[0],
  },
];

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
  bool _showAddModifyPopup = false;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  void _loadAssignments() {
    setState(() {
      _events.clear();

      for (var assignment in existingAsgn) {
        DateTime deadline = DateTime.parse(assignment['deadline']).toLocal();
        DateTime normalizedDeadline =
            DateTime.utc(deadline.year, deadline.month, deadline.day);
        String assignmentTitle = assignment['title'];

        if (_events[normalizedDeadline] == null) {
          _events[normalizedDeadline] = [];
        }
        _events[normalizedDeadline]!.add(assignmentTitle);
      }
    });
  }

  void _toggleAddModifyPopup([bool show = false]) {
    setState(() {
      _showAddModifyPopup = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Homepage().buildAppBar(context),
      body: Stack(
        children: [
          Column(
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
          if (_showAddModifyPopup)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _toggleAddModifyPopup(false),
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap:
                          () {}, // Prevents closing when interacting with the form
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AddModifyAssignmentForm(
                          onSave: () {
                            _loadAssignments();
                            _toggleAddModifyPopup(false);
                          },
                          onCancel: () => _toggleAddModifyPopup(false),
                        ),
                      ),
                    ),
                  ),
                ),
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
                  _toggleAddModifyPopup(true);
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
          ...dayEvents.map((event) {
            // Get the corresponding assignment data for the event
            final assignment = existingAsgn.firstWhere((asgn) => asgn['title'] == event);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ExpansionTile(
                title: Text(
                  "• $event",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description: ${assignment['description']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Course: ${assignment['course']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deadline: ${assignment['deadline']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                expandedAlignment: Alignment.topLeft,
                backgroundColor: Colors.transparent,
                iconColor: Colors.blue,
              ),
            );
          })
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
    final today = DateTime.now();

    // Filter out events with a date that is today or in the future (upcoming events)
    final upcomingEvents = _events.entries.where((entry) {
      final eventDate = entry.key;
      // Include only events in the future
      return eventDate.isAfter(today);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Check if there are any upcoming events, then display them
          if (upcomingEvents.isNotEmpty)
            ...upcomingEvents.map((entry) {
              final eventDate = entry.key;
              final eventsOnDate = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${eventDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Display the events for that date
                  ...eventsOnDate.map((event) => Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text(
                          "  - $event",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      )),
                ],
              );
            })
          else
            const Text(
              'No upcoming events yet.',
              style: TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}

class AddModifyAssignmentForm extends StatefulWidget {
  final Map<String, dynamic>? existingAssignment;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const AddModifyAssignmentForm({
    super.key,
    this.existingAssignment,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _AddModifyAssignmentFormState createState() =>
      _AddModifyAssignmentFormState();
}

class _AddModifyAssignmentFormState extends State<AddModifyAssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCourse;
  DateTime? _selectedDeadline;
  String? _selectedAssignment;

  @override
  void initState() {
    super.initState();
    if (widget.existingAssignment != null) {
      _titleController.text = widget.existingAssignment!['title'] ?? '';
      _descriptionController.text =
          widget.existingAssignment!['description'] ?? '';
      _selectedCourse = widget.existingAssignment!['course'];
      _selectedDeadline =
          DateTime.parse(widget.existingAssignment!['deadline']);
    }
  }

  void _pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  void _saveAssignment() {
    if (_formKey.currentState!.validate()) {
      final updatedAssignment = {
        'id': widget.existingAssignment?['id'] ?? DateTime.now().toString(),
        'title': _titleController.text,
        'course': _selectedCourse,
        'description': _descriptionController.text,
        'deadline': _selectedDeadline!.toIso8601String(),
      };

      if (widget.existingAssignment != null) {
        final index = existingAsgn.indexWhere((assignment) =>
            assignment['id'] == widget.existingAssignment!['id']);
        if (index != -1) {
          existingAsgn[index] = updatedAssignment;
        }
      } else {
        existingAsgn.add(updatedAssignment);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Assignment saved successfully!',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(1400, 0, 20, 20),
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          // Animation configuration
          animation: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeIn,
          ),
          dismissDirection: DismissDirection.vertical,
        ),
      );

      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit or Add New Assignment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedAssignment,
            decoration: const InputDecoration(
              labelText: 'Select Assignment',
              border: OutlineInputBorder(),
            ),
            items: [
              ...existingAsgn.map((asgn) => DropdownMenuItem(
                    value: asgn['id'],
                    child: Text(asgn['title']),
                  )),
              const DropdownMenuItem(
                value: 'new',
                child: Text('Add New Assignment'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                if (value == 'new') {
                  _selectedAssignment = value;
                  _titleController.clear();
                  _descriptionController.clear();
                  _selectedCourse = null;
                  _selectedDeadline = null;
                } else {
                  _selectedAssignment = value;
                  final selectedAssignment =
                      existingAsgn.firstWhere((asgn) => asgn['id'] == value);
                  _titleController.text = selectedAssignment['title'];
                  _descriptionController.text =
                      selectedAssignment['description'];
                  _selectedCourse = selectedAssignment['course'];
                  _selectedDeadline =
                      DateTime.parse(selectedAssignment['deadline']);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCourse,
            decoration: const InputDecoration(
              labelText: 'Course',
              border: OutlineInputBorder(),
            ),
            items: [
              'KQC7015 MACHINE LEARNING',
              'KQC7028 MEMS DESIGN',
              'KQC7017 SYSTEM ANALYSIS AND DESIGN',
            ].map((course) {
              return DropdownMenuItem(
                value: course,
                child: Text(course),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCourse = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a course';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDeadline,
                  child: Text(_selectedDeadline != null
                      ? 'Deadline: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}'
                      : 'Deadline'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: _saveAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // Green save button
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
