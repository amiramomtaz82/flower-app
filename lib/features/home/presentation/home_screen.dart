import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/validation/validation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController();

  int currentIndex = 0;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test".tr()),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                validator: Validation.validateEmail,
                decoration: InputDecoration(
                  labelText: "email".tr(),
                  hintText: "enter your email".tr(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("success".tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text("submit".tr()),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  context.setLocale(const Locale('en'));
                },
                child: Text("english".tr()),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  context.setLocale(const Locale('ar'));
                },
                child: Text("arabic".tr()),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: "home".tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: "search".tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: "profile".tr(),
          ),
        ],
      ),
    );
  }
}

