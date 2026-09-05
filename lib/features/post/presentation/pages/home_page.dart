import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injections.dart';
import '../../domain/entities/post_entity.dart';
import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    //bu context providerin parenti
    return BlocProvider(
      create: (_) =>
          getIt<
              PostCubit
            >() //bu özünün parentine dogru gedir,yuxariya dogru,ona gore valideyn yuxarda olmalidiki bu ona cata bilsin
            ..watchPosts(), //Bu, Dart-ın "cascade" operatorudur (..). Belə mənalandırılır: "əvvəlcə getIt<PostCubit>() ilə obyekt yarat, sonra elə həmin obyektin üzərində .watchPosts() metodunu çağır, sonra yenə həmin obyekti (dəyişməmiş halda) geri qaytar".
      child:
          const _HomeContent(), //Scaffold-u ayrı widget-ə çıxardıq ki, onun öz context-i BlocProvider-in daxilində olsun, context.read<PostCubit>() düzgün işləsin
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Nə düşünürsən?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_contentController.text.trim().isEmpty) {
                      return;
                    } //Boş mətn göndərilməsin deyə yoxlama edirik
                    context.read<PostCubit>().createPost(
                      //createPost çağırılır — indi context, _HomeContent-in ÖZ context-idir, BlocProvider-in daxilindədir, ona görə PostCubit tapılır
                      userId: currentUser.uid,
                      userName: currentUser.email ?? 'İstifadəçi',
                      content: _contentController.text.trim(),
                    );
                    _contentController
                        .clear(); //_contentController.clear() — inputu təmizləyirik ki, istifadəçi yenidən yaza bilsin,yenisin yaza bilmekcun
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PostFailure) {
                  return Center(child: Text(state.message));
                }

                if (state is PostLoaded) {
                  if (state.posts.isEmpty) {
                    return const Center(child: Text('Hələ post yoxdur'));
                  }
                  return ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post =
                          state.posts[index]; //siyahıdan tək-tək post çıxarmaq
                      return _PostCard(post: post);
                    },
                  );
                }

                return const SizedBox.shrink(); //Əgər user == null-dırsa, ekranda heç nə göstərmə.
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostEntity post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final liked = post.isLikedBy(currentUid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.userPhotoUrl != null
                      ? NetworkImage(post.userPhotoUrl!)
                      : null,
                  child: post.userPhotoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : null,
                    size: 20,
                  ),
                  onPressed: () =>
                      context.read<PostCubit>().toggleLike(post.id),
                ),
                Text('${post.likeCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*\
state
 │
 ├── PostLoading
 │      ↓
 │   Loading göstər
 │
 ├── PostFailure
 │      ↓
 │   Error göstər
 │
 ├── PostLoaded
 │      ↓
 │   Postları göstər
 │
 └── başqa bir state
        ↓
   SizedBox.shrink()//yeni burdaki hec bir state uygun gelmirse bos widget qaytar,PostState-lərin heç biri yuxarıdakı şərtlərə uyğun gəlməyəndə işləyir.
   */
