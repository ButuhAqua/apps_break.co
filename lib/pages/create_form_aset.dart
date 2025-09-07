import 'package:flutter/material.dart';

class CreateFormAsetPage extends StatefulWidget {
  const CreateFormAsetPage({
    super.key,
    this.isAdmin = false,
    this.currentUserName = 'User',
    this.currentUserEmail = 'user@example.com',
  });

  final bool isAdmin;
  final String currentUserName;
  final String currentUserEmail;

  @override
  State<CreateFormAsetPage> createState() => _CreateFormAsetPageState();
}

class _CreateFormAsetPageState extends State<CreateFormAsetPage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  final _formKey = GlobalKey<FormState>();

  // ========== IDENTITAS ==========
  final _judulC = TextEditingController();
  final _catatanC = TextEditingController();
  String _jenisPengajuan = 'Pengadaan Aset';
  String _prioritas = 'Normal';
  DateTime _tanggal = DateTime.now();

  // ========== ITEM ASET ==========
  final List<_AsetRowData> _items = [ _AsetRowData() ];

  // ========== VENDOR (ADMIN) ==========
  final _vendorNameC = TextEditingController();

  // ========== PEMBAYARAN (ADMIN) ==========
  String _metodePembayaran = 'Cash';
  String _jenisPembayaran = 'Di muka';
  DateTime? _tanggalBeli;

  // ========== PENYELESAIAN (ADMIN) ==========
  final List<String> _proofs = []; // misal: foto faktur/alat

  // ========== PELAKU & PERSETUJUAN ==========
  bool _autoAdjust = true; // saat selesai: otomatis masuk inventori/asset register
  String _lokasi = 'Basecamp';
  String _calonReviewer = 'Atasan A';
  String _status = 'Menunggu'; // default

  @override
  void dispose() {
    _judulC.dispose();
    _catatanC.dispose();
    _vendorNameC.dispose();
    for (final it in _items) it.dispose();
    super.dispose();
  }

  // ================= PICKERS =================
  Future<void> _pickDatePengajuan() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pickTanggalBeli() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalBeli ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggalBeli = picked);
  }

  // ================= ITEM HANDLERS =================
  void _addItem() => setState(() => _items.add(_AsetRowData()));
  void _removeItem(int i) { if (_items.length > 1) setState(() => _items.removeAt(i)); }

  // ================= PROOF PLACEHOLDER =================
  void _addProofFromCamera() {
    if (!widget.isAdmin) return;
    setState(() => _proofs.add('camera_${_proofs.length + 1}.jpg')); // TODO: integrasi image picker kamera
  }
  void _addProofFromGallery() {
    if (!widget.isAdmin) return;
    setState(() => _proofs.add('gallery_${_proofs.length + 1}.jpg')); // TODO: integrasi image picker galeri
  }

  // ================= SUBMIT =================
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Validasi item
    if (_items.any((it) =>
        it.nameC.text.trim().isEmpty ||
        it.category.isEmpty ||
        (int.tryParse(it.qtyC.text.trim()) ?? 0) <= 0 ||
        (int.tryParse(it.priceC.text.trim()) ?? 0) < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi item: nama, kategori, qty (>0), dan harga ≥ 0')),
      );
      return;
    }

    // Payload mirip struktur CreateFormPage, disesuaikan untuk aset
    final payload = {
      "title": _judulC.text.trim(),
      "request_type": _jenisPengajuan,          // "Pengadaan Aset"
      "priority": _prioritas,
      "request_date": _fmtDate(_tanggal),
      "notes": _catatanC.text.trim(),

      "assets": _items.map((it) => {
        "name": it.nameC.text.trim(),
        "category": it.category,
        "brand": it.brandC.text.trim(),
        "model": it.modelC.text.trim(),
        "spec": it.specC.text.trim(),
        "qty": int.tryParse(it.qtyC.text.trim()) ?? 0,
        "est_price": int.tryParse(it.priceC.text.trim()) ?? 0, // per unit (opsional)
      }).toList(),

      "vendor": widget.isAdmin ? {"name": _vendorNameC.text.trim()} : null,

      "payment": widget.isAdmin ? {
        "method": _metodePembayaran,             // Cash / Transfer / E-Wallet
        "type": _jenisPembayaran,                // Di muka / Termin
        "purchase_date": _tanggalBeli == null ? null : _fmtDate(_tanggalBeli!),
      } : null,

      "completion": widget.isAdmin ? {
        "proofs": _proofs,                       // foto bukti pembelian/serah terima
      } : null,

      // Saat Selesai, kalau auto_adjust=true → otomatis masuk asset register / inventori
      "inventory": {"auto_adjust": _autoAdjust, "location": _lokasi},

      "submitted_by": {"name": widget.currentUserName, "email": widget.currentUserEmail},
      "approval": {"reviewer": _calonReviewer, "status": _status}, // default Menunggu
    };

    // TODO: kirim payload ke backend
    // debugPrint(payload.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan aset disimpan.')),
    );
    Navigator.pop(context);
  }

  // ================= UI =================
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== IDENTITAS ==========
                _SectionCard(
                  title: 'Identitas Pengajuan',
                  child: Column(children: [
                    _textField(
                      label: 'Judul Pengajuan',
                      controller: _judulC,
                      validator: (v) => (v == null || v.trim().length < 5) ? 'Minimal 5 karakter' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: _dropdown(
                            label: 'Jenis Pengajuan',
                            value: _jenisPengajuan,
                            items: const ['Pengadaan Aset', 'Lainnya'],
                            onChanged: (v) => setState(() => _jenisPengajuan = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _dropdown(
                            label: 'Prioritas',
                            value: _prioritas,
                            items: const ['Normal','Mendesak'],
                            onChanged: (v) => setState(() => _prioritas = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dateField(label: 'Tanggal Pengajuan', date: _tanggal, onPick: _pickDatePengajuan),
                    const SizedBox(height: 12),
                    _textField(label: 'Catatan (opsional)', controller: _catatanC, maxLines: 3),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== ITEM ASET ==========
                _SectionCard(
                  title: 'Detail Aset',
                  subtitle: 'Nama, kategori, merek, model, spesifikasi, qty, dan estimasi harga',
                  action: TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded, color: kPrimary),
                    label: const Text('Tambah Aset', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                  ),
                  child: Column(
                    children: List.generate(_items.length, (i) => Padding(
                      padding: EdgeInsets.only(bottom: i == _items.length - 1 ? 0 : 12),
                      child: _AsetRow(
                        data: _items[i],
                        onRemove: _items.length > 1 ? () => _removeItem(i) : null,
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 16),

                // ========== VENDOR (ADMIN) ==========
                _SectionCard(
                  title: 'Vendor',
                  subtitle: widget.isAdmin ? null : 'Hanya admin yang dapat mengisi',
                  child: _textField(
                    label: 'Nama Vendor',
                    controller: _vendorNameC,
                    enabled: widget.isAdmin,
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
                            label: 'Calon Reviewer/Atasan',
                            value: _calonReviewer,
                            items: const ['Atasan A','Atasan B','Owner'],
                            onChanged: (v) => setState(() => _calonReviewer = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _dropdown(
                            label: 'Status',
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
                      title: const Text('Tambahkan otomatis ke inventori saat selesai'),
                      value: _autoAdjust,
                      onChanged: (v) => setState(() => _autoAdjust = v),
                    ),
                    const SizedBox(height: 8),
                    _textField(
                      label: 'Lokasi/Departemen',
                      initialValue: _lokasi,
                      onChanged: (v) => _lokasi = v,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== PEMBAYARAN + PENYELESAIAN (ADMIN) ==========
                _SectionCard(
                  title: 'Pembayaran & Penyelesaian',
                  subtitle: widget.isAdmin ? 'Diisi oleh admin' : 'Hanya admin yang dapat mengisi',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: _dropdown(
                              label: 'Metode Pembayaran',
                              value: _metodePembayaran,
                              items: const ['Cash','Transfer','E-Wallet'],
                              onChanged: widget.isAdmin ? (v) => setState(() => _metodePembayaran = v!) : null,
                              enabled: widget.isAdmin,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: _dropdown(
                              label: 'Pembayaran',
                              value: _jenisPembayaran,
                              items: const ['Di muka','Termin'],
                              onChanged: widget.isAdmin ? (v) => setState(() => _jenisPembayaran = v!) : null,
                              enabled: widget.isAdmin,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _dateField(
                        label: 'Tanggal Beli',
                        date: _tanggalBeli,
                        onPick: widget.isAdmin ? _pickTanggalBeli : null,
                        enabled: widget.isAdmin,
                      ),
                      const SizedBox(height: 12),
                      const Text('Lampiran / Bukti', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    child: const Text('Simpan Pengajuan Aset'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= Helpers UI =================
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

class _AsetRowData {
  final nameC = TextEditingController();
  final brandC = TextEditingController();
  final modelC = TextEditingController();
  final specC = TextEditingController();
  final qtyC = TextEditingController();
  final priceC = TextEditingController(); // estimasi harga per unit
  String category = 'Elektronik';

  void dispose() {
    nameC.dispose();
    brandC.dispose();
    modelC.dispose();
    specC.dispose();
    qtyC.dispose();
    priceC.dispose();
  }
}

class _AsetRow extends StatelessWidget {
  const _AsetRow({required this.data, this.onRemove});
  final _AsetRowData data;
  final VoidCallback? onRemove;

  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kBorder = Color(0xFFE0E0E0);
  static const Color kMuted = Color(0xFF616161);

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
            Flexible(child: _tf('Nama Aset', data.nameC, isRequired: true)),
            const SizedBox(width: 12),
            Flexible(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: data.category,
                items: const [
                  DropdownMenuItem(value: 'Elektronik', child: Text('Elektronik')),
                  DropdownMenuItem(value: 'Peralatan', child: Text('Peralatan')),
                  DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
                  DropdownMenuItem(value: 'Kendaraan', child: Text('Kendaraan')),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: _tf('Merek', data.brandC)),
            const SizedBox(width: 12),
            Flexible(child: _tf('Model/Tipe', data.modelC)),
          ],
        ),
        const SizedBox(height: 12),
        _tf('Spesifikasi/Deskripsi', data.specC, maxLines: 2),
        const SizedBox(height: 12),
        Row(
          children: [
            Flexible(
              child: TextFormField(
                controller: data.qtyC,
                keyboardType: TextInputType.number,
                decoration: _dec('Qty'),
                validator: (v) {
                  final q = int.tryParse((v ?? '').trim()) ?? 0;
                  if (q <= 0) return 'Wajib > 0';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: TextFormField(
                controller: data.priceC,
                keyboardType: TextInputType.number,
                decoration: _dec('Estimasi Harga (Rp)'),
                validator: (v) {
                  final p = int.tryParse((v ?? '').trim()) ?? 0;
                  if (p < 0) return 'Tidak boleh negatif';
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
        const SizedBox(height: 8),
        _hint('Kosongkan harga bila belum tahu, bisa diisi admin saat proses.')
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

  Widget _tf(String label, TextEditingController c, {int maxLines = 1, bool isRequired = false}) =>
      TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration: _dec(label),
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
            : null,
      );

  Widget _hint(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(text, style: const TextStyle(color: kMuted, fontSize: 12)),
    ),
  );
}
