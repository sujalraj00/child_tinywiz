import 'package:flutter/material.dart';
import '../../viewmodels/parent_gatekeeper_viewmodel.dart';
import '../../../core/constants/app_constants.dart';

class ParentGatekeeperScreen extends StatelessWidget {
  final ParentGatekeeperViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onUnlock;

  const ParentGatekeeperScreen({
    Key? key,
    required this.viewModel,
    required this.onBack,
    required this.onUnlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent Gatekeeper',
          style: TextStyle(fontFamily: AppConstants.fontFamily),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: onBack,
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter PIN to exit the app',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    onChanged: viewModel.updatePin,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'PIN',
                      counterText: '',
                      errorText: viewModel.errorMessage,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: viewModel.isValidating
                        ? null
                        : () async {
                            final isValid = await viewModel.validatePin();
                            if (isValid && context.mounted) {
                              onUnlock();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Exit allowed')),
                              );
                            }
                          },
                    child: viewModel.isValidating
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Unlock',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: AppConstants.fontFamily,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

