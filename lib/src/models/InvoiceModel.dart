import 'package:flutter/material.dart';

class InvoiceModel {
  final String UUID;
  final String UID;
  final String PID;
  final int count;
  final double price;
  final String date;
  final bool paid;

  const InvoiceModel({
    required this.UUID,
    required this.UID,
    required this.PID,
    required this.count,
    required this.price,
    required this.date,
    required this.paid,
  });
}
