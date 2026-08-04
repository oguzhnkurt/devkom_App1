import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';

/// Anketler Ekranı
class SurveysScreen extends StatelessWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.surveys),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.poll,
              size: 100,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              loc.surveys,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              loc.surveysInfo,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
