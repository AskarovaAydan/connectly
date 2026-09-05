import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
  }) {
    final post = PostEntity(
      id: '', // Firestore özü yaradacaq, hələ boş saxlayırıq
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      content: content,
      createdAt: DateTime.now(),
    );

    return repository.createPost(post);
  }
}
