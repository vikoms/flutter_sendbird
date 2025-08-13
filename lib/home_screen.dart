import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_view.dart';
import 'controllers/home_controller.dart';

class HomeScreen extends BaseView<HomeController> {
  HomeScreen({super.key});

  @override
  Widget buildView(BuildContext context, HomeController controller) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sendbird Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller.userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.userNameController,
                decoration: const InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.accessTokenController,
                decoration: const InputDecoration(
                  labelText: 'Access Token',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: controller.login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
