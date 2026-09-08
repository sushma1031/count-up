import 'package:flutter/widgets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum AppError {
  dbInitFailed,
  unknown,
}

String errorMessageFor(BuildContext context, AppError error) {
  final l10n = AppLocalizations.of(context);
  switch (error) {
    case AppError.dbInitFailed:
      return l10n.dbInitFailedError;
    case AppError.unknown:
      return l10n.unknownError;
  }
}

enum ExportError { empty, fs, platform, unknown }

enum ImportError { format, type, unknown }

String importErrorMessage(BuildContext context, ImportError error) {
  final l10n = AppLocalizations.of(context);
  switch (error) {
    case ImportError.format:
      return l10n.importErrorFormat;
    case ImportError.type:
      return l10n.importErrorType;
    case ImportError.unknown:
      return l10n.importErrorUnknown;
  }
}

String exportErrorMessage(BuildContext context, ExportError error) {
  final l10n = AppLocalizations.of(context);
  switch (error) {
    case ExportError.empty:
      return l10n.exportErrorEmpty;
    case ExportError.fs:
      return l10n.exportErrorFS;
    case ExportError.platform:
      return l10n.exportErrorPlatform;
    case ExportError.unknown:
      return l10n.exportErrorUnknown;
  }
}
