class BugsnagPerformanceSpanAttributes {
  final Map<String, dynamic> attributes = {};

  BugsnagPerformanceSpanAttributes({
    String? category,
    String? httpMethod,
    String? url,
    bool? isFirstClass,
    double? samplingProbability,
    String? phase,
    String? appStartType,
    Map<String, dynamic>? additionalAttributes,
  }) {
    setAttribute('bugsnag.span.category', category);
    setAttribute('bugsnag.span.first_class', isFirstClass);
    setAttribute('bugsnag.sampling.p', samplingProbability);
    setAttribute('bugsnag.phase', phase);
    setAttribute('bugsnag.app_start.type', appStartType);
    setAttribute('http.method', httpMethod);
    setAttribute('http.url', url);
    additionalAttributes?.forEach((key, value) {
      setAttribute(key, value);
    });
  }

  void setAttribute(String key, dynamic value) {
    if (value != null) {
      attributes[key] = value;
    }
  }

  set httpStatusCode(int httpStatusCode) {
    setAttribute('http.status_code', httpStatusCode);
  }

  set requestContentLength(int requestContentLength) {
    setAttribute('http.request_content_length', requestContentLength);
  }

  set responseContentLength(int responseContentLength) {
    setAttribute('http.response_content_length', responseContentLength);
  }

  set samplingProbability(double? samplingProbability) {
    setAttribute('bugsnag.sampling.p', samplingProbability);
  }

  double? get samplingProbability {
    return attributes['bugsnag.sampling.p'];
  }

  dynamic toJson() {
    const typeMap = {
      bool: 'boolValue',
      double: 'doubleValue',
      int: 'intValue',
      String: 'stringValue',
    };

    return attributes.entries.map((entry) {
      final key = entry.key;
      final value = entry.value;
      String valueType = typeMap[value.runtimeType] ?? 'stringValue';
      dynamic formattedValue = value is int ? value.toString() : value;

      return {
        'key': key,
        'value': {valueType: formattedValue},
      };
    }).toList();
  }

  factory BugsnagPerformanceSpanAttributes.fromJson(
      List<Map<String, dynamic>> json) {
    final attributes = <String, dynamic>{};
    for (var element in json) {
      final key = element['key'];
      final Map<String, dynamic> valueMap = element['value'];
      dynamic value;

      if (valueMap.containsKey('stringValue')) {
        value = valueMap['stringValue'];
      } else if (valueMap.containsKey('boolValue')) {
        value = valueMap['boolValue'];
      } else if (valueMap.containsKey('doubleValue')) {
        value = double.tryParse(valueMap['doubleValue'].toString());
      } else if (valueMap.containsKey('intValue')) {
        value = int.tryParse(valueMap['intValue']);
      }

      if (key != null && value != null) {
        attributes[key] = value;
      }
    }
    return BugsnagPerformanceSpanAttributes(additionalAttributes: attributes);
  }
}
