import 'package:flutter/material.dart';
import '../../../../core/constant/contry_code.dart';


class CountryStep extends StatelessWidget {
  final ValueChanged<Country> onCompleted;

  const CountryStep({
    super.key,
    required this.onCompleted,
  });

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
            decoration: const InputDecoration(
              hintText: 'Select your country',
            ),
            items: supportedCountries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Text(
                  '${country.flag}  ${country.name}',
                ),
              );
            }).toList(),
            onChanged: (country) {
              if (country != null) {
                onCompleted(country);
              }
            },
          ),
        ],
      ),
    );
  }
}
