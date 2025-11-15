import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/payment_cubit.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

class AddMoneyPage extends StatelessWidget {
  const AddMoneyPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (BuildContext context) => PaymentCubit(),
        child: const AddMoneyStateful(),
      );
}

class AddMoneyStateful extends StatefulWidget {
  const AddMoneyStateful({super.key});

  @override
  State<AddMoneyStateful> createState() => _AddMoneyStatefulState();
}

class _AddMoneyStatefulState extends State<AddMoneyStateful> {
  final TextEditingController _amountController = TextEditingController();
  List<PaymentMethod> paymentMethods = [];
  String? paymentMethodSlugSelected;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PaymentCubit>(context)
        .initFetchPaymentMethods(["cod", "wallet"]);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentMethodsLoaded) {
          paymentMethods = state.listPayment;
          isLoading = false;
          setState(() {});
        }
        if (state is PaymentMethodsError) {
          isLoading = false;
          setState(() {});
        }
        if (state is LoadingWalletDeposit) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }

        if (state is WalletDepositLoaded) {
          Navigator.pushNamed(
            context,
            PageRoutes.processPaymentPage,
            arguments: state.paymentData,
          ).then((value) async {
            bool paid = value != null && value is PaymentStatus && value.isPaid;
            Toaster.showToastCenter(AppLocalization.instance.getLocalizationFor(
                paid ? "payment_success_message_wallet" : "payment_fail"));
            if (paid) {
              await LocalDataLayer().setTabUpdate(2, null);
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        }
        if (state is WalletDepositError) {
          Toaster.showToastCenter(state.message);
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
          title: AppLocalization.instance.getLocalizationFor("add_money"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: CustomTextField(
                title: AppLocalization.instance.getLocalizationFor("amt_add"),
                hintText:
                    AppLocalization.instance.getLocalizationFor("ent_amt"),
                textInputType: TextInputType.number,
                controller: _amountController,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                AppLocalization.instance
                    .getLocalizationFor("selectPaymentMethod"),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: paymentMethods.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(22),
                      //shrinkWrap: true,
                      itemCount: paymentMethods.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              paymentMethods[index].imageAsset,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: Text(
                                paymentMethods[index].title ?? "",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Radio<String?>(
                              fillColor:
                                  WidgetStateProperty.all(theme.primaryColor),
                              value: paymentMethods[index].slug,
                              groupValue: paymentMethodSlugSelected,
                              onChanged: (String? val) => setState(
                                  () => paymentMethodSlugSelected = val),
                            ),
                          ],
                        ),
                      ),
                    )
                  : isLoading
                      ? Loader.circularProgressIndicatorPrimary(context)
                      : Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: ErrorFinalWidget.errorWithRetry(
                            context: context,
                            message: AppLocalization.instance
                                .getLocalizationFor("no_pgs_found"),
                            actionText: AppLocalization.instance
                                .getLocalizationFor("okay"),
                            action: () => Navigator.pop(context),
                          )),
            ),
            if (paymentMethodSlugSelected != null)
              CustomButton(
                text:
                    AppLocalization.instance.getLocalizationFor("continueText"),
                margin: const EdgeInsets.all(20),
                onTap: () {
                  if (_amountController.text.trim().isEmpty) {
                    Toaster.showToastBottom(AppLocalization.instance
                        .getLocalizationFor("enter_amount"));
                  } else if (paymentMethodSlugSelected == null) {
                    Toaster.showToastBottom(AppLocalization.instance
                        .getLocalizationFor("select_payment"));
                  } else {
                    BlocProvider.of<PaymentCubit>(context).initWalletDeposit(
                        double.tryParse(_amountController.text.trim()) ?? 0,
                        paymentMethods.firstWhere((element) =>
                            element.slug == paymentMethodSlugSelected),
                        null);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
