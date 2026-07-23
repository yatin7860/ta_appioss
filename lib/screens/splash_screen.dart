import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'check_login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _lottieAnimation;
  late Animation<double> _loadingAnimation;
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _particleController;
  late AnimationController _carController;
  late Animation<double> _carAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  bool updateRequired = false;

  String loadingText = "Initializing...";
  double progress = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(
        0.0,
        0.40,
        curve: Curves.easeOut,
      ),
    );

    _lottieAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(
        0.25,
        0.75,
        curve: Curves.easeOut,
      ),
    );

    _loadingAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(
        0.60,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _contentController.forward();
      }
    });
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _carAnimation = Tween<double>(
      begin: -150,
      end: 450,
    ).animate(
      CurvedAnimation(
        parent: _carController,
        curve: Curves.linear,
      ),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    initializeApp();
  }

  Future<void> initializeApp() async {

    updateProgress(0.10, "Checking Internet...");

    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.none)) {
      showNoInternetDialog();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 600));

    //================ VERSION CHECK =================//

    updateProgress(0.30, "Checking Version...");

    await checkVersion();

    // Stop here if update is required
    if (updateRequired) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    //================ LOAD USER DATA =================//

    updateProgress(0.55, "Loading User Data...");

    await SharedPreferences.getInstance();

    await Future.delayed(const Duration(milliseconds: 500));

    //================ PREPARING APP =================//

    updateProgress(0.80, "Preparing Application...");

    await Future.delayed(const Duration(milliseconds: 700));

    //================ FINAL STEP =================//

    updateProgress(1.0, "Almost Ready...");

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            CheckLogin(),
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          final scaleAnimation = Tween<double>(
            begin: 0.96,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  void updateProgress(double value, String text) {
    if (!mounted) return;

    setState(() {
      progress = value;
      loadingText = text;
    });
  }
  void showNoInternetDialog() {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("No Internet"),
          content: const Text(
            "Please check your internet connection.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                initializeApp();
              },
              child: const Text("Retry"),
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog(String link) {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          title: const Text("Update Required"),

          content: const Text(
            "A new version of the application is available.\n\nPlease update to continue.",
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {

                final Uri url = Uri.parse(link);

                if (await canLaunchUrl(url)) {

                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );

                }

              },

              child: const Text("Update Now"),

            ),

          ],

        );

      },

    );

  }
  //check version

  Future<void> checkVersion() async {

    try {

      final info = await PackageInfo.fromPlatform();

      String currentVersion = info.version;

      print("CURRENT VERSION : $currentVersion");

      final response =
      await ApiService.checkVersion(currentVersion);

      print("VERSION API RESPONSE : $response");

      if (response == null) {
        return;
      }

      if (response["up_to_date"] == true) {

        print("APP IS UP TO DATE");

        updateRequired = false;

      } else {

        print("UPDATE REQUIRED");

        // ===============================
        // TEMPORARILY DISABLED FOR TESTING
        // ===============================

        updateRequired = false;

        // Uncomment these lines when enabling force update
        // updateRequired = true;
        // showUpdateDialog(response["link"]);

      }

    } catch (e) {

      print("VERSION CHECK ERROR : $e");

      // Allow app to continue if version check fails
      updateRequired = false;

    }

  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _carController.dispose();
    _rotationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget buildLogo(double width) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Hero(
            tag: "logo",
            child: Container(
              width: width * 0.42,
              height: width * 0.42,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.30),
                    blurRadius: 70,
                    spreadRadius: 18,
                  ),
                ],
              ),
              child: Image.asset(
                "assets/icon.png",
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            return Positioned(
              left: (index * 27.0) % MediaQuery.of(context).size.width,
              top: ((_particleController.value *
                  MediaQuery.of(context).size.height) +
                  index * 40) %
                  MediaQuery.of(context).size.height,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.20),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
  Widget buildMovingCar(double width, double height) {
    return AnimatedBuilder(
      animation: _carController,
      builder: (context, child) {

        return Positioned(
          bottom: height * .09,
          left: (_carAnimation.value % (width + 150)) - 150,
          child: SizedBox(
            width: width * .20,
            child: Lottie.asset(
              "assets/moving_car.json",
              repeat: true,
            ),
          ),
        );
      },
    );
  }
  Widget buildTitle(double width) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFB3E5FC),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "Travel Allowance",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * .085,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
                height: 1.1,
              ),
            ),
          ),

          SizedBox(height: width * .02),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * .04,
              vertical: width * .012,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white24,
              ),
            ),
            child: Text(
              "PRSC",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: width * .036,
                fontWeight: FontWeight.w500,
                letterSpacing: .8,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildTravelAnimation(double height) {
    return Lottie.asset(
      "assets/animation.json",
      height: height * .22,
      repeat: true,
    );
  }



  Widget buildLoading(double width) {
    return Column(
      children: [
        SizedBox(
          width: width * .68,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 18),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Row(
            key: ValueKey(loadingText),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _rotationAnimation,
                child: const Icon(
                  Icons.sync_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                loadingText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFooter(double width) {
    return Column(
      children: [
        Divider(
          color: Colors.white24,
          indent: width * .12,
          endIndent: width * .12,
        ),

        const SizedBox(height: 10),

        const Text(
          "Punjab Remote Sensing Centre",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "Ludhiana",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF081A44),
              Color(0xFF0F2D73),
              Color(0xFF2A5DB0),
              Color(0xFF4A86E8),
            ],
            stops: [
              0.0,
              0.35,
              0.75,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            buildParticles(),
            buildMovingCar(width, height),
            // Top Glow
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: width * .65,
                height: width * .65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.08),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.15),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Glow
            Positioned(
              bottom: -150,
              left: -120,
              child: Container(
                width: width * .80,
                height: width * .80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.06),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlue.withOpacity(.12),
                      blurRadius: 120,
                      spreadRadius: 35,
                    ),
                  ],
                ),
              ),
            ),

            // Small Glow
            Positioned(
              top: height * .25,
              left: -60,
              child: Container(
                width: width * .30,
                height: width * .30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(.10),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),



            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * .05,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: height * .04,
                            ),

                            buildLogo(width),

                            SizedBox(height: height * .02),

                            FadeTransition(
                              opacity: _titleAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, .20),
                                  end: Offset.zero,
                                ).animate(_titleAnimation),
                                child: buildTitle(width),
                              ),
                            ),

                            SizedBox(height: height * .03),

                            FadeTransition(
                              opacity: _lottieAnimation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: .80,
                                  end: 1,
                                ).animate(_lottieAnimation),
                                child: buildTravelAnimation(height),
                              ),
                            ),

                            SizedBox(height: height * .02),

                            FadeTransition(
                              opacity: _loadingAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, .20),
                                  end: Offset.zero,
                                ).animate(_loadingAnimation),
                                child: SizedBox(
                                  width: width * .82,
                                  child: Container(
                                    padding: EdgeInsets.all(width * .05),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.white24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(.12),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: buildLoading(width),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: height * .03),

                            buildFooter(width),

                            SizedBox(height: height * .015),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
        ),
      ),
    );
    }
  }
