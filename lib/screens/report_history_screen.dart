import 'package:flutter/material.dart';
import 'edit_report_screen.dart';

class ReportHistoryScreen extends StatefulWidget {
  @override
  _ReportHistoryScreenState createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {


  // --- DUMMY DATA ---
  List<Map<String, String>> myReports = [
    {
      'id': '1',
      'title': 'Broken Streetlight',
      'description': 'Light flickering on 5th Avenue.',
      'status': 'Pending',
    },
    {
      'id': '2',
      'title': 'Pothole on Main St',
      'description': 'Huge pothole damaging cars.',
      'status': 'In Progress',
    },
    {
      'id': '3',
      'title': 'Water Leak',
      'description': 'Pipe burst near the park entrance.',
      'status': 'Fixed',
    },
  ];

  void _deleteReport(int index) {
    setState(() {
      myReports.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Report deleted successfully!"),
        backgroundColor: Theme.of(context).primaryColor,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report History"),
      ),
      body: myReports.isEmpty
          ? const Center(child: Text("No reports found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myReports.length,
              itemBuilder: (context, index) {
                final report = myReports[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ROW 1: Title & Menu ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              report['title']!,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => EditReportScreen(
                                      title: report['title']!,
                                      description: report['description']!,
                                    ),
                                  ));
                                } else if (value == 'delete') {
                                  _deleteReport(index);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit', 
                                  child: Text("Edit")
                                ),
                                const PopupMenuItem(
                                  value: 'delete', 
                                  child: Text("Delete", style: TextStyle(color: Colors.redAccent))
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // --- DESCRIPTION ---
                        Text(
                          report['description']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 16),

                        // --- STATUS BADGE ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildStatusBadge(report['status']!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    if (status == 'Fixed') {
      color = const Color(0xFF00E676); // Bright Green
      bgColor = const Color(0xFF00E676).withOpacity(0.1);
    } else if (status == 'In Progress') {
      color = const Color(0xFFFFAB40); // Bright Orange
      bgColor = const Color(0xFFFFAB40).withOpacity(0.1);
    } else {
      color = const Color(0xFFFF5252); // Bright Red
      bgColor = const Color(0xFFFF5252).withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}