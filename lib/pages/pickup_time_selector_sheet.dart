import 'package:flutter/material.dart';

import 'package:deligo/config/colors.dart';
import 'package:deligo/localization/app_localization.dart';

class PickupTimeSelectorSheet extends StatefulWidget {
  final PickupTime? pickupTimeIn;
  const PickupTimeSelectorSheet({super.key, this.pickupTimeIn});

  @override
  State<PickupTimeSelectorSheet> createState() =>
      _PickupTimeSelectorSheetState();
}

class _PickupTimeSelectorSheetState extends State<PickupTimeSelectorSheet> {
  final List<PickupTime> _pickupTimes = [
    PickupTime(
      value: "10",
      title: "10 min",
    ),
    PickupTime(
      value: "20",
      title: "20 min",
    ),
    PickupTime(
      value: "30",
      title: "30 min",
    ),
    PickupTime(
      value: "40",
      title: "40 min",
    ),
    PickupTime(
      value: "50",
      title: "50 min",
    ),
    PickupTime(
      value: "60",
      title: "60 min",
    ),
  ];
  PickupTime? _selectedTime;

  @override
  void initState() {
    _selectedTime = widget.pickupTimeIn ?? _pickupTimes.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DraggableScrollableSheet(
        minChildSize: 0.5,
        maxChildSize: 0.6,
        builder: (context, controller) => Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      AppLocalization.instance
                          .getLocalizationFor("reaching_in"),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8.0),
                      itemCount: _pickupTimes.length,
                      shrinkWrap: true,
                      controller: controller,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedTime == _pickupTimes[index]
                                ? Colors.green
                                : theme.cardColor,
                            width: 1.5,
                          ),
                        ),
                        // ignore: deprecated_member_use
                        child: RadioListTile<PickupTime>(
                          title: Text(
                            _pickupTimes[index].title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _selectedTime == _pickupTimes[index]
                                  ? Colors.green
                                  : theme.primaryColorDark,
                            ),
                          ),
                          value: _pickupTimes[index],
                          groupValue: _selectedTime,
                          onChanged: (PickupTime? value) {
                            setState(() => _selectedTime = value);
                            Future.delayed(const Duration(milliseconds: 500),
                                () => Navigator.pop(context, value));
                          },
                          activeColor: mainColor,
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}

class PickupTime {
  final String value;
  final String title;

  PickupTime({required this.value, required this.title});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PickupTime && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
