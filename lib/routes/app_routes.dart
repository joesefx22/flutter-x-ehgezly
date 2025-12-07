import 'package:flutter/material.dart';
import 'package:ehgezly_app/screens/splash_screen.dart';
import 'package:ehgezly_app/screens/landing_screen.dart';
import 'package:ehgezly_app/screens/auth/login_screen.dart';
import 'package:ehgezly_app/screens/auth/signup_screen.dart';

// Stadiums
import 'package:ehgezly_app/screens/stadiums/stadiums_list_screen.dart';
import 'package:ehgezly_app/screens/stadiums/stadium_detail_screen.dart';

// Player
import 'package:ehgezly_app/screens/player/dashboard_screen.dart';
import 'package:ehgezly_app/screens/player/bookings_screen.dart';
import 'package:ehgezly_app/screens/player/notifications_screen.dart';
import 'package:ehgezly_app/screens/player/profile_screen.dart';
import 'package:ehgezly_app/screens/player/create_request_screen.dart';
import 'package:ehgezly_app/screens/player/play_detail_screen.dart';
import 'package:ehgezly_app/screens/player/play_search_screen.dart';

// Staff
import 'package:ehgezly_app/screens/staff/dashboard_screen.dart';
import 'package:ehgezly_app/screens/staff/stadium_dashboard_screen.dart';
import 'package:ehgezly_app/screens/staff/bookings_screen.dart';
import 'package:ehgezly_app/screens/staff/players_requests_screen.dart';

// Owner
import 'package:ehgezly_app/screens/owner/dashboard_screen.dart';
import 'package:ehgezly_app/screens/owner/stadium_management_screen.dart';
import 'package:ehgezly_app/screens/owner/stadium_dashboard_screen.dart';

// Admin
import 'package:ehgezly_app/screens/admin/dashboard_screen.dart';
import 'package:ehgezly_app/screens/admin/users_management_screen.dart';
import 'package:ehgezly_app/screens/admin/reports_screen.dart';
import 'package:ehgezly_app/screens/admin/codes_screen.dart';

// Payment
import 'package:ehgezly_app/screens/payment/payment_screen.dart';
import 'package:ehgezly_app/widgets/payment/payment_success.dart';
import 'package:ehgezly_app/widgets/payment/payment_failed.dart';

// Maps
import 'package:ehgezly_app/screens/maps/stadium_map_screen.dart';

// Settings & Help
import 'package:ehgezly_app/screens/settings/app_settings_screen.dart';
import 'package:ehgezly_app/screens/help/support_screen.dart';
import 'package:ehgezly_app/screens/terms/terms_screen.dart';

class AppRoutes {
  // Navigation Key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Route Names
  // Public Routes
  static const String splash = '/';
  static const String landing = '/landing';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  
  // Stadiums
  static const String stadiums = '/stadiums';
  static const String stadiumDetail = '/stadiums/:id';
  static const String stadiumMap = '/maps/stadium';
  
  // Payment
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';
  static const String paymentFailed = '/payment/failed';
  
  // Player Routes
  static const String playerDashboard = '/player/dashboard';
  static const String playerBookings = '/player/bookings';
  static const String playerNotifications = '/player/notifications';
  static const String playerProfile = '/player/profile';
  static const String createPlayRequest = '/player/play-request/create';
  static const String playDetail = '/player/play-detail';
  static const String playSearch = '/play-search';
  
  // Staff Routes
  static const String staffDashboard = '/staff/dashboard';
  static const String staffStadiumDashboard = '/staff/stadiums/:id/dashboard';
  static const String staffBookings = '/staff/stadiums/:id/bookings';
  static const String staffPlayersRequests = '/staff/stadiums/:id/players-requests';
  
  // Owner Routes
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerStadiumDashboard = '/owner/stadiums/:id/dashboard';
  static const String ownerStadiumManagement = '/owner/stadiums/:id/manage';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
  static const String adminCodes = '/admin/codes';
  
  // Settings & Help
  static const String settings = '/settings';
  static const String support = '/help/support';
  static const String terms = '/terms';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Public Routes
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      // Stadiums
      case stadiums:
        return MaterialPageRoute(
          builder: (_) => StadiumsListScreen(
            stadiumType: args is String ? args : null,
          ),
        );
      
