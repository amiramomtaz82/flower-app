
import 'package:flower_app/features/commerce/presentation/widgets/poduct_grid.dart';

import 'package:flutter/material.dart';

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
          children: [
            Expanded(child: ProductGrid(products: dummyList))
          ],
        )
    );
  }
}