// file: list_form_subbahan.dart
import 'package:flutter/material.dart';

import 'create_form_subbahan.dart'; // pastikan ada class CreateFormSubBahanPage

/// ===============================================================
/// LIST FORM PENGAJUAN (detail mirror form + status alur lengkap)
/// ===============================================================
class ListFormSubBahanPage extends StatefulWidget {
  const ListFormSubBahanPage({super.key});

  @override
  State<ListFormSubBahanPage> createState() => _ListFormSubBahanPageState();
}

class _ListFormSubBahanPageState extends State<ListFormSubBahanPage> {
  // Palet konsisten merah/putih
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  String _query = '';
  String _statusFilter = 'Semua';

  // Demo data
  final List<_FormItem> _data = [
    _FormItem(
      id: 'PG-001',
      title: 'Pembelian Biji Kopi 5kg',
      requestType: 'Pembelian Bahan Baku',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 5),
      notes: 'Untuk stok minggu depan',
      items: const [
        _Item(name: 'Biji Kopi', category: 'Bahan Baku', uom: 'kg', qty: 5),
      ],
      vendor: const _Vendor(name: 'CV Sumber Jaya'),
      payment: const _Payment(method: 'Transfer', type: 'Di muka', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: true, location: 'Basecamp'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
      amount: 850000,
    ),
    _FormItem(
      id: 'PG-002',
      title: 'Cup 12oz (200 pcs)',
      requestType: 'Pembelian Perlengkapan',
      priority: 'Mendesak',
      requestDate: DateTime(2025, 1, 8),
      notes: 'Event Sabtu',
      items: const [
        _Item(name: 'Cup 12oz', category: 'Kemasan', uom: 'pcs', qty: 200),
      ],
      vendor: const _Vendor(name: 'PT Kemasan Makmur'),
      payment: const _Payment(method: 'Cash', type: 'Di muka', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: false, location: 'Basecamp'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Menunggu'),
      amount: 420000,
    ),
    _FormItem(
      id: 'PG-003',
      title: 'Susu UHT 2 dus',
      requestType: 'Pembelian Bahan Baku',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 9),
      notes: '',
      items: const [
        _Item(name: 'Susu UHT', category: 'Bahan Baku', uom: 'dus', qty: 2),
      ],
      vendor: const _Vendor(name: 'Toko Susu Sejahtera'),
      payment: const _Payment(method: 'E-Wallet', type: 'Termin', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: true, location: 'Basecamp'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan B', status: 'Ditolak'),
      amount: 300000,
    ),
    _FormItem(
      id: 'PG-004',
      title: 'Gula Aren 3kg',
      requestType: 'Pembelian Bahan Baku',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 10),
      notes: 'Untuk minuman signature',
      items: const [
        _Item(name: 'Gula Aren', category: 'Bahan Baku', uom: 'kg', qty: 3),
      ],
      vendor: const _Vendor(name: 'UD Manis Legi'),
      payment: const _Payment(method: 'Cash', type: 'Di muka', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: true, location: 'Basecamp'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Owner', status: 'Menunggu'),
      amount: 150000,
    ),
  ];

  /// ===== Hitung status tampilan (untuk filter & badge) =====
  /// Alur: Menunggu Persetujuan → Disetujui → Diproses → Selesai | Ditolak
  String _computedStatus(_FormItem e) {
    final hasProof = e.completion.proofs.isNotEmpty;
    final hasPurchaseDate = e.payment.purchaseDate != null;

    // Selesai ketika sudah ada bukti atau tanggal beli (bisa diketatkan menjadi && sesuai kebijakan)
    if (hasProof || hasPurchaseDate) return 'Selesai';

    // Menunggu keputusan atasan
    if (e.approval.status == 'Menunggu') return 'Menunggu Persetujuan';

    // Setelah disetujui dan belum ada bukti/tanggal beli → Diproses (sedang dibeli)
    if (e.approval.status == 'Disetujui') return 'Diproses';

    // Selain itu: Ditolak
    return 'Ditolak';
  }

  List<_FormItem> get _filtered {
    return _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          e.requestType.toLowerCase().contains(q) ||
          e.submittedBy.name.toLowerCase().contains(q);

      final statusView = _computedStatus(e);
      final matchS = _statusFilter == 'Semua' || statusView == _statusFilter;
      return matchQ && matchS;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengajuan Sub Bahan'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Cari ID / judul / tipe / pengaju…',
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
                  _statusChip('Menunggu Persetujuan'),
                  const SizedBox(width: 8),
                  _statusChip('Disetujui'),
                  const SizedBox(width: 8),
                  _statusChip('Diproses'),
                  const SizedBox(width: 8),
                  _statusChip('Selesai'),
                  const SizedBox(width: 8),
                  _statusChip('Ditolak'),
                ],
              ),
            ),

            // List (detail)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _FormDetailCard(
                  item: _filtered[i],
                  statusView: _computedStatus(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),

      // Tombol Buat Pengajuan
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 220,
        height: 56,
        child: FloatingActionButton.extended(
          heroTag: 'buatForm',
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Pengajuan', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateFormSubBahanPage(
                  isAdmin: false, // kalau user admin, ganti ke true
                  currentUserName: 'Rafi Rahman',
                  currentUserEmail: 'rafi@example.com',
                ),
              ),
            );
            // TODO: setelah kembali, fetch ulang dari backend
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
/// CARD DETAIL
/// ===============================================================
class _FormDetailCard extends StatelessWidget {
  const _FormDetailCard({required this.item, required this.statusView});
  final _FormItem item;
  final String statusView;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String s) {
    switch (s) {
      case 'Selesai':
      case 'Disetujui':
        return const Color(0xFF2E7D32); // hijau
      case 'Ditolak':
        return const Color(0xFFC62828); // merah
      case 'Diproses':
      case 'Menunggu Persetujuan':
      default:
        return const Color(0xFFEF6C00); // oranye
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
              // Header judul + status + total
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
                      color: _statusColor(statusView).withOpacity(.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        if (statusView == 'Selesai')
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                        if (statusView == 'Diproses')
                          const Icon(Icons.local_shipping, size: 14, color: Color(0xFFEF6C00)),
                        if (statusView == 'Menunggu Persetujuan')
                          const Icon(Icons.schedule, size: 14, color: Color(0xFFEF6C00)),
                        if (statusView == 'Selesai' ||
                            statusView == 'Diproses' ||
                            statusView == 'Menunggu Persetujuan')
                          const SizedBox(width: 6),
                        Text(
                          statusView,
                          style: TextStyle(
                            color: _statusColor(statusView),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: kMuted),
                  const SizedBox(width: 6),
                  Text(_formatDateLong(item.requestDate), style: const TextStyle(color: kMuted, fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.confirmation_number_rounded, size: 14, color: kMuted),
                  const SizedBox(width: 6),
                  Text(item.id, style: const TextStyle(color: kMuted, fontSize: 13)),
                  const Spacer(),
                  Text(
                    _formatCurrency(item.amount),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kText),
                  ),
                ],
              ),
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.notes, style: const TextStyle(color: kText)),
              ],
              const SizedBox(height: 14),

              // ===== Identitas Pengajuan =====
              _SectionCard(
                title: 'Identitas Pengajuan',
                child: _kvGrid([
                  ('Jenis Pengajuan', item.requestType),
                  ('Prioritas', item.priority),
                  ('Tanggal Pengajuan', _formatDate(item.requestDate)),
                ]),
              ),
              const SizedBox(height: 12),

              // ===== Item Belanja =====
              _SectionCard(
                title: 'Item Belanja',
                subtitle: 'Nama item, kategori, satuan, dan kuantitas',
                child: Column(
                  children: [
                    for (final it in item.items) _itemRow(it),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== Vendor =====
              _SectionCard(
                title: 'Vendor',
                child: _kvGrid([
                  ('Nama Vendor', item.vendor.name.isEmpty ? '—' : item.vendor.name),
                ]),
              ),
              const SizedBox(height: 12),

              // ===== Pelaku & Persetujuan =====
              _SectionCard(
                title: 'Pelaku & Persetujuan',
                child: Column(
                  children: [
                    _kvRow('Diajukan oleh', '${item.submittedBy.name} • ${item.submittedBy.email}'),
                    const SizedBox(height: 8),
                    _kvGrid([
                      ('Calon Reviewer/Atasan', item.approval.reviewer),
                      ('Status Approval', item.approval.status), // Info status approval asli
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded, size: 18, color: kMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.inventory.autoAdjust
                                ? 'Update stok otomatis saat Selesai'
                                : 'Tidak update stok otomatis',
                            style: const TextStyle(color: kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _kvRow('Lokasi/Gudang', item.inventory.location),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== Pembayaran & Penyelesaian =====
              _SectionCard(
                title: 'Pembayaran & Penyelesaian',
                subtitle: 'Diisi admin saat proses',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kvGrid([
                      ('Metode Pembayaran', item.payment.method),
                      ('Pembayaran', item.payment.type),
                      ('Tanggal Beli', item.payment.purchaseDate == null ? '—' : _formatDate(item.payment.purchaseDate!)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Bukti Penyelesaian', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    if (item.completion.proofs.isEmpty)
                      const Text('Belum ada bukti', style: TextStyle(color: kMuted))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.completion.proofs.map((f) => Chip(label: Text(f))).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemRow(_Item it) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(it.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _kvGrid([
            ('Kategori', it.category),
            ('Satuan (UoM)', it.uom),
            ('Qty', '${it.qty}'),
          ]),
        ],
      ),
    );
  }

  Widget _kvGrid(List<(String, String)> pairs) {
    // grid 2 kolom responsif
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 520;
        final chunk = <List<(String, String)>>[];
        for (int i = 0; i < pairs.length; i += isWide ? 2 : 1) {
          chunk.add(pairs.sublist(i, (i + (isWide ? 2 : 1)).clamp(0, pairs.length)));
        }
        return Column(
          children: [
            for (final row in chunk) ...[
              Row(
                children: [
                  for (final (k, v) in row) ...[
                    Expanded(child: _kvRow(k, v)),
                    if (row.length == 1) const SizedBox.shrink() else const SizedBox(width: 12),
                  ],
                ],
              ),
              if (row != chunk.last) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  Widget _kvRow(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(k, style: const TextStyle(color: kMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            v.isEmpty ? '—' : v,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700, color: kText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDateLong(DateTime d) {
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatCurrency(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    final len = s.length;
    for (int i = 0; i < len; i++) {
      buf.write(s[i]);
      final rev = len - i - 1;
      if (rev % 3 == 0 && i != len - 1) buf.write('.');
    }
    return 'Rp ${buf.toString()}';
  }
}

/// ===============================================================
/// REUSABLE SECTION CARD
/// ===============================================================
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.subtitle, required this.child, this.action});
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  static const Color kBorder = Color(0xFFE0E0E0);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x14000000),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kText)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: const TextStyle(color: kMuted, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ]),
      ),
    );
  }
}

/// ===============================================================
/// MODEL DATA (mirror CreateFormPage)
/// ===============================================================
class _FormItem {
  final String id;
  final String title;
  final DateTime requestDate;
  final String requestType; // Jenis Pengajuan
  final String priority;    // Prioritas
  final String notes;

  final List<_Item> items;
  final _Vendor vendor;

  final _Payment payment;
  final _Completion completion;

  final _Inventory inventory;
  final _Person submittedBy;
  final _Approval approval;

  final int amount;

  const _FormItem({
    required this.id,
    required this.title,
    required this.requestDate,
    required this.requestType,
    required this.priority,
    required this.notes,
    required this.items,
    required this.vendor,
    required this.payment,
    required this.completion,
    required this.inventory,
    required this.submittedBy,
    required this.approval,
    required this.amount,
  });
}

class _Item {
  final String name;
  final String category;
  final String uom;
  final int qty;
  const _Item({required this.name, required this.category, required this.uom, required this.qty});
}

class _Vendor {
  final String name;
  const _Vendor({required this.name});
}

class _Payment {
  final String method; // Cash / Transfer / E-Wallet
  final String type;   // Di muka / Termin
  final DateTime? purchaseDate;
  const _Payment({required this.method, required this.type, required this.purchaseDate});
}

class _Completion {
  final List<String> proofs; // file bukti
  const _Completion({required this.proofs});
}

class _Inventory {
  final bool autoAdjust;
  final String location;
  const _Inventory({required this.autoAdjust, required this.location});
}

class _Person {
  final String name;
  final String email;
  const _Person({required this.name, required this.email});
}

class _Approval {
  final String reviewer;
  final String status; // Menunggu / Disetujui / Ditolak
  const _Approval({required this.reviewer, required this.status});
}
