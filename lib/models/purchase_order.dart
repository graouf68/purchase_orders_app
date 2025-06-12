class PurchaseOrder {
  final int? id;
  final int vendorId;
  final String date;

  PurchaseOrder({this.id, required this.vendorId, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'date': date,
    };
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: map['id'],
      vendorId: map['vendorId'],
      date: map['date'],
    );
  }
}

class PurchaseOrderDetail {
  final int? id;
  final int orderId;
  final int itemId;
  final int quantity;
  final double price;

  PurchaseOrderDetail({
    this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory PurchaseOrderDetail.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderDetail(
      id: map['id'],
      orderId: map['orderId'],
      itemId: map['itemId'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
