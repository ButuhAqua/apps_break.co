import 'package:flutter/material.dart';

class CreateFormPemakaiBahanPage extends StatefulWidget {
  const CreateFormPemakaiBahanPage({
    super.key,
    this.isAdmin = false,
    this.currentUserName = 'User',
    this.currentUserEmail = 'user@example.com',
  });

  final bool isAdmin;
  final String currentUserName;
  final String currentUserEmail;

  @override
  State<CreateFormPemakaiBahanPage> createState() => _CreateFormPemakaiBahanPageState();
}

class _CreateFormPemakaiBahanPageState extends State<CreateFormPemakaiBahanPage> {
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  final _formKey = GlobalKey<FormState>();

  // Identitas Penggunaan
  final _judulC = TextEditingController();
  final _catatanC = TextEditingController();
  final _shiftC = TextEditingController(); // Opsional: shift/line produksi
  final _noProduksiC = TextEditingController(); // Opsional: No. batch / WO
  DateTime _tanggal = DateTime.now();

  // Items (yang dipakai dari stok)
  final List<_ItemRowData> _items = [ _ItemRowData() ];

  // Penyelesaian (admin): tanggal pakai & bukti
  DateTime? _tanggalPakai;    // Tanggal realisasi pemakaian (oleh admin)
  final List<String> _proofs = [];

  // Pelaku & Persetujuan
  String _calonReviewer = 'Atasan A';
  String _status = 'Menunggu'; // Menunggu / Disetujui / Ditolak (approval)
  bool _autoAdjust = true;     // Saat Selesai -> stok berkurang otomatis
  String _lokasi = 'Basecamp';

  @override
  void dispose() {
    _judulC.dispose();
    _catatanC.dispose();
    _shiftC.dispose();
    _noProduksiC.dispose();
    for (final it in _items) it.dispose();
    super.dispose();
  }

