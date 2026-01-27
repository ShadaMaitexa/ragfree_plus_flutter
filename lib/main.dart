import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/app_theme.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/approval_pending_screen.dart';
import 'dart:async';
import 'screens/student/home_page.dart';
import 'screens/student/complaints_page.dart';
import 'screens/student/chat_page.dart';
import 'screens/student/awareness_page.dart';
import 'screens/student/profile_page.dart';
import 'screens/parent/home_page.dart' as parent;
import 'screens/parent/child_complaints_page.dart' as parent;
import 'screens/parent/chat_page.dart' as parent;
import 'screens/parent/feedback_page.dart' as parent;
import 'screens/parent/awareness_page.dart' as parent;
import 'screens/parent/profile_page.dart' as parent;
import 'screens/warden/dashboard_page.dart' as warden_pages;
import 'screens/warden/view_complaints_page.dart' as warden_pages;
import 'screens/warden/forward_complaints_page.dart' as warden_pages;
import 'screens/warden/students_page.dart' as warden_pages;
import 'screens/warden/awareness_page.dart' as warden_pages;
import 'screens/warden/feedback_page.dart' as warden_pages;
import 'screens/warden/profile_page.dart' as warden_pages;
import 'screens/counsellor/dashboard_page.dart' as counsellor_pages;
import 'screens/counsellor/assigned_complaints_page.dart' as counsellor_pages;
import 'screens/counsellor/schedule_session_page.dart' as counsellor_pages;
import 'screens/counsellor/chat_page.dart' as counsellor_pages;
import 'screens/counsellor/awareness_page.dart' as counsellor_pages;
import 'screens/counsellor/profile_page.dart' as counsellor_pages;
import 'screens/police/dashboard_page.dart' as police_pages;
import 'screens/police/complaints_page.dart' as police_pages;
import 'screens/police/verify_page.dart' as police_pages;
import 'screens/police/generate_report_page.dart' as police_pages;
import 'screens/police/send_notification_page.dart' as police_pages;
import 'screens/police/profile_page.dart' as police_pages;
import 'screens/teacher/dashboard_page.dart' as teacher_pages;
import 'screens/teacher/complaints_page.dart' as teacher_pages;
import 'screens/teacher/chat_page.dart' as teacher_pages;
import 'screens/teacher/awareness_page.dart' as teacher_pages;
import 'screens/teacher/profile_page.dart' as teacher_pages;
import 'screens/admin/dashboard_page.dart' as admin_pages;
import 'screens/admin/manage_users_page.dart' as admin_pages;
import 'screens/admin/complaints_page.dart' as admin_pages;
import 'screens/admin/departments_page.dart' as admin_pages;
import 'screens/admin/awareness_page.dart' as admin_pages;
import 'screens/admin/notifications_page.dart' as admin_pages;
import 'screens/admin/reports_page.dart' as admin_pages;
import 'screens/admin/analytics_page.dart' as admin_pages;
import 'screens/admin/profile_page.dart' as admin_pages;
import 'services/emailjs_service.dart';
import 'services/cloudinary_service.dart';
import 'widgets/responsive_scaffold.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  CloudinaryService().init();

  try {
    final emailJSService = EmailJSService();
    await emailJSService.initialize();
  } catch (e) {
    // EmailJS initialization failed
    debugPrint('EmailJS initialization failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const RagFreePlusApp(),
    ),
  );
}

class RagFreePlusApp extends StatelessWidget {
  const RagFreePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RagFree+',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      initialRoute: Routes.splash,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case Routes.splash:
            page = const SplashScreen();
            break;
          case Routes.login:
            page = const LoginScreen();
            break;
          case Routes.register:
            page = const RegistrationScreen();
            break;
          case Routes.approvalPending:
            page = const ApprovalPendingScreen();
            break;
          case Routes.student:
            page = const StudentDashboard();
            break;
          case Routes.parent:
            page = const ParentDashboard();
            break;
          case Routes.admin:
            page = const AdminDashboard();
            break;
          case Routes.counsellor:
            page = const CounsellorDashboard();
            break;
          case Routes.warden:
            page = const WardenDashboard();
            break;
          case Routes.police:
            page = const PoliceDashboard();
            break;
          case Routes.teacher:
            page = const TeacherDashboard();
            break;
          default:
            page = const SplashScreen();
        }
        return _buildFadeRoute(page, settings);
      },
    );
  }
}

