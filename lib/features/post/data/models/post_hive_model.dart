import 'package:hive/hive.dart';

part 'post_hive_model.g.dart';

@HiveType(
  typeId: 0,
) //Bu, Hive-a deyir: "bu class-ı 0 nömrəli tip kimi tanı". Hər fərqli Hive class-ının unikal bir typeId-si olmalıdır (məsələn, gələcəkdə başqa bir Hive class yazsan, ona typeId: 1 verərsən).
class PostHiveModel extends HiveObject {
  //Hive object-Bu, Hive-ın öz əsas class-ıdır — bizim class-a, Hive-da saxlanmaq üçün lazım olan əlavə funksionallığı (məsələn .save(), .delete()) verir.
  @HiveField(
    0,
  ) //Hər sahəyə, unikal bir nömrə verilir. Bu, Firestore-un Map-i ilə fərqlidir — Hive, performans üçün, sahələri adları ilə deyil, nömrələri ilə saxlayır.
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String userName;

  @HiveField(3)
  final String? userPhotoUrl;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final List<String> likedBy;

  PostHiveModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    required this.likedBy,
  });
}
/*SharedPreferences — sadə dəyərlər üçündür (bool, String, int). Hive isə mürəkkəb obyektləri 
(bizim PostEntity kimi siyahıları) sürətli və effektiv şəkildə cihazda saxlamaq üçündür — bir növ, telefonun daxilində kiçik bir verilənlər bazasıdır.

İnternet var → Firestore-dan postlar gəlir (Stream) → Hive-a YAZILIR (cache)
İnternet yoxdur → Firestore-a çata bilmirik → Hive-dan OXUYURUQ (son bilinən postlar)

Bu, Hive-ın ən vacib məqamıdır: Hive, Map/JSON kimi format işlətmir (Firestore kimi) — o, 
Dart obyektlərini birbaşa saxlamaq üçün, 
hər class üçün bir "tərcüməçi" (TypeAdapter) tələb edir.


firestorede bele yadda saxlanilir 
"name" → "Aydan"
"age"  → 22
"city" → "Baku"

Niyə ayrıca PostHiveModel yaradırıq, PostEntity-ni birbaşa Hive-a yazmırıq?

Bu, çox vacib bir sualdır — məhz Clean Architecture-ın əsas fikri budur:

PostEntity (domain qatı) — heç bir xarici kitabxananı (Firebase, Hive) tanımamalıdır
PostHiveModel (data qatı) — Hive-a məxsus format, @HiveType/@HiveField annotasiyaları ilə "çirklənmiş"

Yəni @HiveField qaydanı müəyyən(nece yadda saxlamilsin bu hive model) edir, .g.dart isə o qaydanı tətbiq edən kodu yaradır.
*/