import '../../domain/oredr_details_entity.dart';
import 'order_item_model.dart';

class OrderDetailsModel {
  final String orderId;
  final String customerName;
  final String addressTitle;
  final String addressDetail;
  final String paymentMethod;
  final String currency;
  final num subTotal;
  final num deliveryFee;
  final num total;
  final List<OrderItemModel> items;

  const OrderDetailsModel({
    required this.orderId,
    required this.customerName,
    required this.addressTitle,
    required this.addressDetail,
    required this.paymentMethod,
    required this.currency,
    required this.subTotal,
    required this.deliveryFee,
    required this.total,
    required this.items,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : (json['order'] is Map<String, dynamic>)
            ? json['order'] as Map<String, dynamic>
            : (json['data'] is Map)
                ? Map<String, dynamic>.from(json['data'] as Map)
                : json;

    final resolvedOrderId = data['orderId']?.toString() ??
        data['_id']?.toString() ??
        data['id']?.toString() ??
        json['orderId']?.toString() ??
        json['_id']?.toString() ??
        json['id']?.toString() ??
        '';

    final recipientMap = data['recipient'] is Map
        ? data['recipient'] as Map
        : (json['recipient'] is Map ? json['recipient'] as Map : null);
    final userMap = data['user'] is Map
        ? data['user'] as Map
        : (json['user'] is Map ? json['user'] as Map : null);
    final resolvedCustomerName = data['customerName']?.toString() ??
        data['recipientName']?.toString() ??
        recipientMap?['name']?.toString() ??
        userMap?['name']?.toString() ??
        data['userName']?.toString() ??
        data['name']?.toString() ??
        json['customerName']?.toString() ??
        '';

    final addressMap = data['userAddress'] is Map
        ? data['userAddress'] as Map
        : (data['address'] is Map ? data['address'] as Map : null);
    final resolvedAddressTitle = data['addressTitle']?.toString() ??
        addressMap?['title']?.toString() ??
        (recipientMap?['area'] != null && recipientMap!['area'].toString().isNotEmpty
            ? recipientMap['area'].toString()
            : null) ??
        'Home';

    String resolvedAddressDetail = data['addressDetail']?.toString() ??
        addressMap?['addressLine']?.toString() ??
        addressMap?['street']?.toString() ??
        addressMap?['detail']?.toString() ??
        '';

    if (resolvedAddressDetail.isEmpty && recipientMap != null) {
      final area = recipientMap['area']?.toString() ?? '';
      final city = recipientMap['city']?.toString() ?? '';
      resolvedAddressDetail = [area, city].where((s) => s.isNotEmpty).join(', ');
    }
    if (resolvedAddressDetail.isEmpty && data['store'] is Map) {
      resolvedAddressDetail = (data['store'] as Map)['address']?.toString() ?? '';
    }

    final paymentMap = data['payment'] is Map ? data['payment'] as Map : null;
    final resolvedPaymentMethod = data['paymentMethod']?.toString() ??
        data['paymentType']?.toString() ??
        paymentMap?['method']?.toString() ??
        paymentMap?['paymentMethod']?.toString() ??
        'Pay with cash';

    final resolvedCurrency = data['currency']?.toString() ??
        json['currency']?.toString() ??
        'EGP';

    final totalNum = (data['total'] as num?) ??
        (data['totalPrice'] as num?) ??
        (data['price'] as num?) ??
        (data['amount'] as num?) ??
        (json['total'] as num?) ??
        0;
    final deliveryFeeNum = (data['deliveryFee'] as num?) ??
        (data['delivery_fee'] as num?) ??
        (data['shippingFee'] as num?) ??
        (data['deliveryCost'] as num?) ??
        0;
    final subTotalNum = (data['subTotal'] as num?) ??
        (data['subtotal'] as num?) ??
        (data['itemsTotal'] as num?) ??
        ((totalNum > deliveryFeeNum) ? (totalNum - deliveryFeeNum) : totalNum);

    final rawItems = (data['items'] is List)
        ? data['items'] as List
        : (data['orderItems'] is List)
            ? data['orderItems'] as List
            : (data['products'] is List)
                ? data['products'] as List
                : (json['items'] is List)
                    ? json['items'] as List
                    : null;

    List<OrderItemModel> resolvedItems = [];
    if (rawItems != null && rawItems.isNotEmpty) {
      resolvedItems = rawItems
          .whereType<Map>()
          .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      final itemCount = (data['itemCount'] as num?)?.toInt() ??
          (json['itemCount'] as num?)?.toInt();
      if (itemCount != null && itemCount > 0) {
        resolvedItems = [
          OrderItemModel(
            id: 'item_summary',
            productName: '$itemCount items',
            description: '',
            price: subTotalNum,
            quantity: itemCount,
          ),
        ];
      }
    }

    return OrderDetailsModel(
      orderId: resolvedOrderId,
      customerName: resolvedCustomerName,
      addressTitle: resolvedAddressTitle,
      addressDetail: resolvedAddressDetail,
      paymentMethod: resolvedPaymentMethod,
      currency: resolvedCurrency,
      subTotal: subTotalNum,
      deliveryFee: deliveryFeeNum,
      total: totalNum,
      items: resolvedItems,
    );
  }
  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'customerName': customerName,
    'addressTitle': addressTitle,
    'addressDetail': addressDetail,
    'paymentMethod': paymentMethod,
    'currency': currency,
    'subTotal': subTotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };

  OrderDetailsEntity toEntity() => OrderDetailsEntity(
    orderId: orderId,
    customerName: customerName,
    addressTitle: addressTitle,
    addressDetail: addressDetail,
    paymentMethod: paymentMethod,
    currency: currency,
    subTotal: subTotal,
    deliveryFee: deliveryFee,
    total: total,
    items: items.map((e) => e.toEntity()).toList(),
  );
}