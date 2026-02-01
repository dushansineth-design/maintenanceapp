import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
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
          backgroundColor: Theme.of(context).colorScheme.primary, // Use Primary Blue
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
      // Background default from Theme
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor, width: 2), 
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.currentUser.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            widget.currentUser.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("ACCOUNT SETTINGS", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                _buildDetailTile(Icons.person, "Name", widget.currentUser.name),
                _buildDetailTile(Icons.email, "Email", widget.currentUser.email),
                _buildDetailTile(Icons.phone, "Contact", widget.currentUser.contact),
                _buildDetailTile(Icons.badge, "Citizen ID", widget.currentUser.citizenID),
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
                child: const Text("Logout"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
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
      drawer: _buildDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM SECTION ---
              Text("Report Issue", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Column(
                  children: [
                    _buildTextField(_locationController, "Location (e.g. Main St)"),
                    const SizedBox(height: 15),
                    
                    // --- DROPDOWN CATEGORY ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor, 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: const Text("Select Category"),
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['name'],
                              child: Row(
                                children: [
                                  Icon(cat['icon'], color: Theme.of(context).primaryColor, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    cat['name'], 
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)
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
                      _buildTextField(_otherCategoryController, "Please specify other..."),
                    ],
                    
                    const SizedBox(height: 15),
                    _buildTextField(_descController, "Description"),
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Submit Report"),
                        ),
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
                  Text("Recent Reports", style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ReportHistoryScreen()
                      ));
                    },
                    child: const Text("View All"),
                  )
                ],
              ),
              
              const SizedBox(height: 15),
              
              _recentReports.isEmpty
                  ? const Center(child: Text("No reports yet."))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentReports.length,
                      itemBuilder: (context, index) {
                        final report = _recentReports[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(
                                  report.reportID.length >= 2 ? report.reportID.substring(0, 2) : "R", 
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
                                ),
                              ),
                              title: Text(report.category, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                "${report.location} - ${report.status.name}",
                              ),
                              
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
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
                                        Icon(Icons.edit, size: 20), 
                                        SizedBox(width: 8), 
                                        Text("Edit")
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

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}