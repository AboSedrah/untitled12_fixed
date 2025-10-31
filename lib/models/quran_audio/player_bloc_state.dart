part of 'player_bloc_bloc.dart';

@immutable
class PlayerBlocState {}

class PlayerBlocInitial extends PlayerBlocState {}

class PlayerBlocPlaying extends PlayerBlocState {
  final Moshaf moshaf;
  final Reciter reciter;
  final int suraNumber;
  // String suraName;
  final List<dynamic> jsonData;
  final AudioPlayer audioPlayer;
  final List surahNumbers;
  final List<AudioSource> playList;

  // bool isHidden;
  PlayerBlocPlaying({
    required this.moshaf,
    required this.reciter,
    required this.suraNumber,
    // required this.suraName,
    required this.jsonData,required this.audioPlayer,required this.surahNumbers,required this.playList
    // required this.isHidden
  });
}

class PlayerBlocPaused extends PlayerBlocState {}

class PlayerBlocClosed extends PlayerBlocState {}
