import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/theme_provider.dart';
import 'package:ehgezly_app/providers/language_provider.dart';
import 'package:ehgezly_app/routes/app_routes.dart';
import 'package:ehgezly_app/utils/app_themes.dart';
import 'package:ehgezly_app/utils/app_localizations.dart';
import 'package:ehgezly_app/utils/app_constants.dart';
import 'package:ehgezly_app/widgets/common/connectivity_wrapper.dart';

class EhgezlyApp extends StatelessWidget {
  const EhgezlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'احجزلي',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // Localization
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('ar', 'SA'), // العربية
            Locale('en', 'US'), // الإنجليزية
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            // Return the first supported locale as default
            return supportedLocales.first;
          },
          
          // Routes
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          navigatorKey: AppRoutes.navigatorKey,
          navigatorObservers: [routeObserver],
          
          // Performance
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: AppConstants.isTablet(context) ? 1.1 : 1.0,
              ),
              child: ConnectivityWrapper(
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}

// Route observer for analytics
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
