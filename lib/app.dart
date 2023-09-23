import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_post/blocs/auth/auth_bloc.dart';
import 'package:firebase_post/blocs/main/main_bloc.dart';
import 'package:firebase_post/blocs/post/post_bloc.dart';
import 'package:firebase_post/pages/home_page.dart';
import 'package:firebase_post/pages/sign_in_page.dart';
import 'package:firebase_post/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<PostBloc>(create: (_) => PostBloc()),
        BlocProvider<MainBloc>(create: (_) => MainBloc()),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: StreamBuilder<User?>(
          initialData: null,
          stream: AuthService.auth.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.data != null) {
              return const HomePage();
            } else {
              return SignInPage();
            }
          },
        ),
      ),
    );
  }
}