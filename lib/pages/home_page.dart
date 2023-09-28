import 'package:firebase_post/blocs/auth/auth_bloc.dart';
import 'package:firebase_post/blocs/main/main_bloc.dart';
import 'package:firebase_post/blocs/post/post_bloc.dart';
import 'package:firebase_post/pages/detail_page.dart';
import 'package:firebase_post/pages/post_page.dart';
import 'package:firebase_post/pages/sign_in_page.dart';
import 'package:firebase_post/services/auth_service.dart';
import 'package:firebase_post/services/db_service.dart';
import 'package:firebase_post/services/strings.dart';
import 'package:firebase_post/views/warning_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SearchType type = SearchType.all;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<MainBloc>().add(const AllPublicPostEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (value) {
        if (value) {
          context.read<AuthBloc>().add(const GetUserEvent());
        }
      },
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutEvent());
            },
            icon: const Icon(Icons.logout),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: TextField(
              decoration: const InputDecoration(
                  hintText: "Search", border: OutlineInputBorder()),
              onChanged: (text) {
                final bloc = context.read<MainBloc>();
                debugPrint(text);
                if (text.isEmpty) {
                  if (type == SearchType.all) {
                    bloc.add(const AllPublicPostEvent());
                  } else {
                    bloc.add(const MyPostEvent());
                  }
                } else {
                  bloc.add(SearchMainEvent(text));
                }
              },
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final String name = state is GetUserSuccess
                    ? state.user.displayName!
                    : "accountName";
                final String email =
                    state is GetUserSuccess ? state.user.email! : "accountName";

                return UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                );
              },
            ),
            ListTile(
              onTap: () => showWarningDialog(context),
              title: const Text(I18N.deleteAccount),
            )
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }

              if (state is DeleteAccountSuccess && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }

              if (state is SignOutSuccess) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()));
              }
            },
          ),
          BlocListener<PostBloc, PostState>(
            listener: (context, state) {
              if (state is DeletePostSuccess || state is LikePostSuccess) {
                if (type == SearchType.all) {
                  context.read<MainBloc>().add(const AllPublicPostEvent());
                } else {
                  context.read<MainBloc>().add(const MyPostEvent());
                }
              }

              if (state is PostFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          )
        ],
        child: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final post = state.items[index];
                    return GestureDetector(
                      onLongPress: () {
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailPage(post: post)));
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PostPage(post: post)));
                      },
                      child: Card(
                        child: Column(
                          children: [
                            Container(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              width: MediaQuery.sizeOf(context).width,
                              height: MediaQuery.sizeOf(context).width - 30,
                              child: Image(
                                image: NetworkImage(post.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    post.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  Text(post.title),
                                ],
                              ),
                              subtitle: Text(post.content),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BlocBuilder<PostBloc, PostState>(
                                    builder: (context, state) {
                                      return IconButton(
                                        onPressed: () {
                                          context.read<PostBloc>().add(
                                                LikePostEvent(
                                                  post.id,
                                                  AuthService.user.uid,
                                                  post.likedUsers,
                                                ),
                                              );
                                        },
                                        color: post.likedUsers
                                                .contains(AuthService.user.uid)
                                            ? Colors.red
                                            : Colors.grey,
                                        icon: Icon(
                                          post.likedUsers.contains(
                                                  AuthService.user.uid)
                                              ? CupertinoIcons.heart_fill
                                              : CupertinoIcons.heart,
                                        ),
                                      );
                                    },
                                  ),
                                  if (post.isMe)
                                    IconButton(
                                      onPressed: () {
                                        context
                                            .read<PostBloc>()
                                            .add(DeletePostEvent(post.id));
                                      },
                                      color: Colors.red,
                                      icon: const Icon(Icons.delete),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (state is MainLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const DetailPage(),
          ));
        },
        child: const Icon(Icons.create_outlined),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            type = SearchType.all;
            context.read<MainBloc>().add(const AllPublicPostEvent());
          } else {
            type = SearchType.me;
            context.read<MainBloc>().add(const MyPostEvent());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "All"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
        ],
      ),
    );
  }
}
