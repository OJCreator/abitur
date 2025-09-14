import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class SettingAppInfoUnlockReviewModePage extends StatefulWidget {
  const SettingAppInfoUnlockReviewModePage({super.key});

  @override
  State<SettingAppInfoUnlockReviewModePage> createState() =>
      _SettingAppInfoUnlockReviewModePageState();
}

class _SettingAppInfoUnlockReviewModePageState
    extends State<SettingAppInfoUnlockReviewModePage> {

  final TextEditingController _controller = TextEditingController();
  final String passwordHash = "50273c4a89c709e1a9d35fcbf36d8da777593a2fee56f4c43e159a7c085113b7";

  void _onOkPressed() {
    final token = _controller.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte einen Token eingeben")),
      );
      return;
    }
    String inputHash = computeSha256Hex(token);
    if (passwordHash != inputHash) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falscher Token")),
      );
      return;
    }
    // TODO: Hier Review-Mode freischalten
    debugPrint("Entwicklermodus freischalten");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Mode freischalten")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Token eingeben",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onOkPressed,
                child: const Text("OK"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hash Validation
  String computeSha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}