class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String approvalPending = '/approval-pending';
  static const String student = '/student';
  static const String parent = '/parent';
  static const String admin = '/admin';
  static const String counsellor = '/counsellor';
  static const String warden = '/warden';
  static const String police = '/police';
  static const String teacher = '/teacher';
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Reduced delay for better UX
    if (!mounted) return;

    final authService = AuthService();

    // 1. Try to get user from local session (SharedPreferences)
    final sessionUser = await authService.getUserFromSession();

    if (sessionUser != null) {
      _navigateBasedOnUser(sessionUser);
      return;
    }

    // 2. Fallback to Firebase Auth persistence
    final user = await authService.authStateChanges.first;

    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      if (userData != null) {
        // Update session for next time
        await authService.saveUserSession(userData);
        if (!mounted) return;
        _navigateBasedOnUser(userData);
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  void _navigateBasedOnUser(UserModel userData) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setUser(userData);

    if ((userData.role == 'police' ||
            userData.role == 'counsellor' ||
            userData.role == 'warden' ||
            userData.role == 'teacher') &&
        !userData.isApproved) {
      Navigator.of(context).pushReplacementNamed(Routes.approvalPending);
      return;
    }

    switch (userData.role) {
      case 'student':
        Navigator.of(context).pushReplacementNamed(Routes.student);
        break;
      case 'parent':
        Navigator.of(context).pushReplacementNamed(Routes.parent);
        break;
      case 'admin':
        Navigator.of(context).pushReplacementNamed(Routes.admin);
        break;
      case 'counsellor':
        Navigator.of(context).pushReplacementNamed(Routes.counsellor);
        break;
      case 'warden':
        Navigator.of(context).pushReplacementNamed(Routes.warden);
        break;
      case 'police':
        Navigator.of(context).pushReplacementNamed(Routes.police);
        break;
      case 'teacher':
        Navigator.of(context).pushReplacementNamed(Routes.teacher);
        break;
      default:
        Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)]
                : [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Icon(Icons.shield_moon, size: 88, color: color),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          'RagFree+',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Safe Campus Initiative',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PageRoute _buildFadeRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.05);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var slideTween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      var scaleTween = Tween<double>(
        begin: 0.98,
        end: 1.0,
      ).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: curve));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: ScaleTransition(
          scale: animation.drive(scaleTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.home, label: 'Home'),
      NavigationDestinationData(icon: Icons.assignment, label: 'Complaints'),
      NavigationDestinationData(icon: Icons.chat_bubble, label: 'Chat'),
      NavigationDestinationData(icon: Icons.school, label: 'Awareness'),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
    ];

    final pages = <Widget>[
      const StudentHomePage(),
      const StudentComplaintsPage(),
      const StudentChatPage(),
      const StudentAwarenessPage(),
      const StudentProfilePage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
      ),
    );
  }
}

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.home, label: 'Home'),
      NavigationDestinationData(
        icon: Icons.assignment,
        label: 'Child Complaints',
      ),
      NavigationDestinationData(icon: Icons.chat_bubble, label: 'Chat'),
      NavigationDestinationData(icon: Icons.school, label: 'Awareness'),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
      NavigationDestinationData(icon: Icons.feedback, label: 'Feedback'),
    ];

    final pages = <Widget>[
      const parent.ParentHomePage(),
      const parent.ParentChildComplaintsPage(),
      const parent.ParentChatPage(),
      const parent.ParentAwarenessPage(),
      const parent.ParentProfilePage(),
      const parent.ParentFeedbackPage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
        showBottomNavigation: false,
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.dashboard, label: 'Dashboard'),
      NavigationDestinationData(icon: Icons.group, label: 'Users'),
      NavigationDestinationData(icon: Icons.assignment, label: 'Complaints'),
      NavigationDestinationData(icon: Icons.apartment, label: 'Depts'),
      NavigationDestinationData(icon: Icons.school, label: 'Awareness'),
      NavigationDestinationData(
        icon: Icons.notifications,
        label: 'Notifications',
      ),
      NavigationDestinationData(icon: Icons.receipt_long, label: 'Reports'),
      NavigationDestinationData(icon: Icons.analytics, label: 'Analytics'),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
    ];

    final pages = const <Widget>[
      _AdminPages.dashboard,
      _AdminPages.manageUsers,
      _AdminPages.complaints,
      _AdminPages.departments,
      _AdminPages.awareness,
      _AdminPages.notifications,
      _AdminPages.reports,
      _AdminPages.analytics,
      _AdminPages.profile,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
        showBottomNavigation: false,
      ),
    );
  }
}

