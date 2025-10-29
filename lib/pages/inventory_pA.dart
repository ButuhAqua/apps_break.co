// inventory_pA.dart
import 'package:flutter/material.dart';

class InventoryGerobakAPage extends StatefulWidget {
  const InventoryGerobakAPage({super.key});

  @override
  State<InventoryGerobakAPage> createState() => _InventoryGerobakAPageState();
}

class _InventoryGerobakAPageState extends State<InventoryGerobakAPage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);
  static const Color kCard = Colors.white;

  String _query = '';
  String _statusFilter = 'Semua'; // Semua / OK / Low / Habis
  String _sort = 'Nama (A-Z)'; // Nama (A-Z) / Stok Terendah / Stok Tertinggi / Terbaru

  // HAPUS const di sini
  final List<_ProductItem> _data = [
    _ProductItem(
      id: 'PA-001',
      name: 'Kopi Gula Aren',
      sku: 'PD-KGA',
      uom: 'cup',
      qty: 6,
      minQty: 10,
      location: 'Gerobak A',
      lastUpdated: DateTime(2025, 1, 15),
    ),
    _ProductItem(
      id: 'PA-002',
      name: 'Kopi Susu',
      sku: 'PD-KS',
      uom: 'cup',
      qty: 15,
      minQty: 10,
      location: 'Gerobak A',
      lastUpdated: DateTime(2025, 1, 15),
    ),
    _ProductItem(
      id: 'PA-003',
      name: 'Aren Creamy',
      sku: 'PD-AC',
      uom: 'cup',
      qty: 0,
      minQty: 8,
      location: 'Gerobak A',
      lastUpdated: DateTime(2025, 1, 14),
    ),
    _ProductItem(
      id: 'PA-004',
      name: 'Kopi Caramel',
      sku: 'PD-KC',
      uom: 'cup',
      qty: 9,
      minQty: 12,
      location: 'Gerobak A',
      lastUpdated: DateTime(2025, 1, 13),
    ),
    _ProductItem(
      id: 'PA-005',
      name: 'Avocado Coffe',
      sku: 'PD-AVC',
      uom: 'cup',
      qty: 3,
      minQty: 6,
      location: 'Gerobak A',
      lastUpdated: DateTime(2025, 1, 12),
    ),
  ];

  String _statusOf(_ProductItem e) {
    if (e.qty <= 0) return 'Habis';
    if (e.qty <= e.minQty) return 'Low';
    return 'OK';
  }

  List<_ProductItem> get _filteredSorted {
    final list = _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.sku.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q);

      final status = _statusOf(e);
      final matchStatus = _statusFilter == 'Semua' || status == _statusFilter;

      return matchQ && matchStatus;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case 'Stok Terendah':
          return a.qty.compareTo(b.qty);
        case 'Stok Tertinggi':
          return b.qty.compareTo(a.qty);
        case 'Terbaru':
          return (b.lastUpdated ?? DateTime(2000)).compareTo(a.lastUpdated ?? DateTime(2000));
        case 'Nama (A-Z)':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return list;
  }

  void _openActions(_ProductItem item) {
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x22000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    _statusBadge(_statusOf(item)),
                  ],
                ),
                const SizedBox(height: 16),
                _sheetBtn(
                  icon: Icons.add_rounded,
                  label: 'Tambah Stok',
                  onTap: () {
                    Navigator.pop(context);
                    _snack('Tambah stok "${item.name}" (demo)');
                  },
                ),
                const SizedBox(height: 8),
                _sheetBtn(
                  icon: Icons.remove_rounded,
                  label: 'Catat Penjualan',
                  onTap: () {
                    Navigator.pop(context);
                    _snack('Catat penjualan "${item.name}" (demo)');
                  },
                ),
                const SizedBox(height: 8),
                _sheetBtn(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Mutasi ke Lokasi Lain',
                  onTap: () {
                    Navigator.pop(context);
                    _snack('Mutasi "${item.name}" (demo)');
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
        title: const Text('Inventory Produk — Gerobak A'),
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
                hintText: 'Cari nama / SKU…',
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

          // Filter bar
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              children: [
                _chip('Semua', selected: _statusFilter == 'Semua', onTap: () => setState(() => _statusFilter = 'Semua')),
                const SizedBox(width: 8),
                _chip('OK', selected: _statusFilter == 'OK', onTap: () => setState(() => _statusFilter = 'OK')),
                const SizedBox(width: 8),
                _chip('Low', selected: _statusFilter == 'Low', onTap: () => setState(() => _statusFilter = 'Low')),
                const SizedBox(width: 8),
                _chip('Habis', selected: _statusFilter == 'Habis', onTap: () => setState(() => _statusFilter = 'Habis')),
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
              itemBuilder: (context, i) {
                final it = _filteredSorted[i];
                final status = _statusOf(it);
                return _ProductCard(
                  item: it,
                  status: status,
                  onTap: () => _openActions(it),
                );
              },
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
        color: kCard,
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
              DropdownMenuItem(value: 'Stok Terendah', child: Text('Stok Terendah')),
              DropdownMenuItem(value: 'Stok Tertinggi', child: Text('Stok Tertinggi')),
              DropdownMenuItem(value: 'Terbaru', child: Text('Terbaru')),
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
      case 'OK':
        c = const Color(0xFF2E7D32);
        break;
      case 'Low':
        c = const Color(0xFFEF6C00);
        break;
      case 'Habis':
        c = const Color(0xFFC62828);
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item, required this.status, required this.onTap});
  final _ProductItem item;
  final String status;
  final VoidCallback onTap;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String s) {
    switch (s) {
      case 'OK':
        return const Color(0xFF2E7D32);
      case 'Low':
        return const Color(0xFFEF6C00);
      case 'Habis':
        return const Color(0xFFC62828);
      default:
        return kMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(status);
    final need = item.minQty <= 0 ? 0 : (item.minQty - item.qty).clamp(0, 999999);
    final pct = item.minQty <= 0
        ? 1.0
        : (item.qty / (item.minQty * 2)).clamp(0.0, 1.0);

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
                // Title + Badge
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
                      child: Text(status, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Meta
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _iconText(Icons.qr_code_rounded, item.sku),
                    _iconText(Icons.place_rounded, item.location),
                    _iconText(Icons.inventory_2_rounded, '${item.qty} ${item.uom} (min ${item.minQty})'),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(c),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.update_rounded, size: 14, color: kMuted),
                    const SizedBox(width: 6),
                    Text(
                      item.lastUpdated == null ? '—' : _fmtDateLong(item.lastUpdated!),
                      style: const TextStyle(color: kMuted, fontSize: 12),
                    ),
                    const Spacer(),
                    if (need > 0)
                      Text('Butuh +$need ${item.uom}', style: const TextStyle(color: kMuted, fontSize: 12)),
                  ],
                ),
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

  String _fmtDateLong(DateTime d) {
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _ProductItem {
  final String id;
  final String name;
  final String sku;
  final String uom;
  final int qty;
  final int minQty;
  final String location;
  final DateTime? lastUpdated;

  // Boleh tetap const; dipanggil tanpa const juga aman
  const _ProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.uom,
    required this.qty,
    required this.minQty,
    required this.location,
    required this.lastUpdated,
  });
}
