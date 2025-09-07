import 'package:flutter/material.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kBg = Colors.white;
  static const Color kText = Color(0xFF212121);
  static const Color kBorder = Color(0xFFE0E0E0);

  int _currentIndex = 2; // Back=0, Home=1, Profile=2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header gradien dengan avatar =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: kPrimary,
                      child: Icon(Icons.person_rounded, size: 56, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Rafi Rahman",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ===== Isi Informasi =====
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                children: const [
                  _InfoCard(
                    icon: Icons.alternate_email_rounded,
                    label: "Email",
                    value: "rafi@example.com",
                  ),
                  _InfoCard(
                    icon: Icons.cake_rounded,
                    label: "Tanggal Lahir",
                    value: "01 Januari 2000",
                  ),
                  _InfoCard(
                    icon: Icons.phone_rounded,
                    label: "No. Telepon",
                    value: "+62 812 3456 7890",
                  ),
                  _InfoCard(
                    icon: Icons.location_on_rounded,
                    label: "Alamat",
                    value: "Jl. Contoh No. 123, Jakarta",
                  ),
                ],
              ),
            ),

            // ===== Tombol Logout =====
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== Bottom Navigation =====
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) {
            Navigator.maybePop(context);
          } else if (i == 1) {
            Navigator.maybePop(context); // balik ke Home
          }
        },
        backgroundColor: kBg,
        indicatorColor: kPrimary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.arrow_back_rounded), label: 'Back'),
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  static const Color kText = Color(0xFF212121);
  static const Color kBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFD32F2F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: kText, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
