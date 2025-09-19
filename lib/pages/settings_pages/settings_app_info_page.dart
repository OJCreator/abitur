import 'package:abitur/in_app_purchases/purchase_service.dart';
import 'package:abitur/pages/settings_pages/settings_app_info_unlock_review_mode_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsAppInfoPage extends StatefulWidget {
  const SettingsAppInfoPage({super.key});

  @override
  State<SettingsAppInfoPage> createState() => _SettingsAppInfoPageState();
}

class _SettingsAppInfoPageState extends State<SettingsAppInfoPage> {

  String _appName = "";
  String _packageName = "";
  String _version = "";
  String _buildNumber = "";

  int _buildNumberTapCounter = 0;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _packageName = info.packageName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> onTapBuildNumber() async {
    _buildNumberTapCounter++;
    if (_buildNumberTapCounter >= 10) {
      _reviewModeToggled();
      _buildNumberTapCounter = 0;
    }
  }

  void _reviewModeToggled() {
    if (PurchaseService.reviewMode) {
      PurchaseService.deactivateReviewMode();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return SettingsAppInfoUnlockReviewModePage();
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("App-Info")),
      body: ListView(
        children: [
          ListTile(title: Text("App-Name"), subtitle: Text(_appName)),
          ListTile(title: Text("Package-Name"), subtitle: Text(_packageName)),
          ListTile(title: Text("Version"), subtitle: Text(_version)),
          ListTile(
            splashColor: Colors.transparent,
            enableFeedback: false,
            title: Text("Build number"),
            subtitle: Text(_buildNumber),
            onTap: onTapBuildNumber,
          ),
        ],
      ),
    );
  }
}
