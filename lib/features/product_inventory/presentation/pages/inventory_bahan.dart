import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InventoryBahanPage extends StatefulWidget {
  const InventoryBahanPage({super.key});

  @override
  State<InventoryBahanPage> createState() => _InventoryBahanPageState();
}

class _InventoryBahanPageState extends State<InventoryBahanPage> {
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  final String baseUrl = 'http://localhost/api';

  String _query = '';
  String _statusFilter = 'Semua';
  String _sort = 'Nama (A-Z)';

  bool _isLoading = true;
  List<RawMaterialInventoryItem> _data = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/raw-material-inventory'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final decoded = jsonDecode(response.body);
      final List data = decoded['data'] ?? [];

      setState(() {
        _data = data
            .map((e) => RawMaterialInventoryItem.fromJson(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil inventory: $e')),
      );
    }
  }

  String _statusOf(RawMaterialInventoryItem item) {
    if (item.totalStock <= 0) return 'Kosong';

    final hasExpired = item.batches.any((batch) => batch.status == 'Expired');
    if (hasExpired) return 'Ada Expired';

    final hasAlmostExpired =
        item.batches.any((batch) => batch.status == 'Hampir Expired');
    if (hasAlmostExpired) return 'Hampir Expired';

    return 'Aman';
  }

  List<RawMaterialInventoryItem> get _filteredSorted {
    final list = _data.where((item) {
      final q = _query.toLowerCase();

      final matchQuery = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.uom.toLowerCase().contains(q);

      final status = _statusOf(item);
      final matchStatus = _statusFilter == 'Semua' || status == _statusFilter;

      return matchQuery && matchStatus;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case 'Stok Terendah':
          return a.totalStock.compareTo(b.totalStock);
        case 'Stok Tertinggi':
          return b.totalStock.compareTo(a.totalStock);
        case 'Expired Terdekat':
          final aDate = a.nearestExpiredDate ?? DateTime(9999);
          final bDate = b.nearestExpiredDate ?? DateTime(9999);
          return aDate.compareTo(bDate);
        case 'Nama (A-Z)':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return list;
  }

  void _showBatchDetail(RawMaterialInventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              minChildSize: 0.35,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x22000000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total: ${item.totalStock} ${item.uom} • ${item.batchCount} batch',
                      style: const TextStyle(color: kMuted),
                    ),
                    const SizedBox(height: 16),
                    if (item.batches.isEmpty)
                      const Text('Belum ada batch aktif.')
                    else
                      ...item.batches.map((batch) {
                        return _BatchCard(batch: batch);
                      }),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    await _loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filteredSorted;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Inventory Bahan Baku'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari nama / kategori / satuan…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              children: [
                _chip('Semua'),
                const SizedBox(width: 8),
                _chip('Aman'),
                const SizedBox(width: 8),
                _chip('Hampir Expired'),
                const SizedBox(width: 8),
                _chip('Ada Expired'),
                const SizedBox(width: 8),
                _chip('Kosong'),
                const SizedBox(width: 12),
                _sortDropdown(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: kPrimary,
                    child: data.isEmpty
                        ? const Center(
                            child: Text('Belum ada inventory bahan baku'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];
                              final status = _statusOf(item);

                              return _InventoryCard(
                                item: item,
                                status: status,
                                onTap: () => _showBatchDetail(item),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value) {
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

  Widget _sortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
              DropdownMenuItem(
                value: 'Nama (A-Z)',
                child: Text('Nama (A-Z)'),
              ),
              DropdownMenuItem(
                value: 'Stok Terendah',
                child: Text('Stok Terendah'),
              ),
              DropdownMenuItem(
                value: 'Stok Tertinggi',
                child: Text('Stok Tertinggi'),
              ),
              DropdownMenuItem(
                value: 'Expired Terdekat',
                child: Text('Expired Terdekat'),
              ),
            ],
            onChanged: (value) {
              setState(() => _sort = value ?? _sort);
            },
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.status,
    required this.onTap,
  });

  final RawMaterialInventoryItem item;
  final String status;
  final VoidCallback onTap;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String status) {
    switch (status) {
      case 'Aman':
        return const Color(0xFF2E7D32);
      case 'Hampir Expired':
        return const Color(0xFFEF6C00);
      case 'Ada Expired':
      case 'Kosong':
        return const Color(0xFFC62828);
      default:
        return kMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ),
                    _badge(status, color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _iconText(
                      Icons.inventory_2_rounded,
                      '${item.totalStock} ${item.uom}',
                    ),
                    _iconText(
                      Icons.category_rounded,
                      item.category,
                    ),
                    _iconText(
                      Icons.all_inbox_rounded,
                      '${item.batchCount} batch',
                    ),
                    _iconText(
                      Icons.event_rounded,
                      item.nearestExpiredDate == null
                          ? 'Exp: -'
                          : 'Exp: ${_fmtDate(item.nearestExpiredDate!)}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ketuk untuk lihat detail batch',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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

  String _fmtDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({
    required this.batch,
  });

  final RawMaterialBatchItem batch;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  Color _statusColor(String status) {
    switch (status) {
      case 'Aman':
        return const Color(0xFF2E7D32);
      case 'Hampir Expired':
        return const Color(0xFFEF6C00);
      case 'Expired':
      case 'Habis':
        return const Color(0xFFC62828);
      default:
        return kMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(batch.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  batch.status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Qty tersisa: ${batch.qtyRemaining} ${batch.uom}'),
          const SizedBox(height: 4),
          Text(
            'Expired: ${batch.expiredDate == null ? '-' : _fmtDate(batch.expiredDate!)}',
            style: const TextStyle(color: kMuted),
          ),
          if (batch.supplier != null && batch.supplier!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Supplier: ${batch.supplier}',
              style: const TextStyle(color: kMuted),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

class RawMaterialInventoryItem {
  final int rawMaterialId;
  final String name;
  final String category;
  final String uom;
  final int totalStock;
  final int batchCount;
  final DateTime? nearestExpiredDate;
  final List<RawMaterialBatchItem> batches;

  RawMaterialInventoryItem({
    required this.rawMaterialId,
    required this.name,
    required this.category,
    required this.uom,
    required this.totalStock,
    required this.batchCount,
    required this.nearestExpiredDate,
    required this.batches,
  });

  factory RawMaterialInventoryItem.fromJson(Map<String, dynamic> json) {
    return RawMaterialInventoryItem(
      rawMaterialId: json['raw_material_id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      uom: json['uom'] ?? '',
      totalStock: json['total_stock'] ?? 0,
      batchCount: json['batch_count'] ?? 0,
      nearestExpiredDate: json['nearest_expired_date'] == null
          ? null
          : DateTime.parse(json['nearest_expired_date']),
      batches: ((json['batches'] ?? []) as List)
          .map((e) => RawMaterialBatchItem.fromJson(e))
          .toList(),
    );
  }
}

class RawMaterialBatchItem {
  final int id;
  final String batchNumber;
  final DateTime? receivedDate;
  final DateTime? expiredDate;
  final int qtyIn;
  final int qtyRemaining;
  final String uom;
  final String? supplier;
  final String status;

  RawMaterialBatchItem({
    required this.id,
    required this.batchNumber,
    required this.receivedDate,
    required this.expiredDate,
    required this.qtyIn,
    required this.qtyRemaining,
    required this.uom,
    required this.supplier,
    required this.status,
  });

  factory RawMaterialBatchItem.fromJson(Map<String, dynamic> json) {
    return RawMaterialBatchItem(
      id: json['id'] ?? 0,
      batchNumber: json['batch_number'] ?? '',
      receivedDate: json['received_date'] == null
          ? null
          : DateTime.parse(json['received_date']),
      expiredDate: json['expired_date'] == null
          ? null
          : DateTime.parse(json['expired_date']),
      qtyIn: json['qty_in'] ?? 0,
      qtyRemaining: json['qty_remaining'] ?? 0,
      uom: json['uom'] ?? '',
      supplier: json['supplier'],
      status: json['status'] ?? 'Aman',
    );
  }
}