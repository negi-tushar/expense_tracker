import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onSelectMenu;

  // onSelectMenu callback to handle navigation/menu clicks
  const AppDrawer({Key? key, required this.onSelectMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.black87),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Text("Welcome!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                Text("user@example.com", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _buildMenuItem(context, icon: Icons.home, title: "Home", id: "home"),
          _buildMenuItem(context, icon: Icons.category, title: "Manage Categories", id: "categories"),
          _buildMenuItem(context, icon: Icons.bar_chart, title: "Reports", id: "reports"),
          _buildMenuItem(context, icon: Icons.settings, title: "Settings", id: "settings"),
          const Divider(),
          _buildMenuItem(context, icon: Icons.info_outline, title: "About", id: "about"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String id}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () {
        Navigator.pop(context); // close drawer
        onSelectMenu(id); // callback to parent to handle navigation
      },
    );
  }
}
