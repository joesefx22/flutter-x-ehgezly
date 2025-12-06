import 'package:flutter/material.dart';
import 'package:ehgezly_app/screens/auth/login_screen.dart';
import 'package:ehgezly_app/screens/auth/signup_screen.dart';
import 'package:ehgezly_app/screens/landing_screen.dart';
import 'package:ehgezly_app/screens/splash_screen.dart';
import 'package:ehgezly_app/screens/stadiums/stadiums_list_screen.dart';
import 'package:ehgezly_app/screens/stadiums/stadium_detail_screen.dart';
import 'package:ehgezly_app/screens/player/dashboard_screen.dart';
import 'package:ehgezly_app/screens/player/bookings_screen.dart';
import 'package:ehgezly_app/screens/player/notifications_screen.dart';
import 'package:ehgezly_app/screens/player/create_request_screen.dart';
import 'package:ehgezly_app/screens/staff/dashboard_screen.dart';
import 'package:ehgezly_app/screens/staff/bookings_screen.dart';
import 'package:ehgezly_app/screens/owner/dashboard_screen.dart';
import 'package:ehgezly_app/screens/admin/dashboard_screen.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String landing = '/landing';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String stadiums = '/stadiums';
  static const String stadiumDetail = '/stadiums/:id';
  static const String playerDashboard = '/player/dashboard';
  static const String playerBookings = '/player/bookings';
  static const String playerNotifications = '/player/notifications';
  static const String createPlayRequest = '/player/play-request/create';
  static const String staffDashboard = '/staff/dashboard';
  static const String staffBookings = '/staff/bookings';
  static const String ownerDashboard = '/owner/dashboard';
  static const String adminDashboard = '/admin/dashboard';

  // Navigation Key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      case stadiums:
        return MaterialPageRoute(
          builder: (_) => StadiumsListScreen(
            stadiumType: args is String ? args : null,
          ),
        );
      
      case stadiumDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => StadiumDetailScreen(stadiumId: args),
          );
        }
        return _errorRoute();
      
      case playerDashboard:
        return MaterialPageRoute(builder: (_) => const PlayerDashboardScreen());
      
      case playerBookings:
        return MaterialPageRoute(builder: (_) => const PlayerBookingsScreen());
      
      case playerNotifications:
        return MaterialPageRoute(builder: (_) => const PlayerNotificationsScreen());
      
      case createPlayRequest:
        return MaterialPageRoute(builder: (_) => const CreatePlayRequestScreen());
      
      case staffDashboard:
        return MaterialPageRoute(builder: (_) => const StaffDashboardScreen());
      
      case staffBookings:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => StaffBookingsScreen(stadiumId: args),
          );
        }
        return _errorRoute();
      
      case ownerDashboard:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
      
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      default:
        return _errorRoute();
    }
  }

  // Error Route
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(
          child: Text('الصفحة غير موجودة'),
        ),
      ),
    );
  }

  // Navigation Methods
  static Future<dynamic> navigateTo(
    String routeName, {
    dynamic arguments,
    bool replace = false,
    bool clearStack = false,
  }) {
    if (clearStack) {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName,
        (_) => false,
        arguments: arguments,
      );
    } else if (replace) {
      return navigatorKey.currentState!.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } else {
      return navigatorKey.currentState!.pushNamed(
        routeName,
        arguments: arguments,
      );
    }
  }

  static void goBack([dynamic result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  // Role-based Navigation
  static void navigateByRole(String primaryRole) {
    switch (primaryRole) {
      case 'player':
        navigateTo(playerDashboard, clearStack: true);
        break;
      case 'staff':
        navigateTo(staffDashboard, clearStack: true);
        break;
      case 'owner':
        navigateTo(ownerDashboard, clearStack: true);
        break;
      case 'admin':
        navigateTo(adminDashboard, clearStack: true);
        break;
      default:
        navigateTo(landing, clearStack: true);
    }
  }

  // Check if user can access route
  static bool canAccessRoute(String routeName, List<String> userRoles) {
    const Map<String, List<String>> routePermissions = {
      playerDashboard: ['player', 'staff', 'owner', 'admin'],
      playerBookings: ['player', 'staff', 'owner', 'admin'],
      staffDashboard: ['staff', 'owner', 'admin'],
      staffBookings: ['staff', 'owner', 'admin'],
      ownerDashboard: ['owner', 'admin'],
      adminDashboard: ['admin'],
    };

    final allowedRoles = routePermissions[routeName];
    if (allowedRoles == null) return true; // Public route

    return userRoles.any((role) => allowedRoles.contains(role));
  }
}
