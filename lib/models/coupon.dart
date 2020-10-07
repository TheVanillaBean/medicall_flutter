import 'package:flutter/foundation.dart';

class Coupon {
  final String code;
  final bool enabled;
  final int initialUseCount;
  final int remainingUses;
  final int discountPercentage;

  Coupon({
    @required this.code,
    @required this.enabled,
    @required this.initialUseCount,
    @required this.remainingUses,
    @required this.discountPercentage,
  });

  factory Coupon.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    final String code = data['code'];
    final bool enabled = data['enabled'];
    final int initialUseCount = data['initial_use_count'];
    final int remainingUses = data['remaining_uses'];
    final int discountPercentage = data['discount_percentage'];

    return Coupon(
      code: code,
      enabled: enabled,
      initialUseCount: initialUseCount,
      remainingUses: remainingUses,
      discountPercentage: discountPercentage,
    );
  }

  double get discountMultiplier {
    return this.discountPercentage * .1;
  }
}
