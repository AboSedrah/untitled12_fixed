// ignore_for_file: unnecessary_null_comparison
// removed unused import 'reciter.dart'
import 'dart:convert';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fazkorony/core/hive_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart';

part 'quran_page_player_event.dart';
part 'quran_page_player_state.dart';

class QuranPagePlayerBloc
    extends Bloc<QuranPagePlayerEvent, QuranPagePlayerState> {
  AudioPlayer? audioPlayer;

  QuranPagePlayerBloc() : super(QuranPagePlayerInitial()) {
    on<PlayFromVerse>(_onPlayFromVerse);
    on<StopPlaying>(_onStopPlaying);
    on<KillPlayerEvent>(_onKillPlayerEvent);
  }

  Future<void> _onPlayFromVerse(
      PlayFromVerse event, Emitter<QuranPagePlayerState> emit) async {
    audioPlayer = AudioPlayer();

    String? storedJsonString = getValue(
      "${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}-durations",
    );

    if (storedJsonString == null) {
      Fluttertoast.showToast(msg: "Durations data not found");
      emit(QuranPagePlayerIdle());
      return;
    }

    List<dynamic> decodedList;
    try {
      decodedList = json.decode(storedJsonString);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid durations data");
      emit(QuranPagePlayerIdle());
      return;
    }

    List durations = List.from(decodedList);

    final verseData = durations.firstWhere(
      (element) => element["verseNumber"] == event.verse,
      orElse: () => null,
    );
    if (verseData == null) {
      Fluttertoast.showToast(msg: "Verse duration not found");
      emit(QuranPagePlayerIdle());
      return;
    }
    double duration = verseData["startDuration"];

    final reciterMatch = getReciters().firstWhere(
      (element) => element["identifier"] == event.reciterIdentifier,
      orElse: () => null,
    );
    if (reciterMatch == null) {
      Fluttertoast.showToast(msg: "Reciter not found");
      emit(QuranPagePlayerIdle());
      return;
    }

    final appDir = await getTemporaryDirectory();
    final filePath =
        "${appDir.path}-${event.reciterIdentifier}-${event.suraName.replaceAll(" ", "")}.mp3";

    if (!File(filePath).existsSync()) {
      Fluttertoast.showToast(msg: "Audio file not found");
      emit(QuranPagePlayerIdle());
      return;
    }

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    audioPlayer!.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      Fluttertoast.showToast(msg: "Playback error: $e");
    });

    try {
      await audioPlayer!.setAudioSource(
        ConcatenatingAudioSource(
          children: [
            AudioSource.file(
              filePath,
            )
          ],
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error loading audio");
      emit(QuranPagePlayerIdle());
      return;
    }

    audioPlayer!.seek(Duration(milliseconds: duration.toInt()));
    audioPlayer!.play();

    emit(QuranPagePlayerPlaying(
      player: audioPlayer!,
      audioPlayerStream: audioPlayer!.durationStream,
      suraNumber: event.surahNumber,
      durations: durations,
      reciter: reciterMatch,
    ));

    Fluttertoast.showToast(msg: "Start Playing");
  }

  Future<void> _onStopPlaying(
      StopPlaying event, Emitter<QuranPagePlayerState> emit) async {
    if (audioPlayer != null) {
      await audioPlayer!.stop();
    }
    emit(QuranPagePlayerStopped());
  }

  Future<void> _onKillPlayerEvent(
      KillPlayerEvent event, Emitter<QuranPagePlayerState> emit) async {
    if (audioPlayer != null) {
      await audioPlayer!.stop();
      audioPlayer = null;
    }
    emit(QuranPagePlayerIdle());
  }

  @override
  Future<void> close() {
    audioPlayer?.dispose();
    return super.close();
  }
}
