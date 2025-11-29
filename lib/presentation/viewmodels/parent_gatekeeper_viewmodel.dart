import 'package:flutter/foundation.dart';
import '../../domain/usecases/validate_pin_usecase.dart';

class ParentGatekeeperViewModel extends ChangeNotifier {
  final ValidatePinUseCase _validatePinUseCase;
  String _pin = '';
  String? _errorMessage;
  bool _isValidating = false;

  ParentGatekeeperViewModel(this._validatePinUseCase);

  String get pin => _pin;
  String? get errorMessage => _errorMessage;
  bool get isValidating => _isValidating;
  bool get isValid => _errorMessage == null && _pin.length == 4;

  void updatePin(String value) {
    if (value.length <= 4) {
      _pin = value;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> validatePin() async {
    if (_pin.length != 4) {
      _errorMessage = 'Please enter 4-digit PIN';
      notifyListeners();
      return false;
    }

    _isValidating = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 300));

    final isValid = _validatePinUseCase.execute(_pin);
    
    _isValidating = false;
    if (!isValid) {
      _errorMessage = 'Incorrect PIN';
    } else {
      _errorMessage = null;
    }
    
    notifyListeners();
    return isValid;
  }

  void clearPin() {
    _pin = '';
    _errorMessage = null;
    notifyListeners();
  }
}

