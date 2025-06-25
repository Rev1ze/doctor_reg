import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final aboutUser = await Supabase.instance.client.from('clinic').select('*');
  return aboutUser;
}

Future<void> openMapWithAddress(String address, BuildContext context) async {
  final encodedAddress = Uri.encodeComponent(address);
  final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress');

  try {
    final canLaunch = await canLaunchUrl(url);
    if (canLaunch) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Не удалось открыть карту. Установите браузер или Google Maps.')),
      );
    }
  } catch (e) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Text('Произошла ошибка: $e'),
        );
      },
    );
  }
}

Future<List<Map<String, dynamic>>> fetchDoctorWorkingDays(
    String doctorId) async {
  final response = await Supabase.instance.client
      .from('working_days')
      .select()
      .eq('doctor_id', doctorId)
      .gte('date', DateTime.now().toIso8601String())
      .order('date', ascending: true);

  if (response == null || response.isEmpty) {
    return [];
  }

  return List<Map<String, dynamic>>.from(response);
}
