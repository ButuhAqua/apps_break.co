import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apps_break/features/approval/data/datasources/approval_remote_datasource.dart';
import 'package:apps_break/features/approval/data/repositories/approval_repository_impl.dart';

import 'package:apps_break/features/approval/domain/usecases/approve_raw_material_request.dart';
import 'package:apps_break/features/approval/domain/usecases/reject_raw_material_request.dart';
import 'package:apps_break/features/approval/domain/usecases/approve_production_report.dart';
import 'package:apps_break/features/approval/domain/usecases/reject_production_report.dart';
import 'package:apps_break/features/approval/domain/usecases/approve_departure_trip.dart';
import 'package:apps_break/features/approval/domain/usecases/reject_departure_trip.dart';
import 'package:apps_break/features/approval/domain/usecases/approve_return_trip.dart';
import 'package:apps_break/features/approval/domain/usecases/reject_return_trip.dart';

import 'package:apps_break/features/pengajuan_bahan_baku/data/datasources/pengajuan_remote_datasource.dart';
import 'package:apps_break/features/pengajuan_bahan_baku/data/repositories/pengajuan_repository_impl.dart';
import 'package:apps_break/features/pengajuan_bahan_baku/domain/entities/pengajuan.dart';
import 'package:apps_break/features/pengajuan_bahan_baku/domain/usecases/get_pengajuan_list.dart';

import 'package:apps_break/features/laporan_produksi/data/datasources/production_remote_datasource.dart';
import 'package:apps_break/features/laporan_produksi/data/repositories/production_repository_impl.dart';
import 'package:apps_break/features/laporan_produksi/domain/entities/production_report.dart';
import 'package:apps_break/features/laporan_produksi/domain/usecases/get_production_reports.dart';

