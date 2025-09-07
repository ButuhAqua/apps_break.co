import 'package:apps_break/pages/list_form_subbahan.dart' show ListFormSubBahanPage;
import 'package:flutter/material.dart';

import 'inventory.dart';                  // InventoryPage
import 'list_form_aset.dart';             // ListFormAsetPage
import 'list_form_maintenance.dart';      // ListFormMaintenancePage
import 'list_form_pemakaibahan.dart';     // ListFormPemakaiBahanPage
import 'login.dart';
import 'profile.dart' as profile;         // ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F); // merah
  static const Color kBg = Colors.white;           // putih
  static const Color kText = Color(0xFF212121);
  static const Color kBorder = Color(0xFFE0E0E0);

  int _currentIndex = 1; // 0=Back, 1=Home, 2=Profile

  @override
  Widget build(BuildContext context) {
    final options = <_HomeOption>[
      // 1) Pengajuan Bahan Baku (paling atas)
      _HomeOption(
        title: 'Pengajuan Bahan Baku',
        subtitle: 'Buat & kelola permintaan bahan baku',
        icon: Icons.assignment_turned_in_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListFormSubBahanPage()),
          );
        },
      ),
      // 2) Pengajuan Aset
      _HomeOption(
        title: 'Pengajuan Aset',
        subtitle: 'Permintaan pembelian/penambahan aset',
        icon: Icons.business_center_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListFormAsetPage()),
          );
        },
      ),
      // 3) Maintenance
      _HomeOption(
        title: 'Maintenance',
        subtitle: 'Perawatan & servis peralatan',
        icon: Icons.build_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListFormMaintenancePage()),
          );
        },
      ),
      // 4) Pengajuan Pemakaian Bahan Baku (Produksi)
      _HomeOption(
        title: 'Pengajuan Pemakaian Bahan Baku',
        subtitle: 'Catat pemakaian bahan untuk produksi',
        icon: Icons.receipt_long_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListFormPemakaiBahanPage()),
          );
        },
      ),
      // 5) Inventori
      _HomeOption(
        title: 'Inventori',
        subtitle: 'Stok bahan & aset',
        icon: Icons.inventory_2_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryPage()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('break.co'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 520;

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  itemCount: options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 140,
                  ),
                  itemBuilder: (_, i) => _HomeOptionCard(
                    title: options[i].title,
                    subtitle: options[i].subtitle,
                    icon: options[i].icon,
                    onTap: options[i].onTap,
                  ),
                ),
              );
            } else {
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _HomeOptionCard(
                  title: options[i].title,
                  subtitle: options[i].subtitle,
                  icon: options[i].icon,
                  onTap: options[i].onTap,
                ),
              );
            }
          },
        ),
      ),

      // ================= Bottom Navigation =================
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) {
            // Back -> ke LoginPage dan hapus history
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          } else if (i == 1) {
            // sudah di Home
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const profile.ProfilePage()),
            ).then((_) {
              if (mounted) setState(() => _currentIndex = 1);
            });
          }
        },
        backgroundColor: kBg,
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

class _HomeOptionCard extends StatelessWidget {
  const _HomeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0x1A000000),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 34, color: kPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(color: kText),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: kPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== Struktur data kecil untuk opsi card ======
class _HomeOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  _HomeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
