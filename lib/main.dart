import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AueLibraryApp());
}

class AueLibraryApp extends StatelessWidget {
  const AueLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AUE Library",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

/* ----------------------------- APP STATE ----------------------------- */
class AppState extends InheritedWidget {
  final _AppData data;

  AppState({super.key, required Widget child})
      : data = _AppData(),
        super(child: child);

  static _AppData of(BuildContext context) {
    final AppState? result = context
        .dependOnInheritedWidgetOfExactType<AppState>();
    assert(result != null, 'No AppState found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(AppState oldWidget) => true;
}

class _AppData extends ChangeNotifier {
  String? username;
  String displayName = "John Doe";
  String libraryId = "LB123456";
  String avatarUrl =
      "https://drive.google.com/file/d/1Mxv-gBZrBo5Pszo-5XjeteTuYTNyN5qt/view?usp=sharing";

  final List<AttendanceRecord> attendance = [];
  final List<Map<String, String>> currentLoans = [
    {"title": "Introduction to Flutter", "due": "2023-12-15"},
    {"title": "Advanced Dart Programming", "due": "2023-12-20"},
  ];

  void login(String user) {
    username = user;
    notifyListeners();
  }

  void logout() {
    username = null;
    attendance.clear();
    notifyListeners();
  }

  void addAttendance(AttendanceRecord record) {
    attendance.add(record);
    notifyListeners();
  }
}

class AttendanceRecord {
  final DateTime timestamp;
  final String location;
  final String raw;

  AttendanceRecord({
    required this.timestamp,
    required this.location,
    required this.raw,
  });
}

/* --------------------------------- LOGIN --------------------------------- */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final String dummyUser = "student";
  final String dummyPass = "1234";
  bool isLoading = false;
  bool obscurePassword = true;

  void _login() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (_usernameController.text.trim() == dummyUser &&
          _passwordController.text == dummyPass) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppState(
              child: HomeScreen(initialUser: _usernameController.text.trim()),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid username or password"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade800, Colors.indigo.shade800],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.library_books, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  "AUE Library",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to your account",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------------- HOME --------------------------------- */
class HomeScreen extends StatefulWidget {
  final String initialUser;
  const HomeScreen({super.key, required this.initialUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppState.of(context);
    if (app.username == null) {
      app.login(widget.initialUser);
    }
    _pages = [
      DashboardPage(
        onOpenAttendance: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendancePage()),
          );
        },
        onOpenBookings: () {
          setState(() => _selectedIndex = 3);
        },
        onOpenMyLoans: () {
          setState(() => _selectedIndex = 2);
        },
        onOpenNews: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewsPage()),
          );
        },
      ),
      const CatalogSearchPage(),
      const MyAccountPage(),
      const BookingsPage(),
      const MorePage(),
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _logout() {
    AppState.of(context).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white, // Placeholder background color
            child: Icon(
              Icons.person, // Placeholder icon
              color: Colors.deepPurple,
            ),
          ),
        ),
        title: const Text('AUE Library'),
        centerTitle: false, // Align title next to the avatar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: "Catalog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: "Account",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            activeIcon: Icon(Icons.meeting_room),
            label: "Bookings",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }
}

/* ------------------------------- DASHBOARD ------------------------------ */
class DashboardPage extends StatelessWidget {
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenMyLoans;
  final VoidCallback onOpenNews;

