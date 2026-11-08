import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/incident_model.dart';

abstract class IncidentRepository {
  Stream<List<IncidentModel>> getUserIncidents(String userId);
  Stream<List<IncidentModel>> getAllIncidents();
  Stream<IncidentModel> getIncidentById(String id);
  Future<String> createIncident({
    required String title,
    required String description,
    required IncidentCategory category,
    required IncidentPriority priority,
    required String location,
    String? locationDetails,
    required List<String> photoUrls,
    required List<String> photoPublicIds,
    required UserModel reporter,
  });
  Future<void> updateIncident(String id, Map<String, dynamic> updates);
  Future<void> deleteIncident(String id);
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required UserModel updatedBy,
    String? note,
  });
}

class FirebaseIncidentRepository implements IncidentRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  FirebaseIncidentRepository({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = const Uuid();

  @override
  Stream<List<IncidentModel>> getUserIncidents(String userId) {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return IncidentModel.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<List<IncidentModel>> getAllIncidents() {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return IncidentModel.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<IncidentModel> getIncidentById(String id) {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('Incident not found');
      }
      return IncidentModel.fromFirestore(doc);
    });
  }

  @override
  Future<String> createIncident({
    required String title,
    required String description,
    required IncidentCategory category,
    required IncidentPriority priority,
    required String location,
    String? locationDetails,
    required List<String> photoUrls,
    required List<String> photoPublicIds,
    required UserModel reporter,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();

      final initialHistory = StatusHistoryEntry(
        status: IncidentStatus.submitted,
        updatedBy: reporter.uid,
        updatedByName: reporter.fullName,
        note: null,
        timestamp: now,
      );

      final incident = IncidentModel(
        id: id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        location: location,
        locationDetails: locationDetails,
        photoUrls: photoUrls,
        photoPublicIds: photoPublicIds,
        status: IncidentStatus.submitted,
        reporterId: reporter.uid,
        reporterName: reporter.fullName,
        reporterDepartment: reporter.department,
        createdAt: now,
        updatedAt: now,
        statusHistory: [initialHistory],
        staffNote: null,
      );

      await _firestore
          .collection(AppConstants.incidentsCollection)
          .doc(id)
          .set(incident.toMap());

      return id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateIncident(String id, Map<String, dynamic> updates) async {
    try {
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AppConstants.incidentsCollection)
          .doc(id)
          .update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteIncident(String id) async {
    try {
      await _firestore
          .collection(AppConstants.incidentsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required UserModel updatedBy,
    String? note,
  }) async {
    try {
      // Verify staff role
      if (updatedBy.role != UserRole.staff) {
        throw Exception('Only staff can update incident status');
      }

      final doc = await _firestore
          .collection(AppConstants.incidentsCollection)
          .doc(incidentId)
          .get();

      if (!doc.exists) {
        throw Exception('Incident not found');
      }

      final incident = IncidentModel.fromFirestore(doc);

      // Validate status transition
      _validateStatusTransition(incident.status, newStatus);

      final newHistoryEntry = StatusHistoryEntry(
        status: newStatus,
        updatedBy: updatedBy.uid,
        updatedByName: updatedBy.fullName,
        note: note,
        timestamp: DateTime.now(),
      );

      final updatedHistory = [...incident.statusHistory, newHistoryEntry];

      await _firestore
          .collection(AppConstants.incidentsCollection)
          .doc(incidentId)
          .update({
        'status': newStatus.value,
        'statusHistory': updatedHistory.map((e) => e.toMap()).toList(),
        'staffNote': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for reporter
      await _createNotification(
        userId: incident.reporterId,
        incidentId: incidentId,
        title: 'Status Update',
        message: 'Your report "${incident.title}" has been updated to ${newStatus.displayName}.',
      );
    } catch (e) {
      rethrow;
    }
  }

  void _validateStatusTransition(
    IncidentStatus currentStatus,
    IncidentStatus newStatus,
  ) {
    if (currentStatus == newStatus) {
      throw Exception('Status is already ${newStatus.displayName}');
    }

    // Allowed transitions:
    // submitted -> in_progress
    // in_progress -> resolved
    // resolved -> in_progress (reopen)
    
    if (currentStatus == IncidentStatus.submitted &&
        newStatus != IncidentStatus.inProgress) {
      throw Exception('Can only move Submitted reports to In Progress');
    }

    if (currentStatus == IncidentStatus.inProgress &&
        newStatus == IncidentStatus.submitted) {
      throw Exception('Cannot move back to Submitted');
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String incidentId,
    required String title,
    required String message,
  }) async {
    final id = _uuid.v4();
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(id)
        .set({
      'id': id,
      'userId': userId,
      'incidentId': incidentId,
      'title': title,
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
