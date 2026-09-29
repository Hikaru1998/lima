import 'package:dio/dio.dart';

/// Metadata and authorization only. The player retrieves media from the CDN.
class ApiService {
  ApiService(String baseUrl)
    : client = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
  final Dio client;
}
