import '../../core/constants/app_constants.dart';

class ValidatePinUseCase {
  bool execute(String pin) {
    return pin == AppConstants.defaultPin;
  }
}

