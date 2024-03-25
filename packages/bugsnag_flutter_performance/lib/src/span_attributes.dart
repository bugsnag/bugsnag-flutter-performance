class BugsnagPerformanceSpanAttributes {
  BugsnagPerformanceSpanAttributes({
    this.category = 'custom',
    this.isFirstClass,
    this.samplingProbability = 1.0,
    this.phase,
    this.url,
    this.httpMethod,
    this.httpStatusCode,
    this.requestContentLength,
    this.responseContentLength,
    this.appStartType,
    this.navigationRoute,
    this.navigatorName,
    this.navigationTriggeredBy,
    this.navigationEndedBy,
    this.navigationPreviousRoute,
  });

  final String category;
  final bool? isFirstClass;
  double samplingProbability;
  final String? phase;
  String? url;
  String? httpMethod;
  int? httpStatusCode;
  int? requestContentLength;
  int? responseContentLength;
  final String? appStartType;
  final String? navigationRoute;
  final String? navigatorName;
  final String? navigationTriggeredBy;
  String? navigationEndedBy;
  final String? navigationPreviousRoute;

  BugsnagPerformanceSpanAttributes.fromJson(dynamic json)
      : category = _value(
              json: json,
              key: 'bugsnag.span.category',
              type: _ParameterType.string,
            ) as String? ??
            'custom',
        isFirstClass = _value(
          json: json,
          key: 'bugsnag.span.first_class',
          type: _ParameterType.bool,
        ) as bool?,
        samplingProbability = _value(
              json: json,
              key: 'bugsnag.sampling.p',
              type: _ParameterType.double,
            ) as double? ??
            1.0,
        phase = _value(
          json: json,
          key: 'bugsnag.phase',
          type: _ParameterType.string,
        ) as String?,
        appStartType = _value(
          json: json,
          key: 'bugsnag.app_start.type',
          type: _ParameterType.string,
        ) as String?,
        url = _value(
          json: json,
          key: 'http.url',
          type: _ParameterType.string,
        ) as String?,
        httpMethod = _value(
          json: json,
          key: 'http.method',
          type: _ParameterType.string,
        ) as String?,
        httpStatusCode = _value(
          json: json,
          key: 'http.status_code',
          type: _ParameterType.double,
        ) as int?,
        requestContentLength = _value(
          json: json,
          key: 'http.request_content_length',
          type: _ParameterType.double,
        ) as int?,
        responseContentLength = _value(
          json: json,
          key: 'http.response_content_length',
          type: _ParameterType.double,
        ) as int?,
        navigationRoute = _value(
          json: json,
          key: 'bugsnag.navigation.route',
          type: _ParameterType.string,
        ) as String?,
        navigatorName = _value(
          json: json,
          key: 'bugsnag.navigation.navigator',
          type: _ParameterType.string,
        ) as String?,
        navigationTriggeredBy = _value(
          json: json,
          key: 'bugsnag.navigation.triggered_by',
          type: _ParameterType.string,
        ) as String?,
        navigationEndedBy = _value(
          json: json,
          key: 'bugsnag.navigation.ended_by',
          type: _ParameterType.string,
        ) as String?,
        navigationPreviousRoute = _value(
          json: json,
          key: 'bugsnag.navigation.previous_route',
          type: _ParameterType.string,
        ) as String?;

  dynamic toJson() => [
        {
          'key': 'bugsnag.span.category',
          'value': {
            'stringValue': category,
          },
        },
        if (isFirstClass != null)
          {
            'key': 'bugsnag.span.first_class',
            'value': {
              'boolValue': isFirstClass,
            },
          },
        {
          'key': 'bugsnag.sampling.p',
          'value': {
            'doubleValue': samplingProbability,
          },
        },
        if (phase != null)
          {
            'key': 'bugsnag.phase',
            'value': {
              'stringValue': phase,
            }
          },
        if (appStartType != null)
          {
            'key': 'bugsnag.app_start.type',
            'value': {
              'stringValue': appStartType,
            }
          },
        if (url != null)
          {
            'key': 'http.url',
            'value': {
              'stringValue': url,
            }
          },
        if (httpMethod != null)
          {
            'key': 'http.method',
            'value': {
              'stringValue': httpMethod,
            }
          },
        if (httpStatusCode != null)
          {
            'key': 'http.status_code',
            'value': {
              'intValue':
                  httpStatusCode.toString(), //integerValue should be a string
            }
          },
        if (requestContentLength != null && requestContentLength != 0)
          {
            'key': 'http.request_content_length',
            'value': {
              'intValue': requestContentLength
                  .toString(), //integerValue should be a string
            }
          },
        if (responseContentLength != null && responseContentLength != 0)
          {
            'key': 'http.response_content_length',
            'value': {
              'intValue': responseContentLength
                  .toString(), //integerValue should be a string
            }
          },
        if (navigationRoute != null)
          {
            'key': 'bugsnag.navigation.route',
            'value': {
              'stringValue': navigationRoute,
            }
          },
        if (navigatorName != null)
          {
            'key': 'bugsnag.navigation.navigator',
            'value': {
              'stringValue': navigatorName,
            }
          },
        if (navigationTriggeredBy != null)
          {
            'key': 'bugsnag.navigation.triggered_by',
            'value': {
              'stringValue': navigationTriggeredBy,
            }
          },
        if (navigationEndedBy != null)
          {
            'key': 'bugsnag.navigation.ended_by',
            'value': {
              'stringValue': navigationEndedBy,
            }
          },
        if (navigationPreviousRoute != null)
          {
            'key': 'bugsnag.navigation.previous_route',
            'value': {
              'stringValue': navigationPreviousRoute,
            }
          }
      ];
}

enum _ParameterType { string, double, bool }

dynamic _value({
  required dynamic json,
  required String key,
  required _ParameterType type,
}) {
  final attributes = json as List<Map<String, dynamic>>?;
  if (attributes == null) {
    return null;
  }
  final entry =
      attributes.where((element) => element['key'] == key).firstOrNull;
  if (entry == null) {
    return null;
  }
  switch (type) {
    case _ParameterType.string:
      return entry['value']['stringValue'];
    case _ParameterType.double:
      return entry['value']['doubleValue'];
    case _ParameterType.bool:
      return entry['value']['boolValue'];
  }
}
