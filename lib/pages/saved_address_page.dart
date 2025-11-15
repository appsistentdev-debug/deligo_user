import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/widgets/address_tile.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedAddressPage extends StatelessWidget {
  const SavedAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return BlocProvider(
      create: (context) => FetcherCubit(),
      child: SavedAddressStateful(
          pick: arguments != null &&
              arguments.containsKey("pick") &&
              arguments["pick"] == true),
    );
  }
}

class SavedAddressStateful extends StatefulWidget {
  final bool pick;

  const SavedAddressStateful({super.key, required this.pick});

  @override
  State<SavedAddressStateful> createState() => _SavedAddressStatefulState();
}

class _SavedAddressStatefulState extends State<SavedAddressStateful> {
  late FetcherCubit _fetcherCubit;
  bool isLoading = true;
  List<Address> addresses = [];

  @override
  void initState() {
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    _fetcherCubit.initFetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is AddressesLoaded) {
          addresses = state.addresses;
          isLoading = false;
          setState(() {});
        }
        if (state is AddressesLoadFail) {
          isLoading = false;
          setState(() {});
        }

        if (state is AddressDeleteLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }

        if (state is AddressDeleteLoaded) {
          addresses
              .removeWhere((Address address) => address.id == state.addressId);
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: theme.cardColor,
        appBar: RegularAppBar(
            title:
                AppLocalization.instance.getLocalizationFor("savedAddresses")),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: addresses.isNotEmpty
                      ? ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                                height: 8,
                              ),
                          itemCount: addresses.length,
                          itemBuilder: (context, index) => AddressTile(
                                type: AppLocalization.instance
                                    .getLocalizationFor(
                                        addresses[index].title!),
                                icon: addresses[index].title ==
                                        "address_type_home"
                                    ? Icons.home
                                    : addresses[index].title ==
                                            "address_type_office"
                                        ? Icons.apartment
                                        : Icons.location_on,
                                address: AppLocalization.instance
                                    .getLocalizationFor(
                                        addresses[index].formatted_address),

                                // subtitle: addresses[index].formatted_address,
                                // bgColor: theme.scaffoldBackgroundColor,
                                // iconColor: theme.primaryColor,
                                // height: 92,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                onTap: () {
                                  if (widget.pick) {
                                    Navigator.pop(context, addresses[index]);
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      PageRoutes.addAddressPage,
                                      arguments: {"address": addresses[index]},
                                    ).then((value) {
                                      if (mounted &&
                                          value != null &&
                                          value is Address) {
                                        int index = addresses.indexOf(value);
                                        if (index != -1) {
                                          addresses[index] = value;
                                          setState(() {});
                                        }
                                      }
                                    });
                                  }
                                },
                                trailing: PopupMenuButton(
                                  color: theme.scaffoldBackgroundColor,
                                  onSelected: (value) {
                                    if (value == "delete") {
                                      _handleDeletion(index);
                                    } else if (value == "edit") {
                                      Navigator.pushNamed(
                                        context,
                                        PageRoutes.addAddressPage,
                                        arguments: {
                                          "address": addresses[index]
                                        },
                                      ).then((value) {
                                        if (mounted &&
                                            value != null &&
                                            value is Address) {
                                          int index = addresses.indexOf(value);
                                          if (index != -1) {
                                            addresses[index] = value;
                                            setState(() {});
                                          }
                                        }
                                      });
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: "edit",
                                      child: Text(
                                        AppLocalization.instance
                                            .getLocalizationFor("edit"),
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: "delete",
                                      child: Text(
                                        AppLocalization.instance
                                            .getLocalizationFor("delete"),
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                  ],
                                  child: const Icon(Icons.more_vert),
                                ),
                              ))
                      : isLoading
                          ? Loader.circularProgressIndicatorPrimary(context)
                          : Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: ErrorFinalWidget.errorWithRetry(
                                context: context,
                                message: AppLocalization.instance
                                    .getLocalizationFor("empty_addresses"),
                                actionText: AppLocalization.instance
                                    .getLocalizationFor("okay"),
                                action: () => Navigator.pop(context),
                              ),
                            ),
                ),
                CustomButton(
                  prefixIcon: Icons.add,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  prefixIconColor: theme.scaffoldBackgroundColor,
                  text: AppLocalization.instance
                      .getLocalizationFor("addNewAddress"),
                  onTap: () =>
                      Navigator.pushNamed(context, PageRoutes.addAddressPage)
                          .then((value) {
                    if (value != null && value is Address) {
                      addresses.insert(0, value);
                      setState(() {});
                    }
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  dynamic _handleDeletion(int index) => ConfirmDialog.showConfirmation(
              context,
              Text(AppLocalization.instance.getLocalizationFor("delete")),
              Text(AppLocalization.instance.getLocalizationFor("delete_msg")),
              AppLocalization.instance.getLocalizationFor("no"),
              AppLocalization.instance.getLocalizationFor("yes"))
          .then((value) {
        if (value != null && value == true) {
          if (mounted) {
            _fetcherCubit.initDeleteAddress(addresses[index].id);
          }
        }
      });
}
