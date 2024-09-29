import 'package:bugsnag_flutter_performance/src/configuration.dart';
import 'package:bugsnag_flutter_performance/src/span_attributes_limits.dart';
import 'package:flutter/foundation.dart';

class BugsnagPerformanceSpanAttributesEncodingResult {
  final dynamic jsonValue;
  final int droppedAttributesCount;

  BugsnagPerformanceSpanAttributesEncodingResult({
    required this.jsonValue,
    required this.droppedAttributesCount,
  });
}

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

  int get count => attributes.length;

  bool hasAttribute(String key) {
    return attributes.containsKey(key);
  }

  BugsnagPerformanceSpanAttributesEncodingResult toJson({
    BugsnagPerformanceConfiguration? config,
  }) {
    final attributeKeyLengthLimit = SpanAttributesLimits.limitValue(
        type: SpanAttributesLimitType.keyLengthLimit);
    final attributeStringValueLimit = config?.attributeStringValueLimit ??
        SpanAttributesLimits.limitValue(
            type: SpanAttributesLimitType.stringValueLimit);
    final attributeArrayLengthLimit = config?.attributeArrayLengthLimit ??
        SpanAttributesLimits.limitValue(
            type: SpanAttributesLimitType.arrayLengthLimit);

    return BugsnagPerformanceSpanAttributesEncoder(
      attributeKeyLengthLimit: attributeKeyLengthLimit,
      attributeStringValueLimit: attributeStringValueLimit,
      attributeArrayLengthLimit: attributeArrayLengthLimit,
    ).toJson(attributes);
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
}

class BugsnagPerformanceSpanAttributesEncoder {
  int attributeKeyLengthLimit;
  int attributeStringValueLimit;
  int attributeArrayLengthLimit;

  BugsnagPerformanceSpanAttributesEncoder({
    required this.attributeKeyLengthLimit,
    required this.attributeStringValueLimit,
    required this.attributeArrayLengthLimit,
  });

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

  BugsnagPerformanceSpanAttributesEncodingResult toJson(
    Map<String, dynamic> attributes,
  ) {
    final validKeys =
        attributes.keys.where((key) => key.length <= attributeKeyLengthLimit);

    final jsonValue = validKeys.map((key) {
      final value = attributes[key];

      return {
        'key': key,
        'value': _encodeAttributeValue(key, value),
      };
    }).toList();

    return BugsnagPerformanceSpanAttributesEncodingResult(
      jsonValue: jsonValue,
      droppedAttributesCount: attributes.length - validKeys.length,
    );
  }

  dynamic _encodeAttributeValue(
    String key,
    dynamic value,
  ) {
    final runtimeType = value.runtimeType;
    String valueType =
        _typeMap[runtimeType] ?? _listTypeMap[runtimeType] ?? 'stringValue';
    dynamic formattedValue = _formattedValue(key, value);
    return {valueType: formattedValue};
  }

  dynamic _formattedValue(
    String key,
    dynamic value,
  ) {
    if (value is String) {
      if (value.length > attributeStringValueLimit) {
        if (kDebugMode) {
          print(
              'The value for span attribute "$key" was truncated as it exceeds the $attributeStringValueLimit attribute limit set by AttributeStringValueLimit');
        }
        return '${value.substring(0, attributeStringValueLimit)}*** ${value.length - attributeStringValueLimit} CHARS TRUNCATED';
      }
      return value;
    }
    if (value is int) {
      return value.toString();
    }
    if (value is List) {
      return _encodeListAttributeValue(key, value);
    }
    return value;
  }

  dynamic _encodeListAttributeValue(
    String key,
    List listAttribute,
  ) {
    List result = [];
    for (var (index, value) in listAttribute.indexed) {
      final runtimeType = value.runtimeType;
      if (_typeMap[runtimeType] != null) {
        result.add(_encodeAttributeValue(key, value));
      } else {
        if (kDebugMode) {
          print(
              'The element at index $index for span attribute "$key" was excluded as its type is not valid.');
        }
      }
    }
    if (result.length > attributeArrayLengthLimit) {
      if (kDebugMode) {
        print(
            'The value for span attribute "$key" was truncated as it exceeds the $attributeArrayLengthLimit attribute limit set by AttributeArrayLengthLimit');
      }
      result = result.sublist(0, attributeArrayLengthLimit).toList();
    }
    return {'values': result};
  }
}
