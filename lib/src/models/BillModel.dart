class BillModel {
  final String uuid;
  final String UID;
  final String PID;
  final int count;
  final double price;
  final int BID;
  final String date;

  const BillModel({
    required this.uuid,
    required this.count,
    required this.price,
    required this.BID,
    required this.PID,
    required this.UID,
    required this.date
  });
}
