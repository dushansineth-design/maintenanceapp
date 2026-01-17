import 'citizen.dart';
import 'admin.dart';

class NotificationModel {
  static int _idCounter = 0;
  final String notificationID;
  final String message;
  final DateTime dateTime;

  NotificationModel({
    String? notificationID,
    required this.message,
    DateTime? dateTime,
  })  : notificationID = notificationID ?? 'N${++_idCounter}',
        dateTime = dateTime ?? DateTime.now();

  void sendToCitizen(Citizen citizen) {
    print('[To Citizen ${citizen.citizenID}] $message');
  }

  void sendToAdmin(Admin admin) {
    print('[To Admin ${admin.adminID}] $message');
  }
}
