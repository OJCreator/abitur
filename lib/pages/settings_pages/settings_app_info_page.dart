import 'package:abitur/pages/settings_pages/settings_app_info_unlock_review_mode_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsAppInfoPage extends StatefulWidget {
  const SettingsAppInfoPage({super.key});

  @override
  State<SettingsAppInfoPage> createState() => _SettingsAppInfoPageState();
}

class _SettingsAppInfoPageState extends State<SettingsAppInfoPage> {

  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  int buildNumberTapCounter = 0;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      packageName = info.packageName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  Future<void> onTapBuildNumber() async {
    buildNumberTapCounter++;
    if (buildNumberTapCounter >= 10) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return SettingsAppInfoUnlockReviewModePage();
        }),
      );
      buildNumberTapCounter = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("App-Info")),
      body: ListView(
        children: [
          ListTile(title: Text("App-Name"), subtitle: Text(appName)),
          ListTile(title: Text("Package-Name"), subtitle: Text(packageName)),
          ListTile(title: Text("Version"), subtitle: Text(version)),
          ListTile(
            splashColor: Colors.transparent,
            enableFeedback: false,
            title: Text("Build number"),
            subtitle: Text(buildNumber),
            onTap: onTapBuildNumber,
          ),
        ],
      ),
    );
  }
}
