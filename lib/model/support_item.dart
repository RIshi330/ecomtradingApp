class SupportItem {
  final String name;
  final double price;
  int quantity;

  SupportItem({
    required this.name,
    required this.price,
    this.quantity = 0,
  });
}
