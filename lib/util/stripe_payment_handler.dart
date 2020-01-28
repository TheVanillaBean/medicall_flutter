import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  Future<bool> addCard(token) async {
    await FirebaseAuth.instance.currentUser().then((user) async {
      final DocumentReference docCardsRef =
          Firestore.instance.document("cards/" + user.uid);
      docCardsRef.snapshots().forEach((snap) {
        if (snap.data == null) {
          Map<String, String> newCardEntryData = <String, String>{
            "custId": "new",
            "email": user.email,
          };
          docCardsRef.setData(newCardEntryData).whenComplete(() {
            print("Card Added");
          }).catchError((e) => print(e));
        }
      });
      await Firestore.instance
          .collection('cards')
          .document(user.uid)
          .collection('tokens')
          .add({'tokenId': token}).then((val) {
        print("token saved");
      });
    });
    return true;
  }

  removeCard(id) {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('cards')
          .document(user.uid)
          .collection('sources')
          .document(id)
          .delete()
          .then((docs) {
        print("card deleted");
      });
    });
  }

  chargePayment(price, description) {
    if (price.runtimeType == String) {
      price = price.toString().split('\$')[1];
    }
    var processedPrice = price * 100;
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('cards')
          .document(user.uid)
          .collection('charges')
          .add({
        'currency': 'usd',
        'amount': processedPrice,
        'description': description
      });
    });
  }
}
