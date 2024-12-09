import 'package:hedieaty/data/db.dart';


class SyncManager {
  static final SyncManager _instance = SyncManager._();

  SyncManager._();

  factory SyncManager() => _instance;

  Future<void> syncAllUnsyncedData() async {
    print("SYNCING...");
    await LocalDatabase().syncUnsyncedData(); // Adjust this method based on your implementation
  }
}
