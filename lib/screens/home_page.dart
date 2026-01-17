import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/citizen.dart';
import '../models/maintenance.dart';
import '../services/maintenance_service.dart';
import 'login_page.dart';
import 'report_history_screen.dart'; // Import History Screen
import 'edit_report_screen.dart';    // Import Edit Screen

class HomePage extends StatefulWidget {
  final Citizen currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  
  // Controllers
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();

  // --- PALETTE COLORS ---
  final Color bgBlack = const Color(0xFF121212); // Main Background
  final Color bgSurface = const Color(0xFF1E1E2C); // Card Background
  final Color accentPurple = const Color(0xFF6C63FF); // Accent

  // --- SUBMIT LOGIC ---
  void _submitReport() {
    if (_locationController.text.isNotEmpty && _categoryController.text.isNotEmpty) {
      setState(() {
        _maintenanceService.createReport(
          widget.currentUser,
          _locationController.text,
          _categoryController.text,
          _descController.text,
        );
      });
      _locationController.clear();
      _categoryController.clear();
      _descController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Report Submitted!"),
          backgroundColor: accentPurple,
        ),
      );
    }
  }

  // --- DELETE LOGIC ---
  void _deleteReport(Maintenance report) {
    setState(() {
      // NOTE: Ideally, you should add a delete method to your MaintenanceService.
      // For now, we are removing it from the UI list locally.
      _maintenanceService.getReports().remove(report); 
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report deleted successfully")),
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // --- DRAWER (Dark Theme) ---
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: bgBlack, 
      child: Column(
        children: [
          const SizedBox(height: 60),
          
          // Profile Pic
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentPurple, width: 2), 
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
          const SizedBox(height: 15),
          
          // Name
          Text(
            widget.currentUser.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.currentUser.email,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),

          const SizedBox(height: 40),
          
          // Details List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("ACCOUNT SETTINGS", style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                _buildDarkDetailTile(Icons.person, "Name", widget.currentUser.name),
                _buildDarkDetailTile(Icons.email, "Email", widget.currentUser.email),
                _buildDarkDetailTile(Icons.phone, "Contact", widget.currentUser.contact),
                _buildDarkDetailTile(Icons.badge, "Citizen ID", widget.currentUser.citizenID),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkDetailTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgSurface, 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF282836),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentPurple, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Maintenance> reports = _maintenanceService.getReports();

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM SECTION ---
              const Text("Report Issue", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgSurface, 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildDarkTextField(_locationController, "Location (e.g. Main St)"),
                    const SizedBox(height: 15),
                    _buildDarkTextField(_categoryController, "Category (e.g. Road)"),
                    const SizedBox(height: 15),
                    _buildDarkTextField(_descController, "Description"),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Submit Report", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- LIST SECTION HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Reports", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  
                  // 1. ADDED: View All History Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ReportHistoryScreen()
                      ));
                    },
                    child: Text("View All", style: TextStyle(color: accentPurple)),
                  )
                ],
              ),
              
              const SizedBox(height: 15),
              
              reports.isEmpty
                  ? const Center(child: Text("No reports yet.", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: bgSurface,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF282836),
                              child: Text(
                                report.reportID.length >= 2 ? report.reportID.substring(0, 2) : "R", 
                                style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)
                              ),
                            ),
                            title: Text(report.category, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              "${report.location} - ${report.status.name}",
                              style: const TextStyle(color: Colors.white54),
                            ),
                            
                            // 2. ADDED: Popup Menu for Edit/Delete
                            trailing: PopupMenuButton<String>(
                              color: const Color(0xFF1E1E2C),
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => EditReportScreen(
                                      // Mapping your Maintenance model to the Edit Screen inputs
                                      title: report.category, 
                                      description: report.description ?? "", // Handle if null
                                    ),
                                  ));
                                } else if (value == 'delete') {
                                  _deleteReport(report);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20), 
                                      SizedBox(width: 8), 
                                      Text("Edit", style: TextStyle(color: Colors.white))
                                    ]
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20), 
                                      SizedBox(width: 8), 
                                      Text("Delete", style: TextStyle(color: Colors.red))
                                    ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}