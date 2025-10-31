import 'dart:convert';
import 'package:http/http.dart' as http;

class LatLng {
  final double lat;
  final double lon;
  const LatLng(this.lat, this.lon);
}

class LocationData {
  final String? locality;
  final String? country;

  LocationData({this.locality, this.country});
}

class GeoApi {
  final Duration timeout;
  const GeoApi({
    this.timeout = const Duration(seconds: 10),
  });

  // الدالة الحالية
  Future<LatLng?> geocode(String query) async {
    final u = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeQueryComponent(query)}&format=json&limit=1',
    );
    final res = await http.get(u, headers: {
      'User-Agent': 'AzkarCalendar/1.0 (+https://example.com)'
    }).timeout(timeout);
    if (res.statusCode != 200) return null;

    final List j = json.decode(res.body);
    if (j.isEmpty) return null;

    final lat = double.tryParse(j.first['lat']?.toString() ?? '');
    final lon = double.tryParse(j.first['lon']?.toString() ?? '');
    if (lat == null || lon == null) return null;

    return LatLng(lat, lon);
  }

  // الدالة الجديدة المطلوبة
  Future<LocationData?> reverseGeocode(double lat, double lon) async {
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=json&lat=$lat&lon=$lon&addressdetails=1'
    );

    try {
      final res = await http.get(uri, headers: {
        'User-Agent': 'AzkarCalendar/1.0 (+https://example.com)'
      }).timeout(timeout);

      if (res.statusCode != 200) return null;

      final jsonResponse = json.decode(res.body);
      final address = jsonResponse['address'] as Map<String, dynamic>?;

      if (address == null) return null;

      return LocationData(
        locality: address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'],
        country: address['country'],
      );
    } catch (e) {
      return null;
    }
  }
}