import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/transaction.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: const WalletStateful(),
      );
}

class WalletStateful extends StatefulWidget {
  const WalletStateful({super.key});

  @override
  State<WalletStateful> createState() => _WalletStatefulState();
}

class _WalletStatefulState extends State<WalletStateful> {
  double balance = 0;
  List<Transaction> transactions = [];
  int pageNo = 1;
  bool isLoading = true;
  bool allDone = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context).initFetchWalletBalance();
    BlocProvider.of<FetcherCubit>(context).initFetchWalletTransactions(1);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final textColor = Colors.white;
    final titleColor = Colors.white;
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is WalletBalanceLoaded) {
          balance = state.wallet.balance;
          setState(() {});
        }
        if (state is WalletTransactionsLoaded) {
          pageNo = state.transactions.meta.current_page ?? 1;
          allDone = state.transactions.meta.current_page ==
              state.transactions.meta.last_page;
          if (state.transactions.meta.current_page == 1) {
            transactions.clear();
          }
          transactions.addAll(state.transactions.data);
          isLoading = false;
          setState(() {});
        }
        if (state is WalletTransactionsFail) {
          isLoading = false;
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: theme.primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [Color(0xFF10C850), Color(0xFF06B13A)],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(32),
                  //   bottomRight: Radius.circular(32),
                  // ),
                  image: DecorationImage(
                image: AssetImage("assets/wallet_bg_big.png"),
                fit: BoxFit.cover,
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppLocalization.instance.getLocalizationFor("wallet"),
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalization.instance
                                .getLocalizationFor("totalBalance"),
                            style: theme.textTheme.titleSmall?.copyWith(
                                color: titleColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${AppSettings.currencyIcon} ${Helper.formatNumber(balance)}",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: textColor,
                              //fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      CustomButton(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                        prefixIcon: Icons.add,
                        prefixIconColor: theme.primaryColor,
                        text: AppLocalization.instance
                            .getLocalizationFor("add_money"),
                        textColor: theme.primaryColor,
                        buttonColor: theme.scaffoldBackgroundColor,
                        onTap: () => Navigator.pushNamed(
                                context, PageRoutes.addMoneyPage)
                            .then((value) {
                          if (mounted) {
                            BlocProvider.of<FetcherCubit>(context)
                                .initFetchWalletBalance();
                            BlocProvider.of<FetcherCubit>(context)
                                .initFetchWalletTransactions(1);
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Text(
                        AppLocalization.instance
                            .getLocalizationFor("recentTransactions"),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ),
                    Expanded(
                      child: transactions.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              // separatorBuilder: (context, index) =>
                              //     const SizedBox(height: 8),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                if ((index == transactions.length - 1) &&
                                    !isLoading &&
                                    !allDone) {
                                  isLoading = true;
                                  BlocProvider.of<FetcherCubit>(context)
                                      .initFetchWalletTransactions(pageNo + 1);
                                }
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  title: Text(
                                    transactions[index].metaDescription ??
                                        "${transactions[index].type}"
                                            .capitalizeFirst(),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    transactions[index].createdAtFormatted ??
                                        "",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: theme.hintColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: Text(
                                    "${AppSettings.currencyIcon} ${transactions[index].amount.toStringAsFixed(0)}",
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: [
                                        "earnings",
                                        "deposit"
                                      ].contains(transactions[index].type)
                                          ? Colors.green
                                          : Colors.redAccent,
                                    ),
                                  ),
                                );
                              },
                            )
                          : (isLoading
                              ? Loader.circularProgressIndicatorPrimary(context)
                              : Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: ErrorFinalWidget.errorWithRetry(
                                    context: context,
                                    message: AppLocalization.instance
                                        .getLocalizationFor(
                                            "no_transactions_found"),
                                    actionText: AppLocalization.instance
                                        .getLocalizationFor("okay"),
                                    action: () => Navigator.pop(context),
                                  ))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
