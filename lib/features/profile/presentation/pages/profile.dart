import 'package:flutter/material.dart';

import 'package:apps_break/features/auth/data/auth_service.dart';
import 'package:apps_break/features/auth/presentation/pages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kPrimaryDark = Color(0xFFB71C1C);
  static const Color kBg = Color(0xFFF8F8FA);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF757575);
  static const Color kDivider = Color(0xFFE8B7B7);

  int _currentIndex = 2;
  bool _isLoading = true;

  String _name = '-';
  String _email = '-';
  String _role = '-';
  String _location = '-';
  String _status = 'Aktif';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthService().me();
      final employee = data['employee'];

      if (!mounted) return;

      setState(() {
        _name = employee?['full_name'] ?? data['name'] ?? '-';
        _email = data['email'] ?? '-';
        _role = employee?['role'] ?? '-';
        _location = employee?['assigned_location'] ?? '-';
        _status = employee?['status'] ?? 'Aktif';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil profile: $e')),
      );
    }
  }

  String get _initials {
    final words = _name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first[0].toUpperCase();

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kPrimary),
              )
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimary, kPrimaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                color: kPrimary,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_role • $_location',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                      children: [
                        const _SectionTitle(title: 'Informasi Akun'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _ProfileInfoTile(
                                icon: Icons.email_outlined,
                                label: 'EMAIL',
                                value: _email,
                              ),
                              const Divider(height: 30, color: kDivider),
                              _ProfileInfoTile(
                                icon: Icons.badge_outlined,
                                label: 'ROLE',
                                value: _role,
                              ),
                              const Divider(height: 30, color: kDivider),
                              _ProfileInfoTile(
                                icon: Icons.location_on_outlined,
                                label: 'LOCATION',
                                value: _location,
                              ),
                              const Divider(height: 30, color: kDivider),
                              _ProfileInfoTile(
                                icon: Icons.verified_outlined,
                                label: 'STATUS AKUN',
                                value: _status,
                                valueColor: const Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle(title: 'Aksi'),
                        const SizedBox(height: 10),
                        _ActionCard(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          subtitle: 'Keluar dari akun saat ini',
                          color: kPrimary,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);

          if (i == 0 || i == 1) {
            Navigator.maybePop(context);
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: kPrimary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.arrow_back_rounded),
            label: 'Back',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  static const Color kMuted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: kMuted,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: .7,
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kPrimary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: kMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withOpacity(.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}