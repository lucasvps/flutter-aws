import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'services/auth_service.dart';
import 'ui/screens/camera_flow.dart';
import 'ui/screens/login_page.dart';
import 'ui/screens/signup_page.dart';
import 'ui/screens/verification_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();
  final _amplify = Amplify();

  void _configureAmplify() async {
    _amplify.addPlugin(
        authPlugins: [AmplifyAuthCognito()],
        storagePlugins: [AmplifyStorageS3()],
        analyticsPlugins: [AmplifyAnalyticsPinpoint()]);
    try {
      await _amplify.configure(amplifyconfig);
      print('Successfully configured Amplify 🎉');
    } catch (e) {
      print('Could not configure Amplify ☠️');
    }
  }

  @override
  void initState() {
    super.initState();
    _authService.checkAuthStatus();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: StreamBuilder<AuthState>(
          stream: _authService.authStateController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Navigator(
                pages: [
                  if (snapshot.data.authFlowStatus == AuthFlowStatus.login)
                    MaterialPage(
                        child: LoginPage(
                      shouldShowSignUp: _authService.showSignUp,
                      didProvideCredentials: _authService.loginWithCredentials,
                    )),
                  if (snapshot.data.authFlowStatus == AuthFlowStatus.signUp)
                    MaterialPage(
                        child: SignUpPage(
                      shouldShowLogin: _authService.showLogin,
                      didProvideCredentials: _authService.signUpWithCredentials,
                    )),
                  if (snapshot.data.authFlowStatus ==
                      AuthFlowStatus.verification)
                    MaterialPage(
                        child: VerificationPage(
                            didProvideVerificationCode:
                                _authService.verifyCode)),
                  if (snapshot.data.authFlowStatus == AuthFlowStatus.session)
                    MaterialPage(
                        child: CameraFlow(shouldLogOut: _authService.logOut))
                ],
                onPopPage: (route, result) => route.didPop(result),
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
