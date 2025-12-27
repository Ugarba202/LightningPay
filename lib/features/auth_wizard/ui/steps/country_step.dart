import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constant/contry_code.dart';

class CountryStep extends StatefulWidget {
  final ValueChanged<Country?> onCompleted;
  final ValueListenable<bool> showValidationNotifier;

  const CountryStep({
    super.key,
    required this.showValidationNotifier,
    required this.onCompleted,
  });

  @override
  State<CountryStep> createState() => _CountryStepState();
}

class _CountryStepState extends State<CountryStep> {
  Country? _selected;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = supportedCountries;

  @override
  void initState() {
    super.initState();
    widget.showValidationNotifier.addListener(_onShowValidation);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.showValidationNotifier.removeListener(_onShowValidation);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = supportedCountries
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onShowValidation() {
    if (widget.showValidationNotifier.value) {
      setState(
        () => _error = _selected == null ? 'Please select your country' : null,
      );
    } else if (_error != null) {
      setState(() => _error = null);
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search country...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    final query = v.toLowerCase();
                    setModalState(() {
                      _filteredCountries = supportedCountries
                          .where((c) => c.name.toLowerCase().contains(query))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      return ListTile(
                        leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                        title: Text(country.name, style: const TextStyle(color: Colors.white)),
                        trailing: Text(country.dialCode, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                        onTap: () {
                          setState(() {
                            _selected = country;
                            _error = null;
                            _searchController.clear();
                          });
                          widget.onCompleted(country);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you located?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We use this to format phone numbers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: _showCountryPicker,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _error != null ? Colors.red : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                   _selected != null 
                    ? Text(_selected!.flag, style: const TextStyle(fontSize: 20))
                    : Icon(Icons.public_rounded, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selected?.name ?? 'Select your country',
                      style: TextStyle(
                        color: _selected != null ? Colors.white : Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
