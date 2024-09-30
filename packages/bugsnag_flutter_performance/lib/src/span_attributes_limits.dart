enum SpanAttributesLimitType {
  keyLengthLimit,
  stringValueLimit,
  arrayLengthLimit,
  attributeCountLimit,
}

class SpanAttributesLimits {
  static const _attributeKeyLengthLimit = 128;

  static const _defaultAttributeStringValueLimit = 1024;
  static const _minAttributeStringValueLimit = 1;
  static const _maxAttributeStringValueLimit = 10000;

  static const _defaultAttributeArrayLengthLimit = 1000;
  static const _minAttributeArrayLengthLimit = 1;
  static const _maxAttributeArrayLengthLimit = 10000;

  static const _defaultAttributeCountLimit = 128;
  static const _minAttributeCountLimit = 1;
  static const _maxAttributeCountLimit = 1000;

  static int limitValue({
    required SpanAttributesLimitType type,
    int? providedValue,
  }) {
    if (providedValue == null) {
      return _defaultValue(type);
    }
    if (providedValue < _minValue(type)) {
      return _defaultValue(type);
    }
    if (providedValue > _maxValue(type)) {
      return _maxValue(type);
    }
    return providedValue;
  }

  static int _defaultValue(SpanAttributesLimitType type) {
    switch (type) {
      case SpanAttributesLimitType.keyLengthLimit:
        return _attributeKeyLengthLimit;
      case SpanAttributesLimitType.stringValueLimit:
        return _defaultAttributeStringValueLimit;
      case SpanAttributesLimitType.arrayLengthLimit:
        return _defaultAttributeArrayLengthLimit;
      case SpanAttributesLimitType.attributeCountLimit:
        return _defaultAttributeCountLimit;
    }
  }

  static int _minValue(SpanAttributesLimitType type) {
    switch (type) {
      case SpanAttributesLimitType.keyLengthLimit:
        return _attributeKeyLengthLimit;
      case SpanAttributesLimitType.stringValueLimit:
        return _minAttributeStringValueLimit;
      case SpanAttributesLimitType.arrayLengthLimit:
        return _minAttributeArrayLengthLimit;
      case SpanAttributesLimitType.attributeCountLimit:
        return _minAttributeCountLimit;
    }
  }

  static int _maxValue(SpanAttributesLimitType type) {
    switch (type) {
      case SpanAttributesLimitType.keyLengthLimit:
        return _attributeKeyLengthLimit;
      case SpanAttributesLimitType.stringValueLimit:
        return _maxAttributeStringValueLimit;
      case SpanAttributesLimitType.arrayLengthLimit:
        return _maxAttributeArrayLengthLimit;
      case SpanAttributesLimitType.attributeCountLimit:
        return _maxAttributeCountLimit;
    }
  }
}
