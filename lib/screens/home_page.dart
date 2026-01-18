import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/citizen.dart';
import '../models/maintenance.dart';
import '../services/maintenance_service.dart';
import 'login_page.dart';
import 'report_history_screen.dart'; 
import 'edit_report_screen.dart';    

class HomePage extends StatefulWidget {
  final Citizen currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  
  // --- CONTROLLERS ---
  final _locationController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final _descController = TextEditingController();

  // --- STATE VARIABLES ---
  String? _selectedCategory;
  List<Maintenance> _recentReports = []; // Store reports locally here

  // --- CATEGORY DATA ---
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Road', 'icon': Icons.add_road},
    {'name': 'Garbage', 'icon': Icons.delete_outline},
    {'name': 'Water', 'icon': Icons.water_drop},
    {'name': 'Electricity', 'icon': Icons.flash_on},
    {'name': 'Street Light', 'icon': Icons.lightbulb_outline},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];

  // --- COLORS ---
  final Color bgBlack = const Color(0xFF121212); 
  final Color bgSurface = const Color(0xFF1E1E2C); 
  final Color accentPurple = const Color(0xFF6C63FF); 

  @override
  void initState() {
    super.initState();
    // 1. Load the reports ONCE when the app starts
    _recentReports = _maintenanceService.getReports();
  }

  // --- SUBMIT LOGIC ---
  void _submitReport() {
    String finalCategory = '';
    
    if (_selectedCategory == 'Others') {
      finalCategory = _otherCategoryController.text;
    } else {
      finalCategory = _selectedCategory ?? '';
    }

    if (_locationController.text.isNotEmpty && finalCategory.isNotEmpty) {
      setState(() {
        // Create the report in the service
        _maintenanceService.createReport(
          widget.currentUser,
          _locationController.text,
          finalCategory,
          _descController.text,
        );
        
        // 2. Refresh the local list so the new item shows up
        _recentReports = _maintenanceService.getReports();
      });
      
      _locationController.clear();
      _otherCategoryController.clear(); 
      _descController.clear();
      setState(() {
        _selectedCategory = null; 
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Report Submitted!"),
          backgroundColor: accentPurple,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
    }
  }

  // --- DELETE LOGIC ---
  void _deleteReport(Maintenance report) {
    setState(() {
      // 3. Remove from the LOCAL list
      _recentReports.remove(report);
      
      // Optional: If your service has a delete method, call it here too
      // _maintenanceService.deleteReport(report.id);
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

  // --- DRAWER ---
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: bgBlack, 
      child: Column(
        children: [
          const SizedBox(height: 60),
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
          Text(
            widget.currentUser.name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.currentUser.email,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 40),
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
    // Note: We use _recentReports variable here, NOT _maintenanceService.getReports()
    
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
                    
                    // --- DROPDOWN CATEGORY ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgBlack, 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: const Text("Select Category", style: TextStyle(color: Colors.white38)),
                          dropdownColor: bgSurface, 
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['name'],
                              child: Row(
                                children: [
                                  Icon(cat['icon'], color: accentPurple, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    cat['name'], 
                                    style: const TextStyle(color: Colors.white)
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ),

                    if (_selectedCategory == 'Others') ...[
                      const SizedBox(height: 15),
                      _buildDarkTextField(_otherCategoryController, "Please specify other..."),
                    ],
                    
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
              
              // --- LIST SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Reports", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
              
              _recentReports.isEmpty
                  ? const Center(child: Text("No reports yet.", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentReports.length,
                      itemBuilder: (context, index) {
                        final report = _recentReports[index];
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
                            
                            trailing: PopupMenuButton<String>(
                              color: const Color(0xFF1E1E2C),
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => EditReportScreen(
                                      title: report.category, 
                                      description: report.description ?? "",
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
                                      Icon(Icons.edit, size: 20, color: Colors.white), 
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