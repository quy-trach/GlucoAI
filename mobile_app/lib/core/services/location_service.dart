import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/medical_center_model.dart';

class LocationService {
  // 1. LẤY TỌA ĐỘ (Đã sửa lỗi deprecated)
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      // 🔥 FIX LỖI Ở ĐÂY: Dùng LocationSettings thay vì desiredAccuracy cũ
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // Độ chính xác cao
        distanceFilter: 100, // Di chuyển 100m mới cập nhật
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      debugPrint("Lỗi GPS: $e");
      return null;
    }
  }

  // 2. GỌI API OSM (Tìm ở VN - Fix lỗi Uganda)
  Future<List<MedicalCenterModel>> getNearbyHospitals() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return [];

      debugPrint("✅ Vị trí: ${position.latitude}, ${position.longitude}");

      // Tạo khung giới hạn (Viewbox) ~5km
      double left = position.longitude - 0.05;
      double top = position.latitude - 0.05;
      double right = position.longitude + 0.05;
      double bottom = position.latitude + 0.05;

      final String url =
          'https://nominatim.openstreetmap.org/search?'
          'q=bệnh viện'
          '&format=json'
          '&limit=15'
          '&addressdetails=1'
          '&countrycodes=vn'
          '&viewbox=$left,$top,$right,$bottom'
          '&bounded=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'GlucoAI_App/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<MedicalCenterModel> results = [];

        for (var item in data) {
          try {
            var center = MedicalCenterModel.fromJson(item);

            if (center.name.length < 4) continue;

            // 2. Nếu là phòng khám thú y (Veterinary) 
            if (center.name.toLowerCase().contains('thú y') ||
                center.name.toLowerCase().contains('veterinary')) {
              continue;
            }

            double dist = _calculateDistance(
              position.latitude,
              position.longitude,
              center.lat,
              center.lon,
            );

            int time = (dist / 30 * 60).round();
            if (time < 5) time = 5;

            results.add(
              MedicalCenterModel(
                name: center.name,
                address: center.address,
                lat: center.lat,
                lon: center.lon,
                distanceKm: dist,
                timeMinutes: time,
              ),
            );
          } catch (e) {
            // Bỏ qua item lỗi
          }
        }

        results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        return results;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Lỗi: $e");
      return [];
    }
  }

  // 3. Tính khoảng cách
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
