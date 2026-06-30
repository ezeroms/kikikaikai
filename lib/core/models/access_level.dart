enum AccessLevel {
  public,
  member,
  resident;

  String get label => switch (this) {
        AccessLevel.public => '誰でも',
        AccessLevel.member => '会員限定',
        AccessLevel.resident => '団地住民限定',
      };
}
