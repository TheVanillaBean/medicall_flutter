import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:flutter/cupertino.dart';

class ZipCodeViewModel with ChangeNotifier {
  final NonAuthDatabase nonAuthDatabase;
  final Symptom symptom;

  ZipCodeViewModel({@required this.nonAuthDatabase, @required this.symptom});

  String getState(zipCode) {
    // Ensure we don't parse strings starting with 0 as octal values
    int thisZip = int.parse(zipCode);

    String st;

    // Code blocks alphabetized by state
    if (thisZip >= 35000 && thisZip <= 36999) {
      st = 'AL';
    } else if (thisZip >= 99500 && thisZip <= 99999) {
      st = 'AK';
    } else if (thisZip >= 85000 && thisZip <= 86999) {
      st = 'AZ';
    } else if (thisZip >= 71600 && thisZip <= 72999) {
      st = 'AR';
    } else if (thisZip >= 90000 && thisZip <= 96699) {
      st = 'CA';
    } else if (thisZip >= 80000 && thisZip <= 81999) {
      st = 'CO';
    } else if (thisZip >= 6000 && thisZip <= 6999) {
      st = 'CT';
    } else if (thisZip >= 19700 && thisZip <= 19999) {
      st = 'DE';
    } else if (thisZip >= 32000 && thisZip <= 34999) {
      st = 'FL';
    } else if (thisZip >= 30000 && thisZip <= 31999) {
      st = 'GA';
    } else if (thisZip >= 96700 && thisZip <= 96999) {
      st = 'HI';
    } else if (thisZip >= 83200 && thisZip <= 83999) {
      st = 'ID';
    } else if (thisZip >= 60000 && thisZip <= 62999) {
      st = 'IL';
    } else if (thisZip >= 46000 && thisZip <= 47999) {
      st = 'IN';
    } else if (thisZip >= 50000 && thisZip <= 52999) {
      st = 'IA';
    } else if (thisZip >= 66000 && thisZip <= 67999) {
      st = 'KS';
    } else if (thisZip >= 40000 && thisZip <= 42999) {
      st = 'KY';
    } else if (thisZip >= 70000 && thisZip <= 71599) {
      st = 'LA';
    } else if (thisZip >= 3900 && thisZip <= 4999) {
      st = 'ME';
    } else if (thisZip >= 20600 && thisZip <= 21999) {
      st = 'MD';
    } else if (thisZip >= 1000 && thisZip <= 2799) {
      st = 'MA';
    } else if (thisZip >= 48000 && thisZip <= 49999) {
      st = 'MI';
    } else if (thisZip >= 55000 && thisZip <= 56999) {
      st = 'MN';
    } else if (thisZip >= 38600 && thisZip <= 39999) {
      st = 'MS';
    } else if (thisZip >= 63000 && thisZip <= 65999) {
      st = 'MO';
    } else if (thisZip >= 59000 && thisZip <= 59999) {
      st = 'MT';
    } else if (thisZip >= 27000 && thisZip <= 28999) {
      st = 'NC';
    } else if (thisZip >= 58000 && thisZip <= 58999) {
      st = 'ND';
    } else if (thisZip >= 68000 && thisZip <= 69999) {
      st = 'NE';
    } else if (thisZip >= 88900 && thisZip <= 89999) {
      st = 'NV';
    } else if (thisZip >= 3000 && thisZip <= 3899) {
      st = 'NH';
    } else if (thisZip >= 7000 && thisZip <= 8999) {
      st = 'NJ';
    } else if (thisZip >= 87000 && thisZip <= 88499) {
      st = 'NM';
    } else if (thisZip >= 10000 && thisZip <= 14999) {
      st = 'NY';
    } else if (thisZip >= 43000 && thisZip <= 45999) {
      st = 'OH';
    } else if (thisZip >= 73000 && thisZip <= 74999) {
      st = 'OK';
    } else if (thisZip >= 97000 && thisZip <= 97999) {
      st = 'OR';
    } else if (thisZip >= 15000 && thisZip <= 19699) {
      st = 'PA';
    } else if (thisZip >= 300 && thisZip <= 999) {
      st = 'PR';
    } else if (thisZip >= 2800 && thisZip <= 2999) {
      st = 'RI';
    } else if (thisZip >= 29000 && thisZip <= 29999) {
      st = 'SC';
    } else if (thisZip >= 57000 && thisZip <= 57999) {
      st = 'SD';
    } else if (thisZip >= 37000 && thisZip <= 38599) {
      st = 'TN';
    } else if ((thisZip >= 75000 && thisZip <= 79999) ||
        (thisZip >= 88500 && thisZip <= 88599)) {
      st = 'TX';
    } else if (thisZip >= 84000 && thisZip <= 84999) {
      st = 'UT';
    } else if (thisZip >= 5000 && thisZip <= 5999) {
      st = 'VT';
    } else if (thisZip >= 22000 && thisZip <= 24699) {
      st = 'VA';
    } else if (thisZip >= 20000 && thisZip <= 20599) {
      st = 'DC';
    } else if (thisZip >= 98000 && thisZip <= 99499) {
      st = 'WA';
    } else if (thisZip >= 24700 && thisZip <= 26999) {
      st = 'WV';
    } else if (thisZip >= 53000 && thisZip <= 54999) {
      st = 'WI';
    } else if (thisZip >= 82000 && thisZip <= 83199) {
      st = 'WY';
    } else {
      st = 'none';
    }

    return st;
  }

  Future<bool> areProvidersInArea(String zipCode) async {
    List<String> addresses = await nonAuthDatabase.getAllProviderAddresses();

    for (var address in addresses) {
      String state = '';
      try {
        state = address.split(',')[2].split(' ')[1];
      } catch (e) {}
      String enteredState = getState(zipCode);
      if (state == enteredState) {
        return true;
      }
    }

    return true;
  }
}
