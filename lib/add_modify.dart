import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:ui';
import 'dashboard.dart'; // Import the file where `existingAsgn` is defined.

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

  // Populate registered assignments from `existingAsgn`
  List<Map<String, String>> get registeredAssignments {
    return existingAsgn.map((assignment) {
      return {
        'id': assignment['id'].toString(),
        'title': assignment['title'].toString(),
        'course': assignment['course'].toString(),
        'description': assignment['description'].toString(),
      };
    }).toList();
  }

  // Fill form fields when an assignment is selected
  void fillAssignmentDetails(Map<String, String> assignment) {
    setState(() {
      titleController.text = assignment['title']!;
      descriptionController.text = assignment['description']!;
      selectedCourse = assignment['course']!;
      selectedAssignment = assignment['id']!;
    });
  }

  // Save assignment to `existingAsgn`
  void saveAssignment() {
    setState(() {
      isLoading = true;
    });

    try {
      logger.d('Saving assignment to in-memory storage...');

      if (selectedAssignment.isEmpty) {
        // Adding a new assignment
        existingAsgn.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': titleController.text,
          'description': descriptionController.text,
          'course': selectedCourse,
          'deadline': deadline.toLocal().toString().split(' ')[0],
        });
      } else {
        // Modifying an existing assignment
        var index =
            existingAsgn.indexWhere((a) => a['id'] == selectedAssignment);
        if (index != -1) {
          existingAsgn[index] = {
            'id': selectedAssignment,
            'title': titleController.text,
            'description': descriptionController.text,
            'course': selectedCourse,
            'deadline': deadline.toLocal().toString().split(' ')[0],
          };
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      logger.d('Assignment saved successfully');
      Navigator.pop(context); // Navigate back to dashboard
      clearForm();
    } catch (e) {
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
      appBar: AppBar(title: const Text('Add/Modify Assignment')),
      body: Container(
        decoration: const BoxDecoration(
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
                  color: Colors.black.withOpacity(0.3),
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
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Dropdown for registered assignments
                            Row(
                              children: [
                                const Text('Assignment: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8.0),
                                SizedBox(
                                  width: 400,
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
                                    hint: const Text('Select Assignment'),
                                    items: [
                                      ...registeredAssignments
                                          .map((assignment) {
                                        return DropdownMenuItem<String>(
                                          value: assignment['id'],
                                          child: Text(assignment['title']!),
                                        );
                                      }).toList(),
                                      const DropdownMenuItem<String>(
                                        value: 'Add New Assignment',
                                        child: Text('Add New Assignment'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),

                            // Course Dropdown
                            Row(
                              children: [
                                const Text('Course: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8.0),
                                SizedBox(
                                  width: 400,
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
                            const SizedBox(height: 16.0),

                            // Title TextField
                            TextField(
                              controller: titleController,
                              decoration:
                                  const InputDecoration(labelText: 'Title'),
                            ),
                            const SizedBox(height: 16.0),

                            // Description TextField
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16.0),

                            // Deadline Picker
                            Row(
                              children: [
                                const Text('Deadline:'),
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
                            const SizedBox(height: 16.0),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: cancel,
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: clearForm,
                                  child: const Text('Clear'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: isLoading ? null : saveAssignment,
                                  child: isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Save'),
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
