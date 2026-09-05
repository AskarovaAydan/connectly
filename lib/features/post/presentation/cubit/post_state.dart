import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostEntity>
  posts; //PostLoaded-da List<PostEntity> saxlanılır (tək PostEntity yox, çünki artıq siyahı ilə işləyirik).

  const PostLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostFailure extends PostState {
  final String message;

  const PostFailure(this.message);

  @override
  List<Object?> get props => [message];
}
