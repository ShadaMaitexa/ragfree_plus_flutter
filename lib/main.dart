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
import 'screens/parent/awareness_page.dart' as parent;
import 'screens/parent/profile_page.dart' as parent;
import 'screens/warden/dashboard_page.dart' as warden_pages;
import 'screens/warden/view_complaints_page.dart' as warden_pages;
import 'screens/warden/forward_complaints_page.dart' as warden_pages;
import 'screens/warden/students_page.dart' as warden_pages;
import 'screens/warden/awareness_page.dart' as warden_pages;
import 'screens/warden/feedback_page.dart' as warden_pages;
import 'screens/counsellor/dashboard_page.dart' as counsellor_pages;
import 'screens/counsellor/assigned_complaints_page.dart' as counsellor_pages;
import 'screens/counsellor/respond_complaint_page.dart' as counsellor_pages;
import 'screens/counsellor/schedule_session_page.dart' as counsellor_pages;
import 'screens/counsellor/chat_page.dart' as counsellor_pages;
import 'screens/counsellor/awareness_page.dart' as counsellor_pages;
import 'screens/police/dashboard_page.dart' as police_pages;
import 'screens/police/complaints_page.dart' as police_pages;
import 'screens/police/generate_report_page.dart' as police_pages;
import 'screens/police/send_notification_page.dart' as police_pages;
import 'screens/police/awareness_page.dart' as police_pages;
import 'screens/admin/dashboard_page.dart' as admin_pages;
import 'screens/admin/manage_users_page.dart' as admin_pages;
import 'screens/admin/departments_page.dart' as admin_pages;
import 'screens/admin/awareness_page.dart' as admin_pages;
import 'screens/admin/notifications_page.dart' as admin_pages;
import 'screens/admin/reports_page.dart' as admin_pages;
import 'screens/admin/feedback_page.dart' as admin_pages;
import 'screens/admin/analytics_page.dart' as admin_pages;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authService = AuthService();
    final user = authService.currentUser;

    if (user != null) {
      // User is logged in, check their status
      final userData = await authService.getUserData(user.uid);
      if (userData != null) {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.setUser(userData);

        // Check if approval is needed
        if ((userData.role == 'police' ||
                userData.role == 'counsellor' ||
                userData.role == 'warden') &&
            !userData.isApproved) {
          Navigator.of(context).pushReplacementNamed(Routes.approvalPending);
        } else {
          // Navigate to appropriate dashboard
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
            default:
              Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        }
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    } else {
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
                ? [color.withOpacity(0.1), color.withOpacity(0.05)]
                : [color.withOpacity(0.1), color.withOpacity(0.05)],
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
                            color.withOpacity(0.2),
                            color.withOpacity(0.05),
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
                                ).colorScheme.onSurface.withOpacity(0.7),
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
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const StudentHomePage(),
      const StudentComplaintsPage(),
      const StudentChatPage(),
      const StudentAwarenessPage(),
      const StudentProfilePage(),
    ];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Student Dashboard')),
        body: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => selectedIndex = i),
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) {
            setState(() => selectedIndex = i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Complaints',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Awareness',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const parent.ParentHomePage(),
      const parent.ParentChildComplaintsPage(),
      const parent.ParentChatPage(),
      const parent.ParentAwarenessPage(),
      const parent.ParentProfilePage(),
    ];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Parent Dashboard')),
        body: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => selectedIndex = i),
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) {
            setState(() => selectedIndex = i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'ChildComplaints',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Awareness',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final railDestinations = const [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.group),
        label: Text('ManageUsers'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.apartment),
        label: Text('Departments'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.school),
        label: Text('Awareness'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.notifications),
        label: Text('Notifications'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.receipt_long),
        label: Text('Reports'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.feedback),
        label: Text('Feedback'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.analytics),
        label: Text('Analytics'),
      ),
    ];

    final pages = const <Widget>[
      _AdminPages.dashboard,
      _AdminPages.manageUsers,
      _AdminPages.departments,
      _AdminPages.awareness,
      _AdminPages.notifications,
      _AdminPages.reports,
      _AdminPages.feedback,
      _AdminPages.analytics,
    ];

    final isWide = MediaQuery.of(context).size.width >= 900;

    final navWidget = isWide
        ? NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => setState(() => selectedIndex = i),
            destinations: railDestinations,
            labelType: NavigationRailLabelType.all,
          )
        : _RoleDrawer(
            onNavigate: (i) => setState(() => selectedIndex = i),
            items: const [
              DrawerItem(icon: Icons.dashboard, label: 'Dashboard'),
              DrawerItem(icon: Icons.group, label: 'ManageUsers'),
              DrawerItem(icon: Icons.apartment, label: 'Departments'),
              DrawerItem(icon: Icons.school, label: 'Awareness'),
              DrawerItem(icon: Icons.notifications, label: 'Notifications'),
              DrawerItem(icon: Icons.receipt_long, label: 'Reports'),
              DrawerItem(icon: Icons.feedback, label: 'Feedback'),
              DrawerItem(icon: Icons.analytics, label: 'Analytics'),
            ],
          );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        drawer: isWide ? null : navWidget as Widget?,
        body: Row(
          children: [
            if (isWide) SizedBox(width: 220, child: navWidget),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey<int>(selectedIndex),
                  child: pages[selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPages {
  static const Widget dashboard = _AdminLazy(page: _AdminPage.dashboard);
  static const Widget manageUsers = _AdminLazy(page: _AdminPage.manageUsers);
  static const Widget departments = _AdminLazy(page: _AdminPage.departments);
  static const Widget awareness = _AdminLazy(page: _AdminPage.awareness);
  static const Widget notifications = _AdminLazy(
    page: _AdminPage.notifications,
  );
  static const Widget reports = _AdminLazy(page: _AdminPage.reports);
  static const Widget feedback = _AdminLazy(page: _AdminPage.feedback);
  static const Widget analytics = _AdminLazy(page: _AdminPage.analytics);
}

enum _AdminPage {
  dashboard,
  manageUsers,
  departments,
  awareness,
  notifications,
  reports,
  feedback,
  analytics,
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
      case _AdminPage.departments:
        return const _AdminDepartmentsProxy();
      case _AdminPage.awareness:
        return const _AdminAwarenessProxy();
      case _AdminPage.notifications:
        return const _AdminNotificationsProxy();
      case _AdminPage.reports:
        return const _AdminReportsProxy();
      case _AdminPage.feedback:
        return const _AdminFeedbackProxy();
      case _AdminPage.analytics:
        return const _AdminAnalyticsProxy();
    }
  }
}

// admin pages imported at top

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

class _AdminFeedbackProxy extends StatelessWidget {
  const _AdminFeedbackProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminFeedbackPage();
}

class _AdminAnalyticsProxy extends StatelessWidget {
  const _AdminAnalyticsProxy();
  @override
  Widget build(BuildContext context) => const admin_pages.AdminAnalyticsPage();
}

class CounsellorDashboard extends StatefulWidget {
  const CounsellorDashboard({super.key});

  @override
  State<CounsellorDashboard> createState() => _CounsellorDashboardState();
}

class _CounsellorDashboardState extends State<CounsellorDashboard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const <Widget>[
      _CounsellorDashboardPages.dashboard,
      _CounsellorDashboardPages.assigned,
      _CounsellorDashboardPages.respond,
      _CounsellorDashboardPages.schedule,
      _CounsellorDashboardPages.chat,
      _CounsellorDashboardPages.awareness,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Counsellor Dashboard')),
      drawer: _RoleDrawer(
        onNavigate: (index) => setState(() => selectedIndex = index),
        items: const [
          DrawerItem(icon: Icons.dashboard_customize, label: 'Dashboard'),
          DrawerItem(icon: Icons.assignment_ind, label: 'AssignedComplaints'),
          DrawerItem(icon: Icons.reply, label: 'RespondComplaint'),
          DrawerItem(icon: Icons.event, label: 'ScheduleSession'),
          DrawerItem(icon: Icons.chat_bubble, label: 'Chat'),
          DrawerItem(icon: Icons.school, label: 'Awareness'),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

class _CounsellorDashboardPages {
  static const Widget dashboard = _CounsellorLazy(
    page: _CounsellorPage.dashboard,
  );
  static const Widget assigned = _CounsellorLazy(
    page: _CounsellorPage.assigned,
  );
  static const Widget respond = _CounsellorLazy(page: _CounsellorPage.respond);
  static const Widget schedule = _CounsellorLazy(
    page: _CounsellorPage.schedule,
  );
  static const Widget chat = _CounsellorLazy(page: _CounsellorPage.chat);
  static const Widget awareness = _CounsellorLazy(
    page: _CounsellorPage.awareness,
  );
}

enum _CounsellorPage { dashboard, assigned, respond, schedule, chat, awareness }

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
      case _CounsellorPage.respond:
        return const _CounsellorRespondProxy();
      case _CounsellorPage.schedule:
        return const _CounsellorScheduleProxy();
      case _CounsellorPage.chat:
        return const _CounsellorChatProxy();
      case _CounsellorPage.awareness:
        return const _CounsellorAwarenessProxy();
    }
  }
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

class _CounsellorRespondProxy extends StatelessWidget {
  const _CounsellorRespondProxy();
  @override
  Widget build(BuildContext context) =>
      const counsellor_pages.CounsellorRespondComplaintPage();
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

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const <Widget>[
      // Dashboard, ViewComplaints, ForwardComplaints, Students, Awareness, Feedback
      _WardenDashboardPages.dashboard,
      _WardenDashboardPages.viewComplaints,
      _WardenDashboardPages.forwardComplaints,
      _WardenDashboardPages.students,
      _WardenDashboardPages.awareness,
      _WardenDashboardPages.feedback,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Warden Dashboard')),
      drawer: _RoleDrawer(
        onNavigate: (index) => setState(() => selectedIndex = index),
        items: const [
          DrawerItem(icon: Icons.dashboard, label: 'Dashboard'),
          DrawerItem(icon: Icons.list_alt, label: 'ViewComplaints'),
          DrawerItem(icon: Icons.forward_to_inbox, label: 'ForwardComplaints'),
          DrawerItem(icon: Icons.people, label: 'Students'),
          DrawerItem(icon: Icons.school, label: 'Awareness'),
          DrawerItem(icon: Icons.feedback, label: 'Feedback'),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({super.key});

  @override
  State<PoliceDashboard> createState() => _PoliceDashboardState();
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
}

enum _WardenPage {
  dashboard,
  viewComplaints,
  forwardComplaints,
  students,
  awareness,
  feedback,
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
    }
  }
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

class _PoliceDashboardState extends State<PoliceDashboard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const <Widget>[
      _PolicePages.dashboard,
      _PolicePages.complaints,
      _PolicePages.verify,
      _PolicePages.generateReport,
      _PolicePages.sendNotification,
      _PolicePages.awareness,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Police Dashboard')),
      drawer: _RoleDrawer(
        onNavigate: (index) => setState(() => selectedIndex = index),
        items: const [
          DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          DrawerItem(icon: Icons.assignment, label: 'Complaints'),
          DrawerItem(icon: Icons.verified_user, label: 'Verify'),
          DrawerItem(icon: Icons.picture_as_pdf, label: 'GenerateReport'),
          DrawerItem(icon: Icons.notifications, label: 'SendNotification'),
          DrawerItem(icon: Icons.school, label: 'Awareness'),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: pages[selectedIndex],
        ),
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
  static const Widget awareness = _PoliceLazy(page: _PolicePage.awareness);
}

enum _PolicePage {
  dashboard,
  complaints,
  verify,
  generateReport,
  sendNotification,
  awareness,
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
        return const _PoliceComplaintsProxy();
      case _PolicePage.generateReport:
        return const _PoliceGenerateReportProxy();
      case _PolicePage.sendNotification:
        return const _PoliceSendNotificationProxy();
      case _PolicePage.awareness:
        return const _PoliceAwarenessProxy();
    }
  }
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

class _PoliceAwarenessProxy extends StatelessWidget {
  const _PoliceAwarenessProxy();
  @override
  Widget build(BuildContext context) =>
      const police_pages.PoliceAwarenessPage();
}

class DrawerItem {
  final IconData icon;
  final String label;
  const DrawerItem({required this.icon, required this.label});
}

class _RoleDrawer extends StatelessWidget {
  final void Function(int index) onNavigate;
  final List<DrawerItem> items;
  const _RoleDrawer({required this.onNavigate, required this.items});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'RagFree+',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text('Navigation'),
                ],
              ),
            ),
            for (int i = 0; i < items.length; i++)
              ListTile(
                leading: Icon(items[i].icon),
                title: Text(items[i].label),
                onTap: () {
                  Navigator.pop(context);
                  onNavigate(i);
                },
              ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(context, Routes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
