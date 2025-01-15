import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:ui'; // For BackdropFilter

class AddModifyAssignment extends StatefulWidget {
  const AddModifyAssignment({super.key});

  @override
  AddModifyAssignmentState createState() => AddModifyAssignmentState();
}

class AddModifyAssignmentState extends State<AddModifyAssignment> {
  final Logger logger = Logger();
  bool isLoading = false;
  String selectedCourse = 'KQC 7015 MACHINE LEARNING';
  String title = '';
  String description = '';
  DateTime deadline = DateTime.now();
  String selectedAssignment = ''; // Tracks selected assignment ID
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Simulating registered assignments
  List<Map<String, String>> registeredAssignments = [
    {
      'id': '1',
      'title': 'Assignment 1',
      'course': 'KQC 7015 MACHINE LEARNING',
      'description': 'Description for assignment 1'
    },
    {
      'id': '2',
      'title': 'Assignment 2',
      'course': 'KQC 7028 MEMS DESIGN',
      'description': 'Description for assignment 2'
    },
  ];

  // Function to fill the form fields when an assignment is selected
  void fillAssignmentDetails(Map<String, String> assignment) {
    setState(() {
      titleController.text = assignment['title']!;
      descriptionController.text = assignment['description']!;
      selectedCourse = assignment['course']!;
      selectedAssignment = assignment['id']!;
    });
  }

  // Save assignment to Firebase
  Future<void> saveAssignment() async {
  setState(() {
    isLoading = true;
  });

  try {
    logger.d('Saving assignment to Firestore...');  // Log before saving
    // Save data to Firestore
    await FirebaseFirestore.instance.collection('assignments').add({
      'title': titleController.text,
      'description': descriptionController.text,
      'course': selectedCourse,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.now(),
    });

    // After saving, show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assignment saved successfully'),
          backgroundColor: Colors.green, 
        ),
      );
      logger.d('Assignment saved successfully');  // Log after saving successfully

      // Navigate back to the previous screen (i.e., the calendar)
      Navigator.pop(context);
    }
  } catch (e) {
    // Log the error
    logger.e('Error saving assignment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error saving assignment: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  // Clear form fields
  void clearForm() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      selectedCourse = 'KQC 7015 MACHINE LEARNING';
      selectedAssignment = '';
    });
  }

  // Cancel operation and navigate back
  void cancel() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add/Modify Assignment')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ambg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 500.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Dropdown for registered assignments
                            Row(
                              children: [
                                Text('Assignment: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 8.0),
                                Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedAssignment.isEmpty
                                        ? null
                                        : selectedAssignment,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedAssignment = newValue!;
                                        if (selectedAssignment !=
                                            'Add New Assignment') {
                                          var selected = registeredAssignments
                                              .firstWhere((assignment) =>
                                                  assignment['id'] ==
                                                  selectedAssignment);
                                          fillAssignmentDetails(selected);
                                        } else {
                                          clearForm();
                                        }
                                      });
                                    },
                                    hint: Text('Select Assignment'),
                                    items: [
                                      ...registeredAssignments
                                          .map((assignment) {
                                        return DropdownMenuItem<String>(
                                          value: assignment['id'],
                                          child: Text(assignment['title']!),
                                        );
                                      }).toList(),
                                      DropdownMenuItem<String>(
                                        value: 'Add New Assignment',
                                        child: Text('Add New Assignment'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),

                            // Course Dropdown
                            Row(
                              children: [
                                Text('Course: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 8.0),
                                Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedCourse,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedCourse = newValue!;
                                      });
                                    },
                                    items: [
                                      'KQC 7015 MACHINE LEARNING',
                                      'KQC 7028 MEMS DESIGN',
                                      'KQC 7017 SYSTEM ANALYSIS AND DESIGN'
                                    ]
                                        .map((course) => DropdownMenuItem(
                                            value: course, child: Text(course)))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),

                            // Title TextField with placeholder
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                hintText: 'e.g. Presentation/Report/Task Title',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  title = value;
                                });
                              },
                            ),
                            SizedBox(height: 16.0),

                            // Description TextField with placeholder
                            TextField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'e.g. Assignment description here',
                              ),
                              maxLines: 5,
                              onChanged: (value) {
                                setState(() {
                                  description = value;
                                });
                              },
                            ),
                            SizedBox(height: 16.0),

                            // Deadline Date Picker
                            Row(
                              children: [
                                Text('Deadline:'),
                                TextButton(
                                  onPressed: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: deadline,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );
                                    if (pickedDate != null && mounted) {
                                      setState(() {
                                        deadline = pickedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                      '${deadline.toLocal()}'.split(' ')[0]),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all(
                                        BorderSide(color: Colors.red)),
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.red),
                                  ),
                                  onPressed: cancel,
                                  child: Text('Cancel'),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all(
                                        BorderSide(color: Colors.grey)),
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.grey),
                                  ),
                                  onPressed: clearForm,
                                  child: Text('Clear'),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all(
                                        BorderSide(color: Colors.lightBlue)),
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    foregroundColor: WidgetStateProperty.all(
                                        Colors.lightBlue),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          saveAssignment();
                                          logger.d('Saving assignment');
                                        },
                                  child: isLoading
                                      ? CircularProgressIndicator()
                                      : Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
