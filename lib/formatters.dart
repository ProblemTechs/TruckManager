/// Exact cents formatting without floating-point rounding or locale ambiguity.
String money(int cents) {
  final absolute = cents.abs();
  final whole = grouped(absolute ~/ 100);
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  return '${cents < 0 ? '-' : ''}\$$whole.$fraction';
}

String grouped(int value) {
  final digits = value.abs().toString();
  final result = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '${value < 0 ? '-' : ''}$result';
}
