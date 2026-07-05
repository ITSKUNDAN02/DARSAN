import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _call(String number) async {
    final Uri phone = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(phone)) {
      await launchUrl(phone);
    }
  }

  Future<void> _openHospital() async {
    final Uri map = Uri.parse(
      "https://www.google.com/maps/search/hospital+near+me",
    );

    if (await canLaunchUrl(map)) {
      await launchUrl(map, mode: LaunchMode.externalApplication);
    }
  }

  Widget emergencyCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(.12),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.call, color: Colors.green),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Assistance"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Emergency Contacts",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Tap any service to open your phone dialer.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          emergencyCard(
            context: context,
            icon: Icons.local_police,
            color: Colors.blue,
            title: "Nepal Police",
            subtitle: "Emergency • 100",
            onTap: () => _call("100"),
          ),

          emergencyCard(
            context: context,
            icon: Icons.local_hospital,
            color: Colors.red,
            title: "Ambulance",
            subtitle: "Emergency • 102",
            onTap: () => _call("102"),
          ),

          emergencyCard(
            context: context,
            icon: Icons.local_fire_department,
            color: Colors.orange,
            title: "Fire Brigade",
            subtitle: "Emergency • 101",
            onTap: () => _call("101"),
          ),

          emergencyCard(
            context: context,
            icon: Icons.support_agent,
            color: Colors.deepPurple,
            title: "Tourist Police",
            subtitle: "Helpline • 1144",
            onTap: () => _call("1144"),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _openHospital,
            icon: const Icon(Icons.local_hospital),
            label: const Text(
              "Find Nearby Hospitals",
              style: TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              "Stay safe and travel responsibly.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
