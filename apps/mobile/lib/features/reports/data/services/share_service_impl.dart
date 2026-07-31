import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../domain/services/report_services.dart';

class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject,
        text: text,
      ),
    );
  }
}
