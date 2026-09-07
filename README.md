# Connectly

Connectly — Flutter, Firebase və Clean Architecture ilə hazırlanan bir Social/Community App layihəsidir.

## Xüsusiyyətlər

- Email/Password ilə real qeydiyyat və giriş (Firebase Authentication)
- Profil yaratma (ad, username, bio, profil şəkli)
- Post paylaşma və real-time yenilənən feed
- Post bəyənmə (like/unlike)
- Tətbiq bağlanıb-açılanda login vəziyyətinin qorunması (auth persistence)

## Texnologiyalar

| Kateqoriya | Texnologiya |
|---|---|
| State Management | Cubit (`flutter_bloc`) |
| Backend | Firebase (Authentication, Firestore, Storage) |
| Dependency Injection | GetIt |
| Naviqasiya | GoRouter *(planlaşdırılıb)* |
| Local Storage | SharedPreferences, Hive  |
| REST API | Dio *(planlaşdırılıb)* |
| Arxitektura | Clean Architecture |

## Arxitektura

Layihə, hər feature üçün 3 qatlı Clean Architecture strukturunu izləyir:

```
lib/
├── app/
├── core/
│   ├── router/
│   ├── theme/
│   ├── constants/
│   └── di/
└── features/
    ├── auth/
    ├── profile/
    └── post/
```

Hər feature öz daxilində belə bölünür:

```
feature/
├── data/
│   ├── datasource/
│   ├── models/
│   └── repository/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

**Qatların məsuliyyəti:**
- **Presentation** — UI və state idarəetməsi (Cubit)
- **Domain** — biznes qaydaları (UseCase), Firebase-dən tamamilə asılı deyil
- **Data** — Firebase/API ilə əlaqə (DataSource, Repository implementasiyası)

## Qeydlər

- Firebase Storage, Google-un 2026-cı il fevral tarixli siyasət dəyişikliyinə görə **Blaze planı** tələb edir. Hazırda layihədə şəkil yükləmə funksionallığı strukturca hazırdır, lakin Blaze planına keçilənə qədər deaktiv saxlanılıb (`photoUrl` sahəsi `null` qalır).
- Firestore Security Rules hazırda **test mode**-dadır (development üçün). Production-a keçmədən əvvəl real qaydalar yazılmalıdır.

## Quraşdırma

```bash
flutter pub get
flutterfire configure
flutter run
```

Firebase Console-da Authentication (Email/Password) və Firestore Database-in aktivləşdirildiyindən əmin olun.
