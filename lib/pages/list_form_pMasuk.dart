import 'package:flutter/material.dart';

import 'create_form_pMasuk.dart';

/// ===============================================================
/// LIST LAPORAN PRODUK MASUK (SISA KELILING)
/// ===============================================================
class ListFormProdukMasukPage extends StatefulWidget {
  const ListFormProdukMasukPage({super.key});

  @override
  State<ListFormProdukMasukPage> createState() => _ListFormProdukMasukPageState();
}

class _ListFormProdukMasukPageState extends State<ListFormProdukMasukPage> {
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  String _query = '';
  String _statusFilter = 'Semua';

  // ===== Dummy data contoh (menyesuaikan field dari CreateFormProdukMasukPage) =====
  final List<_ProdukMasukItem> _data = [
    _ProdukMasukItem(
      id: 'PM-001',
      title: 'Laporan Sisa Gerobak A',
      reportDate: DateTime(2025, 1, 20),
      notes: 'Sisa banyak karena hujan deras',
      items: const [
        _ProdukItem(name: 'Kopi Gula Aren', sku: 'KGA-01', uom: 'cup', qtyLeft: 5),
        _ProdukItem(name: 'Kopi Susu', sku: 'KS-01', uom: 'cup', qtyLeft: 2),
      ],
      cartSource: 'Gerobak A',
      returnLocation: 'Basecamp',
      proofs: const ['foto_sisa_gerobakA.jpg'],
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
    _ProdukMasukItem(
      id: 'PM-002',
      title: 'Laporan Sisa Gerobak B',
      reportDate: DateTime(2025, 1, 21),
      notes: 'Penjualan normal',
      items: const [
        _ProdukItem(name: 'Kopi Hitam', sku: 'KH-01', uom: 'cup', qtyLeft: 3),
      ],
      cartSource: 'Gerobak B',
      returnLocation: 'Basecamp',
      proofs: const [],
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan B', status: 'Menunggu'),
    ),
    _ProdukMasukItem(
      id: 'PM-003',
      title: 'Laporan Sisa Gerobak C',
      reportDate: DateTime(2025, 1, 22),
      notes: 'Beberapa produk basi',
      items: const [
        _ProdukItem(name: 'Es Coklat', sku: 'EC-01', uom: 'cup', qtyLeft: 8),
      ],
      cartSource: 'Gerobak C',
      returnLocation: 'Gudang',
      proofs: const ['foto_sisa_coklat.jpg'],
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Owner', status: 'Ditolak'),
    ),
  ];

  List<_ProdukMasukItem> get _filtered {
    return _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.id.toLowerCase().contains(q) ||
          e.title.toLowerCase().contains(q) ||
          e.cartSource.toLowerCase().contains(q) ||
          e.returnLocation.toLowerCase().contains(q) ||
          e.submittedBy.name.toLowerCase().contains(q) ||
          e.items.any((i) => i.name.toLowerCase().contains(q));

      final matchS = _statusFilter == 'Semua' || e.approval.status == _statusFilter;
      return matchQ && matchS;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Produk Masuk (Sisa)'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Cari ID / judul / gerobak / lokasi / produk…',
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

            // Filter status
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                children: [
                  _statusChip('Semua'),
                  const SizedBox(width: 8),
                  _statusChip('Menunggu'),
                  const SizedBox(width: 8),
                  _statusChip('Disetujui'),
                  const SizedBox(width: 8),
                  _statusChip('Ditolak'),
                ],
              ),
            ),

            // List card
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _ProdukMasukCard(item: _filtered[i]),
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 240,
        height: 56,
        child: FloatingActionButton.extended(
          heroTag: 'buatFormProdukMasuk',
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Laporan Sisa', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateFormProdukMasukPage(
                  isAdmin: false,
                  currentUserName: 'Rafi Rahman',
                  currentUserEmail: 'rafi@example.com',
                ),
              ),
            );
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Widget _statusChip(String value) {
    final selected = _statusFilter == value;
    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = value),
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
}

/// ===============================================================
/// CARD DETAIL PRODUK MASUK (SISA)
/// ===============================================================
class _ProdukMasukCard extends StatelessWidget {
  const _ProdukMasukCard({required this.item});
  final _ProdukMasukItem item;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String s) {
    switch (s) {
      case 'Disetujui':
        return const Color(0xFF2E7D32);
      case 'Ditolak':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFEF6C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x14000000),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kText)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(item.approval.status).withOpacity(.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.approval.status,
                      style: TextStyle(
                        color: _statusColor(item.approval.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: kMuted),
                  const SizedBox(width: 6),
                  Text(_formatDate(item.reportDate), style: const TextStyle(color: kMuted, fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.confirmation_number_rounded, size: 14, color: kMuted),
                  const SizedBox(width: 6),
                  Text(item.id, style: const TextStyle(color: kMuted, fontSize: 13)),
                ],
              ),
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.notes, style: const TextStyle(color: kText)),
              ],
              const SizedBox(height: 12),

              // Detail produk sisa
              const Text('Detail Produk Sisa', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              for (final it in item.items)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text('${it.name} (${it.sku}) • ${it.qtyLeft} ${it.uom}',
                      style: const TextStyle(color: kText)),
                ),

              // Lokasi & Gerobak
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 16, color: kMuted),
                  const SizedBox(width: 6),
                  Text('Dari ${item.cartSource}', style: const TextStyle(color: kText)),
                  const Spacer(),
                  Text('Ke ${item.returnLocation}', style: const TextStyle(color: kMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// ===============================================================
/// MODEL DATA (mirror CreateFormProdukMasukPage)
/// ===============================================================
class _ProdukMasukItem {
  final String id;
  final String title;
  final DateTime reportDate;
  final String notes;
  final List<_ProdukItem> items;
  final String cartSource; // gerobak asal
  final String returnLocation; // lokasi kembali
  final List<String> proofs;
  final _Person submittedBy;
  final _Approval approval;

  const _ProdukMasukItem({
    required this.id,
    required this.title,
    required this.reportDate,
    required this.notes,
    required this.items,
    required this.cartSource,
    required this.returnLocation,
    required this.proofs,
    required this.submittedBy,
    required this.approval,
  });
}

class _ProdukItem {
  final String name;
  final String sku;
  final String uom;
  final int qtyLeft;
  const _ProdukItem({
    required this.name,
    required this.sku,
    required this.uom,
    required this.qtyLeft,
  });
}

class _Person {
  final String name;
  final String email;
  const _Person({required this.name, required this.email});
}

class _Approval {
  final String reviewer;
  final String status;
  const _Approval({required this.reviewer, required this.status});
}
