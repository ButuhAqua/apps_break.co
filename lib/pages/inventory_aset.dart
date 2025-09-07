import 'package:flutter/material.dart';

class InventoryAsetPage extends StatefulWidget {
  const InventoryAsetPage({super.key});

  @override
  State<InventoryAsetPage> createState() => _InventoryAsetPageState();
}

class _InventoryAsetPageState extends State<InventoryAsetPage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  String _query = '';
  String _statusFilter = 'Semua'; // Semua / Aktif / Dalam Servis / Rusak / Retired
  String _sort = 'Nama (A-Z)';    // Nama (A-Z) / Terbaru Servis / Lama Servis / Jadwal Terdekat

  final List<_AssetItem> _data = [
    _AssetItem(
      id: 'AST-001',
      name: 'Cup Sealer',
      code: 'CS-01',
      category: 'Mesin',
      location: 'Basecamp',
      status: 'Dalam Servis',
      condition: 'Butuh perbaikan',
      purchaseDate: DateTime(2023, 6, 10),
      lastService: DateTime(2025, 1, 7),
      nextService: DateTime(2025, 4, 7),
      notes: 'Elemen pemanas diganti',
    ),
    _AssetItem(
      id: 'AST-002',
      name: 'Grinder',
      code: 'GR-01',
      category: 'Mesin',
      location: 'Basecamp',
      status: 'Aktif',
      condition: 'Baik',
      purchaseDate: DateTime(2022, 11, 2),
      lastService: DateTime(2024, 12, 30),
      nextService: DateTime(2025, 2, 1),
      notes: 'Preventive bulanan',
    ),
    _AssetItem(
      id: 'AST-003',
      name: 'Freezer 200L',
      code: 'FZ-01',
      category: 'Pendingin',
      location: 'Basecamp',
      status: 'Aktif',
      condition: 'Baik',
      purchaseDate: DateTime(2021, 3, 14),
      lastService: DateTime(2025, 1, 10),
      nextService: DateTime(2025, 5, 10),
      notes: 'Kompresor diganti',
    ),
    _AssetItem(
      id: 'AST-004',
      name: 'Timbangan Digital',
      code: 'TB-01',
      category: 'Alat Ukur',
      location: 'Basecamp',
      status: 'Rusak',
      condition: 'Tidak akurat',
      purchaseDate: DateTime(2020, 8, 21),
      lastService: DateTime(2024, 1, 10),
      nextService: null,
      notes: 'Menunggu keputusan perbaikan/retire',
    ),
  ];

  List<_AssetItem> get _filteredSorted {
    final list = _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.code.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q);

      final matchStatus = _statusFilter == 'Semua' || e.status == _statusFilter;
      return matchQ && matchStatus;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case 'Terbaru Servis':
          return (b.lastService ?? DateTime(1900)).compareTo(a.lastService ?? DateTime(1900));
        case 'Lama Servis':
          return (a.lastService ?? DateTime(1900)).compareTo(b.lastService ?? DateTime(1900));
        case 'Jadwal Terdekat':
          return (a.nextService ?? DateTime(9999)).compareTo(b.nextService ?? DateTime(9999));
        case 'Nama (A-Z)':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return list;
  }

  void _openActions(_AssetItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0x22000000), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                    _statusBadge(item.status),
                  ],
                ),
                const SizedBox(height: 16),
                _sheetBtn(
                  icon: Icons.build_rounded,
                  label: 'Catat Servis',
                  onTap: () {
                    Navigator.pop(context);
                    _snack('Catat servis "${item.name}" (demo)');
                  },
                ),
                const SizedBox(height: 8),
                _sheetBtn(
                  icon: Icons.info_outline_rounded,
                  label: 'Detail Aset',
                  onTap: () {
                    Navigator.pop(context);
                    _snack('Buka detail "${item.name}" (demo)');
                  },
                ),
                const SizedBox(height: 8),
                _sheetBtn(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Pindah Lokasi',
                  onTap: () {
                    Navigator.pop(context);
                    _snack('Pindah lokasi "${item.name}" (demo)');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Inventory Aset'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari nama aset / kode / kategori…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kPrimary, width: 1.2),
                ),
              ),
            ),
          ),

          // Filter bar (tanpa filter lokasi)
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              children: [
                _chip('Semua', selected: _statusFilter == 'Semua', onTap: () => setState(() => _statusFilter = 'Semua')),
                const SizedBox(width: 8),
                _chip('Aktif', selected: _statusFilter == 'Aktif', onTap: () => setState(() => _statusFilter = 'Aktif')),
                const SizedBox(width: 8),
                _chip('Dalam Servis', selected: _statusFilter == 'Dalam Servis', onTap: () => setState(() => _statusFilter = 'Dalam Servis')),
                const SizedBox(width: 8),
                _chip('Rusak', selected: _statusFilter == 'Rusak', onTap: () => setState(() => _statusFilter = 'Rusak')),
                const SizedBox(width: 8),
                _chip('Retired', selected: _statusFilter == 'Retired', onTap: () => setState(() => _statusFilter = 'Retired')),
                const SizedBox(width: 12),
                _sortDropdown(),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _filteredSorted.length,
              itemBuilder: (context, i) => _AssetCard(
                item: _filteredSorted[i],
                onTap: () => _openActions(_filteredSorted[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widgets kecil
  Widget _chip(String text, {required bool selected, required VoidCallback onTap}) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: kPrimary.withOpacity(.12),
      labelStyle: TextStyle(
        color: selected ? kPrimary : kMuted,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: selected ? kPrimary : kBorder),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _sortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.sort_rounded, size: 18, color: kMuted),
          const SizedBox(width: 6),
          DropdownButton<String>(
            value: _sort,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'Nama (A-Z)', child: Text('Nama (A-Z)')),
              DropdownMenuItem(value: 'Terbaru Servis', child: Text('Terbaru Servis')),
              DropdownMenuItem(value: 'Lama Servis', child: Text('Lama Servis')),
              DropdownMenuItem(value: 'Jadwal Terdekat', child: Text('Jadwal Terdekat')),
            ],
            onChanged: (v) => setState(() => _sort = v ?? _sort),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color c;
    switch (status) {
      case 'Aktif':
        c = const Color(0xFF2E7D32);
        break;
      case 'Dalam Servis':
        c = const Color(0xFFEF6C00);
        break;
      case 'Rusak':
        c = const Color(0xFFC62828);
        break;
      case 'Retired':
        c = const Color(0xFF455A64);
        break;
      default:
        c = kMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _sheetBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: kPrimary),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item, required this.onTap});
  final _AssetItem item;
  final VoidCallback onTap;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String s) {
    switch (s) {
      case 'Aktif':
        return const Color(0xFF2E7D32);
      case 'Dalam Servis':
        return const Color(0xFFEF6C00);
      case 'Rusak':
        return const Color(0xFFC62828);
      case 'Retired':
        return const Color(0xFF455A64);
      default:
        return kMuted;
    }
  }

  double _serviceProgress(DateTime? last, DateTime? next) {
    if (last == null || next == null) return 0.0;
    final total = next.difference(last).inDays;
    final curr = DateTime.now().difference(last).inDays;
    if (total <= 0) return 1.0;
    return (curr / total).clamp(0.0, 1.0);
    }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(item.status);
    final p = _serviceProgress(item.lastService, item.nextService);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x14000000),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: nama + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kText),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.withOpacity(.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item.status, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Meta ringkas
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _iconText(Icons.qr_code_2_rounded, item.code),
                    _iconText(Icons.place_rounded, item.location),
                    _iconText(Icons.category_rounded, item.category),
                    _iconText(Icons.verified_rounded, 'Kondisi: ${item.condition}'),
                  ],
                ),
                const SizedBox(height: 10),

                // Jadwal servis
                Row(
                  children: [
                    const Icon(Icons.build_circle_rounded, size: 16, color: kMuted),
                    const SizedBox(width: 6),
                    Text('Servis terakhir: ${item.lastService == null ? '—' : _fmtDate(item.lastService!)}',
                        style: const TextStyle(color: kMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_available_rounded, size: 16, color: kMuted),
                    const SizedBox(width: 6),
                    Text('Servis berikutnya: ${item.nextService == null ? '—' : _fmtDate(item.nextService!)}',
                        style: const TextStyle(color: kMuted)),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress mendekati servis berikutnya
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: p,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(c),
                  ),
                ),
                const SizedBox(height: 6),
                if (item.notes.isNotEmpty)
                  Text(item.notes, style: const TextStyle(color: kText)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: kMuted),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: kText)),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _AssetItem {
  final String id;
  final String name;
  final String code;
  final String category;
  final String location;
  final String status;     // Aktif / Dalam Servis / Rusak / Retired
  final String condition;  // Baik / Cukup / Rusak / dll
  final DateTime? purchaseDate;
  final DateTime? lastService;
  final DateTime? nextService;
  final String notes;

  const _AssetItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.location,
    required this.status,
    required this.condition,
    required this.purchaseDate,
    required this.lastService,
    required this.nextService,
    required this.notes,
  });
}
