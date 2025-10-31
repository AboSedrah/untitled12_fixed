part of 'quran_page_player_bloc.dart';

@immutable
 class QuranPagePlayerState {}

 class QuranPagePlayerInitial extends QuranPagePlayerState {}


class QuranPagePlayerPlaying extends QuranPagePlayerState {
final Stream<Duration?>  audioPlayerStream;
final AudioPlayer player;
final int suraNumber;
final List durations;
final dynamic reciter;

  QuranPagePlayerPlaying({required this.player,
    required this.audioPlayerStream,required this.suraNumber,required this.durations,
    required this.reciter
  });

}


class QuranPagePlayerStopped extends QuranPagePlayerState{
  
}


class QuranPagePlayerIdle extends QuranPagePlayerState{
  
}