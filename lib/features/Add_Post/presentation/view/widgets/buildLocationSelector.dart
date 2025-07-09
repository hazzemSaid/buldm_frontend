// ignore_for_file: public_member_api_docs, sort_constructors_first, file_names
import 'package:buldm/features/Add_Post/presentation/bloc/location_cubit/location_cubit.dart';
import 'package:buldm/features/Add_Post/presentation/view/screens/LostItemLocationPicker.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuildLocationSelector extends StatefulWidget {
  // هتتهندل ب البلوك  if we have a data location
  final LocationModel? initialLocation;

  const BuildLocationSelector({super.key, this.initialLocation});

  @override
  State<BuildLocationSelector> createState() => _BuildLocationSelectorState();
}

class _BuildLocationSelectorState extends State<BuildLocationSelector> {
  LocationModel? _pickedLocation;

  @override
  void initState() {
    super.initState();

    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final locationCubit = context.read<LocationCubit>();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: locationCubit,
              child: LostItemLocationPicker(),
            ),
          ),
        );

        final currentState = locationCubit.state;

        if (currentState is LocationSelected) {
          final selectedLocation = currentState.location;
          setState(() {
            _pickedLocation = LocationModel(
              type: 'Point',
              coordinates: [
                selectedLocation.longitude,
                selectedLocation.latitude
              ],
              placeName: 'Selected Location',
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              _pickedLocation != null ? Colors.green.shade50 : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pickedLocation != null ? Colors.green : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: _pickedLocation != null ? Colors.green : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pickedLocation != null
                        ? 'Location Selected'
                        : 'Select Location',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _pickedLocation != null
                          ? Colors.green
                          : Colors.grey[700],
                    ),
                  ),
                  if (_pickedLocation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _pickedLocation!.placeName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
