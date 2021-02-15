import 'package:flutter/foundation.dart';

enum CoverageResponse {
  ValidCostEstimate,
  NoCostEstimate,
  ReferralNeeded,
}

class InsuranceInfo {
  final CoverageResponse coverageResponse;
  final String insurance;
  final String providerName;
  final int costEstimate;

  InsuranceInfo({
    @required this.coverageResponse,
    @required this.insurance,
    this.providerName,
    this.costEstimate = 0,
  });
}
