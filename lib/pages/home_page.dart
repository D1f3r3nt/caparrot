import 'dart:async';

import 'package:caparrot/provider/head_provider.dart';
import 'package:caparrot/provider/provider.dart';
import 'package:caparrot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:caparrot/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Animation<double> _animation;
  late AnimationController _animationController;
  late bool _gpsEnabled;
  bool _currentLocation = false;

  StreamSubscription? _gpsSubscription;
  Position? _position;

  late AppLifecycleState appLifecycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycleState = state;
    setState(() {});
    super.didChangeAppLifecycleState(state);
    var musicProvider = Provider.of<MusicProvider>(context, listen: false);

    if (state == AppLifecycleState.paused) {
      musicProvider.pauseMusic();
    }

    if (state == AppLifecycleState.resumed) {
      musicProvider.resumeMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // Para la ubicacion
    verifyGps();

    // Para el menu desplegable
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Para el menu desplegable
    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  Set<Marker> markerse = Set<Marker>();

  void addmarker(HeadProvider headProvider) async {
    headProvider.heads.forEach((element) async {
      var icon = BitmapDescriptor.fromBytes(await assetToBytes(
          'assets/markers/${element.markerImage}',
          width: 200));

      markerse.add(
        Marker(
          markerId: MarkerId(element.name),
          position: LatLng(element.latitude, element.longitude),
          visible: false,
          icon: icon,
          onTap: () {
            popUpHistory(context, element);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Progreso
    Provider.of<FirebaseCrudProvider>(context).getUser();
    // Progreso
    var headProvider = Provider.of<HeadProvider>(context);
    if (headProvider.heads.isEmpty) {
      headProvider.getData();
    }

    addmarker(headProvider);

    if (_currentLocation) {
      if (!_gpsEnabled) {
        return const GpsNotEnabled();
      }

      return Scaffold(
        body: SafeArea(
          child: Maps(
            markers: markerse,
            position: _position!,
          ),
        ),
        floatingActionButton: AnimatedMenu(
          animation: _animation,
          animationController: _animationController,
        ),
      );
    }
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void verifyGps() async {
    dynamic _gps = await Geolocator.isLocationServiceEnabled();
    _position = await Geolocator.getCurrentPosition();

    setState(() {
      _gpsEnabled = _gps;
      _currentLocation = true;

      _gpsSubscription =
          Geolocator.getServiceStatusStream().listen((status) async {
        _gpsEnabled = status == ServiceStatus.enabled;
        _position = await Geolocator.getLastKnownPosition();
      });
    });
  }
}
