import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ncd_screening_mobile/domain/http_client/ip.dart';
import 'package:ncd_screening_mobile/i18n/i18n.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_size.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';
import 'package:ncd_screening_mobile/shared/styles/p_style.dart';
import 'package:ncd_screening_mobile/shared/components/appbar/appbar_custom.dart';
import 'package:ncd_screening_mobile/shared/components/appbar/bottombar_custom.dart';
import 'package:skeletonizer/skeletonizer.dart';

@RoutePage()
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final ipAddress = useState<String?>(null);
    final currentRouteName = context.routeData.name;
    final msg = AppLocalizations(context).homePage;
    final msgGeneral = AppLocalizations(context).general;

    Future<void> fetchIpAndShowDialog() async {
      if (isLoading.value) return;
      isLoading.value = true;
      ipAddress.value = null;

      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => HookBuilder(
            builder: (context) {
              final isLoadingDialog = useState(true);
              final ip = useState<String?>(null);

              useEffect(() {
                Future.microtask(() async {
                  final result = await locator<IpClient>().getIp();
                  ip.value = result;
                  isLoadingDialog.value = false;
                });
                return null;
              }, []);

              return CupertinoAlertDialog(
                title: const Text('IP'),
                content: Skeletonizer(
                  enabled: isLoadingDialog.value,
                  child: Text(
                    ip.value ?? '255.255.255.255',
                    style: const TextStyle(fontSize: PText.textBase),
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(msgGeneral.close),
                  ),
                ],
              );
            },
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => HookBuilder(
            builder: (context) {
              final isLoadingDialog = useState(true);
              final ip = useState<String?>(null);

              useEffect(() {
                Future.microtask(() async {
                  final result = await locator<IpClient>().getIp();
                  ip.value = result;
                  isLoadingDialog.value = false;
                });
                return null;
              }, []);

              return AlertDialog(
                title: const Text('IP'),
                backgroundColor: Colors.white,
                content: Skeletonizer(
                  enabled: isLoadingDialog.value,
                  child: Text(
                    ip.value ?? '255.255.255.255',
                    style: const TextStyle(fontSize: PText.textBase),
                  ),
                ),
                actions: [
                  TextButton(
                    style: PStyle.btnSecondary,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(msgGeneral.close),
                  ),
                ],
              );
            },
          ),
        );
      }

      final ip = await locator<IpClient>().getIp();
      isLoading.value = false;
      ipAddress.value = ip;
    }

    final bodyContent = Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0F7FA), // Light cyan/blue start
            Colors.white, // White end
          ],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: PSpacing.lg),
          padding: const EdgeInsets.all(PSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white.withAlpha(100)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: PText.textLg,
                  color: Colors.grey,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: PSpacing.xs),
              const Text(
                'Fakduai APP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: PColor.primaryColor,
                  decoration: TextDecoration.none,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: Platform.isIOS
                    ? CupertinoButton(
                        color: PColor.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        pressedOpacity: 0.7,
                        onPressed: fetchIpAndShowDialog,
                        child: isLoading.value
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                msg.btn_check_ip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: fetchIpAndShowDialog,
                        child: isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(msg.btn_check_ip),
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar:
            AppBarCustom(currentRouteName: currentRouteName)
                as ObstructingPreferredSizeWidget,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: bodyContent),
              BottomBarCustom(currentRouteName: currentRouteName),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarCustom(currentRouteName: currentRouteName),
      bottomNavigationBar: BottomBarCustom(currentRouteName: currentRouteName),
      backgroundColor: PColor.backgroundColor,
      body: bodyContent,
    );
  }
}
