import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationSelectPage extends StatefulWidget {
  const LocationSelectPage({super.key});

  @override
  State<LocationSelectPage> createState() => _LocationSelectPageState();
}

class _LocationSelectPageState extends State<LocationSelectPage> {
  NaverMapController? mapController;
  NLatLng? _currentPosition;
  String? _selectedCity;
  bool _isLoading = false;
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    // Set initial position to Seoul
    _currentPosition = const NLatLng(37.5665, 126.9780);
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치 서비스가 비활성화되어 있습니다.'),
          action: SnackBarAction(
            label: '설정으로 이동',
            onPressed: () => Geolocator.openLocationSettings(),
          ),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await _requestLocationPermission();
    } else if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('앱 설정에서 위치 권한을 허용해주세요.'),
          action: SnackBarAction(
            label: '설정으로 이동',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      setState(() {
        _isLoading = true;
      });

      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('위치 권한이 필요합니다.'),
            action: SnackBarAction(
              label: '다시 시도',
              onPressed: _requestLocationPermission,
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('앱 설정에서 위치 권한을 허용해주세요.'),
            action: SnackBarAction(
              label: '설정으로 이동',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      print('Error requesting location permission: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = NLatLng(position.latitude, position.longitude);
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String? city = place.locality;
        if (city != null && city.endsWith('시')) {
          setState(() {
            _selectedCity = city;
          });
        }
      }

      if (_isMapInitialized && mapController != null) {
        await mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: _currentPosition!,
            zoom: 14,
          ),
        );

        // Add current location marker
        await mapController!.addOverlay(
          NMarker(
            id: 'currentLocation',
            position: _currentPosition!,
            icon: NOverlayImage.fromAssetImage(
                'assets/image/current_location.png'),
            caption: NOverlayCaption(
              text: '현재 위치',
              color: Colors.black,
              haloColor: Colors.white,
              textSize: 14,
            ),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치를 가져오는 중 오류가 발생했습니다.'),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('지역 선택'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_selectedCity != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '선택된 지역: $_selectedCity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target:
                          _currentPosition ?? const NLatLng(37.5665, 126.9780),
                      zoom: 14.0,
                    ),
                    locationButtonEnable: true,
                    mapType: NMapType.basic,
                  ),
                  onMapReady: (controller) async {
                    mapController = controller;
                    setState(() {
                      _isMapInitialized = true;
                    });
                    if (_currentPosition != null) {
                      await controller.updateCamera(
                        NCameraUpdate.withParams(
                          target: _currentPosition!,
                          zoom: 14,
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedCity != null
                        ? () {
                            Navigator.pop(context, _selectedCity);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('확인'),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _checkLocationPermission,
              child: Icon(Icons.my_location),
              tooltip: '현 위치 검색',
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
