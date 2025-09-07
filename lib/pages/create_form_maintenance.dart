import 'package:flutter/material.dart';

class CreateFormMaintenancePage extends StatefulWidget {
  const CreateFormMaintenancePage({
    super.key,
    this.isAdmin = false,
    this.currentUserName = 'User',
    this.currentUserEmail = 'user@example.com',
  });

  final bool isAdmin;
  final String currentUserName;
  final String currentUserEmail;

  @override
  State<CreateFormMaintenancePage> createState() => _CreateFormMaintenancePageState();
}

class _CreateFormMaintenancePageState extends State<CreateFormMaintenancePage> {
  // Palet
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  final _formKey = GlobalKey<FormState>();

  // ========== IDENTITAS ==========
  final _judulC = TextEditingController();
  final _catatanC = TextEditingController();
  String _jenisMaintenance = 'Preventive';
  String _prioritas = 'Normal';
  DateTime _tanggal = DateTime.now();

  // ========== DETAIL ASET ==========
  final _assetNameC = TextEditingController();
  final _assetCodeC = TextEditingController();
  final _assetLocC  = TextEditingController(text: 'Basecamp');

  // ========== KELUHAN & RENCANA ==========
  final _keluhanC = TextEditingController();
  final _tindakanC = TextEditingController();
  bool  _teknisiInternal = true;
  DateTime? _jadwalDiinginkan;

  // ========== SPARE PARTS DIPAKAI ==========
  final List<_PartRowData> _parts = [ _PartRowData() ];

  // ========== VENDOR (ADMIN) ==========
  final _vendorNameC = TextEditingController();

  // ========== PEMBAYARAN & PENYELESAIAN (ADMIN) ==========
  String _metodePembayaran = 'Cash';
  String _jenisPembayaran  = 'Di muka';
  DateTime? _serviceDate;              // tanggal pekerjaan selesai / service
  final List<String> _proofs = [];     // foto bukti
  final _actualCostC = TextEditingController(); // biaya aktual (opsional)

  // ========== PELAKU & PERSETUJUAN ==========
  String _calonReviewer = 'Atasan A';
  String _status = 'Menunggu'; // default after submit
  bool _autoAdjustPartsOut = true; // saat selesai, parts keluar stok

