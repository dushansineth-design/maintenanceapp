import 'package:flutter/material.dart';

class EditReportScreen extends StatefulWidget {
  final String title;
  final String description;

  EditReportScreen({required this.title, required this.description});

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {


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
      appBar: AppBar(
        title: const Text("Edit Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Container to mimic the Card look from Dashboard
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(_titleController, "Report Title"),
                  const SizedBox(height: 20),
                  _buildTextField(_descController, "Description", maxLines: 5),
                  
                  const SizedBox(height: 30),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Update Successful!"),
                            backgroundColor: Theme.of(context).primaryColor,
                          )
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("Save Changes"),
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
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter $label",
          ),
        ),
      ],
    );
  }
}