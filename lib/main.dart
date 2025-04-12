import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase 客户端实例
final supabase = Supabase.instance.client;

Future<void> main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Supabase
  await Supabase.initialize(
    url: 'https://zpwfrnzossbnhkmlqrmy.supabase.co', // 替换为你的 Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpwd2Zybnpvc3NibmhrbWxxcm15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0Mjk3NjUsImV4cCI6MjA1ODAwNTc2NX0.-bSBE-lgU9OGsgjwxewY1aH1f0qzXVoc2P8BzMMWAyU', // 替换为你的 Supabase Anon Key
    debug: false, // 开发环境打开调试模式
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoTrip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
