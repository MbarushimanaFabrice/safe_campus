import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String incidentId;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.incidentId,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? incidentId,
    String? title,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      incidentId: incidentId ?? this.incidentId,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'incidentId': incidentId,
      'title': title,
      'message': message,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      incidentId: map['incidentId'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      read: map['read'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data);
  }
}
