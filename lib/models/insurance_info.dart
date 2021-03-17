import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';

enum CoverageResponse {
  Medicare,
  ValidCostEstimate,
  NoCostEstimate,
  ReferralNeeded,
}

extension EnumParser on String {
  CoverageResponse toCoverageInfo() {
    return CoverageResponse.values.firstWhere(
      (e) =>
          e.toString().toLowerCase() == 'CoverageResponse.$this'.toLowerCase(),
      orElse: () => null,
    );
  }
}

class InsuranceInfo {
  final CoverageResponse coverageResponse;
  final String insurance;
  final String pcpName;
  final int costEstimate;
  final String memberId;

  InsuranceInfo({
    @required this.coverageResponse,
    @required this.insurance,
    @required this.memberId,
    this.pcpName,
    this.costEstimate = -1,
  });

  factory InsuranceInfo.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final CoverageResponse coverageResponse =
        (data['coverage_response'] as String).toCoverageInfo() ?? null;
    final String insurance = data['insurance'];
    final String memberId = data['member_id'];
    final int costEstimate = data['cost_estimate'];
    final String pcpName = data['pcp_name'];

    return InsuranceInfo(
      coverageResponse: coverageResponse,
      insurance: insurance,
      memberId: memberId,
      costEstimate: costEstimate,
      pcpName: pcpName,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> baseToMap = {
      'coverage_response': EnumToString.convertToString(coverageResponse),
      'insurance': insurance,
      'member_id': memberId,
      'cost_estimate': costEstimate,
      'pcp_name': pcpName,
    };
    return baseToMap;
  }
}
