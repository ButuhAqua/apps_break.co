import 'package:flutter/material.dart';

import 'create_form_maintenance.dart';

/// ===============================================================
/// LIST PENGAJUAN MAINTENANCE (detail mirroring CreateFormMaintenancePage)
/// ===============================================================
class ListFormMaintenancePage extends StatefulWidget {
  const ListFormMaintenancePage({super.key});

  @override
  State<ListFormMaintenancePage> createState() => _ListFormMaintenancePageState();
}

class _ListFormMaintenancePageState extends State<ListFormMaintenancePage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  String _query = '';
  String _statusFilter = 'Semua';

  // ===== Dummy data =====
  final List<_MaintFormItem> _data = [
    _MaintFormItem(
      id: 'MT-001',
      title: 'Service Cup Sealer',
      maintenanceType: 'Corrective',
      priority: 'Mendesak',
      requestDate: DateTime(2025, 1, 6),
      notes: 'Mesin tidak panas',
      asset: const _Asset(name: 'Cup Sealer', code: 'AST-001', location: 'Produksi'),
      issue: 'Elemen pemanas mati',
      actionPlan: 'Ganti elemen dan cek kabel',
      internalTech: false,
      preferredSchedule: DateTime(2025, 1, 7),
      parts: const [
        _Part(name: 'Elemen Pemanas', uom: 'pcs', qty: 1),
        _Part(name: 'Kabel Tahan Panas', uom: 'm', qty: 2),
      ],
      vendor: const _Vendor(name: 'Toko Mesin Jaya'),
      payment: const _Payment(method: 'Transfer', type: 'Di muka', serviceDate: null, actualCost: 0),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(partsAutoOut: true, location: 'Produksi'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
    _MaintFormItem(
      id: 'MT-002',
      title: 'Preventive Grinder Bulanan',
      maintenanceType: 'Preventive',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 5),
      notes: 'Bersihkan burr dan kalibrasi',
      asset: const _Asset(name: 'Grinder', code: 'AST-002', location: 'Bar'),
      issue: 'Jadwal rutin',
      actionPlan: 'Bongkar, bersihkan, kalibrasi',
      internalTech: true,
      preferredSchedule: DateTime(2025, 1, 8),
      parts: const [
        _Part(name: 'Grease Food Grade', uom: 'g', qty: 50),
      ],
      vendor: const _Vendor(name: ''),
      payment: const _Payment(method: 'Cash', type: 'Di muka', serviceDate: null, actualCost: 0),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(partsAutoOut: true, location: 'Bar'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan B', status: 'Menunggu'),
    ),
    _MaintFormItem(
      id: 'MT-003',
      title: 'Kalibrasi Timbangan',
      maintenanceType: 'Calibration',
      priority: 'Normal',
      requestDate: DateTime(2025, 1, 7),
      notes: '',
      asset: const _Asset(name: 'Timbangan Digital', code: 'AST-003', location: 'Bar'),
      issue: 'Akurasi melenceng 2g',
      actionPlan: 'Kalibrasi ulang',
      internalTech: false,
      preferredSchedule: DateTime(2025, 1, 10),
      parts: const [],
      vendor: const _Vendor(name: 'CV Kalibrasi Prima'),
      payment: const _Payment(method: 'E-Wallet', type: 'Termin', serviceDate: null, actualCost: 0),
      completion: const _Completion(proofs: []),
      inventory: const _Inventory(partsAutoOut: false, location: 'Bar'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Owner', status: 'Ditolak'),
    ),
    _MaintFormItem(
      id: 'MT-004',
      title: 'Perbaikan Freezer Tidak Dingin',
      maintenanceType: 'Corrective',
      priority: 'Mendesak',
      requestDate: DateTime(2025, 1, 8),
      notes: 'Untuk stok biji kopi',
      asset: const _Asset(name: 'Freezer 200L', code: 'AST-004', location: 'Gudang'),
      issue: 'Kompresor macet',
      actionPlan: 'Ganti kompresor + isi freon',
      internalTech: false,
      preferredSchedule: DateTime(2025, 1, 9),
      parts: const [
        _Part(name: 'Kompresor', uom: 'pcs', qty: 1),
        _Part(name: 'Freon R134a', uom: 'kg', qty: 0), // contoh qty salah -> di real backend validasi
      ],
      vendor: const _Vendor(name: 'Service Dingin Abadi'),
      payment: _Payment(method: 'Transfer', type: 'Di muka', serviceDate: DateTime(2025, 1, 10), actualCost: 900000),
      completion: const _Completion(proofs: ['foto_freezer_ok.jpg']),
      inventory: const _Inventory(partsAutoOut: true, location: 'Gudang'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
  ];

  // Status tampilan (mengikuti alur yang kamu mau):
  // Menunggu -> jika Disetujui:
  //   - belum ada serviceDate/proofs => Ada di Proses
  //   - sudah ada serviceDate/proofs => Selesai
  // Ditolak -> final
  String _computedStatus(_MaintFormItem e) {
    if (e.approval.status == 'Ditolak') return 'Ditolak';
    if (e.approval.status == 'Menunggu') return 'Menunggu';

    final done = (e.payment.serviceDate != null) || (e.completion.proofs.isNotEmpty);
    if (done) return 'Selesai';
    return 'Ada di Proses';
  }

  List<_MaintFormItem> get _filtered {
    return _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          e.maintenanceType.toLowerCase().contains(q) ||
          e.submittedBy.name.toLowerCase().contains(q) ||
          e.asset.name.toLowerCase().contains(q) ||
          e.asset.code.toLowerCase().contains(q) ||
          e.vendor.name.toLowerCase().contains(q);

      final statusView = _computedStatus(e);
      final matchS = _statusFilter == 'Semua' || statusView == _statusFilter;
      return matchQ && matchS;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Maintenance'),
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
                  hintText: 'Cari ID / judul / tipe / pengaju / aset / vendor…',
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

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _MaintDetailCard(
                  item: _filtered[i],
                  statusView: _computedStatus(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 260,
        height: 56,
        child: FloatingActionButton.extended(
          heroTag: 'buatFormMaintenance',
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Pengajuan Maintenance', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateFormMaintenancePage(
                  isAdmin: false, // ubah ke true untuk admin
                  currentUserName: 'Rafi Rahman',
                  currentUserEmail: 'rafi@example.com',
                ),
              ),
            );
            if (mounted) setState(() {}); // TODO: refresh data dari API
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
class _MaintDetailCard extends StatelessWidget {
  const _MaintDetailCard({required this.item, required this.statusView});
  final _MaintFormItem item;
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
              // Header judul + status
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
                  if (item.payment.actualCost > 0)
                    Text(
                      _formatCurrency(item.payment.actualCost),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kText),
                    ),
                ],
              ),
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.notes, style: const TextStyle(color: kText)),
              ],
              const SizedBox(height: 14),

              // ===== Identitas =====
              _SectionCard(
                title: 'Identitas',
                child: _kvGrid([
                  ('Jenis Maintenance', item.maintenanceType),
                  ('Prioritas', item.priority),
                  ('Tanggal Pengajuan', _formatDate(item.requestDate)),
                ]),
              ),
              const SizedBox(height: 12),

              // ===== Aset =====
              _SectionCard(
                title: 'Aset',
                child: _kvGrid([
                  ('Nama Aset', item.asset.name),
                  ('Kode Aset', item.asset.code.isEmpty ? '—' : item.asset.code),
                  ('Lokasi', item.asset.location),
                ]),
              ),
              const SizedBox(height: 12),

              // ===== Keluhan & Rencana =====
              _SectionCard(
                title: 'Keluhan & Rencana',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kvRow('Keluhan', item.issue.isEmpty ? '—' : item.issue),
                    const SizedBox(height: 8),
                    _kvRow('Rencana Tindakan', item.actionPlan.isEmpty ? '—' : item.actionPlan),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.engineering_rounded, size: 18, color: kMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.internalTech ? 'Teknisi internal' : 'Vendor eksternal',
                            style: const TextStyle(color: kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _kvRow('Jadwal Diinginkan',
                        item.preferredSchedule == null ? '—' : _formatDate(item.preferredSchedule!)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ===== Spare Parts =====
              _SectionCard(
                title: 'Spare Parts Dipakai',
                subtitle: 'Nama, satuan, dan kuantitas',
                child: Column(
                  children: item.parts.isEmpty
                      ? [const Align(alignment: Alignment.centerLeft, child: Text('Tidak ada part'))]
                      : item.parts.map(_partRow).toList(),
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
                        const Icon(Icons.inventory_outlined, size: 18, color: kMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.inventory.partsAutoOut
                                ? 'Part akan otomatis keluar stok saat Selesai'
                                : 'Part tidak otomatis keluar stok',
                            style: const TextStyle(color: kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _kvRow('Lokasi', item.inventory.location),
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
                      ('Tanggal Service', item.payment.serviceDate == null ? '—' : _formatDate(item.payment.serviceDate!)),
                      ('Biaya Aktual', item.payment.actualCost <= 0 ? '—' : _formatCurrency(item.payment.actualCost)),
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

  Widget _partRow(_Part p) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: _kvGrid([
        ('Nama Part', p.name),
        ('Satuan (UoM)', p.uom),
        ('Qty', p.qty.toString()),
      ]),
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
/// MODEL DATA
/// ===============================================================
class _MaintFormItem {
  final String id;
  final String title;
  final DateTime requestDate;
  final String maintenanceType; // Preventive/Corrective/Calibration/Installation
  final String priority;
  final String notes;

  final _Asset asset;

  final String issue;
  final String actionPlan;
  final bool internalTech;
  final DateTime? preferredSchedule;

  final List<_Part> parts;
  final _Vendor vendor;

  final _Payment payment;
  final _Completion completion;

  final _Inventory inventory;
  final _Person submittedBy;
  final _Approval approval;

  const _MaintFormItem({
    required this.id,
    required this.title,
    required this.requestDate,
    required this.maintenanceType,
    required this.priority,
    required this.notes,
    required this.asset,
    required this.issue,
    required this.actionPlan,
    required this.internalTech,
    required this.preferredSchedule,
    required this.parts,
    required this.vendor,
    required this.payment,
    required this.completion,
    required this.inventory,
    required this.submittedBy,
    required this.approval,
  });
}

class _Asset {
  final String name;
  final String code;
  final String location;
  const _Asset({required this.name, required this.code, required this.location});
}

class _Part {
  final String name;
  final String uom;
  final int qty;
  const _Part({required this.name, required this.uom, required this.qty});
}

class _Vendor {
  final String name;
  const _Vendor({required this.name});
}

class _Payment {
  final String method; // Cash / Transfer / E-Wallet
  final String type;   // Di muka / Termin
  final DateTime? serviceDate;
  final int actualCost;
  const _Payment({required this.method, required this.type, required this.serviceDate, required this.actualCost});
}

class _Completion {
  final List<String> proofs;
  const _Completion({required this.proofs});
}

class _Inventory {
  final bool partsAutoOut;
  final String location;
  const _Inventory({required this.partsAutoOut, required this.location});
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
