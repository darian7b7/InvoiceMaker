import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Firefox blocks reading canvas pixels in strict privacy mode, which
/// PdfPreview needs to turn pages into images. Its built-in PDF viewer
/// works there, so Firefox gets that instead.
bool get useBrowserPdfViewer =>
    web.window.navigator.userAgent.contains('Firefox');

/// Embeds [bytes] as a PDF in an iframe using the browser's PDF viewer.
class BrowserPdfView extends StatefulWidget {
  final Uint8List bytes;

  const BrowserPdfView({super.key, required this.bytes});

  @override
  State<BrowserPdfView> createState() => _BrowserPdfViewState();
}

class _BrowserPdfViewState extends State<BrowserPdfView> {
  static int _nextId = 0;
  late String _viewType;
  late String _url;

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(BrowserPdfView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes)) {
      web.URL.revokeObjectURL(_url);
      _register();
    }
  }

  void _register() {
    final blob = web.Blob(
      <web.BlobPart>[widget.bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    _url = web.URL.createObjectURL(blob);
    _viewType = 'browser-pdf-view-${_nextId++}';
    final url = _url;
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => web.HTMLIFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  @override
  void dispose() {
    web.URL.revokeObjectURL(_url);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
