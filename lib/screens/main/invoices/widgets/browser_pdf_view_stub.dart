import 'dart:typed_data';
import 'package:flutter/widgets.dart';

/// Outside the web the regular PdfPreview is always used.
bool get useBrowserPdfViewer => false;

class BrowserPdfView extends StatelessWidget {
  final Uint8List bytes;

  const BrowserPdfView({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
