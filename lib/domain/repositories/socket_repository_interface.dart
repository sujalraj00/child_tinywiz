abstract class SocketRepositoryInterface {
  Future<bool> connect(String childId, {String? serverUrl});
  void disconnect();
  void sendStatusUpdate(Map<String, dynamic> status);
  void sendLockAcknowledgment(bool locked, String timestamp);
  void sendEmergencyAlert({String? reason});
  void requestUnlock({String? reason});
  Stream<bool> get lockStatusStream;
  Stream<bool> get connectionStatusStream;
  bool get isConnected;
  String? get childId;
}

