

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../providers/auth_provider.dart';

enum ApplicationState { idle, loading, success, error }

class ApplicationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider?        _authProvider;
  List<ApplicationModel> _applications = [];
  ApplicationModel?    _myApplication;
  ApplicationState     _state          = ApplicationState.idle;
  String?              _errorMessage;
  String?              _successMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<ApplicationModel> get applications   => _applications;
  ApplicationModel?      get myApplication  => _myApplication;
  ApplicationState       get state          => _state;
  String?                get errorMessage   => _errorMessage;
  String?                get successMessage => _successMessage;
  bool                   get isLoading      => _state == ApplicationState.loading;
  bool                   get hasApplication => _myApplication != null;

  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
        fetchAllApplications();
      } else {
        fetchMyApplication();
      }
    }
  }

  void _setState(ApplicationState s) {
    _state = s;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
  }

  // ─── Ensure session is fresh before any Supabase call ────────────────────────
  Future<void> _ensureSession() async {
    await _authProvider?.ensureValidSession();
  }

  // ─── Upload Document (non-blocking — never fails the whole submission) ────────
  Future<String?> _uploadDocument(File file, String userId) async {
    try {
      // Ensure the bucket exists by trying to list it first
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      await _supabase.storage
          .from('application_documents')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // overwrite if same name exists
            ),
          );

      final url = _supabase.storage
          .from('application_documents')
          .getPublicUrl(fileName);

      debugPrint('Document uploaded: $url');
      return url;
    } catch (e) {
      // Log but DO NOT throw — a failed upload should not block submission
      debugPrint('Document upload failed (non-critical): $e');
      return null;
    }
  }

  // ─── READ: Fetch My Application ──────────────────────────────────────────────
  Future<void> fetchMyApplication() async {
    if (_authProvider?.userId == null || _authProvider!.userId.isEmpty) return;
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();
      final data = await _supabase
          .from('applications')
          .select()
          .eq('user_id', _authProvider!.userId)
          .maybeSingle();

      _myApplication = data != null ? ApplicationModel.fromJson(data) : null;
      _setState(ApplicationState.success);
    } catch (e) {
      debugPrint('fetchMyApplication error: $e');
      _errorMessage = 'Failed to load your application.';
      _setState(ApplicationState.error);
    }
  }

  // ─── READ: Admin — Fetch All Applications ────────────────────────────────────
  Future<void> fetchAllApplications({String? statusFilter}) async {
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();

      List<dynamic> data;
      if (statusFilter != null && statusFilter != 'all') {
        data = await _supabase
            .from('applications')
            .select()
            .eq('status', statusFilter)
            .order('created_at', ascending: false);
      } else {
        data = await _supabase
            .from('applications')
            .select()
            .order('created_at', ascending: false);
      }

      _applications =
          (data).map((e) => ApplicationModel.fromJson(e)).toList();
      _setState(ApplicationState.success);
    } catch (e) {
      debugPrint('fetchAllApplications error: $e');
      _errorMessage = 'Failed to load applications.';
      _setState(ApplicationState.error);
    }
  }

  // ─── CREATE: Submit New Application ──────────────────────────────────────────
  Future<bool> submitApplication({
    required ApplicationModel application,
    File? documentFile,
  }) async {
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();

      String? documentUrl;
      String  documentName = application.documentName;

      // Upload document if provided — failure here does NOT block submission
      if (documentFile != null) {
        documentUrl  = await _uploadDocument(documentFile, _authProvider!.userId);
        documentName = documentFile.path.split('/').last;
      }

      final appToInsert = application.copyWith(
        documentUrl:  documentUrl,
        documentName: documentName,
      );

      final response = await _supabase
          .from('applications')
          .insert(appToInsert.toJson())
          .select()
          .single();

      _myApplication  = ApplicationModel.fromJson(response);
      _successMessage = documentFile != null && documentUrl == null
          ? 'Application submitted! (Document upload failed — you can re-upload by editing your application.)'
          : 'Application submitted successfully!';

      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      debugPrint('submitApplication error: $e');
      _errorMessage = 'Failed to submit application. Please try again.';
      _setState(ApplicationState.error);
      return false;
    }
  }

  // ─── UPDATE: Edit Application ─────────────────────────────────────────────────
  Future<bool> updateApplication({
    required String applicationId,
    required ApplicationModel application,
    File? newDocumentFile,
  }) async {
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();

      String? documentUrl  = application.documentUrl;
      String  documentName = application.documentName;

      // Upload new document if provided — failure does NOT block update
      if (newDocumentFile != null) {
        final uploaded = await _uploadDocument(
          newDocumentFile,
          _authProvider!.userId,
        );
        if (uploaded != null) {
          documentUrl  = uploaded;
          documentName = newDocumentFile.path.split('/').last;
        }
      }

      final updatedApp = application.copyWith(
        documentUrl:  documentUrl,
        documentName: documentName,
        updatedAt:    DateTime.now(),
      );

      final response = await _supabase
          .from('applications')
          .update(updatedApp.toJson())
          .eq('id', applicationId)
          .select()
          .single();

      _myApplication  = ApplicationModel.fromJson(response);
      _successMessage = 'Application updated successfully!';
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      debugPrint('updateApplication error: $e');
      _errorMessage = 'Failed to update application. Please try again.';
      _setState(ApplicationState.error);
      return false;
    }
  }

  // ─── DELETE: Remove Application ──────────────────────────────────────────────
  Future<bool> deleteApplication(String applicationId) async {
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();
      await _supabase.from('applications').delete().eq('id', applicationId);
      _myApplication  = null;
      _successMessage = 'Application deleted successfully.';
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      debugPrint('deleteApplication error: $e');
      _errorMessage = 'Failed to delete application.';
      _setState(ApplicationState.error);
      return false;
    }
  }

  // ─── ADMIN UPDATE: Approve / Reject ──────────────────────────────────────────
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? comment,
  }) async {
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();
      await _supabase.from('applications').update({
        'status':        status,
        'admin_comment': comment,
        'updated_at':    DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      final idx = _applications.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        _applications[idx] = _applications[idx].copyWith(
          status:       status,
          adminComment: comment,
        );
      }
      _successMessage =
          'Application ${status == 'approved' ? 'approved' : 'rejected'}.';
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      debugPrint('updateApplicationStatus error: $e');
      _errorMessage = 'Failed to update status.';
      _setState(ApplicationState.error);
      return false;
    }
  }

  // ─── ADMIN DELETE ─────────────────────────────────────────────────────────────
  Future<bool> adminDeleteApplication(String applicationId) async {
    _setState(ApplicationState.loading);
    try {
      await _ensureSession();
      await _supabase.from('applications').delete().eq('id', applicationId);
      _applications.removeWhere((a) => a.id == applicationId);
      _successMessage = 'Application removed.';
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      debugPrint('adminDeleteApplication error: $e');
      _errorMessage = 'Failed to remove application.';
      _setState(ApplicationState.error);
      return false;
    }
  }
}
