import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id; //id — niyə uid-dən fərqli olaraq id adlandırdıq?
  //uid — Firebase Auth-ın verdiyi, istifadəçinin öz ID-si
  //PostEntity.id — konkret bir postun öz ID-si
  //PostEntity.userId — bu postu kim yazıb, onun ID-si,Bu sahə, sadəcə uid-in başqa adla postun içinə kopyalanmış halıdır. Yəni userId, əslində elə uid-dir — sadəcə "post" kontekstində işlədəndə, daha aydın olsun deyə, adını userId qoyuruq.
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime
  createdAt; //Postları xronoloji sırada (ən yenidən köhnəyə) göstərmək üçün.
  final List<String> likedBy; // ← YENİ, likeCount əvəzinə

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    this.likedBy = const [],
  });

  int get likeCount =>
      likedBy.length; // ← hesablanan sahə, saxlanmır, hesablanır

  bool isLikedBy(String uid) => likedBy.contains(uid);

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userPhotoUrl,
    content,
    createdAt,
    likedBy,
  ];
}
