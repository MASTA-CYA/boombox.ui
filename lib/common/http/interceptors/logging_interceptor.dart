import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    Logger.logAsync(
      LogEvent<LoggingInterceptor>(
        severity: Severity.debug,
        tag: Tag.http,
        line: data.toString(),
      ),
    );

    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode > 400) {
      Logger.logAsync(
        LogEvent<LoggingInterceptor>(
          severity: Severity.debug,
          tag: Tag.http,
          line: data.toString(),
        ),
      );
    }

    return data;
  }
}
