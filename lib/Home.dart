import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  final _record = Record();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final TextEditingController _controller = TextEditingController();

  Timer? _timer;
  int _time = 0;
  bool _isrecording = true;
  String? _audioPath;

  @override
  void initState() {
    requestPermission();
    super.initState();
  }

  requestPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _time++;
      });
    });
  }

  Future<void> start() async {
    try {
      if (await _record.hasPermission()) {
        Directory _dir;

        if (Platform.isIOS) {
          _dir = await getApplicationDocumentsDirectory();
        } else {
          _dir = Directory('/storage/emulated/0/Download/');
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