  // Pickers
  Future<void> _pickTanggalForm() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pickTanggalPakai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPakai ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggalPakai = picked);
  }

  // Items ops
  void _addItem() => setState(() => _items.add(_ItemRowData()));
  void _removeItem(int i) { if (_items.length > 1) setState(() => _items.removeAt(i)); }

  // Placeholder upload
  void _addProofFromCamera() {
    if (!widget.isAdmin) return;
    setState(() => _proofs.add('camera_${_proofs.length + 1}.jpg'));
  }
  void _addProofFromGallery() {
    if (!widget.isAdmin) return;
    setState(() => _proofs.add('gallery_${_proofs.length + 1}.jpg'));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.any((it) =>
      it.nameC.text.trim().isEmpty ||
      it.uomC.text.trim().isEmpty ||
      (double.tryParse(it.qtyC.text.trim().replaceAll(',', '.')) ?? 0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi item: nama, satuan, dan qty > 0')),
      );
      return;
    }

    final payload = {
      "title": _judulC.text.trim(),
      "usage_date_planned": _fmtDate(_tanggal),
      "notes": _catatanC.text.trim(),
      "shift": _shiftC.text.trim(),
      "production_ref": _noProduksiC.text.trim(), // nomor batch/WO opsional
      "items_used": _items.map((it) => {
        "name": it.nameC.text.trim(),
        "category": it.category,
        "uom": it.uomC.text.trim(),
        "qty": double.tryParse(it.qtyC.text.trim().replaceAll(',', '.')) ?? 0.0,
      }).toList(),

      // Penyelesaian (admin): bukti & tanggal pakai aktual
      "completion": widget.isAdmin ? {
        "proofs": _proofs,
        "used_at": _tanggalPakai == null ? null : _fmtDate(_tanggalPakai!),
      } : null,

      "inventory": {
        "auto_adjust_on_done": _autoAdjust, // jika selesai -> stok berkurang
        "location": _lokasi,
      },
      "submitted_by": {"name": widget.currentUserName, "email": widget.currentUserEmail},
      "approval": {"reviewer": _calonReviewer, "status": _status},
      "form_type": "pemakaian_bahan",
    };

    // TODO: kirim payload ke backend
    // debugPrint(payload.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan pemakaian disimpan.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Pemakaian Bahan'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== IDENTITAS ==========
                _SectionCard(
                  title: 'Identitas Pemakaian',
                  child: Column(children: [
                    _textField(
                      label: 'Judul Pemakaian',
                      controller: _judulC,
                      validator: (v) => (v == null || v.trim().length < 5) ? 'Minimal 5 karakter' : null,
                    ),
                    const SizedBox(height: 12),
                    _dateField(label: 'Tanggal Rencana Pakai', date: _tanggal, onPick: _pickTanggalForm),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Shift / Line Produksi (opsional)', controller: _shiftC)),
                        const SizedBox(width: 12),
                        Expanded(child: _textField(label: 'No. Produksi / Batch (opsional)', controller: _noProduksiC)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _textField(label: 'Catatan (opsional)', controller: _catatanC, maxLines: 3),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== ITEM DIPAKAI ==========
                _SectionCard(
                  title: 'Item Dipakai',
                  subtitle: 'Nama, kategori, satuan, dan kuantitas yang diambil dari stok',
                  action: TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded, color: kPrimary),
                    label: const Text('Tambah Item', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                  ),
                  child: Column(
                    children: List.generate(_items.length, (i) => Padding(
                      padding: EdgeInsets.only(bottom: i == _items.length - 1 ? 0 : 12),
                      child: _ItemRow(
                        data: _items[i],
                        onRemove: _items.length > 1 ? () => _removeItem(i) : null,
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 16),

                // ========== PELAKU & PERSETUJUAN ==========
                _SectionCard(
                  title: 'Pelaku & Persetujuan',
                  child: Column(children: [
                    _readonlyTile(
                      title: 'Diajukan oleh',
                      value: '${widget.currentUserName} • ${widget.currentUserEmail}',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: _dropdown(
                            label: 'Reviewer/Atasan',
                            value: _calonReviewer,
                            items: const ['Atasan A','Atasan B','Owner'],
                            onChanged: (v) => setState(() => _calonReviewer = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _dropdown(
                            label: 'Status Approval',
                            value: _status,
                            items: const ['Menunggu','Disetujui','Ditolak'],
                            onChanged: null,
                            enabled: false, // user tidak bisa ubah
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Kurangi stok otomatis saat status Selesai'),
                      value: _autoAdjust,
                      onChanged: (v) => setState(() => _autoAdjust = v),
                    ),
                    const SizedBox(height: 8),
                    _textField(
                      label: 'Lokasi/Gudang',
                      initialValue: _lokasi,
                      onChanged: (v) => _lokasi = v,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== PENYELESAIAN (ADMIN) ==========
                _SectionCard(
                  title: 'Penyelesaian (Admin)',
                  subtitle: widget.isAdmin ? 'Isi setelah pemakaian dilakukan' : 'Hanya admin yang dapat mengisi',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _dateField(
                        label: 'Tanggal Pakai Aktual',
                        date: _tanggalPakai,
                        onPick: widget.isAdmin ? _pickTanggalPakai : null,
                        enabled: widget.isAdmin,
                      ),
                      const SizedBox(height: 12),
                      const Text('Bukti Pemakaian (foto/nota)'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _proofs.isEmpty
                            ? [const Text('Belum ada bukti', style: TextStyle(color: kMuted))]
                            : _proofs
                                .map((f) => Chip(
                                      label: Text(f),
                                      onDeleted: widget.isAdmin
                                          ? () => setState(() => _proofs.remove(f))
                                          : null,
                                    ))
                                .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.isAdmin ? _addProofFromCamera : null,
                            icon: const Icon(Icons.photo_camera_rounded),
                            label: const Text('Kamera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isAdmin ? kPrimary : Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: widget.isAdmin ? _addProofFromGallery : null,
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('Galeri'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ========== SUBMIT ==========
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    child: const Text('Simpan Pengajuan Pemakaian'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helpers UI =====
  Widget _textField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      decoration: _dec(label),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: enabled ? onChanged : null,
      decoration: _dec(label),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback? onPick,
    bool enabled = true,
  }) {
    final text = date == null ? '—' : _fmtDate(date);
    return InkWell(
      onTap: (enabled && onPick != null) ? onPick : null,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _dec(label),
        child: Row(children: [
          const Icon(Icons.date_range_rounded, size: 18, color: kMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (enabled) const Icon(Icons.expand_more_rounded, color: kMuted),
        ]),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.2)),
  );

  Widget _readonlyTile({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Text(title, style: const TextStyle(color: kMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700, color: kText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ======================== UI PIECES ==============================

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kText)),
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
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

class _ItemRowData {
  final nameC = TextEditingController();
  final uomC = TextEditingController();
  final qtyC = TextEditingController();
  String category = 'Bahan Baku';

  void dispose() {
    nameC.dispose();
    uomC.dispose();
    qtyC.dispose();
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.data, this.onRemove});
  final _ItemRowData data;
  final VoidCallback? onRemove;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: _tf('Nama Item', data.nameC)),
            const SizedBox(width: 12),
            Flexible(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: data.category,
                items: const [
                  DropdownMenuItem(value: 'Bahan Baku', child: Text('Bahan Baku')),
                  DropdownMenuItem(value: 'Kemasan', child: Text('Kemasan')),
                  DropdownMenuItem(value: 'Perlengkapan', child: Text('Perlengkapan')),
                  DropdownMenuItem(value: 'Operasional', child: Text('Operasional')),
                  DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                ],
                onChanged: (v) => data.category = v ?? data.category,
                decoration: _dec('Kategori'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Flexible(child: _tf('Satuan (UoM)', data.uomC)),
            const SizedBox(width: 12),
            Flexible(
              child: TextFormField(
                controller: data.qtyC,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _dec('Qty Pakai'),
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, color: kPrimary),
                tooltip: 'Hapus item',
              ),
            ],
          ],
        ),
      ]),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.2)),
  );

  Widget _tf(String label, TextEditingController c) =>
      TextFormField(controller: c, decoration: _dec(label));
}
