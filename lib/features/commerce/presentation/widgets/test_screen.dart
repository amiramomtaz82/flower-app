
import 'package:flower_app/features/commerce/presentation/widgets/poduct_grid.dart';

import 'package:flutter/material.dart';

import '../../../../config/di/di.dart';
import '../../../../core/guest_browsing/guest_browsing_provider.dart';
import '../../api/data_source_impl/local/dummy_data.dart';

class TestView extends StatelessWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Test',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [ElevatedButton(
            onPressed: () async { print('🔴 BUTTON PRESSED');
              await getIt<GuestBrowsingProvider>().requireAuth(
                action: () async {
                  print('🟢 PENDING ACTION EXECUTED');
                  debugPrint('✅ Pending action executed after login!');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pending action executed!'),
                      ),
                    );
                  }
                },
              );
            },
            child: const Text('Test Guest Auth'),
          ),
            Expanded(child: ProductGrid(products: dummyList)),


          ],
        )
    );
  }
}