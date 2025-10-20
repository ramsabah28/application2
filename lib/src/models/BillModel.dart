class BillItem {
  final String pid;
  final int count;
  final double price;

  const BillItem({required this.pid, required this.count, required this.price});
}

class BillModel {
  final String uuid;
  final String UID;
  final List<BillItem> items;
  final int count;
  final double price;
  final int BID;
  final String date;

  const BillModel({
    required this.uuid,
    required this.count,
    required this.price,
    required this.BID,
    required this.items,
    required this.UID,
    required this.date,
  });
}
