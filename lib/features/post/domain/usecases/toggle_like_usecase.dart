import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<void> call({required String postId, required String uid}) {
    return repository.toggleLike(postId: postId, uid: uid);
  }
}
