import 'package:deligo/config/style.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/utility/helper.dart';
import 'package:flutter/material.dart';

class DateTimePickerSheet extends StatefulWidget {
  final String title;
  final DateTime? date;
  final TimeOfDay? time;
  const DateTimePickerSheet(
      {super.key, required this.title, this.date, this.time});

  @override
  State<DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<DateTimePickerSheet> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  late DateTime dateSelected;
  late TimeOfDay timeSelected;

  @override
  void initState() {
    dateSelected = widget.date ?? DateTime.now();
    timeSelected = widget.time ?? TimeOfDay.now();
    dateController.text =
        Helper.setupDateFromMillis(dateSelected.millisecondsSinceEpoch, true);
    timeController.text = Helper.setupTimeFromMillis(
        DateTime(dateSelected.year, dateSelected.month, dateSelected.day,
                timeSelected.hour, timeSelected.minute)
            .millisecondsSinceEpoch,
        true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close),
            ),
            const SizedBox(height: 25),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 38),
            CustomTextField(
              title:
                  AppLocalization.instance.getLocalizationFor("selectedDate"),
              hintText: "",
              readOnly: true,
              controller: dateController,
              onTap: () => showDatePicker(
                context: context,
                initialDate: dateSelected,
                initialDatePickerMode: DatePickerMode.day,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 395)),
                builder: (context, child) =>
                    timePickerBuilder(Theme.of(context), child!),
              ).then((value) {
                if (value != null) {
                  dateSelected = value;
                  dateController.text = Helper.setupDateFromMillis(
                      dateSelected.millisecondsSinceEpoch, true);
                  setState(() {});
                }
              }),
            ),
            const SizedBox(height: 26),
            CustomTextField(
              title:
                  AppLocalization.instance.getLocalizationFor("selectedTime"),
              hintText: "",
              readOnly: true,
              controller: timeController,
              onTap: () => showTimePicker(
                context: context,
                initialTime: timeSelected,
                builder: (context, child) =>
                    timePickerBuilder(Theme.of(context), child!),
              ).then((value) {
                if (value != null) {
                  timeSelected = value;
                  timeController.text = Helper.setupTimeFromMillis(
                      DateTime(
                              dateSelected.year,
                              dateSelected.month,
                              dateSelected.day,
                              timeSelected.hour,
                              timeSelected.minute)
                          .millisecondsSinceEpoch,
                      true);
                  setState(() {});
                }
              }),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: AppLocalization.instance.getLocalizationFor("next"),
              onTap: () => Navigator.pop(context, {
                "date": dateSelected,
                "time": timeSelected,
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
}
