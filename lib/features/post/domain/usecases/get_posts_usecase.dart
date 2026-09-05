import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Stream<List<PostEntity>> call() {
    return repository.getPosts();
  }
}
