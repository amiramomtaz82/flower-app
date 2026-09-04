// lib/features/checkout/presentation/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../Address/domain/entities/address_entity.dart';
import '../../../Address/presentaion/manager/address_cubit.dart';
import '../../../Address/presentaion/manager/address_events.dart';
import '../../../Address/presentaion/manager/address_state.dart';

import '../manager/checkout_cubit.dart';
import '../manager/checkout_event.dart';
import '../manager/checkout_state.dart';
import 'order_succss_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String cartId;

  const CheckoutScreen({super.key, required this.cartId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final addressCubit = context.read<AddressCubit>();
    final checkoutCubit = context.read<CheckoutCubit>();

    // 1. Fetch saved addresses if not already loaded
    addressCubit.doEvents(GetSavedAddressesEvent());

    // 2. Fetch checkout overview & details
    final defaultId = addressCubit.state.selectedAddress?.id;
    checkoutCubit.doEvents(
      GetCheckoutDetailsEvent(
        cartId: widget.cartId,
        defaultAddressId: defaultId,
      ),
    );
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
        BlocListener<CheckoutCubit, CheckoutState>(
          listenWhen: (prev, curr) =>
              prev.placeOrderResource != curr.placeOrderResource,
          listener: (context, state) {
            final resource = state.placeOrderResource;

            if (resource.isSuccess) {
              final orderPlacement = resource.data;
              if (orderPlacement?.cardSession?.successUrl != null) {
                // Navigate to webview
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                );
              }
            } else if (resource.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resource.errorMessage ?? 'Failed to place order'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
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
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, checkoutState) {
            final cubit = context.read<CheckoutCubit>();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. DELIVERY TIME BANNER ---
                  const Text(
                    'Delivery time',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                        checkoutState.estimateDeliveryResource.data?.estimatedDeliveryAt != null
                            ? 'Instant, By ${checkoutState.estimateDeliveryResource.data!.estimatedDeliveryAt}'
                            : 'Instant, By 24 Sep 2024, 11:00 AM',

                      style: const TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    )
                  ),
                  const SizedBox(height: 24),

                  // --- 2. DELIVERY ADDRESS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Delivery address',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // Navigate to Saved Addresses Screen
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<AddressCubit, AddressState>(
                    builder: (context, addressState) {
                      final addresses = addressState.addresses;

                      if (addresses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'No address found. Please add a delivery address.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        );
                      }

                      return Column(
                        children: addresses.map((addr) {
                          final isSelected =
                              checkoutState.selectedAddressId == addr.id;
                          return _buildAddressCard(
                            address: addr,
                            isSelected: isSelected,
                            onTap: () {
                              cubit.doEvents(
                                EstimateDeliveryEvent(
                                  addressId: addr.id ?? '',
                                  cartId: widget.cartId,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to Add Address Screen
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Color(0xFFD81B60),
                    ),
                    label: const Text(
                      'Add item',
                      style: TextStyle(
                        color: Color(0xFFD81B60),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Divider(height: 32, thickness: 0.8),

                  // --- 3. PAYMENT METHOD ---
                  const Text(
                    'Payment method',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildRadioOption(
                    title: 'Cash on delivery',
                    value: PaymentMethodType.cash,
                    groupValue: checkoutState.paymentMethod,
                    onChanged: (val) =>
                        cubit.doEvents(SelectPaymentMethodEvent(val!)),
                  ),
                  _buildRadioOption(
                    title: 'Credit card',
                    value: PaymentMethodType.card,
                    groupValue: checkoutState.paymentMethod,
                    onChanged: (val) =>
                        cubit.doEvents(SelectPaymentMethodEvent(val!)),
                  ),
                  const Divider(height: 32, thickness: 0.8),

                  // --- 4. GIFT OPTION ---
                  _buildGiftSection(checkoutState, cubit),
                  const Divider(height: 32, thickness: 0.8),

                  // --- 5. PRICE BREAKDOWN ---
                  _buildSummaryRow('Sub Total', '100\$'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Delivery Fee', '50\$'),
                  const Divider(height: 24, thickness: 0.8),
                  _buildSummaryRow('Total', '115\$', isTotal: true),
                  const SizedBox(height: 24),

                  // --- 6. PLACE ORDER BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD81B60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: checkoutState.placeOrderResource.isLoading
                          ? null
                          : () =>
                                cubit.doEvents(PlaceOrderEvent(widget.cartId)),
                      child: checkoutState.placeOrderResource.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Place order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildAddressCard({
    required AddressEntity address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD81B60)
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                activeColor: const Color(0xFFD81B60),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label ?? 'Address',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.addressLine ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required PaymentMethodType value,
    required PaymentMethodType groupValue,
    required ValueChanged<PaymentMethodType?> onChanged,
  }) {
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
              activeColor: const Color(0xFFD81B60),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'It is a gift',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isCash ? Colors.grey.shade400 : Colors.black,
              ),
            ),
            Switch(
              value: !isCash && state.isGift,
              activeColor: const Color(0xFFD81B60),
              onChanged: isCash
                  ? null
                  : (value) => cubit.doEvents(ToggleGiftEvent(value)),
            ),
          ],
        ),
        if (isCash)
          const Text(
            'Gift option is unavailable when paying with Cash on Delivery.',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        if (!isCash && state.isGift) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter recipient name',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (name) =>
                cubit.doEvents(UpdateGiftDetailsEvent(name: name)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter recipient phone number',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (phone) =>
                cubit.doEvents(UpdateGiftDetailsEvent(phone: phone)),
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
