import 'package:flower_app/core/app_theme/app_colors.dart';

import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/checkout_address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_constants/app_strings.dart';
import '../../../../core/validation/validation.dart';
import '../../../Address/presentaion/manager/address_cubit.dart';
import '../../../Address/presentaion/manager/address_events.dart';
import '../../../Address/presentaion/manager/address_state.dart';

import '../manager/checkout_cubit.dart';
import '../manager/checkout_event.dart';
import '../manager/checkout_state.dart';
import 'order_succss_screen.dart';

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

  Widget _buildDeliveryTimeWidget(CheckoutState checkoutState) {
    final isEstimateLoading = checkoutState.estimateDeliveryResource.isLoading;
    final isDetailsLoading = checkoutState.checkoutDetailsResource.isLoading;

    if (isEstimateLoading || isDetailsLoading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF00897B),
        ),
      );
    }

    final estimatedTime = checkoutState.estimateDeliveryResource.data?.estimatedDeliveryAt ??
        checkoutState.checkoutDetailsResource.data?.estimatedDeliveryAt;

    final displayText = (estimatedTime != null && estimatedTime.trim().isNotEmpty)
        ? '${AppStrings.arriveBy} $estimatedTime'
        : AppStrings.notDetermined;

    return Text(
      displayText,
      style: TextStyle(
        color: (estimatedTime != null && estimatedTime.trim().isNotEmpty)
            ? const Color(0xFF00897B)
            : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final addressCubit = context.read<AddressCubit>();
    final checkoutCubit = context.read<CheckoutCubit>();

    _nameController = TextEditingController(
      text: checkoutCubit.state.recipientName ?? '',
    );
    _phoneController = TextEditingController(
      text: checkoutCubit.state.recipientPhone ?? '',
    );

    // 1. Fetch saved addresses
    addressCubit.doEvents(GetSavedAddressesEvent());

    // 2. Resolve default address id
    final currentSelectedId = widget.defaultAddressId ??
        addressCubit.state.selectedAddress?.id ??
        (addressCubit.state.addresses.isNotEmpty ? addressCubit.state.addresses.first.id : null);

    if (currentSelectedId != null) {
      checkoutCubit.doEvents(
        GetCheckoutDetailsEvent(
          cartId: widget.cartId,
          defaultAddressId: currentSelectedId,
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
    AppColors colors = LightColors();

    return MultiBlocListener(
      listeners: [
        BlocListener<AddressCubit, AddressState>(
          listenWhen: (prev, curr) {
            final hadNoAddresses = prev.addresses.isEmpty && curr.addresses.isNotEmpty;
            final addressSelected = prev.selectedAddress?.id != curr.selectedAddress?.id;
            return hadNoAddresses || addressSelected;
          },
          listener: (context, addressState) {
            final checkoutCubit = context.read<CheckoutCubit>();

            if (checkoutCubit.state.selectedAddressId == null) {
              final resolvedAddressId = addressState.selectedAddress?.id ??
                  (addressState.addresses.isNotEmpty ? addressState.addresses.first.id : null);

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
          prev.recipientName != curr.recipientName ||
              prev.recipientPhone != curr.recipientPhone,
          listener: (context, state) {
            final incomingName = state.recipientName ?? '';
            if (_nameController.text != incomingName) {
              _nameController.value = TextEditingValue(
                text: incomingName,
                selection: TextSelection.collapsed(offset: incomingName.length),
              );
            }

            final incomingPhone = state.recipientPhone ?? '';
            if (_phoneController.text != incomingPhone) {
              _phoneController.value = TextEditingValue(
                text: incomingPhone,
                selection: TextSelection.collapsed(offset: incomingPhone.length),
              );
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
              if (orderPlacement?.cardSession?.successUrl != null) {
                // Card session flow
              } else {
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(AppStrings.checkoutTitle),
          centerTitle: true,
        ),
        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, checkoutState) {
            final cubit = context.read<CheckoutCubit>();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. DELIVERY TIME ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.deliveryTime, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.watch_later_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(AppStrings.instant, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: 4),
                            _buildDeliveryTimeWidget(checkoutState),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _buildSectionDivider(colors.surface),

                  // --- 2. DELIVERY ADDRESS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.deliveryAddress,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<AddressCubit, AddressState>(
                          builder: (context, addressState) {
                            final addresses = addressState.addresses;

                            return Column(
                              children: [
                                if (addresses.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      AppStrings.noSavedAddresses,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: addresses.length,
                                    itemBuilder: (context, index) {
                                      final addressItem = addresses[index];
                                      final isSelected = checkoutState.selectedAddressId == addressItem.id ||
                                          (checkoutState.selectedAddressId == null &&
                                              addressItem.id == addressState.selectedAddress?.id);

                                      return CheckoutAddressCard(
                                        address: addressItem,
                                        isSelected: isSelected,
                                        onTap: () {
                                          context.read<AddressCubit>().doEvents(SelectAddressEvent(addressItem));
                                          cubit.doEvents(
                                            EstimateDeliveryEvent(
                                              addressId: addressItem.id ?? '',
                                              cartId: widget.cartId,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () => context.push(AppRoutes.addAddress),
                                    icon: const Icon(Icons.add, size: 20, color: Color(0xFFD81B60)),
                                    label: const Text(
                                      AppStrings.addNew,
                                      style: TextStyle(
                                        color: Color(0xFFD81B60),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  _buildSectionDivider(colors.surface),

                  // --- 3. PAYMENT METHOD ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.paymentMethod, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 6),
                        _buildRadioOption(
                          title: AppStrings.cashOnDelivery,
                          value: PaymentMethodType.cash,
                          groupValue: checkoutState.paymentMethod,
                          onChanged: (val) => cubit.doEvents(SelectPaymentMethodEvent(val!)),
                        ),
                        _buildRadioOption(
                          title: AppStrings.creditCard,
                          value: PaymentMethodType.card,
                          groupValue: checkoutState.paymentMethod,
                          onChanged: (val) =>
                              cubit.doEvents(SelectPaymentMethodEvent(val!)),
                        ),
                      ],
                    ),
                  ),

                  _buildSectionDivider(colors.surface),

                  // --- 4. GIFT OPTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildGiftSection(checkoutState, cubit),
                  ),

                  _buildSectionDivider(colors.surface),

                  // --- 5. PRICE BREAKDOWN & BUTTON ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Builder(
                      builder: (context) {
                        final details = checkoutState.checkoutDetailsResource.data;
                        final subtotal = details?.subtotal ?? 0.0;
                        final deliveryFee = details?.deliveryFee ?? 0.0;
                        final total = details?.total ?? 0.0;

                        return Column(
                          children: [
                            _buildSummaryRow(
                              AppStrings.subTotal,
                              '${subtotal.toStringAsFixed(2)}\$',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              AppStrings.deliveryFee,
                              '${deliveryFee.toStringAsFixed(2)}\$',
                            ),
                            const Divider(height: 24, thickness: 0.8),
                            _buildSummaryRow(
                              AppStrings.total,
                              '${total.toStringAsFixed(2)}\$',
                              isTotal: true,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD81B60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: checkoutState.placeOrderResource.isLoading
                                    ? null
                                    : () {
                                  if (checkoutState.selectedAddressId == null ||
                                      checkoutState.selectedAddressId!.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: const Text(AppStrings.selectAddressWarning),
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    return;
                                  }

                                  if (checkoutState.isGift &&
                                      checkoutState.paymentMethod != PaymentMethodType.cash) {
                                    if (!(_giftFormKey.currentState?.validate() ?? false)) {
                                      return;
                                    }
                                    cubit.doEvents(
                                      UpdateGiftDetailsEvent(
                                        name: _nameController.text.trim(),
                                        phone: _phoneController.text.trim(),
                                      ),
                                    );
                                  }

                                  cubit.doEvents(PlaceOrderEvent(widget.cartId));
                                },
                                child: checkoutState.placeOrderResource.isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  AppStrings.placeOrder,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionDivider(Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: 25,
      width: double.infinity,
      color: surfaceColor,
    );
  }

  Widget _buildRadioOption({
    required String title,
    required PaymentMethodType value,
    required PaymentMethodType groupValue,
    required ValueChanged<PaymentMethodType?> onChanged,
  }) {
    AppColors colors = LightColors();
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Radio<PaymentMethodType>(
              value: value,
              groupValue: groupValue,
              activeColor: colors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftSection(CheckoutState state, CheckoutCubit cubit) {
    final isCash = state.paymentMethod == PaymentMethodType.cash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCash && state.isGift) ...[
          const SizedBox(height: 12),
          Form(
            key: _giftFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterRecipientName,
                    labelText: AppStrings.name,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: Validation.validateName,
                  onChanged: (name) => cubit.doEvents(UpdateGiftDetailsEvent(name: name)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterRecipientPhone,
                    labelText: AppStrings.phoneNumber,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: Validation.validatePhoneNumber,
                  onChanged: (phone) => cubit.doEvents(UpdateGiftDetailsEvent(phone: phone)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: Colors.black,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}