import '../models/notification_model.dart';
import '../models/citizen.dart';
import '../models/admin.dart';

class NotificationService {
  void notifyCitizen(Citizen citizen, String message) {
    NotificationModel(message: message).sendToCitizen(citizen);
  }

  void notifyAdmin(Admin admin, String message) {
    NotificationModel(message: message).sendToAdmin(admin);
  }
}
