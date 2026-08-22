import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// General utility helper functions
class Helpers {
  Helpers._();

  static const Uuid _uuid = Uuid();

  /// Generate a unique ID
  static String generateId() => _uuid.v4();

  /// Generate a short unique code (for invoices, etc.)
  static String generateShortCode([int length = 8]) {
    return _uuid.v4().replaceAll('-', '').substring(0, length).toUpperCase();
  }

  /// Get file extension from path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  static bool isImage(String path) {
    final ext = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  /// Check if file is a document
  static bool isDocument(String path) {
    final ext = getFileExtension(path);
    return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx']
        .contains(ext);
  }

  /// Get file size from File object
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Get MIME type from extension
  static String getMimeType(String extension) {
    final mimeTypes = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'mp3': 'audio/mpeg',
      'mp4': 'video/mp4',
    };
    return mimeTypes[extension.toLowerCase()] ?? 'application/octet-stream';
  }

  /// Calculate reading time for text
  static int calculateReadingTime(String text) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil(); // 200 words per minute
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Debounce helper for search
  static void Function() debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    // BUG-12 FIX: Proper basic debounce mechanism
    // In a real app with state management, it's better to use something like
    // flutter_hooks or a debouncer package, but this works for basic cases
    // if the caller stores the returned function.
    // Note: for this to work correctly, the caller must store and reuse 
    // the returned function, not recreate it on every call.
    bool isActive = false;
    return () {
      if (isActive) return;
      isActive = true;
      Future.delayed(duration, () {
        isActive = false;
        callback();
      });
    };
  }

  /// Calculate platform fee
  static double calculatePlatformFee(double amount) {
    return amount * 0.10; // 10% platform fee
  }

  /// Calculate GST
  static double calculateGST(double amount) {
    return amount * 0.18; // 18% GST
  }

  /// Calculate total with fees
  static Map<String, double> calculateTotalWithFees(double baseAmount) {
    final platformFee = calculatePlatformFee(baseAmount);
    // BUG-16 FIX: Clarified naming. GST applies only to the platform fee, 
    // not the full baseAmount.
    final gstOnPlatformFee = calculateGST(platformFee);
    final total = baseAmount + platformFee + gstOnPlatformFee;

    return {
      'baseAmount': baseAmount,
      'platformFee': platformFee,
      'gst': gstOnPlatformFee,
      'total': total,
    };
  }

  /// Get avatar color from name (for placeholder avatars)
  static Color getAvatarColor(String name) {
    final colors = [
      const Color(0xFF1E90FF),
      const Color(0xFF6C63FF),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];
    final index = name.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    return colors[index];
  }

  /// Mask Aadhaar number (show last 4 digits)
  static String maskAadhaar(String aadhaar) {
    if (aadhaar.length < 4) return aadhaar;
    return 'XXXX XXXX ${aadhaar.substring(aadhaar.length - 4)}';
  }

  /// Mask phone number (show last 4 digits)
  static String maskPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 4) return phone;
    // BUG-14 FIX: Format for 10 digits -> XXXXXX (6 X's) + last 4 = 10 digits
    return '+91 XXXXXX${cleaned.substring(cleaned.length - 4)}';
  }
}
