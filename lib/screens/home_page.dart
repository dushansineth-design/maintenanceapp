import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/citizen.dart';
import 'login_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomePage extends StatefulWidget {
  final Citizen currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  final _locationController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedCategory;

  // Colors
  final Color bgBlack = const Color(0xFF121212);
  final Color bgSurface = const Color(0xFF1E1E2C);
  final Color accentPurple = const Color(0xFF6C63FF);

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Road', 'icon': Icons.add_road},
    {'name': 'Garbage', 'icon': Icons.delete_outline},
    {'name': 'Water', 'icon': Icons.water_drop},
    {'name': 'Electricity', 'icon': Icons.flash_on},
    {'name': 'Street Light', 'icon': Icons.lightbulb_outline},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];

  //  SUBMIT REPORT (Firestore)
  Future<void> _submitReport() async {
    String finalCategory = _selectedCategory == 'Others'
        ? _otherCategoryController.text.trim()
        : _selectedCategory ?? '';

    if (_locationController.text.isEmpty || finalCategory.isEmpty) {
      _showMessage("Please fill all fields", isError: true);
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;

      await _firestore.collection('reports').add({
        'userId': uid,
        'userName': widget.currentUser.name,
        'email': widget.currentUser.email,
        'location': _locationController.text.trim(),
        'category': finalCategory,
        'description': _descController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      _locationController.clear();
      _otherCategoryController.clear();
      _descController.clear();
      setState(() => _selectedCategory = null);

      _showMessage("Report submitted successfully");
    } catch (e) {
      _showMessage("Failed to submit report", isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : accentPurple,
      ),
    );
  }

  Future<void> _deleteReport(String docId) async {
    await _firestore.collection('reports').doc(docId).delete();
    _showMessage("Report deleted");
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Report Issue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildForm(),
              const SizedBox(height: 30),
              _buildRecentReports(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTextField(_locationController, "Location"),
          const SizedBox(height: 15),
          _buildDropdown(),
          if (_selectedCategory == 'Others') ...[
            const SizedBox(height: 15),
            _buildTextField(_otherCategoryController, "Specify category"),
          ],
          const SizedBox(height: 15),
          _buildTextField(_descController, "Description"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Submit Report",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
  final user = _auth.currentUser;

  if (user == null) {
    return const Text(
      "User not logged in",
      style: TextStyle(color: Colors.red),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('reports')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots(),

    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text(
          "Error loading reports",
          style: TextStyle(color: Colors.red),
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data?.docs ?? [];

      if (docs.isEmpty) {
        return const Text(
          "No reports yet",
          style: TextStyle(color: Colors.white54),
        );
      }

      return Column(
        children: docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};

          final category = data['category'] ?? 'Unknown';
          final location = data['location'] ?? 'No location';
          final status = data['status'] ?? 'pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: bgSurface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(category,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                "$location - $status",
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReport(doc.id),
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}


  Widget _buildReportTile(String docId, Map<String, dynamic> data) {
    final category = data['category'] ?? 'Unknown';
    final location = data['location'] ?? 'No location';
    final status = data['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(category, style: const TextStyle(color: Colors.white)),
        subtitle: Text(location, style: const TextStyle(color: Colors.white54)),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteReport(docId);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'delete',
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: bgBlack,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            widget.currentUser.name,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          Text(
            widget.currentUser.email,
            style: const TextStyle(color: Colors.white54),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(backgroundColor: accentPurple),
              child: const Text("Logout", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgBlack,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCategory,
        hint: const Text(
          "Select Category",
          style: TextStyle(color: Colors.white38),
        ),
        dropdownColor: bgSurface,
        isExpanded: true,
        items: _categories.map<DropdownMenuItem<String>>((cat) {
          return DropdownMenuItem(
            value: cat['name'],
            child: Text(
              cat['name'],
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
      ),
    );
  }
}
