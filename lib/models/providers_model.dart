class Provider {
  final String prefix;
  final String firstName;
  final String lastName;
  final String address;
  final String rating;

  Provider({
    this.prefix,
    this.firstName,
    this.lastName,
    this.address,
    this.rating
  });
}

class Providers {
  final List<Provider> providers;

  Providers({
    this.providers,
  });
}