class _AdminPages {
  static const Widget dashboard = _AdminLazy(page: _AdminPage.dashboard);
  static const Widget manageUsers = _AdminLazy(page: _AdminPage.manageUsers);
  static const Widget complaints = _AdminLazy(page: _AdminPage.complaints);
  static const Widget departments = _AdminLazy(page: _AdminPage.departments);
  static const Widget awareness = _AdminLazy(page: _AdminPage.awareness);
  static const Widget notifications = _AdminLazy(
    page: _AdminPage.notifications,
  );
  static const Widget reports = _AdminLazy(page: _AdminPage.reports);
  static const Widget analytics = _AdminLazy(page: _AdminPage.analytics);
  static const Widget profile = _AdminLazy(page: _AdminPage.profile);
}

enum _AdminPage {
  dashboard,
  manageUsers,
  complaints,
  departments,
  awareness,
  notifications,
  reports,
  analytics,
  profile,
}

class _AdminLazy extends StatelessWidget {
  final _AdminPage page;
  const _AdminLazy({required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case _AdminPage.dashboard:
        return const _AdminDashboardProxy();
      case _AdminPage.manageUsers:
        return const _AdminManageUsersProxy();
      case _AdminPage.complaints:
        return const _AdminComplaintsProxy();
      case _AdminPage.departments:
        return const _AdminDepartmentsProxy();
      case _AdminPage.awareness:
        return const _AdminAwarenessProxy();
      case _AdminPage.notifications:
        return const _AdminNotificationsProxy();
      case _AdminPage.reports:
        return const _AdminReportsProxy();
      case _AdminPage.analytics:
        return const _AdminAnalyticsProxy();
      case _AdminPage.profile:
        return const _AdminProfileProxy();
    }
  }
}

class _AdminDashboardProxy extends StatelessWidget {
  const _AdminDashboardProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminDashboardPage();
}

class _AdminManageUsersProxy extends StatelessWidget {
  const _AdminManageUsersProxy();
  @override
  Widget build(BuildContext context) =>
      const admin_pages.AdminManageUsersPage();
}

class _AdminComplaintsProxy extends StatelessWidget {
  const _AdminComplaintsProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminComplaintsPage();
}

class _AdminDepartmentsProxy extends StatelessWidget {
  const _AdminDepartmentsProxy();
  @override
  Widget build(BuildContext context) =>
      const admin_pages.AdminDepartmentsPage();
}

class _AdminAwarenessProxy extends StatelessWidget {
  const _AdminAwarenessProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminAwarenessPage();
}

class _AdminNotificationsProxy extends StatelessWidget {
  const _AdminNotificationsProxy();
  @override
  Widget build(BuildContext context) =>
      const admin_pages.AdminNotificationsPage();
}

class _AdminReportsProxy extends StatelessWidget {
  const _AdminReportsProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminReportsPage();
}

class _AdminAnalyticsProxy extends StatelessWidget {
  const _AdminAnalyticsProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminAnalyticsPage();
}

class _AdminProfileProxy extends StatelessWidget {
  const _AdminProfileProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminProfilePage();
}

class CounsellorDashboard extends StatelessWidget {
  const CounsellorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.dashboard, label: 'Dashboard'),
      NavigationDestinationData(icon: Icons.assignment, label: 'Assigned'),
      NavigationDestinationData(icon: Icons.schedule, label: 'Schedule'),
      NavigationDestinationData(icon: Icons.chat_bubble, label: 'Chat'),
      NavigationDestinationData(icon: Icons.school, label: 'Awareness'),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
    ];

    final pages = [
      _CounsellorPages.dashboard,
      _CounsellorPages.assigned,
      _CounsellorPages.schedule,
      _CounsellorPages.chat,
      _CounsellorPages.awareness,
      _CounsellorPages.profile,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
      ),
    );
  }
}

class _CounsellorPages {
  static const Widget dashboard = _CounsellorLazy(
    page: _CounsellorPage.dashboard,
  );
  static const Widget assigned = _CounsellorLazy(
    page: _CounsellorPage.assigned,
  );
  static const Widget schedule = _CounsellorLazy(
    page: _CounsellorPage.schedule,
  );
  static const Widget chat = _CounsellorLazy(page: _CounsellorPage.chat);
  static const Widget awareness = _CounsellorLazy(
    page: _CounsellorPage.awareness,
  );
  static const Widget profile = _CounsellorLazy(page: _CounsellorPage.profile);
}

