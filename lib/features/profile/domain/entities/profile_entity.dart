import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String
  uid; //ProfileEntity, UserEntity-dən ayrı bir sənəddir (Firestore-da), amma kimin profili olduğunu bilmək üçün yenə uid saxlamalıyıq — bu, Firestore-da sənədin ID-si kimi işləyəcək (users/{uid} kolleksiyasında).
  final String name;
  final String username;
  final String bio;
  final String?
  photoUrl; //Çünki profil şəkli opsionaldır — istifadəçi şəkil yükləməyə bilər,Register mərhələsində name null ola bilərdi (hələ doldurulmayıb). Amma Profile yaradılanda, istifadəçi bu məlumatları artıq doldurur — ona görə burada bunları məcburi (required) edirik. Real tətbiqdə, profil yaradılmazdan əvvəl istifadəçini bu formanı doldurmağa məcbur edəcəyik.

  const ProfileEntity({
    required this.uid,
    required this.name,
    required this.username,
    required this.bio,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, name, username, bio, photoUrl];
}
