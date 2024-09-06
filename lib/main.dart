import 'package:dripa/map.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notications_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [

  ]);
  SystemChrome.setPreferredOrientations( [DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
 // await NetworkProvider().connectivity();

 // await NotifyFirebase().initNotifications();
  //ApiData.instance.dispose();
 // await NotifyFirebase().notify();
  //MobileAds.instance.initialize();
 // EventLogger().openApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dripa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splashscreen(),
        routes:{
          NotificationsScreen.route:(context)=> const NotificationsScreen(allnotifications: [], hroute: false,),}
    );
  }
}

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    navigateHome();
    // Initialize bounce animations for each character in "Dripa"
    _bounceControllers = List.generate(5, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
    });

    _bounceAnimations = _bounceControllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.bounceOut);
    }).toList();

    // Staggered start for bounce animations
    for (int i = 0; i < _bounceControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _bounceControllers[i].forward();
      });
    }
  }

  Future<void> navigateHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    String name = "Michael";
    String collectionName = "Passenger";
    String url = "";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        String? user='"'; // Simulate a user check
        if (user != null) {
          return TripPage(
            person: Person(
              name: name,
              url: url,
              collectionName: collectionName,
              userId: "FirebaseAuth.instance.currentUser!.uid",
            ),
          );
        } else {
          return WelcomePage();
        }
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildBouncingLetter(String letter, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * animation.value), // Bounce effect
          child: child,
        );
      },
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[350],
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DripaLogo(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return _buildBouncingLetter(
                  "Dripa"[index],
                  _bounceAnimations[index],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late PageController _pageController;
  late Timer _timer;
  final int _pageCount = 4; // Number of pages in the PageView
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPageIndex < _pageCount - 1) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }
      _pageController.animateToPage(
        _currentPageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _pageCount - 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          TextButton(
            onPressed: _skipToLastPage,
            child: Text(
              'Skip',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          WelcomePageContent(
            title: 'Welcome to Dripa!',
            description: 'Discover a world of possibilities with Dripa... your personal travel companion',
            imagePath: 'assets/intro.png', // Replace with your image path
            buttonText: 'Get Started',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          WelcomePageContent(
            title: 'Discover Drivers near you',
            description: 'Search and visualize drivers near you. Reduce your travel anxiety with vehicle availability.',
            imagePath: 'assets/video_editing.png', // Replace with your image path
            buttonText: 'Explore Drivers',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          WelcomePageContent(
            title: 'Discover Vehicle Destinations',
            description: 'Know what vehicles are coming your way and make appropriate decisions.',
            imagePath: 'assets/music_trimming.png', // Replace with your image path
            buttonText: 'See Destinations',
            onButtonPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          WelcomePageContent(
            title: 'Ready to Begin?',
            description: 'You’re all set to start your journey with Dripa!',
            imagePath: 'assets/get_started.png', // Replace with your image path
            buttonText: 'Start Now',
            onButtonPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
class WelcomePageContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String buttonText;
  final VoidCallback onButtonPressed;

  WelcomePageContent({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Image.asset(imagePath, height: 200), // Adjust as needed
        SizedBox(height: 200),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: onButtonPressed,
          child: Text(buttonText),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}


class DripaLogo extends StatelessWidget {
  const DripaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 280,
        width: 250,
        child: Image.asset(
          "assets/logo1.png",
          height: 250,
          width: 250,
        ),
      ),
    );
  }

}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Position location;
  String collection="";
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    initialize();
  }
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  late DateTime  _startTime;
  void initialize()async{
    await initPlatformState();
    location= await getCurrentLocation();
  }
  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }
  String _platformVersion = '',
      _imeiNo = "",
      _modelName = "",
      _manufacturerName = "",
      _deviceName = "",
      _productName = "",
      _cpuType = "",
      _hardware = "";
  var _apiLevel;

  Future<void> initPlatformState() async {
    late String platformVersion,
        imeiNo = '',
        modelName = '',
        manufacturer = '',
        deviceName = '',
        productName = '',
        cpuType = '',
        hardware = '';
    var apiLevel;

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        // Handle web-specific logic if necessary
        platformVersion = 'Web';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            var androidInfo = await deviceInfoPlugin.androidInfo;
            platformVersion = androidInfo.version.release;
            modelName = androidInfo.model;
            manufacturer = androidInfo.manufacturer;
            deviceName = androidInfo.device;
            productName = androidInfo.product;
            cpuType = androidInfo.supportedAbis.join(', ');
            hardware = androidInfo.hardware;
            apiLevel = androidInfo.version.sdkInt;
            break;
          case TargetPlatform.iOS:
            var iosInfo = await deviceInfoPlugin.iosInfo;
            platformVersion = iosInfo.systemVersion;
            modelName = iosInfo.model;
            manufacturer = 'Apple';
            deviceName = iosInfo.name;
            productName = iosInfo.localizedModel;
            cpuType = iosInfo.utsname.machine;
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.linux:
            var linuxInfo = await deviceInfoPlugin.linuxInfo;
            platformVersion = linuxInfo.version!;
            modelName = linuxInfo.name;
            manufacturer = linuxInfo.id;
            deviceName = linuxInfo.prettyName;
            productName = linuxInfo.variant!;
            cpuType = 'Not available';
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.windows:
            var windowsInfo = await deviceInfoPlugin.windowsInfo;
            platformVersion = windowsInfo.releaseId;
            modelName = windowsInfo.productName;
            manufacturer = 'Microsoft';
            deviceName = windowsInfo.computerName;
            productName = windowsInfo.editionId;
            cpuType = windowsInfo.computerName;
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.macOS:
            var macOsInfo = await deviceInfoPlugin.macOsInfo;
            platformVersion = macOsInfo.osRelease;
            modelName = macOsInfo.model;
            manufacturer = 'Apple';
            deviceName = macOsInfo.computerName;
            productName = macOsInfo.model;
            cpuType = macOsInfo.arch;
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.fuchsia:
            platformVersion = 'Fuchsia platform isn\'t supported';
            modelName = 'Fuchsia platform isn\'t supported';
            manufacturer = 'Fuchsia platform isn\'t supported';
            deviceName = 'Fuchsia platform isn\'t supported';
            productName = 'Fuchsia platform isn\'t supported';
            cpuType = 'Fuchsia platform isn\'t supported';
            hardware = 'Fuchsia platform isn\'t supported';
            apiLevel = 'Fuchsia platform isn\'t supported';
            break;
        }
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _imeiNo = imeiNo;
      _modelName = modelName;
      _manufacturerName = manufacturer;
      _apiLevel = apiLevel;
      _deviceName = deviceName;
      _productName = productName;
      _cpuType = cpuType;
      _hardware = hardware;
    });
  }


  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<UserCredential?> handleSignIn(String collection) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text('Checking...'),
              ],
            ),
          ),
        );
      },
    );
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final String userId = (await _auth.signInWithCredential(credential)).user!.uid ?? '';
        final DocumentSnapshot doc = await FirebaseFirestore.instance.collection(collection).doc(userId).get();
        if (doc.exists) {
          await back();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20.0),
                      Text('Signing In...'),
                    ],
                  ),
                ),
              );
            },
          );
          await addData(userCredential,collection);
          return null;
        } else {
          if(location==null) {
            location = await getCurrentLocation();
          }
          await back();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20.0),
                      Text('Signing Up...'),
                    ],
                  ),
                ),
              );
            },
          );
        await addData(userCredential,collection);
          return userCredential;
        }
      }
    } catch (e, exception) {
      //await back();
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Error'),
          content: Text('$exception'),
        );
      });
    }
    return null;
  }
  Future<void>back()async{
    Navigator.of(context, rootNavigator: true).pop();
  }
  Future<void> addData(UserCredential user,String collection)async{
    String? token= await NotifyFirebase().requestFCMToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('fcmToken',token!);
    });
    final String Id = generateUniqueNotificationId();
    final like = {
      'Id': Id,
      'devicename': _deviceName,
      'devicemodel': _modelName,
      'osversion': _platformVersion,
      'manufacturername': _manufacturerName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'state': 'login',
    };
    Map<String, dynamic> data = {
      'fcmToken':token,
      'onlinestatus':1,
      'collection':"${collectionNamefor}s",
      'userId':user.user!.uid,
      'location':like,
    };
    await NotifyFirebase().saveSingIn(data,context,Person(
        name: user.user!.displayName!,
        url: user.user!.photoURL!,
        collectionName: collection,
        userId: user.user!.uid));
  }
  @override
  Widget build(BuildContext context) {
    return    SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const Text('Tap to Sign In or Sign Up',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.08,
              width: MediaQuery.of(context).size.width*0.3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: ()async{
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        content: Column(
                          children: [
                            OutlinedButton(onPressed: ()async{
                              UserCredential? userCredential = await handleSignIn("Passenger");
                              if (userCredential != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TripPage(
                                    person: Person(name: userCredential.user!.displayName!,
                                        url: userCredential.user!.photoURL!,
                                        collectionName: "Passenger",
                                        userId: userCredential.user!.uid),)),
                                );
                              }
                            }, child: Text("Passenger")),
                            OutlinedButton(onPressed: ()async{
                              UserCredential? userCredential = await handleSignIn('Driver');
                              if (userCredential != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TripPage(
                                    person: Person(name: userCredential.user!.displayName!,
                                        url: userCredential.user!.photoURL!,
                                        collectionName: "Driver",
                                        userId: userCredential.user!.uid),)),
                                );
                              }
                            }, child: Text("Driver")),
                          ],
                        ),
                      );
                    });
                   },
                  child: Image.asset("assets/google.png",fit: BoxFit.fitHeight,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;
  late List<int> _delays;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _animations = List.generate(
      7,
          (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.1),
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    _delays = List.generate(
      7,
          (index) => (index + 1) * 100,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildAnimatedContainer(String text, void Function() onTap, int index) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        final delay = _delays[index];
        Future.delayed(Duration(milliseconds: delay), () {
          if (_animationController.isAnimating) {
            setState(() {});
          }
        });

        return Opacity(
          opacity: _animations[index].value,
          child: Transform.translate(
            offset: Offset(0, (1 - _animations[index].value) * 50),
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: InkWell(
                onTap: onTap,
                child: Container(
                  height: 60,
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchSettings(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 33,
                    ),
                  ),
                )
              ],
            )
          ],
          title: const Text(
            'Settings',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildAnimatedContainer(
                'Account',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Account(),
                    ),
                  );
                },
                0,
              ),
              buildAnimatedContainer(
                'Notifications',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Notify(),
                    ),
                  );
                },
                1,
              ),
              buildAnimatedContainer(
                'Invite friends',
                    () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        expand: true,
                        initialChildSize: 0.32,
                        builder: (context, controller) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Choose the platform to invite your friends from',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: () async {
                                            // Implement your action here
                                          },
                                          child: Image.asset(
                                            "assets/whatsapplogo.png",
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: () async {
                                            // Implement your action here
                                          },
                                          child: Image.asset(
                                            "assets/instagram.png",
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: () async {
                                            // Implement your action here
                                          },
                                          child: Image.asset(
                                            "assets/facebooklogo.png",
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                2,
              ),
              buildAnimatedContainer(
                'Theme',
                    () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        expand: true,
                        initialChildSize: 0.32,
                        builder: (context, controller) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: Container(
                            color: Colors.white,
                            child: const Column(
                              children: [
                                // Add your theme options here
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                3,
              ),
              buildAnimatedContainer(
                'Log out',
                    () async {
                  dialog();
                },
                4,
              ),
              buildAnimatedContainer(
                'Help',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Help(),
                    ),
                  );
                },
                5,
              ),
              buildAnimatedContainer(
                'About',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutTheApp(),
                    ),
                  );
                },
                6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dialog() {
    // Implement your logout dialog here
  }
}


