import 'package:flutter/material.dart';

class EditReportScreen extends StatefulWidget {
  final String title;
  final String description;

  const EditReportScreen({super.key, required this.title, required this.description});

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  // --- COLOR PALETTE ---
  final Color bgBlack = const Color(0xFF121212);
  final Color bgSurface = const Color(0xFF1E1E2C);
  final Color accentPurple = const Color(0xFF6C63FF);

  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descController = TextEditingController(text: widget.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack, // Dark Background
      appBar: AppBar(
        title: const Text("Edit Report", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Container to mimic the Card look from Dashboard
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgSurface, // Dark Card
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildDarkTextField(_titleController, "Report Title"),
                  const SizedBox(height: 20),
                  _buildDarkTextField(_descController, "Description", maxLines: 5),
                  
                  const SizedBox(height: 30),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple, // Your Theme Purple
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Update Successful!"),
                            backgroundColor: accentPurple,
                          )
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Dark Input Fields
  Widget _buildDarkTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: bgBlack, // Inner input is darker (0xFF121212)
            hintText: "Enter $label",
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}