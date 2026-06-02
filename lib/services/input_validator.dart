import '../constants/app_constants.dart';

/// Input Validator Service
/// Protects against XSS, SQL Injection and other malicious inputs
/// Following SOLID principles (Single Responsibility Principle)
class InputValidator {
  // Private constructor (Singleton pattern)
  InputValidator._();
  static final InputValidator instance = InputValidator._();

  /// Validates and sanitizes user message input
  /// Returns null if valid, error message if invalid
  String? validateMessage(String message) {
    // Check if message is empty
    if (message.trim().isEmpty) {
      return AppConstants.errorMessageEmpty;
    }

    // Check message length
    if (message.length > AppConstants.maxMessageLength) {
      return AppConstants.errorMessageTooLong;
    }

    // Check for minimum length
    if (message.trim().length < AppConstants.minMessageLength) {
      return AppConstants.errorMessageEmpty;
    }

    return null; // Valid
  }

  /// Sanitizes user input to prevent XSS attacks
  /// Removes potentially dangerous characters and patterns
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Remove control characters (except newlines and tabs)
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Remove excessive whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Trim
    sanitized = sanitized.trim();

    // Limit consecutive special characters to prevent pattern abuse
    sanitized = _limitConsecutiveChars(sanitized, '<', 3);
    sanitized = _limitConsecutiveChars(sanitized, '>', 3);
    sanitized = _limitConsecutiveChars(sanitized, '{', 3);
    sanitized = _limitConsecutiveChars(sanitized, '}', 3);
    sanitized = _limitConsecutiveChars(sanitized, '[', 3);
    sanitized = _limitConsecutiveChars(sanitized, ']', 3);

    return sanitized;
  }

  /// Limits consecutive occurrences of a character
  String _limitConsecutiveChars(String text, String char, int maxConsecutive) {
    final pattern = RegExp('\\$char{${maxConsecutive + 1},}');
    return text.replaceAll(pattern, char * maxConsecutive);
  }

  /// Validates email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength
  /// Returns null if valid, error message if invalid
  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermelidir';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermelidir';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir';
    }

    return null; // Valid
  }

  /// Checks if string contains SQL injection patterns
  bool containsSqlInjection(String input) {
    final sqlPatterns = [
      r"('\s*(or|and)\s*'?[0-9])",
      r"(union|select|insert|update|delete|drop|create|alter)",
      r"--",
      r";",
      r"/\*.*?\*/",
    ];

    final lowerInput = input.toLowerCase();

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerInput)) {
        return true;
      }
    }

    return false;
  }

  /// Checks if string contains script injection patterns
  bool containsScriptInjection(String input) {
    final scriptPatterns = [
      r'<\s*script',
      r'javascript:',
      r'onerror\s*=',
      r'onload\s*=',
      r'onclick\s*=',
      r'<\s*iframe',
      r'<\s*object',
      r'<\s*embed',
    ];

    final lowerInput = input.toLowerCase();

    for (final pattern in scriptPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerInput)) {
        return true;
      }
    }

    return false;
  }

  /// Comprehensive security check
  /// Returns error message if malicious pattern detected, null otherwise
  String? performSecurityCheck(String input) {
    if (containsSqlInjection(input)) {
      return 'Güvenlik nedeniyle bu mesaj gönderilemez';
    }

    if (containsScriptInjection(input)) {
      return 'Güvenlik nedeniyle bu mesaj gönderilemez';
    }

    return null; // Safe
  }
}
