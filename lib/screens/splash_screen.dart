import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/routes/app_routes.dart';
import 'package:ehgezly_app/utils/app_themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    // Start animations
    _controller.forward();
    
    // Check authentication after delay
    Future.delayed(const Duration(seconds: 2), _checkAuth);
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Check if user is already logged in
      final isAuthenticated = await authProvider.checkExistingAuth();
      
      if (mounted) {
        if (isAuthenticated) {
          // User is logged in, navigate based on role
          AppRoutes.navigateByRole(authProvider.user?.primaryRole ?? 'player');
        } else {
          // User not logged in, go to landing
          AppRoutes.navigateTo(AppRoutes.landing, clearStack: true);
        }
      }
    } catch (error) {
      // On error, still go to landing
      if (mounted) {
        AppRoutes.navigateTo(AppRoutes.landing, clearStack: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppThemes.elevatedShadow,
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 60,
                  color: AppThemes.primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'احجزلي',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  letterSpacing: 1.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              const Text(
                'ملاعب. رياضة. متعة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