  @override
  void dispose() {
    _judulC.dispose();
    _catatanC.dispose();
    _assetNameC.dispose();
    _assetCodeC.dispose();
    _assetLocC.dispose();
    _keluhanC.dispose();
    _tindakanC.dispose();
    _vendorNameC.dispose();
    _actualCostC.dispose();
    for (final p in _parts) p.dispose();
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

  Future<void> _pickJadwalDiinginkan() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _jadwalDiinginkan ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _jadwalDiinginkan = picked);
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _serviceDate = picked);
  }

  // ================= HANDLERS =================
  void _addPart() => setState(() => _parts.add(_PartRowData()));
  void _removePart(int i) { if (_parts.length > 1) setState(() => _parts.removeAt(i)); }

  void _addProofFromCamera() {
    if (!widget.isAdmin) return;
    setState(() => _proofs.add('camera_${_proofs.length + 1}.jpg'));
  }
  void _addProofFromGallery() {
    if (!widget.isAdmin) return;
    setState(() => _proofs.add('gallery_${_proofs.length + 1}.jpg'));
  }

  // ================= SUBMIT =================
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Validasi parts
    if (_parts.any((p) =>
      p.nameC.text.trim().isEmpty ||
      p.uomC.text.trim().isEmpty ||
      (int.tryParse(p.qtyC.text.trim()) ?? 0) <= 0
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi spare part: nama, satuan, qty (>0)')),
      );
      return;
    }

    final payload = {
      "title": _judulC.text.trim(),
      "maintenance_type": _jenisMaintenance,      // Preventive/Corrective/Calibration/Installation
      "priority": _prioritas,
      "request_date": _fmtDate(_tanggal),
      "notes": _catatanC.text.trim(),

      "asset": {
        "name": _assetNameC.text.trim(),
        "code": _assetCodeC.text.trim(),
        "location": _assetLocC.text.trim(),
      },

      "issue": _keluhanC.text.trim(),
      "action_plan": _tindakanC.text.trim(),
      "internal_technician": _teknisiInternal,
      "preferred_schedule": _jadwalDiinginkan == null ? null : _fmtDate(_jadwalDiinginkan!),

      "parts": _parts.map((p) => {
        "name": p.nameC.text.trim(),
        "uom": p.uomC.text.trim(),
        "qty": int.tryParse(p.qtyC.text.trim()) ?? 0,
      }).toList(),

      "vendor": widget.isAdmin ? {"name": _vendorNameC.text.trim()} : null,

      "payment": widget.isAdmin ? {
        "method": _metodePembayaran,     // Cash / Transfer / E-Wallet
        "type": _jenisPembayaran,        // Di muka / Termin
        "service_date": _serviceDate == null ? null : _fmtDate(_serviceDate!),
        "actual_cost": int.tryParse(_actualCostC.text.trim().isEmpty ? '0' : _actualCostC.text.trim()) ?? 0,
      } : null,

      "completion": widget.isAdmin ? {
        "proofs": _proofs,
      } : null,

      "inventory": { "parts_auto_out": _autoAdjustPartsOut, "location": _assetLocC.text.trim() },

      "submitted_by": { "name": widget.currentUserName, "email": widget.currentUserEmail },
      "approval": { "reviewer": _calonReviewer, "status": _status }, // default Menunggu
    };

    // TODO: kirim payload ke backend
    // debugPrint(payload.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan maintenance disimpan.')),
    );
    Navigator.pop(context);
  }

  // ================= UI =================
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
                            label: 'Jenis Maintenance',
                            value: _jenisMaintenance,
                            items: const ['Preventive','Corrective','Calibration','Installation'],
                            onChanged: (v) => setState(() => _jenisMaintenance = v!),
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

                // ========== DETAIL ASET ==========
                _SectionCard(
                  title: 'Detail Aset',
                  child: Column(children: [
                    _textField(label: 'Nama Aset', controller: _assetNameC, validator: (v) => (v==null||v.trim().isEmpty)?'Wajib diisi':null),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(child: _textField(label: 'Kode Aset', controller: _assetCodeC)),
                        const SizedBox(width: 12),
                        Flexible(child: _textField(label: 'Lokasi/Departemen', controller: _assetLocC)),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== KELUHAN & RENCANA ==========
                _SectionCard(
                  title: 'Keluhan & Rencana',
                  child: Column(children: [
                    _textField(label: 'Keluhan/Deskripsi Masalah', controller: _keluhanC, maxLines: 3,
                      validator: (v)=> (v==null||v.trim().isEmpty)?'Wajib diisi':null),
                    const SizedBox(height: 12),
                    _textField(label: 'Rencana Tindakan (opsional)', controller: _tindakanC, maxLines: 2),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Teknisi Internal'),
                            value: _teknisiInternal,
                            onChanged: (v)=> setState(()=> _teknisiInternal = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateField(
                            label: 'Jadwal Diinginkan',
                            date: _jadwalDiinginkan,
                            onPick: _pickJadwalDiinginkan,
                            enabled: true,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== SPARE PARTS ==========
                _SectionCard(
                  title: 'Spare Parts Dipakai',
                  subtitle: 'Nama, satuan (UoM), dan kuantitas',
                  action: TextButton.icon(
                    onPressed: _addPart,
                    icon: const Icon(Icons.add_rounded, color: kPrimary),
                    label: const Text('Tambah Part', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                  ),
                  child: Column(
                    children: List.generate(_parts.length, (i) => Padding(
                      padding: EdgeInsets.only(bottom: i == _parts.length - 1 ? 0 : 12),
                      child: _PartRow(
                        data: _parts[i],
                        onRemove: _parts.length > 1 ? () => _removePart(i) : null,
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 16),

                // ========== VENDOR (ADMIN) ==========
                _SectionCard(
                  title: 'Vendor (Admin)',
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
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Kurangi stok spare part otomatis saat selesai'),
                      value: _autoAdjustPartsOut,
                      onChanged: (v)=> setState(()=> _autoAdjustPartsOut = v),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ========== PEMBAYARAN & PENYELESAIAN (ADMIN) ==========
                _SectionCard(
                  title: 'Pembayaran & Penyelesaian (Admin)',
                  subtitle: widget.isAdmin ? 'Diisi saat proses' : 'Hanya admin yang dapat mengisi',
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
                        label: 'Tanggal Service Selesai',
                        date: _serviceDate,
                        onPick: widget.isAdmin ? _pickServiceDate : null,
                        enabled: widget.isAdmin,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        label: 'Biaya Aktual (Rp, opsional)',
                        controller: _actualCostC,
                        enabled: widget.isAdmin,
                      ),
                      const SizedBox(height: 12),
                      const Text('Lampiran / Bukti (foto/nota/serah-terima)', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _proofs.isEmpty
                            ? [const Text('Belum ada bukti', style: TextStyle(color: kMuted))]
                            : _proofs
                                .map((f) => Chip(
                                      label: Text(f),
                                      onDeleted: widget.isAdmin ? () => setState(() => _proofs.remove(f)) : null,
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
                    child: const Text('Simpan Pengajuan Maintenance'),
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

class _PartRowData {
  final nameC = TextEditingController();
  final uomC  = TextEditingController();
  final qtyC  = TextEditingController();

  void dispose() {
    nameC.dispose();
    uomC.dispose();
    qtyC.dispose();
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({required this.data, this.onRemove});
  final _PartRowData data;
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
          children: [
            Flexible(child: _tf('Nama Part', data.nameC, required: true)),
            const SizedBox(width: 12),
            Flexible(child: _tf('Satuan (UoM)', data.uomC, required: true)),
          ],
        ),
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
            if (onRemove != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, color: kPrimary),
                tooltip: 'Hapus part',
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

  Widget _tf(String label, TextEditingController c, {bool required = false}) =>
      TextFormField(
        controller: c,
        decoration: _dec(label),
        validator: required ? (v)=> (v==null||v.trim().isEmpty)?'Wajib diisi':null : null,
      );
}
