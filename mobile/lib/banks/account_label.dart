/// An account reads as its name and the last few digits of its number. Not every account has one -
/// an Apple Cash balance has nothing to print - and dots with nothing after them say less than the
/// name on its own.
String accountLabel(String name, String? number) =>
    number == null || number.isEmpty ? name : '$name ••••$number';
