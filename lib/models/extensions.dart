extension StringExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstOfEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
  String get capitalizeFirstLetter => (this?.isNotEmpty ?? false)
      ? '${this[0].toUpperCase()}${this.substring(1)}'
      : this;
  String capitalize() {
    if (this == null || this == "") {
      return "";
    }
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}