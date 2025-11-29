class GenkaimeshiRepository {
  factory GenkaimeshiRepository() {
    return _instance;
  }

  GenkaimeshiRepository._internal();

  static final GenkaimeshiRepository _instance =
      GenkaimeshiRepository._internal();
}
