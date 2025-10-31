part of 'player_bar_bloc.dart';

@immutable
class PlayerBarState {}

class PlayerBarInitial extends PlayerBarState {
  final double height;
  PlayerBarInitial({
    required this.height,
  });
}

class PlayerBarVisible extends PlayerBarState {
  final double height;
  PlayerBarVisible({
    required this.height,
  });
}

class PlayerBarHidden extends PlayerBarState {}

class PlayerBarClosed extends PlayerBarState {}