class Updates extends StatefulWidget {
  const Updates({super.key});

  @override
  State<Updates> createState() => _UpdatesState();
}

class _UpdatesState extends State<Updates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Updates Page Content'),
      ),
    );
  }
}

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Privacy Policy Content'),
      ),
    );
  }
}

class TermsofUse extends StatefulWidget {
  const TermsofUse({super.key});

  @override
  State<TermsofUse> createState() => _TermsofUseState();
}

class _TermsofUseState extends State<TermsofUse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Terms of Use Content'),
      ),
    );
  }
}

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Help Page Content'),
      ),
    );
  }
}

class AboutTheApp extends StatefulWidget {
  const AboutTheApp({super.key});

  @override
  State<AboutTheApp> createState() => _AboutTheAppState();
}

class _AboutTheAppState extends State<AboutTheApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About the App'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('About the App Content'),
      ),
    );
  }
}

class Notify extends StatefulWidget {
  const Notify({super.key});

  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Notifications Page Content'),
      ),
    );
  }
}

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Account Page Content'),
      ),
    );
  }
}

class SearchSettings extends StatefulWidget {
  const SearchSettings({super.key});

  @override
  State<SearchSettings> createState() => _SearchSettingsState();
}

class _SearchSettingsState extends State<SearchSettings> {
  TextEditingController _controller = TextEditingController();

