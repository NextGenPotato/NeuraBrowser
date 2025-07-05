import 'package:flutter/material.dart';
import 'package:neura_browser/pages/home_page.dart';

import '../helpers/biometric_helper.dart';

class IncognitoPage extends StatelessWidget {
  const IncognitoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: BiometricHelper()
          .authenticate(localizedReason: 'Authenticate to view incognito tabs'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return const HomePage();
        } else {
          return const Scaffold(
            body: Center(child: Text("Authentication failed")),
          );
        }
      },
    );
  }
}
