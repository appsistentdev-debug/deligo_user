import 'package:deligo/localization/app_localization.dart';
import 'package:flutter/material.dart';

class PackageTypeSheet extends StatelessWidget {
  final String value;
  const PackageTypeSheet({super.key, required this.value});

  @override
  Widget build(BuildContext context) => PackageTypeStateful(value);
}

class PackageTypeStateful extends StatefulWidget {
  final String value;
  const PackageTypeStateful(this.value, {super.key});

  @override
  State<PackageTypeStateful> createState() => _PackageTypeStatefulState();
}

class _PackageTypeStatefulState extends State<PackageTypeStateful> {
  final List<String> _packages = [
    "Document",
    "Electronic Gadget",
    "Food Item",
    "Gift",
    "Flower",
    "Chocolate",
    "Furniture",
  ];
  String? packageTypeSelected;

  @override
  void initState() {
    packageTypeSelected = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: theme.hintColor,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppLocalization.instance.getLocalizationFor("selectPackageType"),
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          //if (state is CategoriesLoaded)
          ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: _packages.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              ),
              child: RadioListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (value) {
                  packageTypeSelected = _packages[index];
                  setState(() {});
                  Future.delayed(const Duration(milliseconds: 250),
                      () => Navigator.pop(context, packageTypeSelected));
                },
                title: Text(
                  _packages[index],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                fillColor: WidgetStateProperty.all(theme.primaryColor),
                value: _packages[index],
                groupValue: packageTypeSelected,
              ),
            ),
          ),
          // else if (state is CategoriesLoading)
          //   Loader.circularProgressIndicatorPrimary(context)
          // else
          //   Padding(
          //     padding: const EdgeInsets.all(32.0),
          //     child: ErrorFinalWidget.errorWithRetry(
          //       context: context,
          //       message: AppLocalization.instance
          //           .getLocalizationFor("empty_package_types"),
          //       actionText:
          //           AppLocalization.instance.getLocalizationFor("okay"),
          //       action: () => Navigator.pop(context),
          //     ),
          //   ),
          const SizedBox(height: 20),
          // if (packageTypeSelected != null)
          //   CustomButton(
          //     label:
          //         AppLocalization.instance.getLocalizationFor("continueText"),
          //     margin: const EdgeInsets.all(20),
          //     onTap: () => Navigator.pop(context, packageTypeSelected),
          //   ),
        ],
      ),
    );
  }
}
