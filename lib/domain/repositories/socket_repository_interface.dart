abstract class SocketRepositoryInterface {
  Future<bool> connect(String childId, {String? serverUrl});
  void disconnect();
  void sendStatusUpdate(Map<String, dynamic> status);
  void sendLockAcknowledgment(bool locked, String timestamp);
  void sendEmergencyAlert({String? reason});
  void requestUnlock({String? reason});
  void sendUsageStats(List<Map<String, dynamic>> usageStats);
  Stream<bool> get lockStatusStream;
  Stream<bool> get connectionStatusStream;
  bool get isConnected;
  String? get childId;
}
