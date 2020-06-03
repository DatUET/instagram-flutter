import 'package:cloud_firestore/cloud_firestore.dart';

class Distance {
  final String id;
  final String name;
  final String profileImageUrl;
  final String email;
  final String bio;
  final String type;
  final bool isActive;
  final double distance;

  Distance({this.id, this.name, this.profileImageUrl, this.email, this.bio,
      this.type, this.isActive, this.distance});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['id'] = this.id;
    map['name'] = this.name;
    map['profileImageUrl'] = this.profileImageUrl;
    map['email'] = this.email;
    map['bio'] = this.bio;
    map['type'] = this.type;
    map['isActive'] = this.isActive;
    map['distance'] = this.distance;
    return map;
  }

  factory Distance.fromMap(DocumentSnapshot doc) {
    double distance = doc['distance'];
    String distanceFormat = distance.toStringAsFixed(distance.truncateToDouble() == distance ? 0 : 2);
    return Distance(
        id: doc.documentID,
        name: doc['name'],
        profileImageUrl: doc['profileImageUrl'],
        email: doc['email'],
        bio: doc['bio'] ?? '',
        type: doc['type'],
        isActive: doc['isActive'],
        distance: double.parse(distanceFormat)
    );
  }
}