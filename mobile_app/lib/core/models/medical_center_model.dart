class MedicalCenterModel {
  final String name;
  final String address;
  final double lat;
  final double lon;
  final double distanceKm;
  final int timeMinutes;

  MedicalCenterModel({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    this.distanceKm = 0.0,
    this.timeMinutes = 0,
  });

  factory MedicalCenterModel.fromJson(Map<String, dynamic> json) {
    // Lấy tên: Ưu tiên 'name', nếu null thì lấy 'display_name' cắt ra
    String rawName = json['name'] ?? "";
    if (rawName.isEmpty) {
      rawName = (json['display_name'] ?? "Cơ sở y tế").split(',')[0];
    }

    return MedicalCenterModel(
      name: rawName,
      address: json['display_name'] ?? "Địa chỉ đang cập nhật",
      // Chuyển đổi an toàn sang double
      lat: double.tryParse(json['lat'].toString()) ?? 0.0, 
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
    );
  }
}