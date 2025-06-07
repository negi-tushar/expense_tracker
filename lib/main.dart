import 'package:expense_tracker/blocs/bloc/category_bloc.dart';
import 'package:expense_tracker/blocs/bloc/category_event.dart';
import 'package:expense_tracker/blocs/transactions/transaction_bloc.dart';
import 'package:expense_tracker/screens/add_category_screen.dart';
import 'package:expense_tracker/screens/homescreen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';
import 'package:expense_tracker/screens/splash_screen.dart';
import 'package:expense_tracker/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.init();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<TransactionBloc>(
      create: (_) => TransactionBloc(),
    ),
    BlocProvider<CategoryBloc>(
      create: (context) => CategoryBloc()..add(InitializeCategories()),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expensely',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      themeMode: ThemeMode.light,
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/reports': (context) => const ReportScreen(),
        '/addCategory': (context) => const AddCategoryScreen()
      },
    );
  }
}
