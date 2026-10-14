import 'web_download_helper_stub.dart'
    if (dart.library.js_interop) 'web_download_helper_web.dart' as impl;

void downloadFileWeb(List<int> bytes, String filename, String mimeType) {
  impl.downloadFileWebImpl(bytes, filename, mimeType);
}
