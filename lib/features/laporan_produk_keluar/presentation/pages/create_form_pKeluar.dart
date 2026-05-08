import 'package:flutter/material.dart';

class CreateFormProdukKeluarPage extends StatefulWidget {
  const CreateFormProdukKeluarPage({
    super.key,
    this.isAdmin = false,
    this.currentUserName = 'User',
    this.currentUserEmail = 'user@example.com',
  });

  final bool isAdmin;
  final String currentUserName;
  final String currentUserEmail;

  @override
  State<CreateFormProdukKeluarPage> createState() => _CreateFormProdukKeluarPageState();
}

class _CreateFormProdukKeluarPageState extends State<CreateFormProdukKeluarPage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  final _formKey = GlobalKey<FormState>();

  // Identitas
  final _judulC = TextEditingController(text: 'Produk Dibawa Keliling');
  final _catatanC = TextEditingController();
  DateTime _tanggal = DateTime.now();

  // Lokasi/gerobak
  String _lokasiSumber = 'Basecamp';
  String _gerobak = 'Gerobak A'; // tujuan operasional

  // Item dibawa
  final List<_KeluarItemRowData> _items = [ _KeluarItemRowData() ];

  // Lampiran bukti (dummy)
  final List<String> _proofs = [];

  // Persetujuan
  String _calonReviewer = 'Atasan A';
  String _status = 'Menunggu';
  bool _autoAdjust = true; // jika disetujui: stok - dari sumber & + ke gerobak

  @override
  void dispose() {
    _judulC.dispose();
    _catatanC.dispose();
    for (final it in _items) it.dispose();
    super.dispose();
  }

  // Pickers
  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  // Items ops
  void _addItem() => setState(() => _items.add(_KeluarItemRowData()));
  void _removeItem(int i) { if (_items.length > 1) setState(() => _items.removeAt(i)); }

  // Upload dummy
  void _addProofFromCamera() => setState(() => _proofs.add('camera_${_proofs.length + 1}.jpg'));
  void _addProofFromGallery() => setState(() => _proofs.add('gallery_${_proofs.length + 1}.jpg'));

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_items.any((it) {
      final qty = double.tryParse(it.qtyC.text.trim().replaceAll(',', '.')) ?? 0.0;
      final nameOk = it.nameC.text.trim().isNotEmpty;
      final uomOk  = it.uomC.text.trim().isNotEmpty;
      return !nameOk || !uomOk || qty <= 0;
    })) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi item: nama, satuan, dan qty > 0')),
      );
      return;
    }

    final payload = {
      "form_type": "produk_keluar_keliling",
      "title": _judulC.text.trim(),
      "issue_date": _fmtDate(_tanggal),
      "notes": _catatanC.text.trim(),
      "source_location": _lokasiSumber, // stok berkurang dari sini
      "target_cart": _gerobak,          // berpindah ke gerobak ini
      "items": _items.map((it) => {
        "name": it.nameC.text.trim(),
        "sku": it.skuC.text.trim(),
        "uom": it.uomC.text.trim(),
        "qty_out": double.tryParse(it.qtyC.text.trim().replaceAll(',', '.')) ?? 0.0,
      }).toList(),
      "proofs": _proofs,
      "inventory": {
        "auto_adjust_on_approve": _autoAdjust, // jika disetujui -> -sumber, +gerobak
      },
      "submitted_by": {
        "name": widget.currentUserName,
        "email": widget.currentUserEmail,
      },
      "approval": {
        "reviewer": _calonReviewer,
        "status": _status,
      },
    };

    // TODO: kirim payload ke backend
    // debugPrint(payload.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan produk keluar disimpan.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Keluar (Berangkat)'),
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
                  title: 'Identitas',
                  child: Column(
                    children: [
                      _textField(
                        label: 'Judul',
                        controller: _judulC,
                        validator: (v) => (v == null || v.trim().length < 5) ? 'Minimal 5 karakter' : null,
                      ),
                      const SizedBox(height: 12),
                      _dateField(label: 'Tanggal Berangkat', date: _tanggal, onPick: _pickTanggal),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _dropdown(
                              label: 'Lokasi Sumber',
                              value: _lokasiSumber,
                              items: const ['Basecamp','Gudang','Outlet'],
                              onChanged: (v) => setState(() => _lokasiSumber = v ?? _lokasiSumber),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dropdown(
                              label: 'Gerobak Tujuan',
                              value: _gerobak,
                              items: const ['Gerobak A','Gerobak B'],
                              onChanged: (v) => setState(() => _gerobak = v ?? _gerobak),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _textField(label: 'Catatan (opsional)', controller: _catatanC, maxLines: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ========== ITEM ==========
                _SectionCard(
                  title: 'Item Dibawa',
                  subtitle: 'Nama, SKU, satuan, dan qty dibawa',
                  action: TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded, color: kPrimary),
                    label: const Text('Tambah Item', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                  ),
                  child: Column(
                    children: [
                      ...List.generate(_items.length, (i) => Padding(
                        padding: EdgeInsets.only(bottom: i == _items.length - 1 ? 0 : 12),
                        child: _KeluarItemRow(
                          data: _items[i],
                          onRemove: _items.length > 1 ? () => _removeItem(i) : null,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ========== LAMPIRAN ==========
                _SectionCard(
                  title: 'Lampiran Bukti (opsional)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _proofs.isEmpty
                          ? [const Text('Belum ada bukti', style: TextStyle(color: kMuted))]
                          : _proofs.map((f) => Chip(label: Text(f), onDeleted: () => setState(() => _proofs.remove(f)))).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addProofFromCamera,
                            icon: const Icon(Icons.photo_camera_rounded),
                            label: const Text('Kamera'),
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _addProofFromGallery,
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('Galeri'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ========== PERSETUJUAN ==========
                _SectionCard(
                  title: 'Persetujuan & Inventory',
                  child: Column(
                    children: [
                      _readonlyTile(
                        title: 'Diajukan oleh',
                        value: '${widget.currentUserName} • ${widget.currentUserEmail}',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _dropdown(
                              label: 'Reviewer/Atasan',
                              value: _calonReviewer,
                              items: const ['Atasan A','Atasan B','Owner'],
                              onChanged: (v) => setState(() => _calonReviewer = v ?? _calonReviewer),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dropdown(
                              label: 'Status Approval',
                              value: _status,
                              items: const ['Menunggu','Disetujui','Ditolak'],
                              onChanged: null,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Sesuaikan stok otomatis saat disetujui'),
                        value: _autoAdjust,
                        onChanged: (v) => setState(() => _autoAdjust = v),
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
                      backgroundColor: kPrimary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    child: const Text('Simpan Produk Keluar'),
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

class _KeluarItemRowData {
  final nameC = TextEditingController();
  final skuC = TextEditingController();
  final uomC = TextEditingController();
  final qtyC = TextEditingController(); // qty dibawa

  void dispose() {
    nameC.dispose();
    skuC.dispose();
    uomC.dispose();
    qtyC.dispose();
  }
}

class _KeluarItemRow extends StatelessWidget {
  const _KeluarItemRow({required this.data, this.onRemove});
  final _KeluarItemRowData data;
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
            Flexible(child: _tf('Nama Produk', data.nameC)),
            const SizedBox(width: 12),
            Flexible(child: _tf('SKU (opsional)', data.skuC)),
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
                decoration: _dec('Qty Dibawa'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim().replaceAll(',', '.')) ?? 0;
                  if (n <= 0) return 'Harus > 0';
                  return null;
                },
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
      TextFormField(controller: c, decoration: _dec(label), validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null);
}
