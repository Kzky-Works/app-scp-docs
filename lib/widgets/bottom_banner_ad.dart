import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 画面最下部にアンカーバナー枠のみ（Google 提供のテストユニット ID）。
class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({super.key});

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  static bool get _supported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get _unitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  void initState() {
    super.initState();
    if (!_supported) return;
    _ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _unitId,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported || _ad == null) {
      return const SizedBox.shrink();
    }
    final h = _loaded ? _ad!.size.height.toDouble() : AdSize.banner.height.toDouble();
    return SizedBox(
      height: h,
      width: double.infinity,
      child: _loaded ? AdWidget(ad: _ad!) : const SizedBox.shrink(),
    );
  }
}
