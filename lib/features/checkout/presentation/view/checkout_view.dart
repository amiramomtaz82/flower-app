import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/checkout_payment_method_service.dart' show CheckoutPaymentSection;

import 'package:flower_app/features/checkout/presentation/view/widget/checkout_summery_option.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/deliver_time_section.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/divider_section.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final addressCubit = context.read<AddressCubit>();
    final checkoutCubit = context.read<CheckoutCubit>();

    _nameController = TextEditingController(text: checkoutCubit.state.recipientName ?? '');
    _phoneController = TextEditingController(text: checkoutCubit.state.recipientPhone ?? '');

    addressCubit.doEvents(GetSavedAddressesEvent());

    final initialAddressId = widget.defaultAddressId ??
        addressCubit.state.selectedAddress?.id ??
        (addressCubit.state.addresses.isNotEmpty ? addressCubit.state.addresses.first.id : null);

    if (initialAddressId != null) {
      checkoutCubit.doEvents(
        GetCheckoutDetailsEvent(
          cartId: widget.cartId,
          defaultAddressId: initialAddressId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddressCubit, AddressState>(
          listenWhen: (prev, curr) =>
          (prev.addresses.isEmpty && curr.addresses.isNotEmpty) ||
              prev.selectedAddress?.id != curr.selectedAddress?.id,
          listener: (context, addressState) {
            final checkoutCubit = context.read<CheckoutCubit>();
            if (checkoutCubit.state.selectedAddressId == null) {
              final resolvedId = addressState.selectedAddress?.id ??
                  (addressState.addresses.isNotEmpty ? addressState.addresses.first.id : null);

              if (resolvedId != null) {
                checkoutCubit.doEvents(
                  GetCheckoutDetailsEvent(
                    cartId: widget.cartId,
                    defaultAddressId: resolvedId,
                  ),
                );
              }
            }
          },
        ),
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (prev, curr) =>
          prev.recipientName != curr.recipientName ||
              prev.recipientPhone != curr.recipientPhone,
          listener: (_, state) {
            _syncController(_nameController, state.recipientName ?? '');
            _syncController(_phoneController, state.recipientPhone ?? '');
          },
        ),
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (prev, curr) => prev.placeOrderResource != curr.placeOrderResource,
          listener: (context, state) {
            final resource = state.placeOrderResource;
            if (resource.isSuccess) {
              if (resource.data?.cardSession?.successUrl == null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                );
              }
            } else if (resource.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resource.errorMessage ?? AppStrings.orderFailedFallback),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:  Text(AppStrings.checkoutTitle.tr()),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckoutDeliveryTimeSection(),
              const CheckoutSectionDivider(),
              CheckoutAddressSection(cartId: widget.cartId),
              const CheckoutSectionDivider(),
              const CheckoutPaymentSection(),
              const CheckoutSectionDivider(),
              CheckoutGiftSection(
                formKey: _giftFormKey,
                nameController: _nameController,
                phoneController: _phoneController,
              ),
              const CheckoutSectionDivider(),
              CheckoutSummarySection(
                cartId: widget.cartId,
                giftFormKey: _giftFormKey,
                nameController: _nameController,
                phoneController: _phoneController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncController(TextEditingController controller, String incoming) {
    if (controller.text != incoming) {
      controller.value = TextEditingValue(
        text: incoming,
        selection: TextSelection.collapsed(offset: incoming.length),
      );
    }
  }
}