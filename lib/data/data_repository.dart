import 'package:cloud_firestore/cloud_firestore.dart';

class DataRepositroy {
  Future createUser(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();

    Map<String, dynamic> user = {
      'userID': docUser.id,
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
    };

    await docUser.set(user);
  }

  Future addNotificationSetting(
    String name,
    String symbol,
    String criteria,
    double criteriaPercent,
    String userID,
    String screenID,
  ) async {
    final docUser =
        FirebaseFirestore.instance.collection('notifications').doc();

    Map<String, dynamic> item = {
      'id': docUser.id,
      'currencyName': name,
      'currencySymbol': symbol,
      'criteria': criteria,
      'criteriaPercent': criteriaPercent,
      'userID': userID,
      'screenID': screenID,
    };

    await docUser.set(item);
  }

  Future addUpdateToken(String userID, String? token) async {
    final docUpdate =
        FirebaseFirestore.instance.collection('users').doc(userID);

    docUpdate.update(
      {
        'token': token,
      },
    );
  }
}
