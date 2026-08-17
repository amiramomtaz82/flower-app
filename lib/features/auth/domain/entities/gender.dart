enum Gender {
  female,
  male;

  String get value {
    switch (this) {
      case Gender.female:
        return 'Female';
      case Gender.male:
        return 'Male';
    }
  }

  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
      default:
        return Gender.female;
    }
  }
}
