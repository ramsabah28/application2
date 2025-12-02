class OrderModel {
  final String uuid;
  final String BID;
  final String UID;
  final String date;
  final String status;
  final bool deleverd;

  const OrderModel({
    required this.uuid,
    required this.UID,
    required this.BID,
    required this.status,
    required this.date,
    required this.deleverd,
  });
}
