

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User?   _user;
  bool    _isLoading  = true;
  bool    _isAdmin    = false;
  String? _errorMessage;
  Timer?  _refreshTimer;

  // ─── Getters ────────────────────────────────────────────────────────────────
  User?   get user            => _user;
  bool    get isLoading       => _isLoading;
  bool    get isAuthenticated => _user != null;
  bool    get isAdmin         => _isAdmin;
  String? get errorMessage    => _errorMessage;
  String  get userId          => _user?.id ?? '';
  String  get userEmail       => _user?.email ?? '';
  String  get userFullName    =>
      _user?.userMetadata?['full_name'] ?? 'Student';

  AuthProvider() {
    _init();
  }

  // ─── Init ────────────────────────────────────────────────────────────────────
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _user = _supabase.auth.currentUser;

    if (_user != null) {
      await _refreshSession();
      await _checkAdminRole();
      _startRefreshTimer();
    }

    _isLoading = false;
    notifyListeners();

    _supabase.auth.onAuthStateChange.listen((data) async {
      final event   = data.event;
      final session = data.session;

      debugPrint('Auth event: $event');

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        _user = session?.user;
        if (_user != null) {
          await _checkAdminRole();
          _startRefreshTimer();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _user    = null;
        _isAdmin = false;
        _stopRefreshTimer();
      }
      notifyListeners();
    });
  }

  // ─── Session Refresh ─────────────────────────────────────────────────────────
  Future<void> _refreshSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final expiry      = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        final fiveMinsOut = DateTime.now().add(const Duration(minutes: 5));
        if (expiry.isBefore(fiveMinsOut)) {
          debugPrint('Token expiring soon — refreshing...');
          await _supabase.auth.refreshSession();
          _user = _supabase.auth.currentUser;
          debugPrint('Token refreshed successfully.');
        }
      }
    } catch (e) {
      debugPrint('Session refresh error: $e');
    }
  }

  /// Call this before any Supabase operation to ensure the token is valid.
  Future<void> ensureValidSession() async {
    await _refreshSession();
  }

  // ─── Auto-refresh Timer ──────────────────────────────────────────────────────
  void _startRefreshTimer() {
    _stopRefreshTimer();
    _refreshTimer = Timer.periodic(const Duration(minutes: 50), (_) async {
      debugPrint('Auto-refreshing Supabase session...');
      try {
        await _supabase.auth.refreshSession();
        _user = _supabase.auth.currentUser;
        debugPrint('Session auto-refreshed.');
      } catch (e) {
        debugPrint('Auto-refresh failed: $e');
      }
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // ─── Check Admin Role ────────────────────────────────────────────────────────
  Future<void> _checkAdminRole() async {
    if (_user == null) return;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _supabase
            .from('user_profiles')
            .select('role')
            .eq('user_id', _user!.id)
            .maybeSingle();

        if (response != null) {
          _isAdmin = response['role'] == 'admin';
          return;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('_checkAdminRole attempt $attempt error: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    _isAdmin = false;
  }

  // ─── Sign In ─────────────────────────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email:    email.trim(),
        password: password,
      );
      _user = response.user;

      if (_user != null) {
        await _checkAdminRole();
        _startRefreshTimer();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Sign in failed. Please try again.';
      _isLoading    = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
      _isLoading    = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('signIn error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign Up ─────────────────────────────────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email:    email.trim(),
        password: password,
        data:     {'full_name': fullName},
      );

      if (response.user != null && response.session != null) {
        _user = response.user;
        await _checkAdminRole();
        _startRefreshTimer();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.user != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Registration failed. Please try again.';
      _isLoading    = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
      _isLoading    = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('signUp error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    _stopRefreshTimer();
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
    _user    = null;
    _isAdmin = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    } else if (message.contains('Email not confirmed')) {
      return 'Please verify your email address before signing in.';
    } else if (message.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (message.contains('Password should be')) {
      return 'Password must be at least 6 characters long.';
    }
    return message;
  }

  @override
  void dispose() {
    _stopRefreshTimer();
    super.dispose();
  }
}
