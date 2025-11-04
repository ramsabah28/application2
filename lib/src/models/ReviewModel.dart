class Review {
  final String uuid;
  final String UID;
  final String PID;
  final String date;
  final int rank;
  final String titel;
  final String message;

  const Review({
    required this.uuid,
    required this.UID,
    required this.PID,
    required this.date,
    required this.rank,
    required this.titel,
    required this.message,
  });

  // Convert Review to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'UID': UID,
      'PID': PID,
      'date': date,
      'rank': rank,
      'titel': titel,
      'message': message,
    };
  }

  // Create Review from Firestore document
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      uuid: map['uuid'] ?? '',
      UID: map['UID'] ?? '',
      PID: map['PID'] ?? '',
      date: map['date'] ?? '',
      rank: map['rank'] ?? 0,
      titel: map['titel'] ?? '',
      message: map['message'] ?? '',
    );
  }

  // Create a copy of Review with updated fields
  Review copyWith({
    String? uuid,
    String? UID,
    String? PID,
    String? date,
    int? rank,
    String? titel,
    String? message,
  }) {
    return Review(
      uuid: uuid ?? this.uuid,
      UID: UID ?? this.UID,
      PID: PID ?? this.PID,
      date: date ?? this.date,
      rank: rank ?? this.rank,
      titel: titel ?? this.titel,
      message: message ?? this.message,
    );
  }
}
