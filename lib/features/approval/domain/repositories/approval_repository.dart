abstract class ApprovalRepository {
  Future<void> approveRawMaterialRequest({
    required String token,
    required int requestId,
  });

  Future<void> rejectRawMaterialRequest({
    required String token,
    required int requestId,
    String? reason,
  });

  Future<void> approveProductionReport({
    required String token,
    required int reportId,
  });

  Future<void> rejectProductionReport({
    required String token,
    required int reportId,
    String? reason,
  });

  Future<void> approveDepartureTrip({
    required String token,
    required int tripId,
  });

  Future<void> rejectDepartureTrip({
    required String token,
    required int tripId,
    String? reason,
  });

  Future<void> approveReturnTrip({
    required String token,
    required int tripId,
  });

  Future<void> rejectReturnTrip({
    required String token,
    required int tripId,
    String? reason,
  });
}