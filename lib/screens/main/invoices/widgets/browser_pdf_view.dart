// Shows a PDF with the browser's own viewer; only available on the web.
export 'browser_pdf_view_stub.dart'
    if (dart.library.js_interop) 'browser_pdf_view_web.dart';
