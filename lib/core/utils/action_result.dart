class ActionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ActionResult({required this.success, required this.message, this.data});
}