import 'package:apps_break/features/runner_trip/data/datasources/runner_trip_remote_datasource.dart';
import 'package:apps_break/features/runner_trip/data/repositories/runner_trip_repository_impl.dart';
import 'package:apps_break/features/runner_trip/domain/entities/runner_trip.dart';
import 'package:apps_break/features/runner_trip/domain/usecases/get_runner_trips.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  static const Color kPrimary = Color(0xFFD32F2F);
  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);
  static const Color kBorder = Color(0xFFE0E0E0);

  int _selectedTab = 0;

  bool _isLoading = true;
  bool _isProcessing = false;

  List<Pengajuan> _pengajuanData = [];
  List<ProductionReport> _productionData = [];
  List<RunnerTrip> _runnerTripData = [];

  @override
  void initState() {
    super.initState();
    _loadAllApprovals();
  }

  Future<void> _loadAllApprovals() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadPengajuanApprovals(),
        _loadProductionApprovals(),
        _loadRunnerTripApprovals(),
      ]);

      if (!mounted) return;

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil approval: $e')),
      );
    }
  }

  Future<void> _loadPengajuanApprovals() async {
    final token = await _getToken();

    final repository = PengajuanRepositoryImpl(
      PengajuanRemoteDataSource(),
    );

    final getPengajuanList = GetPengajuanList(repository);
    final result = await getPengajuanList(token);

    _pengajuanData = result.where((item) {
      return item.status == 'Menunggu';
    }).toList();
  }

  Future<void> _loadProductionApprovals() async {
    final token = await _getToken();

    final repository = ProductionRepositoryImpl(
      ProductionRemoteDatasource(),
    );

    final getProductionReports = GetProductionReports(repository);
    final result = await getProductionReports(token);

    _productionData = result.where((item) {
      final status = item.status.toLowerCase();
      return status == 'submitted' || status == 'menunggu';
    }).toList();
  }

  Future<void> _loadRunnerTripApprovals() async {
    final token = await _getToken();

    final repository = RunnerTripRepositoryImpl(
      RunnerTripRemoteDatasource(),
    );

    final getRunnerTrips = GetRunnerTrips(repository);
    final result = await getRunnerTrips(token);

    _runnerTripData = result.where((trip) {
      return trip.status == 'PENDING_DEPARTURE' ||
          trip.status == 'PENDING_RETURN';
    }).toList();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    return token;
  }

  ApprovalRepositoryImpl _approvalRepository() {
    return ApprovalRepositoryImpl(
      ApprovalRemoteDataSource(),
    );
  }

  Future<void> _approvePengajuan(Pengajuan item) async {
    await _processApproval(
      action: () async {
        final token = await _getToken();

        final approve = ApproveRawMaterialRequest(
          _approvalRepository(),
        );

        await approve(
          token: token,
          requestId: int.parse(item.id),
        );
      },
      successMessage: 'Pengajuan bahan baku disetujui',
    );
  }

  Future<void> _rejectPengajuan(Pengajuan item) async {
    final reason = await _showRejectDialog();

    if (reason == null) return;

    await _processApproval(
      action: () async {
        final token = await _getToken();

        final reject = RejectRawMaterialRequest(
          _approvalRepository(),
        );

        await reject(
          token: token,
          requestId: int.parse(item.id),
          reason: reason,
        );
      },
      successMessage: 'Pengajuan bahan baku ditolak',
    );
  }

  Future<void> _approveProduction(ProductionReport item) async {
    await _processApproval(
      action: () async {
        final token = await _getToken();

        final approve = ApproveProductionReport(
          _approvalRepository(),
        );

        await approve(
          token: token,
          reportId: int.parse(item.id),
        );
      },
      successMessage: 'Laporan produksi disetujui',
    );
  }

  Future<void> _rejectProduction(ProductionReport item) async {
    final reason = await _showRejectDialog();

    if (reason == null) return;

    await _processApproval(
      action: () async {
        final token = await _getToken();

        final reject = RejectProductionReport(
          _approvalRepository(),
        );

        await reject(
          token: token,
          reportId: int.parse(item.id),
          reason: reason,
        );
      },
      successMessage: 'Laporan produksi ditolak',
    );
  }

  Future<void> _approveRunnerTrip(RunnerTrip trip) async {
    await _processApproval(
      action: () async {
        final token = await _getToken();

        if (trip.status == 'PENDING_DEPARTURE') {
          final approve = ApproveDepartureTrip(
            _approvalRepository(),
          );

          await approve(
            token: token,
            tripId: trip.id,
          );
        }

        if (trip.status == 'PENDING_RETURN') {
          final approve = ApproveReturnTrip(
            _approvalRepository(),
          );

          await approve(
            token: token,
            tripId: trip.id,
          );
        }
      },
      successMessage: 'Runner trip berhasil disetujui',
    );
  }

  Future<void> _rejectRunnerTrip(RunnerTrip trip) async {
    final reason = await _showRejectDialog();

    if (reason == null) return;

    await _processApproval(
      action: () async {
        final token = await _getToken();

        if (trip.status == 'PENDING_DEPARTURE') {
          final reject = RejectDepartureTrip(
            _approvalRepository(),
          );

          await reject(
            token: token,
            tripId: trip.id,
            reason: reason,
          );
        }

        if (trip.status == 'PENDING_RETURN') {
          final reject = RejectReturnTrip(
            _approvalRepository(),
          );

          await reject(
            token: token,
            tripId: trip.id,
            reason: reason,
          );
        }
      },
      successMessage: 'Runner trip berhasil ditolak',
    );
  }

  Future<void> _processApproval({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await action();

      await _loadAllApprovals();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal proses approval: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final reasonC = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Tolak Approval'),
          content: TextField(
            controller: reasonC,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alasan penolakan',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, reasonC.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );

    reasonC.dispose();
    return result;
  }

  int get _pendingCount {
    if (_selectedTab == 0) return _pengajuanData.length;
    if (_selectedTab == 1) return _productionData.length;
    return _runnerTripData.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Approval Manager'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimary),
            )
          : RefreshIndicator(
              color: kPrimary,
              onRefresh: _loadAllApprovals,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _tabSelector(),
                  const SizedBox(height: 14),
                  Text(
                    'Menunggu approval: $_pendingCount',
                    style: const TextStyle(
                      color: kMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_selectedTab == 0)
                    _buildPengajuanList()
                  else if (_selectedTab == 1)
                    _buildProductionList()
                  else
                    _buildRunnerTripList(),
                ],
              ),
            ),
    );
  }

  Widget _tabSelector() {
    return Row(
      children: [
        Expanded(
          child: _tabButton(
            title: 'Pengajuan',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _tabButton(
            title: 'Produksi',
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _tabButton(
            title: 'Runner',
            selected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
        ),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : kPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPengajuanList() {
    if (_pengajuanData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(
          child: Text('Tidak ada pengajuan bahan menunggu approval'),
        ),
      );
    }

    return Column(
      children: _pengajuanData.map((item) {
        return _PengajuanApprovalCard(
          item: item,
          isProcessing: _isProcessing,
          onApprove: () => _approvePengajuan(item),
          onReject: () => _rejectPengajuan(item),
        );
      }).toList(),
    );
  }

  Widget _buildProductionList() {
    if (_productionData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(
          child: Text('Tidak ada laporan produksi menunggu approval'),
        ),
      );
    }

    return Column(
      children: _productionData.map((item) {
        return _ProductionApprovalCard(
          item: item,
          isProcessing: _isProcessing,
          onApprove: () => _approveProduction(item),
          onReject: () => _rejectProduction(item),
        );
      }).toList(),
    );
  }

  Widget _buildRunnerTripList() {
    if (_runnerTripData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(
          child: Text('Tidak ada runner trip menunggu approval'),
        ),
      );
    }

    return Column(
      children: _runnerTripData.map((trip) {
        return _RunnerTripApprovalCard(
          trip: trip,
          isProcessing: _isProcessing,
          onApprove: () => _approveRunnerTrip(trip),
          onReject: () => _rejectRunnerTrip(trip),
        );
      }).toList(),
    );
  }
}

class _PengajuanApprovalCard extends StatelessWidget {
  const _PengajuanApprovalCard({
    required this.item,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final Pengajuan item;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.requestType} • ${item.priority}',
            style: const TextStyle(color: kMuted),
          ),
          const SizedBox(height: 6),
          Text(
            'Tanggal: ${_fmtDate(item.requestDate)}',
            style: const TextStyle(color: kMuted),
          ),
          if ((item.purchaseLocation ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Lokasi beli: ${item.purchaseLocation ?? '-'}',
              style: const TextStyle(color: kMuted),
            ),
          ],
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.notes),
          ],
          const SizedBox(height: 12),
          const Text(
            'Detail Item',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final detail in item.items)
            _MiniDetailRow(
              title: detail.name,
              trailing: '${detail.qty} ${detail.uom}',
            ),
          const SizedBox(height: 12),
          _ActionButtons(
            isProcessing: isProcessing,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ProductionApprovalCard extends StatelessWidget {
  const _ProductionApprovalCard({
    required this.item,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final ProductionReport item;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.reportNumber,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tanggal: ${item.productionDate}',
            style: const TextStyle(color: kMuted),
          ),
          const SizedBox(height: 6),
          Text(
            'Status: ${item.status}',
            style: const TextStyle(color: kMuted),
          ),
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.notes),
          ],
          const SizedBox(height: 12),
          const Text(
            'Bahan Dipakai',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final usage in item.materialUsages)
            _MiniDetailRow(
              title: usage.rawMaterialName,
              trailing: '${usage.qty} ${usage.uom}',
            ),
          const SizedBox(height: 12),
          const Text(
            'Produk Jadi',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final product in item.finishedProducts)
            _MiniDetailRow(
              title: product.productName,
              trailing: '${product.qty} ${product.uom}',
            ),
          const SizedBox(height: 12),
          _ActionButtons(
            isProcessing: isProcessing,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}

class _RunnerTripApprovalCard extends StatelessWidget {
  const _RunnerTripApprovalCard({
    required this.trip,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final RunnerTrip trip;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static const Color kText = Color(0xFF212121);
  static const Color kMuted = Color(0xFF616161);

  String get statusLabel {
    if (trip.status == 'PENDING_DEPARTURE') {
      return 'Menunggu Approval Berangkat';
    }

    if (trip.status == 'PENDING_RETURN') {
      return 'Menunggu Approval Pulang';
    }

    return trip.status;
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip #${trip.id} • ${trip.location}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Runner: ${trip.runnerName.isEmpty ? '-' : trip.runnerName}',
            style: const TextStyle(color: kMuted),
          ),
          const SizedBox(height: 6),
          Text(
            statusLabel,
            style: const TextStyle(
              color: kMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trip.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(trip.notes),
          ],
          const SizedBox(height: 12),
          const Text(
            'Detail Produk',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final item in trip.items)
            _MiniDetailRow(
              title: item.productName,
              trailing: trip.status == 'PENDING_RETURN'
                  ? 'Bawa ${item.qtyTaken}, Sisa ${item.qtyReturned ?? 0}, Jual ${item.qtySold}'
                  : 'Bawa ${item.qtyTaken} ${item.uom}',
            ),
          const SizedBox(height: 12),
          _ActionButtons(
            isProcessing: isProcessing,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
  });

  final Widget child;

  static const Color kBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x14000000),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MiniDetailRow extends StatelessWidget {
  const _MiniDetailRow({
    required this.title,
    required this.trailing,
  });

  final String title;
  final String trailing;

  static const Color kText = Color(0xFF212121);
  static const Color kBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: kText),
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static const Color kPrimary = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isProcessing ? null : onReject,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Tolak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : onApprove,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Setujui'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}