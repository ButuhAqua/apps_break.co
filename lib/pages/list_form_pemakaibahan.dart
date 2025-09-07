import 'package:flutter/material.dart';

import 'create_form_pemakaibahan.dart';

/// ===============================================================
/// LIST FORM PEMAKAIAN BAHAN (detail mirror dari form)
/// Alur status tampilan:
/// - Jika ada completion.usedAt atau proofs -> "Selesai"
/// - Else jika approval.status == "Disetujui" -> "Ada di Proses"
/// - Else jika approval.status == "Ditolak" -> "Ditolak"
/// - Else -> "Menunggu"
/// ===============================================================
class ListFormPemakaiBahanPage extends StatefulWidget {
  const ListFormPemakaiBahanPage({super.key});

  @override
  State<ListFormPemakaiBahanPage> createState() => _ListFormPemakaiBahanPageState();
}

class _ListFormPemakaiBahanPageState extends State<ListFormPemakaiBahanPage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  String _query = '';
  String _statusFilter = 'Semua';

  final List<_UsageForm> _data = [
    _UsageForm(
      id: 'PB-001',
      title: 'Pakai Biji Kopi utk Batch #2025-01',
      plannedDate: DateTime(2025, 1, 8),
      notes: 'Espresso base harian',
      shift: 'Pagi',
      productionRef: 'BATCH-2025-01',
      items: const [
        _UsageItem(name: 'Biji Kopi', category: 'Bahan Baku', uom: 'kg', qty: 2.5),
        _UsageItem(name: 'Gula Aren', category: 'Bahan Baku', uom: 'kg', qty: 1),
      ],
      completion: const _Completion(usedAt: null, proofs: []),
      inventory: const _Inventory(autoAdjustOnDone: true, location: 'Gudang'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
    _UsageForm(
      id: 'PB-002',
      title: 'Cup 12oz untuk Produksi Cold Brew',
      plannedDate: DateTime(2025, 1, 9),
      notes: 'Packing 200 botol',
      shift: 'Siang',
      productionRef: 'CB-200',
      items: const [
        _UsageItem(name: 'Cup 12oz', category: 'Kemasan', uom: 'pcs', qty: 200),
      ],
      completion: _Completion(usedAt: DateTime(2025, 1, 9), proofs: const ['foto_rak_1.jpg']),
      inventory: const _Inventory(autoAdjustOnDone: true, location: 'Bar'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan A', status: 'Disetujui'),
    ),
    _UsageForm(
      id: 'PB-003',
      title: 'Susu UHT untuk Latte',
      plannedDate: DateTime(2025, 1, 10),
      notes: '',
      shift: 'Malam',
      productionRef: 'LATTE-01',
      items: const [
        _UsageItem(name: 'Susu UHT', category: 'Bahan Baku', uom: 'dus', qty: 1),
      ],
      completion: const _Completion(usedAt: null, proofs: []),
      inventory: const _Inventory(autoAdjustOnDone: true, location: 'Basecamp'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Atasan B', status: 'Ditolak'),
    ),
    _UsageForm(
      id: 'PB-004',
      title: 'Gula Aren untuk Signature',
      plannedDate: DateTime(2025, 1, 11),
      notes: 'Signature brown sugar',
      shift: 'Pagi',
      productionRef: '',
      items: const [
        _UsageItem(name: 'Gula Aren', category: 'Bahan Baku', uom: 'kg', qty: 3),
      ],
      completion: const _Completion(usedAt: null, proofs: []),
      inventory: const _Inventory(autoAdjustOnDone: false, location: 'Gudang'),
      submittedBy: const _Person(name: 'Rafi Rahman', email: 'rafi@example.com'),
      approval: const _Approval(reviewer: 'Owner', status: 'Menunggu'),
    ),
  ];

  // Hitung status tampilan
  String _statusViewOf(_UsageForm e) {
    final isDone = (e.completion.usedAt != null) || (e.completion.proofs.isNotEmpty);
    if (isDone) return 'Selesai';
    if (e.approval.status == 'Disetujui') return 'Ada di Proses';
    if (e.approval.status == 'Ditolak') return 'Ditolak';
    return 'Menunggu';
    // Alur: Menunggu -> (approve) Ada di Proses -> (bukti/tanggal pakai) Selesai; Ditolak -> selesai.
  }

  List<_UsageForm> get _filtered {
    return _data.where((e) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          (e.productionRef ?? '').toLowerCase().contains(q) ||
          e.submittedBy.name.toLowerCase().contains(q);

      final statusView = _statusViewOf(e);
      final matchS = _statusFilter == 'Semua' || statusView == _statusFilter;

      return matchQ && matchS;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemakaian Bahan'),
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
                  hintText: 'Cari ID / judul / no. produksi / pengaju…',
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
                  _statusChip('Ada di Proses'),
                  const SizedBox(width: 8),
                  _statusChip('Selesai'),
                  const SizedBox(width: 8),
                  _statusChip('Ditolak'),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _UsageDetailCard(
                  item: _filtered[i],
                  statusView: _statusViewOf(_filtered[i]),
                ),
              ),
            ),
          ],
        ),
      ),

      // Tombol buat pengajuan
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 240,
        height: 56,
        child: FloatingActionButton.extended(
          heroTag: 'buatPemakaian',
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat Pemakaian Bahan', style: TextStyle(fontWeight: FontWeight.w700)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateFormPemakaiBahanPage(
                  isAdmin: false,
                  currentUserName: 'Rafi Rahman',
                  currentUserEmail: 'rafi@example.com',
                ),
              ),
            );
            if (mounted) setState(() {}); // TODO: refresh dari API
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
        color: selected ? Colors.white : kMuted,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      showCheckmark: false,
      avatar: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: selected ? kPrimary : kBorder),
      ),
      backgroundColor: selected ? kPrimary : Colors.white,
    );
  }
}

