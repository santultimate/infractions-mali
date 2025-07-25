 import 'package:flutter/material.dart';
 import 'package:google_mobile_ads/google_mobile_ads.dart';
 import 'dart:io';

 class AdBanner extends StatefulWidget {
   const AdBanner({Key? key}) : super(key: key);

   @override
   State<AdBanner> createState() => _AdBannerState();
 }

 class _AdBannerState extends State<AdBanner> {
   BannerAd? _bannerAd;
   bool _isLoaded = false;

   String get _adUnitId => Platform.isIOS
       ? 'ca-app-pub-7487587531173203/7914855242' // iOS
       : 'ca-app-pub-7487587531173203/4925907434'; // Android

   @override
   void initState() {
     super.initState();
     _bannerAd = BannerAd(
       adUnitId: _adUnitId,
       size: AdSize.banner,
       request: AdRequest(),
       listener: BannerAdListener(
         onAdLoaded: (_) => setState(() => _isLoaded = true),
         onAdFailedToLoad: (_, __) => setState(() => _isLoaded = false),
       ),
     )..load();
   }

   @override
   void dispose() {
     _bannerAd?.dispose();
     super.dispose();
   }

   @override
   Widget build(BuildContext context) {
     if (!_isLoaded) return SizedBox.shrink();
     return Container(
       alignment: Alignment.center,
       width: _bannerAd!.size.width.toDouble(),
       height: _bannerAd!.size.height.toDouble(),
       child: AdWidget(ad: _bannerAd!),
     );
   }
 }
