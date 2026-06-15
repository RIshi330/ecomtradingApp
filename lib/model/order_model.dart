class OrderModel {
  final String id;
  final String customerName;
  final String date;
  final double amount;
  final String items;
  final String status;
  final String contact;
  final String email;
  final String community;
  final String chapter;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.items,
    required this.status,
    required this.contact,
    required this.email,
    required this.community,
    required this.chapter,
    required this.deliveryAddress,
  });
}
