part of 'player_bloc_bloc.dart';

@immutable
class PlayerBlocEvent {}

class StartPlaying extends PlayerBlocEvent {
  final Moshaf moshaf;
  final Reciter reciter;
  final int suraNumber;
  final BuildContext buildContext;
  // String suraName;
  final List jsonData;
  final int initialIndex;

  StartPlaying({
    required this.moshaf,
    required this.reciter,
    required this.suraNumber,
    required this.initialIndex,required this.buildContext,
    // required this.suraName,
    required this.jsonData,
  });
}

class DownloadSurah extends PlayerBlocEvent {
  final Moshaf moshaf;
  final Reciter reciter;
  final String suraNumber;
  final String url;
  DownloadSurah({
    required this.reciter,
    required this.moshaf,
    required this.suraNumber,
    required this.url,// required String surahName,
  });
}


class DownloadAllSurahs extends PlayerBlocEvent {
  final Moshaf moshaf;
  final Reciter reciter;
  DownloadAllSurahs({
    required this.moshaf,
    required this.reciter,
  });

}

class ClosePlayerEvent extends PlayerBlocEvent {}
class PausePlayer extends PlayerBlocEvent {}
