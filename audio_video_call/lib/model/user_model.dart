class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  bool? status;
  String? roomId;
  bool? callStatus;
  bool? audiocallStatus;
  String? type;
  String? token;
  UserModel(
      {this.uid,
      this.email,
      this.firstName,
      this.secondName,
      this.status,
      this.callStatus,
      this.roomId,
      this.token,
      this.type,
      this.audiocallStatus});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      secondName: map['secondName'],
      status: map['status'],
      callStatus: map['callStatus'],
      roomId: map['roomId'],
      audiocallStatus: map['audiocallStatus'],
      type: map['type'],
      token: map['token'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'status': status,
      'roomId': roomId,
      'callStatus': callStatus,
      'audiocallStatus': audiocallStatus,
      'type': type,
      'token': token,
    };
  }
}
