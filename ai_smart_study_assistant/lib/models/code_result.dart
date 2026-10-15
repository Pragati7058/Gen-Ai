/// Result of the code generator.
class CodeResult {
  final String title;
  final String language;
  final String code;
  final String explanation;
  final List<String> widgetsUsed;

  const CodeResult({
    required this.title,
    required this.language,
    required this.code,
    required this.explanation,
    required this.widgetsUsed,
  });
}
