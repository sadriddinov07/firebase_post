import 'package:firebase_post/blocs/auth/auth_bloc.dart';
import 'package:firebase_post/blocs/main/main_bloc.dart';
import 'package:firebase_post/blocs/post/post_bloc.dart';
import 'package:firebase_post/pages/detail_page.dart';
import 'package:firebase_post/pages/sign_in_page.dart';
import 'package:firebase_post/services/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<MainBloc>().add(
          const SortDataEvent(true),
        );
  }

  void showWarningDialog(BuildContext ctx) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (context) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is DeleteAccountSuccess) {
              Navigator.of(context).pop();
              if (ctx.mounted) {
                Navigator.of(ctx).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()));
              }
            }

            if (state is AuthFailure) {
              Navigator.of(context).pop();
              Navigator.of(ctx).pop();
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                AlertDialog(
                  title: const Text(I18N.deleteAccount),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state is DeleteConfirmSuccess
                          ? I18N.requestPassword
                          : I18N.deleteAccountWarning),
                      const SizedBox(
                        height: 10,
                      ),
                      if (state is DeleteConfirmSuccess)
                        TextField(
                          controller: controller,
                          decoration:
                              const InputDecoration(hintText: I18N.password),
                        ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    /// #cancel
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(I18N.cancel),
                    ),

                    /// #confirm #delete
                    ElevatedButton(
                      onPressed: () {
                        if (state is DeleteConfirmSuccess) {
                          context
                              .read<AuthBloc>()
                              .add(DeleteAccountEvent(controller.text.trim()));
                        } else {
                          context
                              .read<AuthBloc>()
                              .add(const DeleteConfirmEvent());
                        }
                      },
                      child: Text(state is DeleteConfirmSuccess
                          ? I18N.delete
                          : I18N.confirm),
                    ),
                  ],
                ),
                if (state is AuthLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        onDrawerChanged: (value) {
          if (value) {
            context.read<AuthBloc>().add(const GetUserEvent());
          }
        },
        appBar: AppBar(
          toolbarHeight: 80,
          title: TextField(
            controller: controller,
            onChanged: (value) {
              context.read<MainBloc>().add(
                    SearchDataEvent(value),
                  );
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(.075),
              hintText: "Search",
              suffixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.red),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const SignOutEvent(),
                    );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                child: TextButton(
                  onPressed: () {
                    context.read<MainBloc>().add(const SortDataEvent(true));
                  },
                  child: const Text("All"),
                ),
              ),
              Tab(
                child: TextButton(
                  onPressed: () {
                    context.read<MainBloc>().add(const SortDataEvent(false));
                  },
                  child: const Text("Private"),
                ),
              ),
            ],
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
                  final String email = state is GetUserSuccess
                      ? state.user.email!
                      : "accountName";

                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                    ),
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
                if (state is DeletePostSuccess) {
                  // context.read<MainBloc>().add(const GetAllDataEvent());
                  context.read<MainBloc>().add(
                        const SortDataEvent(true),
                      );
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
                      return Card(
                        child: ListTile(
                          onLongPress: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DetailPage(post: post)));
                          },
                          leading: Text(
                            post.isPublic ? "Public" : "Private",
                            style: TextStyle(
                              color:
                                  post.isPublic ? Colors.green : Colors.yellow,
                            ),
                          ),
                          title: Text(post.title),
                          subtitle: Text(post.content),
                          trailing: IconButton(
                            onPressed: () {
                              context
                                  .read<PostBloc>()
                                  .add(DeletePostEvent(post.id));
                            },
                            color: Colors.red,
                            icon: const Icon(Icons.delete),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DetailPage(),
              ),
            );
          },
          child: const Icon(Icons.create_outlined),
        ),
      ),
    );
  }
}
