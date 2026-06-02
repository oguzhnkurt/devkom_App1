import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global error handler for production-ready error management
class ErrorHandler {
  /// Handle async operations with automatic error catching and logging
  Future<T?> handleAsync<T>(
    Future<T> Function() action, {
    String? context,
    bool showUserMessage = true,
    T? fallbackValue,
  }) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      _logSupabaseError(e, context);
      if (showUserMessage) {
        _showUserFriendlyMessage(e);
      }
      return fallbackValue;
    } on AuthException catch (e) {
      _logAuthError(e, context);
      if (showUserMessage) {
        _showUserFriendlyMessage(e);
      }
      return fallbackValue;
    } on StorageException catch (e) {
      _logStorageError(e, context);
      if (showUserMessage) {
        _showUserFriendlyMessage(e);
      }
      return fallbackValue;
    } catch (e, stackTrace) {
      _logUnexpectedError(e, stackTrace, context);
      if (showUserMessage) {
        _showGenericErrorMessage();
      }
      return fallbackValue;
    }
  }

  /// Handle sync operations
  T? handleSync<T>(
    T Function() action, {
    String? context,
    T? fallbackValue,
  }) {
    try {
      return action();
    } catch (e, stackTrace) {
      _logUnexpectedError(e, stackTrace, context);
      return fallbackValue;
    }
  }

  /// Supabase-specific error logging
  void _logSupabaseError(PostgrestException e, String? context) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ SUPABASE ERROR');
    if (context != null) debugPrint('Context: $context');
    debugPrint('Message: ${e.message}');
    debugPrint('Code: ${e.code}');
    debugPrint('Details: ${e.details}');
    debugPrint('Hint: ${e.hint}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // TODO: Send to Sentry/Crashlytics in production
    // Sentry.captureException(e, stackTrace: StackTrace.current);
  }

  void _logAuthError(AuthException e, String? context) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ AUTH ERROR');
    if (context != null) debugPrint('Context: $context');
    debugPrint('Message: ${e.message}');
    debugPrint('Status Code: ${e.statusCode}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _logStorageError(StorageException e, String? context) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ STORAGE ERROR');
    if (context != null) debugPrint('Context: $context');
    debugPrint('Message: ${e.message}');
    debugPrint('Status Code: ${e.statusCode}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _logUnexpectedError(dynamic e, StackTrace stackTrace, String? context) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ UNEXPECTED ERROR');
    if (context != null) debugPrint('Context: $context');
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// User-friendly error messages
  void _showUserFriendlyMessage(dynamic e) {
    String message = _getUserFriendlyMessage(e);
    debugPrint('👤 User Message: $message');
    // TODO: Show SnackBar or Dialog
  }

  void _showGenericErrorMessage() {
    debugPrint('👤 User Message: Bir şeyler ters gitti. Lütfen tekrar deneyin.');
  }

  /// Convert technical errors to user-friendly Turkish messages
  String _getUserFriendlyMessage(dynamic e) {
    if (e is PostgrestException) {
      if (e.code == '23505') return 'Bu kayıt zaten mevcut.';
      if (e.code == '23503') return 'İlişkili kayıt bulunamadı.';
      if (e.code == '42501') return 'Bu işlem için yetkiniz yok.';
      return 'Veritabanı hatası. Lütfen tekrar deneyin.';
    }

    if (e is AuthException) {
      if (e.message.contains('Invalid login credentials')) {
        return 'Hatalı e-posta veya şifre.';
      }
      if (e.message.contains('Email not confirmed')) {
        return 'E-posta adresinizi onaylamanız gerekiyor.';
      }
      if (e.message.contains('User already registered')) {
        return 'Bu e-posta adresi zaten kullanımda.';
      }
      return 'Giriş hatası. Lütfen tekrar deneyin.';
    }

    if (e is StorageException) {
      if (e.statusCode == '413') return 'Dosya çok büyük.';
      if (e.statusCode == '415') return 'Desteklenmeyen dosya türü.';
      return 'Dosya yükleme hatası. Lütfen tekrar deneyin.';
    }

    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Performance monitoring
  Future<T> measurePerformance<T>(
    Future<T> Function() action,
    String operationName,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      // Log slow operations (>1000ms)
      if (duration > 1000) {
        debugPrint('⚠️ SLOW OPERATION: $operationName took ${duration}ms');
      } else {
        debugPrint('✅ $operationName completed in ${duration}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }
}
