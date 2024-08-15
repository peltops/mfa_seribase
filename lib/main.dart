import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mfa_app/pages/auth/login_page.dart';
import 'package:mfa_app/pages/auth/register_page.dart';
import 'package:mfa_app/pages/home_page.dart';
import 'package:mfa_app/pages/list_mfa_page.dart';
import 'package:mfa_app/pages/mfa/verify_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mfa_app/pages/mfa/enroll_page.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://eimunisasi-base-staging.peltops.com',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzIzNDEzNjAwLAogICJleHAiOiAxODgxMTgwMDAwCn0.LP3Zca0w11eNX1974BpPg0GWShJysP6jw9732kL-Y9c',
  );
  runApp(const MyApp());
}
final supabase = Supabase.instance.client;

final _router = GoRouter(
  routes: [
    GoRoute(
      path: HomePage.route,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: ListMFAPage.route,
      builder: (context, state) => ListMFAPage(),
    ),
    GoRoute(
      path: LoginPage.route,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RegisterPage.route,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: MFAEnrollPage.route,
      builder: (context, state) => const MFAEnrollPage(),
    ),
    GoRoute(
      path: MFAVerifyPage.route,
      builder: (context, state) => const MFAVerifyPage(),
    ),
  ],
  redirect: (context, state) async {
    // Any users can visit the /auth route
    if (state.location.contains('/auth') == true) {
      return null;
    }

    final session = supabase.auth.currentSession;
    // A user without a session should be redirected to the register page
    if (session == null) {
      return RegisterPage.route;
    }

    final assuranceLevelData =
        supabase.auth.mfa.getAuthenticatorAssuranceLevel();

    // The user has not setup MFA yet, so send them to enroll MFA page.
    if (assuranceLevelData.currentLevel == AuthenticatorAssuranceLevels.aal1) {
      await supabase.auth.refreshSession();
      final nextLevel =
          supabase.auth.mfa.getAuthenticatorAssuranceLevel().nextLevel;
      if (nextLevel == AuthenticatorAssuranceLevels.aal2) {
        // The user has already setup MFA, but haven't login via MFA
        // Redirect them to the verify page
        return MFAVerifyPage.route;
      } else {
        // The user has not yet setup MFA
        // Redirect them to the enrollment page
        return MFAEnrollPage.route;
      }
    }

    // The user has signed invia MFA, and is allowed to view any page.
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MFA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
