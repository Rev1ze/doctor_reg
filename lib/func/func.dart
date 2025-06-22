import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>> getCurrentUser() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    throw Exception('No user is currently authenticated');
  }
  final userData = await Supabase.instance.client
      .from('user')
      .select('*')
      .eq('uuid', session.user.id)
      .limit(1)
      .single();
  return userData;
}

Future<List<Map<String, dynamic>>> getUserTable() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    throw Exception('No user is currently authenticated');
  }
  final userData = await Supabase.instance.client
      .from('user')
      .select('*')
      .eq('uuid', session.user.id);
  return userData;
}

Future<Map<String, dynamic>> getAboutUser() async {
  final user = await getCurrentUser();
  final aboutUser = await Supabase.instance.client
      .from('about_user')
      .select('*')
      .eq('id', user['id'])
      .limit(1)
      .single();
  return aboutUser;
}

Future<PostgrestList> getAllDoctors() async {
  final aboutUser = await Supabase.instance.client.from('doctors').select('*');
  return aboutUser;
}

Future<PostgrestList> getGraduation() async {
  final aboutUser =
      await Supabase.instance.client.from('doctor_graduation').select('*');
  return aboutUser;
}
Future<PostgrestList> getClinic() async {
  final aboutUser =
      await Supabase.instance.client.from('clinic').select('*');
  return aboutUser;
}
