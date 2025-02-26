import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trip_tales/src/controllers/auth_controller.dart';
import 'package:trip_tales/src/pages/create_tale_page.dart';
import 'package:trip_tales/src/pages/favorite_tales.dart';
import 'package:trip_tales/src/pages/login.dart';
import 'package:trip_tales/src/pages/profile.dart';
import 'package:trip_tales/src/pages/register.dart';
import 'package:trip_tales/src/pages/my_tales.dart';
import 'package:trip_tales/src/pages/tale.dart';
import 'package:trip_tales/src/services/auth_service.dart';
import 'package:trip_tales/src/services/card_service.dart';
import 'package:trip_tales/src/services/tale_service.dart';
import 'package:trip_tales/src/utils/app_manager.dart';
import 'package:trip_tales/src/utils/device_info.dart';
import 'package:trip_tales/src/pages/home.dart';
import 'package:trip_tales/src/widgets/menu_bar_tale.dart';
import 'firebase_options.dart';



final AppManager _appManager = Get.put(AppManager());

Future<void> main() async {
  // final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  // await GetStorage.init();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //.then((value) => Get.put(AuthenticationRepository));
  User? user = FirebaseAuth.instance.currentUser;
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Now we have a context to use
    DeviceInfo device = DeviceInfo();
    device.computeDeviceInfo(context);
    bool isTablet = device.isTablet;
    _appManager.setIsTablet(isTablet);
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    bool isLoggedIn = GetStorage().read<bool>('isLoggedIn') ?? false;


    // Set preferred orientations to portrait mode
    if (!isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    return GetMaterialApp(
      navigatorKey: GlobalContextService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(fontFamily: 'WorkSans'),
      routes: {
        '/': (context) => HomePage(),
        '/loginPage': (context) => LoginPage(),
        '/registerPage': (context) => RegisterPage(),
        '/customMenu': (context) => CustomMenu(index: 0),
        '/myTalesPage': (context) => MyTalesPage(),
        '/createTalePage': (context) => CreateTalePage(),
        '/talePage': (context) => TalePage(),
        '/favoriteTalesPage': (context) => FavoriteTalesPage(),
        '/profilePage': (context) => ProfilePage(),
      },
      initialRoute: isLoggedIn ? '/customApp' : '/',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
        Get.put(AuthController(), permanent: true);
        Get.put(CardService(), permanent: true);
        Get.put(TaleService(), permanent: true);
      }),
    );
  }
}
