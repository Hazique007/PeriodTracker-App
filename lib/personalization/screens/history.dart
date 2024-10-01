import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controllers/periodController.dart';
// Import the PeriodController

class HistoryPage extends StatelessWidget {
  final PeriodController controller = Get.find<PeriodController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildHistoryList(),
        );
      }),
    );
  }

  // Build a list of history dates grouped by month
  Widget _buildHistoryList() {
    if (controller.confirmedDates.isEmpty) {
      return Center(child: Text("No history available."));
    }

    // Create a map to group dates by month
    Map<String, List<DateTime>> groupedDates = {};

    for (var date in controller.confirmedDates) {
      String monthKey = DateFormat('MMMM yyyy').format(date); // Group by month and year
      if (!groupedDates.containsKey(monthKey)) {
        groupedDates[monthKey] = [];
      }
      groupedDates[monthKey]!.add(date);
    }

    // Generate the list of month headings and corresponding dates
    List<Widget> monthWidgets = [];
    groupedDates.forEach((month, dates) {
      monthWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            month,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
      for (var date in dates) {
        monthWidgets.add(
          Card(
            child: ListTile(
              leading: Icon(Iconsax.calendar),
              title: Text(
                "Confirmed Date: ${DateFormat('dd-MM-yyyy').format(date)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }
    });

    return ListView(children: monthWidgets);
  }

  // Show a confirmation dialog before deleting the history
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete History"),
          content: Text("Are you sure you want to delete all history?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                controller.clearHistory(); // Clear the history
                Navigator.of(context).pop(); // Close the dialog

                // Show a SnackBar confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('History deleted!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
