import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasource/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createPost(PostEntity post) {
    return remoteDataSource.createPost(post);
  }

  @override
  Stream<List<PostEntity>> getPosts() {
    return remoteDataSource.getPosts();
  }

  @override
  Future<void> toggleLike({required String postId, required String uid}) {
    return remoteDataSource.toggleLike(postId: postId, uid: uid);
  }
}