enum _CounsellorPage {
  dashboard,
  assigned,
  schedule,
  chat,
  awareness,
  profile,
}

class _CounsellorLazy extends StatelessWidget {
  final _CounsellorPage page;
  const _CounsellorLazy({required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case _CounsellorPage.dashboard:
        return const _CounsellorDashboardProxy();
      case _CounsellorPage.assigned:
        return const _CounsellorAssignedProxy();
      case _CounsellorPage.schedule:
        return const _CounsellorScheduleProxy();
      case _CounsellorPage.chat:
        return const _CounsellorChatProxy();
      case _CounsellorPage.awareness:
        return const _CounsellorAwarenessProxy();
      case _CounsellorPage.profile:
        return const _CounsellorProfileProxy();
    }
  }
}

class _CounsellorProfileProxy extends StatelessWidget {
  const _CounsellorProfileProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorProfilePage();
}

// counsellor pages imported at top of file

class _CounsellorDashboardProxy extends StatelessWidget {
  const _CounsellorDashboardProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorDashboardPage();
}

class _CounsellorAssignedProxy extends StatelessWidget {
  const _CounsellorAssignedProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorAssignedComplaintsPage();
}


class _CounsellorScheduleProxy extends StatelessWidget {
  const _CounsellorScheduleProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorScheduleSessionPage();
}

class _CounsellorChatProxy extends StatelessWidget {
  const _CounsellorChatProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorChatPage();
}

class _CounsellorAwarenessProxy extends StatelessWidget {
  const _CounsellorAwarenessProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorAwarenessPage();
}

class WardenDashboard extends StatelessWidget {
  const WardenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.dashboard, label: 'Dashboard'),
      NavigationDestinationData(icon: Icons.list_alt, label: 'Complaints'),
      NavigationDestinationData(icon: Icons.forward_to_inbox, label: 'Forward'),
      NavigationDestinationData(icon: Icons.people, label: 'Students'),
      NavigationDestinationData(icon: Icons.school, label: 'Awareness'),
      NavigationDestinationData(icon: Icons.feedback, label: 'Feedback'),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
    ];

    final pages = const <Widget>[
      _WardenDashboardPages.dashboard,
      _WardenDashboardPages.viewComplaints,
      _WardenDashboardPages.forwardComplaints,
      _WardenDashboardPages.students,
      _WardenDashboardPages.awareness,
      _WardenDashboardPages.feedback,
      _WardenDashboardPages.profile,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
      ),
    );
  }
}

// Lightweight indirection to avoid heavy imports at top
class _WardenDashboardPages {
  static const Widget dashboard = _WardenDashboardLazy(
    page: _WardenPage.dashboard,
  );
  static const Widget viewComplaints = _WardenDashboardLazy(
    page: _WardenPage.viewComplaints,
  );
  static const Widget forwardComplaints = _WardenDashboardLazy(
    page: _WardenPage.forwardComplaints,
  );
  static const Widget students = _WardenDashboardLazy(
    page: _WardenPage.students,
  );
  static const Widget awareness = _WardenDashboardLazy(
    page: _WardenPage.awareness,
  );
  static const Widget feedback = _WardenDashboardLazy(
    page: _WardenPage.feedback,
  );
  static const Widget profile = _WardenDashboardLazy(page: _WardenPage.profile);
}

enum _WardenPage {
  dashboard,
  viewComplaints,
  forwardComplaints,
  students,
  awareness,
  feedback,
  profile,
}

class _WardenDashboardLazy extends StatelessWidget {
  final _WardenPage page;
  const _WardenDashboardLazy({required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case _WardenPage.dashboard:
        return const _ImportWardenDashboardPage();
      case _WardenPage.viewComplaints:
        return const _ImportWardenViewComplaintsPage();
      case _WardenPage.forwardComplaints:
        return const _ImportWardenForwardComplaintsPage();
      case _WardenPage.students:
        return const _ImportWardenStudentsPage();
      case _WardenPage.awareness:
        return const _ImportWardenAwarenessPage();
      case _WardenPage.feedback:
        return const _ImportWardenFeedbackPage();
      case _WardenPage.profile:
        return const _ImportWardenProfilePage();
    }
  }
}

class _ImportWardenProfilePage extends StatelessWidget {
  const _ImportWardenProfilePage();
  @override
  Widget build(BuildContext context) {
    return const _WardenProfileProxy();
  }
}

class _WardenProfileProxy extends StatelessWidget {
  const _WardenProfileProxy();
  @override
  Widget build(BuildContext context) => const warden_pages.WardenProfilePage();
}

