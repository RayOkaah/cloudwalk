import 'package:cloudwalk/services/authentication_service.dart';
import 'package:cloudwalk/services/dialog_service.dart';
import 'package:cloudwalk/services/navigation_service.dart';
import 'package:cloudwalk/ui/router.dart';
import 'package:cloudwalk/ui/views/startup_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'locator.dart';
import 'managers/dialog_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StreamProvider(
      create: (context) => locator<AuthenticationService>().userStreamController.stream,
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Cloudwalk Test',
        builder: (context, child) => Navigator(
          key: locator<DialogService>().dialogNavigationKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => DialogManager(child: child)),
        ),
        navigatorKey: locator<NavigationService>().navigationKey,
        theme: ThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartUpView(),
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
