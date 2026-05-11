class ProductInventoryItem {
  final String id;
  final String productId;
  final String name;
  final String sku;
  final String uom;
  final int qty;
  final int minQty;
  final String location;
  final DateTime? lastUpdated;

  const ProductInventoryItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.uom,
    required this.qty,
    required this.minQty,
    required this.location,
    required this.lastUpdated,
  });
}