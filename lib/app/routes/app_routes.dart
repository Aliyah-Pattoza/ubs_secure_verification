import 'package:get/get.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/login/login_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String faceRecognition = '/face-recognition';
  static const String transactionList = '/transaction-list';
  static const String success = '/success';
  
  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),

  ];
}

class SplashScreen {
  const SplashScreen();
}

class LoginScreen {
  const LoginScreen();
}