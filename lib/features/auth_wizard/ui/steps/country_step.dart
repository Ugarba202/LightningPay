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

  @override
  void initState() {
    super.initState();
    widget.showValidationNotifier.addListener(_onShowValidation);
  }

  @override
  void dispose() {
    widget.showValidationNotifier.removeListener(_onShowValidation);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you located?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'We use this to format phone numbers',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<Country>(
            decoration: InputDecoration(
              hintText: 'Select your country',
              errorText: _error,
            ),
            value: _selected,
            items: supportedCountries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Text('${country.flag}  ${country.name}'),
              );
            }).toList(),
            onChanged: (country) {
              setState(() {
                _selected = country;
                _error = null;
              });
              widget.onCompleted(country);
            },
          ),
        ],
      ),
    );
  }
}