// Split small adapters to keep main.dart tidy
class _ImportWardenDashboardPage extends StatelessWidget {
  const _ImportWardenDashboardPage();
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_returning_widgets
    return const _WardenDashboardProxy();
  }
}

class _ImportWardenViewComplaintsPage extends StatelessWidget {
  const _ImportWardenViewComplaintsPage();
  @override
  Widget build(BuildContext context) {
    return const _WardenViewComplaintsProxy();
  }
}

class _ImportWardenForwardComplaintsPage extends StatelessWidget {
  const _ImportWardenForwardComplaintsPage();
  @override
  Widget build(BuildContext context) {
    return const _WardenForwardComplaintsProxy();
  }
}

class _ImportWardenStudentsPage extends StatelessWidget {
  const _ImportWardenStudentsPage();
  @override
  Widget build(BuildContext context) {
    return const _WardenStudentsProxy();
  }
}

class _ImportWardenAwarenessPage extends StatelessWidget {
  const _ImportWardenAwarenessPage();
  @override
  Widget build(BuildContext context) {
    return const _WardenAwarenessProxy();
  }
}

class _ImportWardenFeedbackPage extends StatelessWidget {
  const _ImportWardenFeedbackPage();
  @override
  Widget build(BuildContext context) {
    return const _WardenFeedbackProxy();
  }
}

// Proxies resolve actual pages via top-level imports

class _WardenDashboardProxy extends StatelessWidget {
  const _WardenDashboardProxy();
  @override
  Widget build(BuildContext context) =>
      const warden_pages.WardenDashboardPage();
}

class _WardenViewComplaintsProxy extends StatelessWidget {
  const _WardenViewComplaintsProxy();
  @override
  Widget build(BuildContext context) =>
      const warden_pages.WardenViewComplaintsPage();
}

class _WardenForwardComplaintsProxy extends StatelessWidget {
  const _WardenForwardComplaintsProxy();
  @override
  Widget build(BuildContext context) =>
      const warden_pages.WardenForwardComplaintsPage();
}

class _WardenStudentsProxy extends StatelessWidget {
  const _WardenStudentsProxy();
  @override
  Widget build(BuildContext context) => const warden_pages.WardenStudentsPage();
}

class _WardenAwarenessProxy extends StatelessWidget {
  const _WardenAwarenessProxy();
  @override
  Widget build(BuildContext context) =>
      const warden_pages.WardenAwarenessPage();
}

class _WardenFeedbackProxy extends StatelessWidget {
  const _WardenFeedbackProxy();
  @override
  Widget build(BuildContext context) => const warden_pages.WardenFeedbackPage();
}

class PoliceDashboard extends StatelessWidget {
  const PoliceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.dashboard, label: 'Dashboard'),
      NavigationDestinationData(icon: Icons.assignment, label: 'Complaints'),
      NavigationDestinationData(icon: Icons.verified_user, label: 'Verify'),
      NavigationDestinationData(icon: Icons.assessment, label: 'Reports'),
      NavigationDestinationData(
        icon: Icons.notifications_active,
        label: 'Notify',
      ),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
    ];

    final pages = const <Widget>[
      _PolicePages.dashboard,
      _PolicePages.complaints,
      _PolicePages.verify,
      _PolicePages.generateReport,
      _PolicePages.sendNotification,
      _PolicePages.profile,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
        showBottomNavigation: false,
      ),
    );
  }
}

class _PolicePages {
  static const Widget dashboard = _PoliceLazy(page: _PolicePage.dashboard);
  static const Widget complaints = _PoliceLazy(page: _PolicePage.complaints);
  static const Widget verify = _PoliceLazy(page: _PolicePage.verify);
  static const Widget generateReport = _PoliceLazy(
    page: _PolicePage.generateReport,
  );
  static const Widget sendNotification = _PoliceLazy(
    page: _PolicePage.sendNotification,
  );
  static const Widget profile = _PoliceLazy(page: _PolicePage.profile);
}

enum _PolicePage {
  dashboard,
  complaints,
  verify,
  generateReport,
  sendNotification,
  profile,
}

class _PoliceLazy extends StatelessWidget {
  final _PolicePage page;
  const _PoliceLazy({required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case _PolicePage.dashboard:
        return const _PoliceDashboardProxy();
      case _PolicePage.complaints:
        return const _PoliceComplaintsProxy();
      case _PolicePage.verify:
        return const _PoliceVerifyProxy();
      case _PolicePage.generateReport:
        return const _PoliceGenerateReportProxy();
      case _PolicePage.sendNotification:
        return const _PoliceSendNotificationProxy();
      case _PolicePage.profile:
        return const _PoliceProfileProxy();
    }
  }
}

