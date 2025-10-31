import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fazkorony/models/moshaf.dart';
import 'package:fazkorony/models/reciter.dart';
import 'package:fazkorony/models/quran_audio/player_bar_bloc.dart';
import 'package:quran/quran.dart';

part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBlocBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  AudioPlayer? audioPlayer;
  PlayerBarBloc playerBarBloc;

  PlayerBlocBloc({required this.playerBarBloc}) : super(PlayerBlocInitial()) {
    on<PlayerBlocEvent>((event, emit) async {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final appDir = Directory('${appDocumentsDir.path}/skoon');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }

      if (event is StartPlaying) {
        if (audioPlayer != null) {
          audioPlayer!.dispose();
        }
        audioPlayer = AudioPlayer();
        int nextMediaId = 0;
        List<String> surahNumbers = event.moshaf.surahList.split(',');

        if (surahNumbers.any((element) {
          if (File(
                  "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(element))}.mp3")
              .existsSync()) {
            return true;
          } else {
            return false;
          }
        })) {
          PermissionStatus status = await Permission.storage.request();
          PermissionStatus status2 =
              await Permission.manageExternalStorage.request();
          if (status.isPermanentlyDenied ||
              status2.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
        List reciterLinks = surahNumbers.map((e) {
          if (File(
                  "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(e))}.mp3")
              .existsSync()) {
            var link = {
              "link": Uri.file(
                  "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(e))}.mp3"),
              "suraNumber": e
            };
            return link;
          } else {
            var link = {
              "link": Uri.parse(
                      "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3")
                  .replace(scheme: 'http'),
              "suraNumber": e
            };
            return link;
          }
        }).toList();

        var playList = reciterLinks.map((e) {
          return AudioSource.uri(
            e["link"],
            tag: MediaItem(
              id: '${nextMediaId++}',
              album: event.reciter.name,
              title: event.jsonData
                  .where((element) =>
                      element["id"].toString() == e["suraNumber"].toString())
                  .first["name"]
                  .toString(),
              artUri: Uri.parse(
                  "https://images.pexels.com/photos/318451/pexels-photo-318451.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
            ),
          );
        }).toList();
        String currentSuraNumber = "";
        if (event.suraNumber == -1) {
          currentSuraNumber = surahNumbers[0];
        }
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.speech());

        audioPlayer!.playbackEventStream.listen((event) {},
            onError: (Object e, StackTrace stackTrace) {
        });
        audioPlayer!.setLoopMode(LoopMode.off);
        try {
          await audioPlayer!.setAudioSource(
              initialIndex: event.initialIndex,
              ConcatenatingAudioSource(children: playList));
        } catch (e) {
          print(e);
        }
        audioPlayer!.play();

        playerBarBloc.add(ShowBarEvent());
        emit(PlayerBlocPlaying(
            moshaf: event.moshaf,
            reciter: event.reciter,
            suraNumber: event.suraNumber == -1
                ? int.parse(currentSuraNumber)
                : event.suraNumber,
            jsonData: event.jsonData,
            audioPlayer: audioPlayer!,
            surahNumbers: surahNumbers,
            playList: playList));
      } else if (event is DownloadSurah) {
        final dio = Dio();
        PermissionStatus status = await Permission.storage.request();
        PermissionStatus status2 =
            await Permission.manageExternalStorage.request();
        if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
          await openAppSettings();
        }
        final fullSuraFilePath =
            "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(event.suraNumber))}.mp3";

        if (!File(fullSuraFilePath).existsSync()) {
          try {
            await dio.download(event.url, fullSuraFilePath);
          } catch (e) {
            print(e);
          }
        }
      } else if (event is DownloadAllSurahs) {
        List<String> surahNumbers = event.moshaf.surahList.split(',');

        List reciterLinks = surahNumbers
            .map((e) => {
                  "link":
                      "${event.moshaf.server}/${e.toString().padLeft(3, "0")}.mp3",
                  "suraNumber": e
                })
            .toList();

        final dio = Dio();
        PermissionStatus status = await Permission.storage.request();
        PermissionStatus status2 =
            await Permission.manageExternalStorage.request();
        if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
          await openAppSettings();
        }

        for (var suraLink in reciterLinks) {
          final fullSuraFilePath =
              "${appDir.path}${event.reciter.name}-${event.moshaf.id}-${getSurahNameArabic(int.parse(suraLink["suraNumber"]))}.mp3";

          if (!File(fullSuraFilePath).existsSync()) {
            try {
              await dio.download(suraLink["link"], fullSuraFilePath);
            } catch (e) {
              print(e);
            }
          }
        }
      } else if (event is ClosePlayerEvent) {
        if (audioPlayer != null) {
          audioPlayer!.dispose();
        }
        emit(PlayerBlocInitial());
      } else if (event is PausePlayer) {
        emit(PlayerBlocPaused());
      }
    });
  }
}