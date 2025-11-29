import 'dart:async';
import '../../domain/repositories/socket_repository_interface.dart';
import '../datasources/socket_datasource.dart';

class SocketRepository implements SocketRepositoryInterface {
  final SocketDataSource _dataSource;

  SocketRepository(this._dataSource);

  @override
  Future<bool> connect(String childId, {String? serverUrl}) async {
    return await _dataSource.connect(childId, serverUrl: serverUrl);
  }

  @override
  void disconnect() {
    _dataSource.disconnect();
  }

  @override
  void sendStatusUpdate(Map<String, dynamic> status) {
    _dataSource.sendStatusUpdate(status);
  }

  @override
  void sendLockAcknowledgment(bool locked, String timestamp) {
    _dataSource.sendLockAcknowledgment(locked, timestamp);
  }

  @override
  void sendEmergencyAlert({String? reason}) {
    _dataSource.sendEmergencyAlert(reason: reason);
  }

  @override
  void requestUnlock({String? reason}) {
    _dataSource.requestUnlock(reason: reason);
  }

  @override
  Stream<bool> get lockStatusStream => _dataSource.lockStatusStream;

  @override
  Stream<bool> get connectionStatusStream => _dataSource.connectionStatusStream;

  @override
  bool get isConnected => _dataSource.isConnected;

  @override
  String? get childId => _dataSource.childId;
}

