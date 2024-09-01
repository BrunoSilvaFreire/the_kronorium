class FormValidators {
  static String? notEmpty(String? value, [String? Function()? and]) {
    if (value?.isEmpty ?? true) {
      return "This field is required";
    }
    if (and != null) {
      return and();
    }
    return null;
  }
}
