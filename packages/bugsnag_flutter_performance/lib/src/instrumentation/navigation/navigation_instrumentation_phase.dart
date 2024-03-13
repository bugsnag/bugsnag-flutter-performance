enum NavigationInstrumentationPhase {
  preBuild,
  build,
  appearing,
  loading,
}

extension PhaseName on NavigationInstrumentationPhase {
  String name() {
    switch (this) {
      case NavigationInstrumentationPhase.preBuild:
        return 'pre-build';
      case NavigationInstrumentationPhase.build:
        return 'build';
      case NavigationInstrumentationPhase.appearing:
        return 'appearing';
      case NavigationInstrumentationPhase.loading:
        return 'loading';
    }
  }
}
