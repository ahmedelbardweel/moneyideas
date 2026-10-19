import 'package:moneyideas/core/validation/rules/text_rules.dart';
import 'package:moneyideas/core/validation/validation_error.dart';

/// Metadata of a file picked by the user before upload.
class PickedFileInfo {
  const PickedFileInfo({required this.name, required this.sizeBytes});
  final String name;
  final int sizeBytes;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

/// Rules for uploaded files and multi-select inputs.
abstract final class FileRules {
  static const int defaultMaxBytes = 10 * 1024 * 1024;
  static const List<String> documentExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  static ValidationRule<PickedFileInfo> file({
    List<String> allowed = documentExtensions,
    int maxBytes = defaultMaxBytes,
  }) => (f) {
    if (!allowed.contains(f.extension)) return FileTypeNotAllowedError(allowed);
    if (f.sizeBytes > maxBytes) return FileTooLargeError(maxBytes);
    return null;
  };
}

abstract final class SelectionRules {
  static ValidationRule<Iterable<Object?>> atLeast(int min) =>
      (items) => items.length < min ? SelectionRequiredError(min: min) : null;
}