/// ===============================================================
/// CARD DETAIL
/// ===============================================================
class _UsageDetailCard extends StatelessWidget {
  const _UsageDetailCard({required this.item, required this.statusView});
  final _UsageForm item;
  final String statusView;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String s) {
    switch (s) {
      case 'Selesai':
        return const Color(0xFF2E7D32);
      case 'Ditolak':
        return const Color(0xFFC62828);
      case 'Ada di Proses':
        return const Color(0xFFEF6C00);
      case 'Menunggu':
      default:
        return const Color(0xFF455A64);
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
                  Text(_fmtDateLong(item.plannedDate), style: const TextStyle(color: kMuted, fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.confirmation_number_rounded, size: 14, color: kMuted),
                  const SizedBox(width: 6),
                  Text(item.id, style: const TextStyle(color: kMuted, fontSize: 13)),
                  const Spacer(),
                  if ((item.productionRef ?? '').isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.tag_rounded, size: 14, color: kMuted),
                        const SizedBox(width: 6),
                        Text(item.productionRef!, style: const TextStyle(color: kMuted, fontSize: 13)),
                      ],
                    ),
                ],
              ),
              if ((item.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.notes!, style: const TextStyle(color: kText)),
              ],
              const SizedBox(height: 14),

              // Identitas
              _SectionCard(
                title: 'Identitas Pemakaian',
                child: _kvGrid([
                  ('Tanggal Rencana', _fmtDate(item.plannedDate)),
                  ('Shift/Line', item.shift?.isEmpty == true ? '—' : (item.shift ?? '—')),
                  ('No. Produksi/Batch', item.productionRef?.isEmpty == true ? '—' : (item.productionRef ?? '—')),
                ]),
              ),
              const SizedBox(height: 12),

              // Item Dipakai
              _SectionCard(
                title: 'Item Dipakai',
                subtitle: 'Nama, kategori, satuan, dan kuantitas yang diambil dari stok',
                child: Column(
                  children: [
                    for (final it in item.items) _itemRow(it),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Pelaku & Persetujuan
              _SectionCard(
                title: 'Pelaku & Persetujuan',
                child: Column(
                  children: [
                    _kvRow('Diajukan oleh', '${item.submittedBy.name} • ${item.submittedBy.email}'),
                    const SizedBox(height: 8),
                    _kvGrid([
                      ('Reviewer/Atasan', item.approval.reviewer),
                      ('Status Approval', item.approval.status),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded, size: 18, color: kMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.inventory.autoAdjustOnDone
                                ? 'Kurangi stok otomatis saat status Selesai'
                                : 'Tidak mengurangi stok otomatis',
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

              // Penyelesaian
              _SectionCard(
                title: 'Penyelesaian',
                subtitle: 'Diisi saat pemakaian selesai',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kvGrid([
                      ('Tanggal Pakai Aktual', item.completion.usedAt == null ? '—' : _fmtDate(item.completion.usedAt!)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Bukti Pemakaian'),
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

  Widget _itemRow(_UsageItem it) {
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
            ('Qty Pakai', _fmtQty(it.qty)),
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

  static String _fmtQty(num v) {
    // Hilangkan .0 kalau bilangan bulat
    if (v % 1 == 0) return v.toInt().toString();
    return v.toString().replaceAll('.', ','); // tampilan koma opsional
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _fmtDateLong(DateTime d) {
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
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
class _UsageForm {
  final String id;
  final String title;
  final DateTime plannedDate;
  final String? notes;

  final String? shift;
  final String? productionRef;

  final List<_UsageItem> items;

  final _Completion completion; // usedAt + proofs
  final _Inventory inventory;   // auto adjust & lokasi
  final _Person submittedBy;
  final _Approval approval;

  const _UsageForm({
    required this.id,
    required this.title,
    required this.plannedDate,
    required this.notes,
    required this.shift,
    required this.productionRef,
    required this.items,
    required this.completion,
    required this.inventory,
    required this.submittedBy,
    required this.approval,
  });
}

class _UsageItem {
  final String name;
  final String category;
  final String uom;
  final num qty; // pakai num agar bisa desimal

  const _UsageItem({
    required this.name,
    required this.category,
    required this.uom,
    required this.qty,
  });
}

class _Completion {
  final DateTime? usedAt;
  final List<String> proofs;
  const _Completion({required this.usedAt, required this.proofs});
}

class _Inventory {
  final bool autoAdjustOnDone;
  final String location;
  const _Inventory({required this.autoAdjustOnDone, required this.location});
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
