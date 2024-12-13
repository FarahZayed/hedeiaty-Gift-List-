import 'package:hedieaty/data/db.dart';


class SyncManager {
  static final SyncManager _instance = SyncManager._();

  SyncManager._();

  factory SyncManager() => _instance;

  Future<void> syncAllUnsyncedData(String userID) async {
    print("SYNCING...");
    await LocalDatabase().syncUnsyncedData(userID);
  }
}
