import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/checkout_payment_method_service.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/checkout_payment_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Address/presentaion/manager/address_cubit.dart';
import '../../../Address/presentaion/manager/address_events.dart';
import '../../../Address/presentaion/manager/address_state.dart';
import '../manager/checkout_cubit.dart';
import '../manager/checkout_event.dart';
import '../manager/checkout_state.dart';
import 'order_succss_screen.dart';
import 'widget/checkout_address_section.dart';

import 'widget/checkout_delivery_time_section.dart';
import 'widget/checkout_gift_section.dart';


class CheckoutScreen extends StatefulWidget {
  final String cartId;
  final String? defaultAddressId;

  const CheckoutScreen({
    super.key,
    required this.cartId,
    this.defaultAddressId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _giftFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final addressCubit = context.read<AddressCubit>();
    final checkoutCubit = context.read<CheckoutCubit>();

    addressCubit.doEvents(GetSavedAddressesEvent());

    final currentSelectedId = widget.defaultAddressId ??
        addressCubit.state.selectedAddress?.id ??
        (addressCubit.state.addresses.isNotEmpty
            ? addressCubit.state.addresses.first.id
            : null);

    if (currentSelectedId != null) {
      checkoutCubit.doEvents(
        GetCheckoutDetailsEvent(
          cartId: widget.cartId,
          defaultAddressId: currentSelectedId,
        ),
      );
    }
  }

  Widget _buildSectionDivider(Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: 25,
      width: double.infinity,
      color: surfaceColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? LightColors();

    return MultiBlocListener(
      listeners: [
        BlocListener<AddressCubit, AddressState>(
          listenWhen: (prev, curr) {
            final hadNoAddresses =
                prev.addresses.isEmpty && curr.addresses.isNotEmpty;
            final addressSelected =
                prev.selectedAddress?.id != curr.selectedAddress?.id;
            return hadNoAddresses || addressSelected;
          },
          listener: (context, addressState) {
            final checkoutCubit = context.read<CheckoutCubit>();

            if (checkoutCubit.state.selectedAddressId == null) {
              final resolvedAddressId = addressState.selectedAddress?.id ??
                  (addressState.addresses.isNotEmpty
                      ? addressState.addresses.first.id
                      : null);

              if (resolvedAddressId != null) {
                checkoutCubit.doEvents(
                  GetCheckoutDetailsEvent(
                    cartId: widget.cartId,
                    defaultAddressId: resolvedAddressId,
                  ),
                );
              }
            }
          },
        ),
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (prev, curr) =>
          prev.placeOrderResource != curr.placeOrderResource,
          listener: (context, state) {
            final resource = state.placeOrderResource;
            if (resource.isSuccess) {
              final orderPlacement = resource.data;
              if (orderPlacement?.cardSession?.successUrl == null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                );
              }
            } else if (resource.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    resource.errorMessage ?? AppStrings.orderFailedFallback.tr(),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(AppStrings.checkoutTitle.tr()),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckoutDeliveryTimeSection(colors: colors),
              _buildSectionDivider(colors.surface),
              CheckoutAddressSection(cartId: widget.cartId, colors: colors),
              _buildSectionDivider(colors.surface),
              CheckoutPaymentMethodSection(colors: colors),
              _buildSectionDivider(colors.surface),
              CheckoutGiftSection(formKey: _giftFormKey),
              _buildSectionDivider(colors.surface),
              CheckoutBottomSummarySection(
                cartId: widget.cartId,
                colors: colors,
                giftFormKey: _giftFormKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}