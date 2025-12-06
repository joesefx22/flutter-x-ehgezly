import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/routes/app_routes.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Container(
                height: size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'احجزلي',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'احجز ملاعب الرياضة بسهولة',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Main Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Stadium Type Cards
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.stadiums,
                              arguments: {'type': 'football'},
                            ),
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.sports_soccer,
                                    size: 50,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ملاعب كورة',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'احجز ملاعب كرة القدم',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.stadiums,
                              arguments: {'type': 'paddle'},
                            ),
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.sports_tennis,
                                    size: 50,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ملاعب بادل',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'احجز ملاعب التنس والبـادل',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    if (authProvider.isAuthenticated) ...[
                      AppButton(
                        text: 'لوحة التحكم',
                        type: ButtonType.primary,
                        onPressed: () {
                          AppRoutes.navigateByRole(context, authProvider.user!);
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'تسجيل الخروج',
                        type: ButtonType.outline,
                        onPressed: () {
                          authProvider.logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.landing,
                            (route) => false,
                          );
                        },
                      ),
                    ] else ...[
                      AppButton(
                        text: 'تسجيل الدخول',
                        type: ButtonType.primary,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'إنشاء حساب جديد',
                        type: ButtonType.outline,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Add Stadium Button
                    AppButton(
                      text: 'أضف ملعب',
                      type: ButtonType.secondary,
                      icon: Icons.add,
                      onPressed: () {
                        Helpers.launchURL(AppConstants.addStadiumFormUrl);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Features Section
                    Text(
                      'مميزات التطبيق',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._buildFeatures(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatures(ThemeData theme) {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'حجز سهل',
        'description': 'احجز في خطوات بسيطة وسريعة',
      },
      {
        'icon': Icons.payment,
        'title': 'دفع آمن',
        'description': 'دفع إلكتروني آمن ومتعدد الخيارات',
      },
      {
        'icon': Icons.group,
        'title': 'لاعبوني معاكم',
        'description': 'ابحث عن لاعبين وانضم للفرق',
      },
      {
        'icon': Icons.notifications,
        'title': 'تحديثات فورية',
        'description': 'إشعارات لحظية بتأكيد الحجز',
      },
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature['title'] as String,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    feature['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