  bool _showCloseIcon = false;
  List<Setting>settings1=[];
  List<Setting>settings=[
    Setting(
        set: 'Notifications',
        layout: Notify()),
    Setting(
        set: 'Invite friends',
        layout: SettingsPage()),
    Setting(
        set: 'Log out',
        layout: SettingsPage()),
    Setting(
        set: 'Help',
        layout: Help()),
    Setting(
        set: 'About',
        layout: AboutTheApp()),
    Setting(
        set: 'Privacy policy',
        layout: PrivacyPolicy()),
    Setting(
        set: 'Terms of use',
        layout: TermsofUse()),
    Setting(
        set: 'Updates',
        layout: Updates()),
  ];
  String matchedItem='';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            title:   Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SizedBox(
                height: 37,
                width: MediaQuery.of(context).size.width*0.75,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: TextFormField(
                    textAlign: TextAlign.justify,
                    textAlignVertical: TextAlignVertical.bottom,
                    cursorColor: Colors.black,
                    textInputAction: TextInputAction.search,
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        settings1 = settings.where((match) => match.set.toLowerCase().contains(value.toLowerCase())||
                            match.set.toUpperCase().contains(value.toUpperCase())).toList();
                        _showCloseIcon = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(width: 1, color: Colors.black),
                      ),
                      focusedBorder:  OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(width: 1, color: Colors.black),
                      ),
                      filled: true,
                      hintStyle: const TextStyle(color: Colors.black,
                        fontSize: 20, fontWeight: FontWeight.normal,),
                      fillColor: Colors.white70,
                      suffixIcon: _showCloseIcon ? IconButton(
                        icon: const Icon(Icons.close,color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _showCloseIcon = false;
                          });
                        },
                      ) : null,
                      hintText: 'Search',
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.white,
          ),
          body: ListView.builder(
              itemCount: settings1.length,
              itemBuilder: (context,index){
                return  Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap:  () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>settings1[index].layout));
                    },
                    child: Container(
                      height: 60,
                      color: Colors.grey[200],
                      width: MediaQuery.of(context).size.width,
                      child:  Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(settings1[index].set),
                          )),
                    ),
                  ),
                );
              }),
        )
    );
  }
}


class Setting{
  String set;
  Widget layout;
  Setting({required this.set,required this.layout});
}