      case stadiumDetail:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StadiumDetailScreen(
              stadiumId: args['stadiumId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      case stadiumMap:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StadiumMapScreen(
              latitude: args['latitude'] as double,
              longitude: args['longitude'] as double,
              stadiumName: args['stadiumName'] as String,
              stadiumAddress: args['stadiumAddress'] as String?,
            ),
          );
        }
        return _errorRoute();
      
      // Payment
      case payment:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PaymentScreen(
              bookingId: args['bookingId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      case paymentSuccess:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              bookingId: args['bookingId'] as String,
              transactionId: args['transactionId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      case paymentFailed:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PaymentFailedScreen(
              bookingId: args['bookingId'] as String,
              error: args['error'] as String,
            ),
          );
        }
        return _errorRoute();
      
      // Player Routes
      case playerDashboard:
        return MaterialPageRoute(builder: (_) => const PlayerDashboardScreen());
      
      case playerBookings:
        return MaterialPageRoute(builder: (_) => const PlayerBookingsScreen());
      
      case playerNotifications:
        return MaterialPageRoute(builder: (_) => const PlayerNotificationsScreen());
      
      case playerProfile:
        return MaterialPageRoute(builder: (_) => const PlayerProfileScreen());
      
      case createPlayRequest:
        return MaterialPageRoute(builder: (_) => const CreatePlayRequestScreen());
      
      case playDetail:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PlayDetailScreen(
              playRequestId: args['playRequestId'] as String?,
            ),
          );
        }
        return _errorRoute();
      
      case playSearch:
        return MaterialPageRoute(builder: (_) => const PlaySearchScreen());
      
      // Staff Routes
      case staffDashboard:
        return MaterialPageRoute(builder: (_) => const StaffDashboardScreen());
      
      case staffStadiumDashboard:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StaffStadiumDashboardScreen(
              stadiumId: args['stadiumId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      case staffBookings:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StaffBookingsScreen(
              stadiumId: args['stadiumId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      case staffPlayersRequests:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StaffPlayersRequestsScreen(
              stadiumId: args['stadiumId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      // Owner Routes
      case ownerDashboard:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
      
      case ownerStadiumDashboard:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => OwnerStadiumDashboardScreen(
              stadiumId: args['stadiumId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      case ownerStadiumManagement:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => OwnerStadiumManagementScreen(
              stadiumId: args['stadiumId'] as String,
            ),
          );
        }
        return _errorRoute();
      
      // Admin Routes
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersManagementScreen());
      
      case adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      
      case adminCodes:
        return MaterialPageRoute(builder: (_) => const AdminCodesScreen());
      
      // Settings & Help
      case settings:
        return MaterialPageRoute(builder: (_) => const AppSettingsScreen());
      
      case support:
        return MaterialPageRoute(builder: (_) => const SupportScreen());
      
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());
      
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
      // Public routes - accessible to all
      landing: ['player', 'staff', 'owner', 'admin'],
      stadiums: ['player', 'staff', 'owner', 'admin'],
      stadiumDetail: ['player', 'staff', 'owner', 'admin'],
      stadiumMap: ['player', 'staff', 'owner', 'admin'],
      payment: ['player', 'staff', 'owner', 'admin'],
      paymentSuccess: ['player', 'staff', 'owner', 'admin'],
      paymentFailed: ['player', 'staff', 'owner', 'admin'],
      
      // Player routes
      playerDashboard: ['player', 'staff', 'owner', 'admin'],
      playerBookings: ['player', 'staff', 'owner', 'admin'],
      playerNotifications: ['player', 'staff', 'owner', 'admin'],
      playerProfile: ['player', 'staff', 'owner', 'admin'],
      createPlayRequest: ['player', 'staff', 'owner', 'admin'],
      playDetail: ['player', 'staff', 'owner', 'admin'],
      playSearch: ['player', 'staff', 'owner', 'admin'],
      
      // Staff routes
      staffDashboard: ['staff', 'owner', 'admin'],
      staffStadiumDashboard: ['staff', 'owner', 'admin'],
      staffBookings: ['staff', 'owner', 'admin'],
      staffPlayersRequests: ['staff', 'owner', 'admin'],
      
      // Owner routes
      ownerDashboard: ['owner', 'admin'],
      ownerStadiumDashboard: ['owner', 'admin'],
      ownerStadiumManagement: ['owner', 'admin'],
      
      // Admin routes
      adminDashboard: ['admin'],
      adminUsers: ['admin'],
      adminReports: ['admin'],
      adminCodes: ['admin'],
      
      // Settings routes
      settings: ['player', 'staff', 'owner', 'admin'],
      support: ['player', 'staff', 'owner', 'admin'],
      terms: ['player', 'staff', 'owner', 'admin'],
    };

    final allowedRoles = routePermissions[routeName];
    if (allowedRoles == null) return true; // Public route (like splash, login, signup)

    return userRoles.any((role) => allowedRoles.contains(role));
  }

  // Helper method to extract route name from full path
  static String getRouteName(String fullPath) {
    // Remove query parameters
    final path = fullPath.split('?').first;
    
    // Map of path patterns to route names
    final patterns = {
      RegExp(r'^/stadiums/[^/]+$'): stadiumDetail,
      RegExp(r'^/staff/stadiums/[^/]+/dashboard$'): staffStadiumDashboard,
      RegExp(r'^/staff/stadiums/[^/]+/bookings$'): staffBookings,
      RegExp(r'^/staff/stadiums/[^/]+/players-requests$'): staffPlayersRequests,
      RegExp(r'^/owner/stadiums/[^/]+/dashboard$'): ownerStadiumDashboard,
      RegExp(r'^/owner/stadiums/[^/]+/manage$'): ownerStadiumManagement,
    };
    
    // Check against patterns
    for (final pattern in patterns.entries) {
      if (pattern.key.hasMatch(path)) {
        return pattern.value;
      }
    }
    
    // If no pattern matches, return the path itself
    return path;
  }
}