  const DashboardPage({
    super.key,
    required this.onOpenAttendance,
    required this.onOpenBookings,
    required this.onOpenMyLoans,
    required this.onOpenNews,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Image.network("https://iili.io/FDLueqv.png"),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          app.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "ID: ${app.libraryId}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildCard(
                  context,
                  Icons.book_outlined,
                  "My Loans",
                  Colors.deepPurple.shade100,
                  Colors.deepPurple,
                  onOpenMyLoans,
                ),
                _buildCard(
                  context,
                  Icons.meeting_room_outlined,
                  "Bookings",
                  Colors.blue.shade100,
                  Colors.blue,
                  onOpenBookings,
                ),
                _buildCard(
                  context,
                  Icons.qr_code_scanner_outlined,
                  "Attendance",
                  Colors.green.shade100,
                  Colors.green,
                  onOpenAttendance,
                ),
                _buildCard(
                  context,
                  Icons.new_releases_outlined,
                  "Library News",
                  Colors.orange.shade100,
                  Colors.orange,
                  onOpenNews,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.deepPurple.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Library Hours",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHoursRow(context, "Mon-Fri", "8:00 AM - 10:00 PM"),
                    _buildHoursRow(context, "Saturday", "9:00 AM - 6:00 PM"),
                    _buildHoursRow(context, "Sunday", "Closed"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context,
      IconData icon,
      String title,
      Color bgColor,
      Color iconColor,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoursRow(BuildContext context, String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(hours, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/* -------------------------------- CATALOG ------------------------------- */
class CatalogSearchPage extends StatefulWidget {
  const CatalogSearchPage({super.key});

  @override
  State<CatalogSearchPage> createState() => _CatalogSearchPageState();
}

class _CatalogSearchPageState extends State<CatalogSearchPage> {
  final List<String> books = const [
    "Introduction to Library Science",
    "Digital Libraries and E-Resources",
    "Koha OPAC User Guide",
    "Advanced Cataloging",
    "Library Automation Essentials",
    "Metadata and MARC21 Standards",
    "Information Retrieval Basics",
    "Research Methods for LIS",
  ];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filtered = books
        .where((b) => b.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search books, authors, topics...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) => setState(() => searchQuery = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No books found",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "Try a different search term",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.menu_book_outlined,
                  color: Colors.deepPurple,
                ),
                title: Text(filtered[i]),
                subtitle: const Text("Available"),
                trailing: const Icon(Icons.chevron_right),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ MY ACCOUNT ------------------------------ */
class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(app.avatarUrl),
          ),
          const SizedBox(height: 16),
          Text(
            app.displayName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            "ID: ${app.libraryId}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text("Library ID"),
                  subtitle: Text(app.libraryId),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text("Email"),
                  subtitle: const Text("student@aue.ae"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text("Phone"),
                  subtitle: const Text("+971 50 123 4567"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.attach_money_outlined),
                  title: const Text("Fines"),
                  subtitle: const Text("0 AED"),
                  trailing: Chip(
                    label: const Text("Paid"),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: const Text("Current Loans"),
                  subtitle: Text("${app.currentLoans.length} items"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyLoansPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyLoansPage extends StatelessWidget {
  const MyLoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("My Loans")),
      body: app.currentLoans.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No current loans",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: app.currentLoans.length,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.book_outlined),
            title: Text(app.currentLoans[i]["title"]!),
            subtitle: Text("Due: ${app.currentLoans[i]["due"]!}"),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------- BOOKINGS ------------------------------- */
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  final List<Map<String, String>> bookings = const [
    {"room": "Study Room A", "time": "10:00 – 11:00 AM", "date": "2023-12-10"},
    {"room": "Study Room B", "time": "2:00 – 3:00 PM", "date": "2023-12-11"},
    {"room": "Group Room C", "time": "4:00 – 5:30 PM", "date": "2023-12-12"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No bookings yet",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Book a study room to get started",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (_, index) => Card(
          child: ListTile(
            leading: const Icon(Icons.meeting_room_outlined),
            title: Text(bookings[index]["room"]!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bookings[index]["date"]!),
                Text(bookings[index]["time"]!),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel_outlined),
              color: Colors.red,
              onPressed: () {},
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

/* --------------------------------- NEWS --------------------------------- */
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  final List<Map<String, String>> news = const [
    {
      "title": "Library Orientation Week",
      "desc": "Join our sessions to explore e-resources and study rooms.",
      "date": "Dec 1, 2023",
    },
    {
      "title": "New Arrivals: Research Methods",
      "desc": "Fresh titles now available in print and eBook.",
      "date": "Nov 25, 2023",
    },
    {
      "title": "Extended Hours During Exams",
      "desc": "Library open until 11 PM from Dec 10-20.",
      "date": "Nov 20, 2023",
    },
    {
      "title": "Koha Training Sessions",
      "desc": "Learn how to use our new library system.",
      "date": "Nov 15, 2023",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: news.length,
        itemBuilder: (_, i) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        news[i]["title"]!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(news[i]["desc"]!),
                const SizedBox(height: 8),
                Text(
                  news[i]["date"]!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------- ATTENDANCE PAGE --------------------------- */
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _qrController = TextEditingController(
    text: "AUEATTEND|location=Main Library|ts=202308151000|sig=DEMO",
  );
  String? _statusMessage;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _qrController.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _processScan() {
    final payload = _qrController.text.trim();
    final parsed = _parseQrPayload(payload);
    if (parsed == null) {
      setState(() => _statusMessage = "Invalid QR code. Please try again.");
      return;
    }
    final app = AppState.of(context);
    final now = DateTime.now();
    app.addAttendance(
      AttendanceRecord(
        timestamp: now,
        location: parsed["location"]!,
        raw: payload,
      ),
    );
    setState(
          () => _statusMessage =
      "Attendance recorded for ${app.displayName} at ${parsed["location"]}.",
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance Recorded ✓"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, String>? _parseQrPayload(String payload) {
    if (!payload.startsWith("AUEATTEND|")) return null;
    final parts = payload.split("|");
    final map = <String, String>{};
    for (int i = 1; i < parts.length; i++) {
      final kv = parts[i].split("=");
      if (kv.length == 2) map[kv[0]] = kv[1];
    }
    if (!map.containsKey("location")) return null;
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final records = app.attendance.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: "Scanner", icon: Icon(Icons.qr_code_scanner)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // --- Demo Scanner ---
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "DartPad Demo Scanner",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "Paste the QR content below (as encoded in the QR). In production, this will be read automatically by the camera.",
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qrController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "QR Code Content",
                  hintText:
                  "AUEATTEND|location=Main Library|ts=YYYYMMDDHHMM|sig=...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Record Attendance"),
                  onPressed: _processScan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.verified, color: Colors.green),
                    title: Text(_statusMessage!),
                    subtitle: Text(
                      "User: ${app.displayName} (${app.libraryId})",
                    ),
                  ),
                ),
              ],
            ],
          ),
          // --- History ---
          records.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No attendance records",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: records.length,
            itemBuilder: (_, i) {
              final r = records[i];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(r.location),
                  subtitle: Text(
                    "${_fmt(r.timestamp)} • ${AppState.of(context).displayName}",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}";
  }
}

/* --------------------------------- MORE --------------------------------- */
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_outlined),
                title: const Text("Attendance Tracking"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttendancePage()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Settings"),
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text("Help & Support"),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text("Feedback"),
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("About Library"),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text("Privacy Policy"),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.exit_to_app_outlined),
                title: const Text("Logout"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  AppState.of(context).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
