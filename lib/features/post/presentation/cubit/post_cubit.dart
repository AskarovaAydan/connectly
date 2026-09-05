import 'dart:async';
import 'package:connectly/features/post/domain/usecases/toggle_like_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final CreatePostUseCase createPostUseCase;
  final GetPostsUseCase getPostsUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  StreamSubscription? _postsSubscription;

  PostCubit(
    this.createPostUseCase,
    this.getPostsUseCase,
    this.toggleLikeUseCase,
  ) : super(PostInitial());

  void watchPosts() {
    emit(PostLoading());
    _postsSubscription?.cancel();
    _postsSubscription = getPostsUseCase().listen(
      //.listen(...) — bu, Stream-i "işə salan" hissədir
      (posts) {
        //getPostsUseCase() — Stream<List<PostEntity>> qaytarır (yadına gəlsin, bu, davamlı axındır)
        //.listen(...) — bu axına abunə oluruq. Hər dəfə Firestore-da yeni data gələndə (yeni post əlavə olunanda), bu funksiya avtomatik çağırılır, biz də emit(PostLoaded(posts)) edirik
        emit(PostLoaded(posts));
      },
      onError: (e) {
        emit(PostFailure(e.toString()));
      },
    );
  }

  Future<void> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
  }) async {
    try {
      await createPostUseCase(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
      );
      // Stream artıq watchPosts() ilə dinlənildiyi üçün,
      // yeni post avtomatik gələcək, burada əlavə emit lazım deyil
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  Future<void> toggleLike(String postId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await toggleLikeUseCase(postId: postId, uid: uid);
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}

/*1. Niyə StreamSubscription lazımdır?
StreamSubscription? _postsSubscription;

register/login-də Future idi — bir dəfə await edib, nəticəni aldıq, iş bitdi. Amma Stream davamlı olduğu üçün, ona "abunə olmaq" (listen) lazımdır, və bu abunəliyi idarə etmək (lazım olanda ləğv etmək) üçün onu bir dəyişəndə saxlamalıyıq.

2. watchPosts() — niyə Future<void> yox, sadə void?
void watchPosts() {

Diqqət et — bu metod async deyil! Çünki Stream-ə abunə olmaq, Future kimi "bir nəticəni gözləmək" demək deyil — sadəcə "bundan sonra hər gələn dəyəri mənə bildir" demiş oluruq, dərhal geri qayıdırıq.

3. Niyə createPost-dan sonra əlavə emit yazmırıq?
Bu, çox vacib bir məntiqdir. createPost işlədikdə, Firestore-a yeni sənəd əlavə olunur. Bu, avtomatik olaraq bizim watchPosts()-un içindəki Stream-i işə salır (çünki Firestore "kolleksiyada dəyişiklik oldu" deyir), bu da öz-özünə emit(PostLoaded(yeni_siyahı)) çağıracaq. Yəni iki dəfə eyni işi görməyə ehtiyac yoxdur — Stream artıq "avtomatik" hər şeyi idarə edir.

4. close() — niyə override edirik?
@override
Future<void> close() {Bu, flutter_bloc paketinin daxilində, Cubit class-ında ARTIQ mövcuddur:
  _postsSubscription?.cancel();
  return super.close();Bu, "valideyn class-ın (Cubit-in) öz orijinal close() metodunu da işə sal" deməkdir.
bunu yazmasaydıq, Cubit-in öz daxili təmizlik işi (state stream-inin bağlanması) heç vaxt baş verməzdi
  Çünki bizim əlavə bir resursumuz var — _postsSubscription (bizim özümüzün açdığı Stream abunəliyi). Cubit-in öz daxili close()-u, bizim yaratdığımız bu əlavə abunəlikdən xəbərsizdir — o, yalnız öz (Cubit-in öz daxili) resurslarını təmizləyir.

Ona görə, biz close()-u override edirik ki, deyə bilək: "Cubit bağlananda, əvvəlcə MƏNİM əlavə abunəliyimi də ləğv et, SONRA öz adi işini gör":
}

Cubit bağlananda (məsələn səhifədən çıxanda), Stream abunəliyini də ləğv etməliyik — yoxsa "yaddaş sızması" (memory leak) yaranar, Cubit artıq mövcud olmasa da, Stream arxa planda işləməyə davam edər.
*/
