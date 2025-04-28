import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationSelectPage extends StatefulWidget {
  const LocationSelectPage({super.key});

  @override
  State<LocationSelectPage> createState() => _LocationSelectPageState();
}

class _LocationSelectPageState extends State<LocationSelectPage> {
  late NaverMapController _mapController;

  NLatLng _initialPosition = const NLatLng(37.5665, 126.9780); // 서울 기본값
  bool _isLoading = false;
  String? _fullAddress;
  List<Map<String, dynamic>> _features = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    final String data =
        await rootBundle.loadString('assets/mapCore/HangJeongDong.geojson');
    final Map<String, dynamic> jsonResult = json.decode(data);
    _features = List<Map<String, dynamic>>.from(jsonResult['features']);
  }

  NLatLng _calculatePolygonCenter(List<NLatLng> polygon) {
    double sumLat = 0;
    double sumLng = 0;

    for (final point in polygon) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    final centerLat = sumLat / polygon.length;
    final centerLng = sumLng / polygon.length;

    return NLatLng(centerLat, centerLng);
  }

  Future<void> _drawCurrentNeighborhood() async {
    try {
      setState(() => _isLoading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentPoint = NLatLng(position.latitude, position.longitude);

      for (final feature in _features) {
        final geometry = feature['geometry'];
        if (geometry['type'] == 'MultiPolygon') {
          final coordinates = geometry['coordinates'][0][0] as List;
          List<NLatLng> polygon = coordinates.map<NLatLng>((coord) {
            return NLatLng(coord[1], coord[0]);
          }).toList();

          if (polygon.first != polygon.last) {
            polygon.add(polygon.first); // 폴리곤 닫기
          }

          if (_isPointInPolygon(currentPoint, polygon)) {
            // ✅ 내 동 찾음

            // 💬 행정동 이름 가져오기
            final addressName =
                feature['properties']['adm_nm'] as String? ?? '알 수 없음';

            // 🔥 상단 텍스트를 이때 업데이트
            setState(() {
              _fullAddress = addressName;
            });

            // 폴리곤 중심 계산
            final centerPoint = _calculatePolygonCenter(polygon);

            // 폴리곤 오버레이 생성
            final polygonOverlay = NPolygonOverlay(
              id: 'currentNeighborhood',
              coords: polygon,
              color: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.3),
              outlineColor: Color.fromARGB(255, 255, 0, 0),
              outlineWidth: 2,
            );

            _mapController.clearOverlays(); // 기존 오버레이 지우고
            _mapController.addOverlay(polygonOverlay);

            // 중심점으로 카메라 이동
            await _mapController.updateCamera(
              NCameraUpdate.scrollAndZoomTo(
                target: centerPoint,
                zoom: 13.5,
              ),
            );

            print('내 동 이름: $addressName');
            break;
          }
        }
      }
    } catch (e) {
      print('폴리곤 찾기 실패: $e');
      _showSnackbar('오버레이를 표시하는 데 실패했습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isPointInPolygon(NLatLng point, List<NLatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(NLatLng point, NLatLng vertA, NLatLng vertB) {
    final aY = vertA.latitude;
    final bY = vertB.latitude;
    final aX = vertA.longitude;
    final bX = vertB.longitude;
    final pY = point.latitude;
    final pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    final m = (aY - bY) / (aX - bX);
    final bee = -aX * m + aY;
    final x = (pY - bee) / m;

    return x > pX;
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('위치 서비스가 비활성화되어 있습니다.', Geolocator.openLocationSettings);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await _requestLocationPermission();
    } else if (permission == LocationPermission.deniedForever) {
      _showSnackbar('앱 설정에서 위치 권한을 허용해주세요.', Geolocator.openAppSettings);
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showSnackbar('위치 권한이 필요합니다.', _requestLocationPermission);
    } else if (permission == LocationPermission.deniedForever) {
      _showSnackbar('앱 설정에서 위치 권한을 허용해주세요.', Geolocator.openAppSettings);
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialPosition = NLatLng(position.latitude, position.longitude);
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _fullAddress =
              '${place.administrativeArea ?? ''} ${place.subAdministrativeArea ?? ''} ${place.subLocality ?? ''}'
                  .trim();
        });
      }

      await _moveCamera(_initialPosition);
    } catch (e) {
      print('Error getting location: $e');
      _showSnackbar('위치를 가져오는 중 오류가 발생했습니다.', _getCurrentLocation);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _moveCamera(NLatLng position) async {
    await _mapController.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: position,
        zoom: 14,
      ),
    );
  }

  void _showSnackbar(String message, [VoidCallback? action]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action != null
            ? SnackBarAction(
                label: '설정',
                onPressed: action,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('지역 선택'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_fullAddress != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '선택된 지역: $_fullAddress',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                    locationButtonEnable: false,
                    indoorEnable: true,
                  ),
                  onMapReady: (NaverMapController controller) {
                    _mapController = controller;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _fullAddress != null
                        ? () => Navigator.pop(context, _fullAddress)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 576,
            left: 6,
            child: FloatingActionButton(
              onPressed: _drawCurrentNeighborhood,
              tooltip: '현 위치 동 찾기',
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
