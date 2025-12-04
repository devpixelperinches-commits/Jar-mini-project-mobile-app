// my_reader_delegate.dart
import 'package:flutter/foundation.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class MyReaderDelegate extends MobileReaderDelegate {
  @override
  void onReportAvailableUpdate(ReaderSoftwareUpdate update) {
    debugPrint('Update available: ${update.version}');
  }

  @override
  void onBatteryLevelUpdate(
    double batteryLevel,
    BatteryStatus? batteryStatus,
    bool isCharging,
  ) {
    debugPrint('Battery level: $batteryLevel');
  }

  @override
  void onReportLowBatteryWarning() {
    debugPrint('Low battery warning!');
  }

  @override
  void onStartInstallingUpdate(
    ReaderSoftwareUpdate update,
    Cancellable cancelUpdate,
  ) {
    debugPrint('Starting update: ${update.version}');
  }

  @override
  void onReportReaderSoftwareUpdateProgress(double progress) {
    debugPrint('Update progress: ${(progress * 100).toStringAsFixed(1)}%');
  }

  @override
  void onFinishInstallingUpdate(
    ReaderSoftwareUpdate? update,
    TerminalException? exception,
  ) {
    debugPrint('Finished update: ${update?.version ?? 'N/A'}');
  }

  @override
  void onRequestReaderInput(List<ReaderInputOption> options) {
    debugPrint('Reader input requested: $options');
  }

  @override
  void onRequestReaderDisplayMessage(ReaderDisplayMessage message) {
    debugPrint('Reader display message: $message');
  }
}
