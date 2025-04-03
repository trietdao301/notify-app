enum Day {
  monday("Monday"),
  tuesday("Tuesday"),
  wednesday("Wednesday"),
  thursday("Thursday"),
  friday("Friday"),
  saturday("Saturday"),
  sunday("Sunday");

  final String name;
  const Day(this.name);

  factory Day.fromString(String input) {
    for (Day day in Day.values) {
      if (day.name == input) {
        return day;
      }
    }
    throw Exception("Error in Day fromString");
  }
}
