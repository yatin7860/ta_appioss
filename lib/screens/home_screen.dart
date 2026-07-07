import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'profile_screen.dart';
import 'apply_tour_screen.dart';
import 'my_tour_list_screen.dart';
import 'action_list_screen.dart';
import 'employee_tour_list_screen.dart';
import 'drivers_tour_list.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({required this.name, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String email = "";
  String role = "";

  @override
 
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {

  final prefs = await SharedPreferences.getInstance();

  setState(() {

    email = prefs.getString("email") ?? "";

    role = prefs.getString("role") ?? "";

  });

  print("HOME ROLE : $role");

}

  // ================= LOGOUT =================
  void logout(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // ================= DASHBOARD CARDS =================
    List<Widget> cards = [
      buildCard(
        icon: Icons.flight,
        title: "Apply Tour",
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ApplyTourScreen(),
            ),
          );
        },
      ),

      buildCard(
        icon: Icons.calendar_today,
        title: "My Tour List",
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyTourListScreen(),
            ),
          );
        },
      ),

  if (

role.contains("PROJECT_INCHARGE") ||

role.contains("REPORTING_INCHARGE") ||

role.contains("ACCOUNT") ||

role.contains("DIRECTOR") ||

role.contains("VEHICLE_INCHARGE")

)

buildCard(

icon: Icons.check_circle,

title: "Action List",

color: Colors.red,

onTap: () {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) => const ActionListScreen(),

),

);

},

),

if (

role.contains("PROJECT_INCHARGE") ||

role.contains("REPORTING_INCHARGE") ||

role.contains("ACCOUNT") ||

role.contains("DIRECTOR") ||

role.contains("VEHICLE_INCHARGE")

)

buildCard(

icon: Icons.groups,

title: "Employee Tour List",

color: Colors.amber,

onTap: () {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) => const EmployeeTourListScreen(),

),

);

},

),
if (

role.contains("VEHICLE_INCHARGE")

)

buildCard(

icon: Icons.local_taxi,

title: "Drivers Tour List",

color: Colors.amber,

onTap: () {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) => const DriversTourListScreen(),

),

);

},

),

      buildCard(
        icon: Icons.person,
        title: "Profile",
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(),
            ),
          );
        },
      ),

      buildCard(
        icon: Icons.key,
        title: "Change Password",
        color: Colors.blueAccent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(),
            ),
          );
        },
      ),
    ];

    return Scaffold(

      ///drawer
      drawer: AppDrawer(
  name: widget.name,
  email: email,
),

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2F5B),
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "logout") {
                logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      backgroundColor: Colors.grey[200],

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(
              "Welcome ${widget.name} to TA App",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, index) {
                  return cards[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD UI =================
  Widget buildCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}