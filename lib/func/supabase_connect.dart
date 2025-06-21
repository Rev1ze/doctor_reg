import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yakwxeskxztzsvdoxezn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlha3d4ZXNreHp0enN2ZG94ZXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg0MzAzMTEsImV4cCI6MjA2NDAwNjMxMX0.Hs3j4ln2lviTub-L3bf21dxZIwnbA5lH-hZqpfrUVCg',
  );
}
final supabase = Supabase.instance.client;