import 'package:flutter/material.dart';

import '../widgets/acilis_sahnesi.dart';

/// Oturum yuklenirken gosterilen ekran (AuthWrapper).
///
/// Eskiden baska renkte, baska yerlesimde ve her dilde Turkce
/// "Yazilim ve Robotik Ogren" yazan ikinci bir acilis ekraniydi. Artik
/// ilk acilis sahnesinin SON HALI: kullanici iki ayri ekran gormuyor,
/// yalnizca bloklarin uzerinden gecen bekleme isigini goruyor.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AcilisSahnesi.zemin,
      body: AcilisSahnesi(giris: false),
    );
  }
}
