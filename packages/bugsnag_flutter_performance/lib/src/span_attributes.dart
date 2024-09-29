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
    } else {
      attributes.remove(key);
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
    return attributes.entries.map((entry) {
      final key = entry.key;
      final value = entry.value;

      return {
        'key': key,
        'value': _encodeAttributeValue(value),
      };
    }).toList();
  }

  factory BugsnagPerformanceSpanAttributes.fromJson(
      List<Map<String, dynamic>> json) {
    final attributes = <String, dynamic>{};
    for (var element in json) {
      final key = element['key'];
      dynamic value = _decodeAttributeValue(element['value']);

      if (key != null && value != null) {
        attributes[key] = value;
      }
    }
    return BugsnagPerformanceSpanAttributes(additionalAttributes: attributes);
  }

  static const _typeMap = {
    bool: 'boolValue',
    double: 'doubleValue',
    int: 'intValue',
    String: 'stringValue'
  };

  static const _listTypeMap = {
    List<bool>: 'arrayValue',
    List<double>: 'arrayValue',
    List<int>: 'arrayValue',
    List<String>: 'arrayValue',
    List<Object>: 'arrayValue'
  };

  static dynamic _decodeAttributeValue(Map<String, dynamic> valueMap) {
    if (valueMap.containsKey('stringValue')) {
      return valueMap['stringValue'];
    } else if (valueMap.containsKey('boolValue')) {
      return valueMap['boolValue'];
    } else if (valueMap.containsKey('doubleValue')) {
      return double.tryParse(valueMap['doubleValue'].toString());
    } else if (valueMap.containsKey('intValue')) {
      return int.tryParse(valueMap['intValue']);
    } else if (valueMap.containsKey('arrayValue')) {
      final arrayValue = valueMap['arrayValue'];
      if (arrayValue is Map<String, List> && arrayValue.containsKey('values')) {
        List result = [];
        for (var element in arrayValue['values']!) {
          dynamic decodedValue = _decodeAttributeValue(element);
          if (decodedValue != null) {
            result.add(decodedValue);
          }
        }
        return result;
      }
    }
    return null;
  }

  dynamic _encodeAttributeValue(dynamic value) {
    final runtimeType = value.runtimeType;
    String valueType =
        _typeMap[runtimeType] ?? _listTypeMap[runtimeType] ?? 'stringValue';
    dynamic formattedValue = _formattedValue(value);
    return {valueType: formattedValue};
  }

  dynamic _formattedValue(dynamic value) {
    if (value is int) {
      return value.toString();
    }
    if (value is List) {
      return _encodeListAttributeValue(value);
    }
    return value;
  }

  dynamic _encodeListAttributeValue(List listAttribute) {
    List result = [];
    for (var value in listAttribute) {
      final runtimeType = value.runtimeType;
      if (_typeMap[runtimeType] != null) {
        result.add(_encodeAttributeValue(value));
      }
    }
    return {'values': result};
  }
}
