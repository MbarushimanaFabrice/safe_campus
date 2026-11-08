import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

class StatusHistoryEntry {
  final IncidentStatus status;
  final String updatedBy;
  final String updatedByName;
  final String? note;
  final DateTime timestamp;

  const StatusHistoryEntry({
    required this.status,
    required this.updatedBy,
    required this.updatedByName,
    this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.value,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory StatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    return StatusHistoryEntry(
      status: IncidentStatus.fromString(map['status'] as String),
      updatedBy: map['updatedBy'] as String,
      updatedByName: map['updatedByName'] as String,
      note: map['note'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final IncidentPriority priority;
  final String location;
  final String? locationDetails;
  final List<String> photoUrls;
  final List<String> photoPublicIds;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final String reporterDepartment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusHistoryEntry> statusHistory;
  final String? staffNote;

  const IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.location,
    this.locationDetails,
    required this.photoUrls,
    required this.photoPublicIds,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.reporterDepartment,
    required this.createdAt,
    required this.updatedAt,
    required this.statusHistory,
    this.staffNote,
  });

  String get fullLocation {
    if (locationDetails != null && locationDetails!.isNotEmpty) {
      return '$location — $locationDetails';
    }
    return location;
  }

  StatusHistoryEntry? get submittedEntry {
    return statusHistory.firstWhere(
      (e) => e.status == IncidentStatus.submitted,
      orElse: () => statusHistory.first,
    );
  }

  StatusHistoryEntry? get inProgressEntry {
    try {
      return statusHistory.firstWhere(
        (e) => e.status == IncidentStatus.inProgress,
      );
    } catch (_) {
      return null;
    }
  }

  StatusHistoryEntry? get resolvedEntry {
    try {
      return statusHistory.firstWhere(
        (e) => e.status == IncidentStatus.resolved,
      );
    } catch (_) {
      return null;
    }
  }

  IncidentModel copyWith({
    String? id,
    String? title,
    String? description,
    IncidentCategory? category,
    IncidentPriority? priority,
    String? location,
    String? locationDetails,
    List<String>? photoUrls,
    List<String>? photoPublicIds,
    IncidentStatus? status,
    String? reporterId,
    String? reporterName,
    String? reporterDepartment,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<StatusHistoryEntry>? statusHistory,
    String? staffNote,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      photoUrls: photoUrls ?? this.photoUrls,
      photoPublicIds: photoPublicIds ?? this.photoPublicIds,
      status: status ?? this.status,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterDepartment: reporterDepartment ?? this.reporterDepartment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusHistory: statusHistory ?? this.statusHistory,
      staffNote: staffNote ?? this.staffNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.value,
      'priority': priority.value,
      'location': location,
      'locationDetails': locationDetails,
      'photoUrls': photoUrls,
      'photoPublicIds': photoPublicIds,
      'status': status.value,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterDepartment': reporterDepartment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
      'staffNote': staffNote,
    };
  }

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    final reporterId = map['reporterId'] as String? ?? '';
    final reporterName = map['reporterName'] as String? ?? '';
    final status = IncidentStatus.fromString(map['status'] as String? ?? 'submitted');
    final createdAtValue = map['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : createdAtValue is DateTime
            ? createdAtValue
            : DateTime.fromMillisecondsSinceEpoch(0);
    final rawStatusHistory = map['statusHistory'] as List? ?? const [];
    final statusHistory = rawStatusHistory
        .map((entry) => StatusHistoryEntry.fromMap(entry as Map<String, dynamic>))
        .toList();
    if (statusHistory.isEmpty) {
      statusHistory.add(
        StatusHistoryEntry(
          status: status,
          updatedBy: reporterId,
          updatedByName: reporterName,
          timestamp: createdAt,
        ),
      );
    }

    return IncidentModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String,
      description: map['description'] as String,
      category: IncidentCategory.fromString(map['category'] as String),
      priority: IncidentPriority.fromString(map['priority'] as String),
      location: map['location'] as String,
      locationDetails: map['locationDetails'] as String?,
      photoUrls: List<String>.from(map['photoUrls'] as List? ?? const []),
      photoPublicIds: List<String>.from(map['photoPublicIds'] as List? ?? const []),
      status: status,
      reporterId: reporterId,
      reporterName: reporterName,
      reporterDepartment: map['reporterDepartment'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : createdAt,
      statusHistory: statusHistory,
      staffNote: map['staffNote'] as String?,
    );
  }

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final incident = IncidentModel.fromMap(data);
    if (incident.id.isNotEmpty) return incident;
    return incident.copyWith(id: doc.id);
  }
}
