import 'dart:convert';

import 'package:firebase_post/blocs/post/post_bloc.dart';
import 'package:firebase_post/models/post_model.dart';
import 'package:firebase_post/pages/detail_page.dart';
import 'package:firebase_post/services/auth_service.dart';
import 'package:firebase_post/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostPage extends StatelessWidget {
  final Post post;

  PostPage({Key? key, required this.post}) : super(key: key);

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          if (post.isMe)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailPage(post: post),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Image(image: NetworkImage(post.imageUrl)),
          const SizedBox(
            height: 10,
          ),
          Text(
            post.username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            post.content,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: DBService.db.ref(Folder.post).child(post.id).onValue,
            builder: (context, snapshot) {
              Post current = snapshot.hasData
                  ? Post.fromJson(
                      jsonDecode(jsonEncode(snapshot.data!.snapshot.value))
                          as Map<String, Object?>,
                      isMe: AuthService.user.uid == post.userId)
                  : post;

              post.comments = current.comments;
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: current.comments.length,
                itemBuilder: (context, index) {
                  final msg = current.comments[index];

                  if (AuthService.user.uid == msg.userId) {
                    return Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      msg.message,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.read<PostBloc>().add(
                                              DeleteCommentPostEvent(
                                                post.id,
                                                msg.id,
                                                post.comments,
                                              ),
                                            );
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${msg.writtenAt.hour.toString().padLeft(2, "0")} : ${msg.writtenAt.minute.toString().padLeft(2, "0")}",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.username,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                        const SizedBox(width: 10),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.deepPurple,
                                          child: Text(
                                            msg.username.substring(0, 1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }


                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.message,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.lightBlueAccent,
                                        child: Text(
                                          msg.username.substring(0, 1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        msg.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      )
                                    ],
                                  ),
                                  Text(
                                    "${msg.writtenAt.hour.toString().padLeft(2, "0")} : ${msg.writtenAt.minute.toString().padLeft(2, "0")}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Write a comment...",
            suffixIcon: IconButton(
              onPressed: () {
                context.read<PostBloc>().add(
                      WriteCommentPostEvent(
                        post.id,
                        controller.text,
                        post.comments,
                      ),
                    );
                controller.clear();
              },
              icon: const Icon(
                Icons.send,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
