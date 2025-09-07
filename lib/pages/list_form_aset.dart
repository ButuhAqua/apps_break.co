import 'package:flutter/material.dart';

import 'create_form_aset.dart';

/// ===============================================================
/// LIST PENGAJUAN ASET (detail mirroring CreateFormAsetPage)
/// ===============================================================
class ListFormAsetPage extends StatefulWidget {
  const ListFormAsetPage({super.key});

  @override
  State<ListFormAsetPage> createState() => _ListFormAsetPageState();
}

class _ListFormAsetPageState extends State<ListFormAsetPage> {
  // Palet konsisten merah/putih
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  String _query = '';
  String _statusFilter = 'Semua';

  // ===== Dummy data contoh =====
  final List<_AsetFormItem> _data = [
    _AsetFormItem(
      id: 'AS-001',
      title: 'Laptop Admin Kasir',
      requestType: 'Pengadaan Aset',
      priority: 'Mendesak',
      requestDate: DateTime(2025, 1, 6),
      notes: 'Butuh segera untuk operasional kasir',
      assets: const [
        _AsetItem(
          name: 'Laptop',
          category: 'Elektronik',
          brand: 'Lenovo',
          model: 'ThinkPad E14',
          spec: 'i5, 16GB RAM, 512GB SSD',
          qty: 1,
          estPrice: 12000000,
        ),
      ],
      vendor: const _Vendor(name: 'PT Komputer Jaya'),
      payment: const _Payment(method: 'Transfer', type: 'Di muka', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: true, location: 'Basecamp'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
    _AsetFormItem(
      id: 'AS-002',
      title: 'Freezer Untuk Biji Kopi',
      requestType: 'Pengadaan Aset',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 7),
      notes: 'Kapasitas 200L, hemat listrik',
      assets: const [
        _AsetItem(
          name: 'Freezer',
          category: 'Elektronik',
          brand: 'Sharp',
          model: 'SJ-200L',
          spec: '200L, Low Watt',
          qty: 1,
          estPrice: 3500000,
        ),
      ],
      vendor: const _Vendor(name: ''),
      payment: const _Payment(method: 'Cash', type: 'Di muka', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: true, location: 'Gudang'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan B', status: 'Menunggu'),
    ),
    _AsetFormItem(
      id: 'AS-003',
      title: 'Rak Display Kayu',
      requestType: 'Pengadaan Aset',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 9),
      notes: '',
      assets: const [
        _AsetItem(
          name: 'Rak Display',
          category: 'Furniture',
          brand: 'Custom',
          model: '-',
          spec: 'Kayu jati, 3 susun',
          qty: 2,
          estPrice: 800000,
        ),
      ],
      vendor: const _Vendor(name: 'UD Mebel Makmur'),
      payment: const _Payment(method: 'E-Wallet', type: 'Termin', purchaseDate: null),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(autoAdjust: true, location: 'Toko Depan'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Owner', status: 'Ditolak'),
    ),
    _AsetFormItem(
      id: 'AS-004',
      title: 'Mesin Press Cup',
      requestType: 'Pengadaan Aset',
      priority: 'Mendesak',
      requestDate: DateTime(2025, 1, 10),
      notes: 'Untuk kecepatan produksi cup',
      assets: const [
        _AsetItem(
          name: 'Cup Sealer',
          category: 'Peralatan',
          brand: 'Powerpack',
          model: 'CS-300',
          spec: 'Automatic, 300W',
          qty: 1,
          estPrice: 1500000,
        ),
      ],
      vendor: const _Vendor(name: 'Toko Mesin Jaya'),
      payment: _Payment(method: 'Transfer', type: 'Di muka', purchaseDate: DateTime(2025, 1, 11)),
      completion: const _Completion(proofs: ['foto_terima_mesin.jpg']),
      inventory: const _Inventory(autoAdjust: true, location: 'Produksi'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
  ];

  // Hitung status tampilan sesuai alur aset:
  // - Menunggu (default setelah submit)
  // - Jika Disetujui:
  //    - Belum purchase/proof -> Ada di Proses
  //    - Sudah purchaseDate/proofs -> Selesai
  // - Ditolak -> final
  String _computedStatus(_AsetFormItem e) {
    final hasProof = e.completion.proofs.isNotEmpty;
    final hasPurchased = e.payment.purchaseDate != null;

    if (e.approval.status == 'Ditolak') return 'Ditolak';
    if (e.approval.status == 'Menunggu') return 'Menunggu';

    // Disetujui:
    if (hasProof || hasPurchased) return 'Selesai';
    return 'Ada di Proses';
  }

  List<_AsetFormItem> get _filtered {
    return _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          e.requestType.toLowerCase().contains(q) ||
          e.submittedBy.name.toLowerCase().contains(q) ||
          e.assets.any((a) =>
              a.name.toLowerCase().contains(q) ||
              a.brand.toLowerCase().contains(q) ||
              a.model.toLowerCase().contains(q));

      final statusView = _computedStatus(e);
      final matchS = _statusFilter == 'Semua' || statusView == _statusFilter;
      return matchQ && matchS;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Aset'),
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
                  hintText: 'Cari ID / judul / tipe / pengaju / brand / model…',
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
                  const SizedBox(width: 8),
                  _statusChip('Ada di Proses'),
                  const SizedBox(width: 8),
                  _statusChip('Selesai'),
                ],
              ),
            ),

            // List (detail)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _AsetFormDetailCard(
                  item: _filtered[i],
                  statusView: _computedStatus(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB: Buat Pengajuan Aset
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 240,
        height: 56,
        child: FloatingActionButton.extended(
          heroTag: 'buatFormAset',
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Pengajuan Aset', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateFormAsetPage(
                  isAdmin: false, // kalau user admin, ubah ke true
                  currentUserName: 'Rafi Rahman',
                  currentUserEmail: 'rafi@example.com',
                ),
              ),
            );
            if (mounted) setState(() {}); // TODO: fetch ulang dari API
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
/// CARD DETAIL ASET
/// ===============================================================
class _AsetFormDetailCard extends StatelessWidget {
  const _AsetFormDetailCard({required this.item, required this.statusView});
  final _AsetFormItem item;
  final String statusView;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String s) {
    switch (s) {
      case 'Selesai':
      case 'Disetujui':
        return const Color(0xFF2E7D32);
      case 'Ditolak':
        return const Color(0xFFC62828);
      case 'Ada di Proses':
      case 'Menunggu':
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
              // Header judul + status + (opsional total estimasi)
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
                        if (statusView == 'Selesai') const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                        if (statusView == 'Selesai') const SizedBox(width: 6),
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
                  if (item.assets.isNotEmpty)
                    Text(
                      _formatCurrency(item.assets
                          .map((e) => (e.estPrice ?? 0) * e.qty)
                          .fold<int>(0, (a, b) => a + b)),
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

              // ===== Detail Aset =====
              _SectionCard(
                title: 'Detail Aset',
                subtitle: 'Nama, kategori, merek, model, spesifikasi, qty, estimasi harga',
                child: Column(
                  children: [
                    for (final it in item.assets) _asetRow(it),
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
                      ('Status Approval', item.approval.status),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded, size: 18, color: kMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.inventory.autoAdjust
                                ? 'Auto tambah ke inventori saat selesai'
                                : 'Tidak auto tambah ke inventori',
                            style: const TextStyle(color: kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _kvRow('Lokasi/Departemen', item.inventory.location),
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
                    const Text('Lampiran / Bukti', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _asetRow(_AsetItem it) {
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
            ('Merek', it.brand.isEmpty ? '—' : it.brand),
            ('Model/Tipe', it.model.isEmpty ? '—' : it.model),
            ('Spesifikasi', it.spec.isEmpty ? '—' : it.spec),
            ('Qty', '${it.qty}'),
            ('Estimasi Harga', it.estPrice == null ? '—' : _formatCurrency(it.estPrice!)),
          ]),
        ],
      ),
    );
  }

  Widget _kvGrid(List<(String, String)> pairs) {
    // grid 2 kolom, responsif
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
/// REUSABLE SECTION CARD (sama gaya dengan form)
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
/// MODEL DATA (mirror CreateFormAsetPage)
/// ===============================================================
class _AsetFormItem {
  final String id;
  final String title;
  final DateTime requestDate;
  final String requestType; // "Pengadaan Aset"
  final String priority;    // 'Normal'/'Mendesak'
  final String notes;

  final List<_AsetItem> assets;
  final _Vendor vendor;

  final _Payment payment;
  final _Completion completion;

  final _Inventory inventory;
  final _Person submittedBy;
  final _Approval approval;

  const _AsetFormItem({
    required this.id,
    required this.title,
    required this.requestDate,
    required this.requestType,
    required this.priority,
    required this.notes,
    required this.assets,
    required this.vendor,
    required this.payment,
    required this.completion,
    required this.inventory,
    required this.submittedBy,
    required this.approval,
  });
}

class _AsetItem {
  final String name;
  final String category;
  final String brand;
  final String model;
  final String spec;
  final int qty;
  final int? estPrice; // per unit
  const _AsetItem({
    required this.name,
    required this.category,
    required this.brand,
    required this.model,
    required this.spec,
    required this.qty,
    this.estPrice,
  });
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
  final List<String> proofs; // file bukti (foto/faktur/serah-terima)
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
