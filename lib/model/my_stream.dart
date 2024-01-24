import 'package:cloud_firestore/cloud_firestore.dart';

class MyStream {
  String title;
  String channel;
  String username;
  String url;
  int viewers;
  Timestamp started;

  MyStream(this.title, this.channel, this.username, this.url, this.viewers,
      this.started);

  static MyStream fromMap(Map<String, dynamic> map) => MyStream(
      map['title'],
      map['channel'],
      map['username'],
      map['url'],
      map['viewers'],
      map['started']);

  static const appID = '3b976354de434dfdbb93b69b48f3fb21';
  static const token =
      '007eJxTYJDQ5IsKSxLQ9aviWDi9PCIujvHf/y1T14TO6/bubtf4PFWBwTjJ0tzM2NQkJdXE2CQlLSUpydI4ycwyycQizTgtycgwz2RDakMgI4PawkIGRigE8VkYSlJzCxgYAH/tHT0=';
}
