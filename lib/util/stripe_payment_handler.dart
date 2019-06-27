import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  addCard(token) {
    FirebaseAuth.instance.currentUser().then((user) {
      final DocumentReference docCardsRef =
          Firestore.instance.document("cards/" + user.uid);
      Map<String, String> newCardEntryData = <String, String>{
        "custId": "new",
        "email": user.email,
      };
      docCardsRef.setData(newCardEntryData).whenComplete(() {
        print("Document Added");
      }).catchError((e) => print(e));
      Firestore.instance
          .collection('cards')
          .document(user.uid)
          .collection('tokens')
          .add({'tokenId': token}).then((val) {
        print("token saved");
      });
    });
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
