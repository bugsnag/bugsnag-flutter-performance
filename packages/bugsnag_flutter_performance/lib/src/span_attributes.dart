class BugsnagPerformanceSpanAttributes {
  BugsnagPerformanceSpanAttributes({
    this.category = 'custom',
    this.isFirstClass,
    this.samplingProbability = 1.0,
    this.phase,
    this.connectionType,
    this.url,
    this.httpMethod,
    this.httpStatusCode,
    this.request_content_length,
    this.response_content_length
  });

  final String category;
  final bool? isFirstClass;
  double samplingProbability;
  final String? phase;
  late final String? connectionType;
  late final String? url;
  late final String? httpMethod;
  late final int? httpStatusCode;
  late final int? request_content_length;
  late final int? response_content_length;

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
    connectionType = _value(
          json: json,
          key: 'net.host.connection.type',
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
    request_content_length = _value(
          json: json,
          key: 'http.request_content_length',
          type: _ParameterType.double,
        ) as int?,
    response_content_length = _value(
          json: json,
          key: 'http.response_content_length',
          type: _ParameterType.double,
        ) as int?;

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
        if (connectionType != null)
          {
            'key': 'net.host.connection.type',
            'value': {
              'stringValue': connectionType,
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
              'doubleValue': httpStatusCode,
            }
          },
        if (request_content_length != null)
          {
            'key': 'http.request_content_length',
            'value': {
              'doubleValue': request_content_length,
            }
          },
        if (response_content_length != null)
          {
            'key': 'http.response_content_length',
            'value': {
              'doubleValue': response_content_length,
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
