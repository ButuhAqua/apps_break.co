import 'package:flutter/material.dart';

import 'package:apps_break/core/constants/app_colors.dart';
import 'package:apps_break/features/pengajuan_bahan_baku/presentation/pages/list_form_subbahan.dart';
import 'package:apps_break/features/laporan_produk_keluar/presentation/pages/list_form_pKeluar.dart';
import 'package:apps_break/features/laporan_produk_masuk/presentation/pages/list_form_pMasuk.dart';
import 'package:apps_break/features/laporan_produksi/presentation/pages/list_form_lProduksi.dart';
import 'package:apps_break/features/product_inventory/presentation/pages/inventory.dart';
import 'package:apps_break/features/profile/presentation/pages/profile.dart' as profile;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final options = [
      _HomeOption(
        title: 'Pengajuan Bahan Baku',
        icon: Icons.assignment_rounded,
        badge: 3,
        page: const ListFormSubBahanPage(),
      ),
      _HomeOption(
        title: 'Laporan Berangkat',
        icon: Icons.outbox_rounded,
        badge: 5,
        page: const ListFormProdukKeluarPage(),
      ),
      _HomeOption(
        title: 'Laporan Pulang',
        icon: Icons.move_to_inbox_rounded,
        badge: 2,
        page: const ListFormProdukMasukPage(),
      ),
      _HomeOption(
        title: 'Laporan Produksi',
        icon: Icons.factory_rounded,
        badge: 4,
        page: const ListFormLProduksiPage(),
      ),
      _HomeOption(
        title: 'Inventori',
        icon: Icons.inventory_2_rounded,
        badge: 0,
        page: const InventoryPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Break.Co Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickStat(title: "Produksi", value: "120"),
                    _QuickStat(title: "Berangkat", value: "89"),
                    _QuickStat(title: "Pulang", value: "76"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: options.length,
              itemBuilder: (_, i) {
                final item = options[i];
                return _AnimatedMenuCard(option: item);
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);

          if (i == 0) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const profile.ProfilePage(),
              ),
            ).then((_) {
              setState(() => _currentIndex = 1);
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.arrow_back),
            label: 'Back',
          ),
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AnimatedMenuCard extends StatelessWidget {
  final _HomeOption option;

  const _AnimatedMenuCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.9, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, animation, __) => FadeTransition(
                opacity: animation,
                child: option.page,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      option.icon,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  if (option.badge > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          option.badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  option.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String title;
  final String value;

  const _QuickStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HomeOption {
  final String title;
  final IconData icon;
  final int badge;
  final Widget page;

  _HomeOption({
    required this.title,
    required this.icon,
    required this.badge,
    required this.page,
  });
}