class _PoliceProfileProxy extends StatelessWidget {
  const _PoliceProfileProxy();
  @override
  Widget build(BuildContext context) => const police_pages.PoliceProfilePage();
}

// police pages imported at top

class _PoliceDashboardProxy extends StatelessWidget {
  const _PoliceDashboardProxy();
  @override
  Widget build(BuildContext context) =>
      const police_pages.PoliceDashboardPage();
}

class _PoliceComplaintsProxy extends StatelessWidget {
  const _PoliceComplaintsProxy();
  @override
  Widget build(BuildContext context) =>
      const police_pages.PoliceComplaintsPage();
}

class _PoliceVerifyProxy extends StatelessWidget {
  const _PoliceVerifyProxy();
  @override
  Widget build(BuildContext context) => const police_pages.PoliceVerifyPage();
}

class _PoliceGenerateReportProxy extends StatelessWidget {
  const _PoliceGenerateReportProxy();
  @override
  Widget build(BuildContext context) =>
      const police_pages.PoliceGenerateReportPage();
}

class _PoliceSendNotificationProxy extends StatelessWidget {
  const _PoliceSendNotificationProxy();
  @override
  Widget build(BuildContext context) =>
      const police_pages.PoliceSendNotificationPage();
}


class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedIndex = appState.navIndex;

    const destinations = [
      NavigationDestinationData(icon: Icons.home, label: 'Home'),
      NavigationDestinationData(icon: Icons.assignment, label: 'Complaints'),
      NavigationDestinationData(icon: Icons.chat_bubble, label: 'Chat'),
      NavigationDestinationData(icon: Icons.school, label: 'Awareness'),
      NavigationDestinationData(icon: Icons.person, label: 'Profile'),
    ];

    final pages = <Widget>[
      _TeacherDashboardPages.dashboard,
      _TeacherDashboardPages.complaints,
      _TeacherDashboardPages.chat,
      _TeacherDashboardPages.awareness,
      _TeacherDashboardPages.profile,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: ResponsiveScaffold(
        title: destinations[selectedIndex].label,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => appState.setNavIndex(i),
        destinations: destinations,
        pages: pages,
      ),
    );
  }
}

class _TeacherDashboardPages {
  static const Widget dashboard = _TeacherLazy(page: _TeacherPage.dashboard);
  static const Widget complaints = _TeacherLazy(page: _TeacherPage.complaints);
  static const Widget chat = _TeacherLazy(page: _TeacherPage.chat);
  static const Widget awareness = _TeacherLazy(page: _TeacherPage.awareness);
  static const Widget profile = _TeacherLazy(page: _TeacherPage.profile);
}

enum _TeacherPage { dashboard, complaints, chat, awareness, profile }

class _TeacherLazy extends StatelessWidget {
  final _TeacherPage page;
  const _TeacherLazy({required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case _TeacherPage.dashboard:
        return const _TeacherDashboardProxy();
      case _TeacherPage.complaints:
        return const _TeacherComplaintsProxy();
      case _TeacherPage.chat:
        return const _TeacherChatProxy();
      case _TeacherPage.awareness:
        return const _TeacherAwarenessProxy();
      case _TeacherPage.profile:
        return const _TeacherProfileProxy();
    }
  }
}

class _TeacherDashboardProxy extends StatelessWidget {
  const _TeacherDashboardProxy();
  @override
  Widget build(BuildContext context) =>
      const teacher_pages.TeacherDashboardPage();
}

class _TeacherComplaintsProxy extends StatelessWidget {
  const _TeacherComplaintsProxy();
  @override
  Widget build(BuildContext context) =>
      const teacher_pages.TeacherComplaintsPage();
}

class _TeacherChatProxy extends StatelessWidget {
  const _TeacherChatProxy();
  @override
  Widget build(BuildContext context) => const teacher_pages.TeacherChatPage();
}

class _TeacherAwarenessProxy extends StatelessWidget {
  const _TeacherAwarenessProxy();
  @override
  Widget build(BuildContext context) =>
      const teacher_pages.TeacherAwarenessPage();
}

class _TeacherProfileProxy extends StatelessWidget {
  const _TeacherProfileProxy();
  @override
  Widget build(BuildContext context) =>
      const teacher_pages.TeacherProfilePage();
}
