// lib/features/checkout/presentation/screens/checkout_screen.dart
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/checkout/presentation/view/widget/checkout_address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


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
  final _giftFormKey = GlobalKey<FormState>();
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
    AppColors colors=LightColors();
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
                // Navigate to success screen
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
          title: Text(
            'Checkout',

            ),

          centerTitle: true,),

        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, checkoutState) {
            final cubit = context.read<CheckoutCubit>();

            return  SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12.0), // No horizontal padding here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. DELIVERY TIME ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivery time', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Container(

                          child: Row(
                            children: [
                              const Icon(Icons.watch_later_outlined),
                              const SizedBox(width: 6),
                              Text("Instant, ", style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                checkoutState.estimateDeliveryResource.data?.estimatedDeliveryAt != null
                                    ? 'Arrive by ${checkoutState.estimateDeliveryResource.data!.estimatedDeliveryAt}'
                                    : 'Arrive by 24 Sep 2024, 11:00 AM',
                                style: const TextStyle(
                                  color: Color(0xFF00897B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Full-width Divider
                  _buildSectionDivider(colors.surface),

                  // --- 2. DELIVERY ADDRESS ---
                  // --- 2. DELIVERY ADDRESS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery address',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<AddressCubit, AddressState>(
                          builder: (context, addressState) {
                            final addresses = addressState.addresses;

                            return Column(
                              children: [
                                // 1. Show empty placeholder or address list
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
                                      'No saved addresses found. Please add a delivery address.',
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

                                // 2. "Add new" button always renders here
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
                                      'Add new',
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
                  // Full-width Divider
                  _buildSectionDivider(colors.surface),

                  // --- 3. PAYMENT METHOD ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment method', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 6),
                        _buildRadioOption(
                          title: 'Cash on delivery',
                          value: PaymentMethodType.cash,
                          groupValue: checkoutState.paymentMethod,
                          onChanged: (val) => cubit.doEvents(SelectPaymentMethodEvent(val!)),
                        ),
                        _buildRadioOption(
                          title: 'Credit card',
                          value: PaymentMethodType.card,
                          groupValue: checkoutState.paymentMethod,
                          onChanged: (val) =>
                              cubit.doEvents(SelectPaymentMethodEvent(val!)),
                        ),
                      ],
                    ),
                  ),

                  // Full-width Divider
                  _buildSectionDivider(colors.surface),

                  // --- 4. GIFT OPTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildGiftSection(checkoutState, cubit),
                  ),

                  // Full-width Divider
                  _buildSectionDivider(colors.surface),

                  // --- 5. PRICE BREAKDOWN & BUTTON ---
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
                              'Sub Total',
                              '${subtotal.toStringAsFixed(2)}\$',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Delivery Fee',
                              '${deliveryFee.toStringAsFixed(2)}\$',
                            ),
                            const Divider(height: 24, thickness: 0.8),
                            _buildSummaryRow(
                              'Total',
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
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
            onPressed: checkoutState.placeOrderResource.isLoading
            ? null
                : () {
            // 1. Check Address Selection
            if (checkoutState.selectedAddressId == null ||
            checkoutState.selectedAddressId!.isEmpty) {
            ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
            SnackBar(
            content: const Text('Please select a delivery address first.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            ),
            );
            return;
            }

            // 2. Check Gift Info (if active)
            if (checkoutState.isGift &&
            checkoutState.paymentMethod != PaymentMethodType.cash) {
            if (!(_giftFormKey.currentState?.validate() ?? false)) {
            return;
            }
            }

            // 3. Dispatch Event
            cubit.doEvents(PlaceOrderEvent(widget.cartId));
            },child: Text("Place order") ,
                    ),
            ),
                  const SizedBox(height: 16),
                ],
            );}
            )
              )]
            )
            );
          },
        ),
      ),
    );
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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
    AppColors colors=LightColors();
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
    AppColors colors = LightColors();
    final isCash = state.paymentMethod == PaymentMethodType.cash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... Toggle Switch ...
        if (!isCash && state.isGift) ...[
          const SizedBox(height: 12),
          Form(
            key: _giftFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter recipient name',
                    labelText: "Name",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter recipient name';
                    }
                    return null;
                  },
                  onChanged: (name) => cubit.doEvents(UpdateGiftDetailsEvent(name: name)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter recipient phone number',
                    labelText: "Phone number",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter recipient phone number';
                    }
                    if (val.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
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
