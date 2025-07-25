 import 'package:google_mobile_ads/google_mobile_ads.dart';
 import 'package:flutter/material.dart';
 import 'dart:io';

 class AdInterstitial {
   static String get adUnitId => Platform.isIOS
       ? 'ca-app-pub-7487587531173203/9260738260' // iOS
       : 'ca-app-pub-7487587531173203/8083387965'; // Android

   static InterstitialAd? _interstitialAd;
   static int _numInterstitialLoadAttempts = 0;
   static const int maxFailedLoadAttempts = 3;

   static void loadAndShow({required BuildContext context, VoidCallback? onAdClosed}) {
     InterstitialAd.load(
       adUnitId: adUnitId,
       request: AdRequest(),
       adLoadCallback: InterstitialAdLoadCallback(
         onAdLoaded: (InterstitialAd ad) {
           _numInterstitialLoadAttempts = 0;
           _interstitialAd = ad;
           _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
             onAdDismissedFullScreenContent: (InterstitialAd ad) {
               ad.dispose();
               if (onAdClosed != null) onAdClosed();
             },
             onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
               ad.dispose();
               if (onAdClosed != null) onAdClosed();
             },
           );
           _interstitialAd!.show();
         },
         onAdFailedToLoad: (LoadAdError error) {
           _numInterstitialLoadAttempts += 1;
           _interstitialAd = null;
           if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
             loadAndShow(context: context, onAdClosed: onAdClosed);
           }
         },
       ),
     );
   }
 }
