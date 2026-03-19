import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createAppHttpClient({bool allowBadCertificates = false}) {
  if (!allowBadCertificates) {
    return http.Client();
  }

  final client = HttpClient()
    ..badCertificateCallback = (X509Certificate _, String __, int ___) => true;
  return IOClient(client);
}
