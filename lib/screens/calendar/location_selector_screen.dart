// lib/screens/calendar/location_selector_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  List<dynamic> countries = [];
  List<dynamic> states = [];
  List<dynamic> cities = [];

  dynamic selectedCountry;
  dynamic selectedState;
  dynamic selectedCity;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGeoData();
  }

  Future<void> _loadGeoData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/countries+states+cities.json');
      final data = json.decode(jsonString) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        countries = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل بيانات الأماكن: $e';
        _loading = false;
      });
    }
  }

  void _onCountryChanged(dynamic value) {
    setState(() {
      selectedCountry = value;
      selectedState = null;
      selectedCity = null;
      states = (selectedCountry?['states'] as List?) ?? [];
      cities = [];
    });
  }

  void _onStateChanged(dynamic value) {
    setState(() {
      selectedState = value;
      selectedCity = null;
      cities = (selectedState?['cities'] as List?) ?? [];
    });
  }

  void _onCityChanged(dynamic value) {
    setState(() => selectedCity = value);
  }

  Future<void> _saveSelection() async {
    if (selectedCity == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountry', json.encode(selectedCountry));
    await prefs.setString('selectedState', json.encode(selectedState));
    await prefs.setString('selectedCity', json.encode(selectedCity));

    if (!mounted) return;
    Navigator.pop(context, {
      'country': selectedCountry?['name'],
      'state': selectedState?['name'],
      'city': selectedCity?['name'],
      'lat': double.tryParse('${selectedCity?['latitude']}') ?? 0.0,
      'lon': double.tryParse('${selectedCity?['longitude']}') ?? 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تحديد الموقع')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تحديد الموقع')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تحديد الموقع')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _LabeledDropdown(
              label: 'الدولة',
              value: selectedCountry,
              items: countries.map((c) => DropdownMenuItem(value: c, child: Text('${c['name']}'))).toList(),
              onChanged: _onCountryChanged,
            ),
            const SizedBox(height: 16),
            _LabeledDropdown(
              label: 'الولاية/المحافظة',
              value: selectedState,
              items: states.map((s) => DropdownMenuItem(value: s, child: Text('${s['name']}'))).toList(),
              onChanged: (selectedCountry != null) ? _onStateChanged : null,
            ),
            const SizedBox(height: 16),
            _LabeledDropdown(
              label: 'المدينة',
              value: selectedCity,
              items: cities.map((c) => DropdownMenuItem(value: c, child: Text('${c['name']}'))).toList(),
              onChanged: (selectedState != null) ? _onCityChanged : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (selectedCity != null) ? _saveSelection : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('تأكيد الموقع'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  final String label;
  final dynamic value;
  final List<DropdownMenuItem> items;
  final ValueChanged<dynamic>? onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: ' ',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          menuMaxHeight: 420,
          hint: Text(label),
        ),
      ),
    );
  }
}
