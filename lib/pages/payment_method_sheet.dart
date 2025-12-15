import 'package:deligo/bloc/payment_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentMethodSheet extends StatelessWidget {
  final PaymentMethod? value;

  const PaymentMethodSheet({super.key, this.value});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => PaymentCubit(),
        child: PaymentMethodStateful(value),
      );
}

class PaymentMethodStateful extends StatefulWidget {
  final PaymentMethod? value;

  const PaymentMethodStateful(this.value, {super.key});

  @override
  State<PaymentMethodStateful> createState() => _PaymentMethodStatefulState();
}

class _PaymentMethodStatefulState extends State<PaymentMethodStateful> {
  String? paymentMethodSlugSelected;
  PaymentMethod? paymentMethodSelected;

  @override
  void initState() {
    paymentMethodSelected = widget.value;
    paymentMethodSlugSelected = paymentMethodSelected?.slug;
    super.initState();
    BlocProvider.of<PaymentCubit>(context).initFetchPaymentMethods([]);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) => DraggableScrollableSheet(
        minChildSize: 0.5,
        maxChildSize: 0.8,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                AppLocalization.instance.getLocalizationFor("select_payment"),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              if (state is PaymentMethodsLoaded && state.listPayment.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    itemCount: state.listPayment.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                      // ignore: deprecated_member_use
                      child: RadioListTile(
                        toggleable: true,
                        value: state.listPayment[index].slug,
                        groupValue: paymentMethodSlugSelected,
                        onChanged: (value) {
                          paymentMethodSlugSelected =
                              state.listPayment[index].slug;
                          paymentMethodSelected = state.listPayment[index];
                          Navigator.pop(context, paymentMethodSelected);
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                        activeColor: theme.primaryColor,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.primaryColor;
                            }
                            return theme
                                .unselectedWidgetColor; // Unselected color
                          },
                        ),
                        secondary: Image.asset(
                          state.listPayment[index].imageAsset,
                          width: 20,
                          height: 20,
                        ),
                        title: Text(
                          state.listPayment[index].title ?? "",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else if (state is LoadingPaymentMethods)
                Loader.circularProgressIndicatorPrimary(context)
              else
                Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ErrorFinalWidget.errorWithRetry(
                      context: context,
                      message: AppLocalization.instance
                          .getLocalizationFor("no_pgs_found"),
                      actionText:
                          AppLocalization.instance.getLocalizationFor("okay"),
                      action: () => Navigator.pop(context),
                    )),
              const SizedBox(height: 20),
              // if (paymentMethodSelected != null)
              //   CustomButton(
              //     label: AppLocalization.instance
              //         .getLocalizationFor("continueText"),
              //     margin: const EdgeInsets.all(20),
              //     onTap: () => Navigator.pop(context, paymentMethodSelected),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
