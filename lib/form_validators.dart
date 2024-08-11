class FormValidators {
  static String? notEmpty(String? value) {
    if (value?.isEmpty ?? true) {
      return "This field is required";
    }
    return null;
  }
}
