class CouponModel {
  final String title;
  final String code;
  final String description;
  final String discount;
  final String expiry;
  final String type; // 'Percentage', 'Cashback', 'Popular', etc.

  const CouponModel({
    required this.title,
    required this.code,
    required this.description,
    required this.discount,
    required this.expiry,
    required this.type,
  });
}
