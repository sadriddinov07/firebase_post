import 'package:firebase_post/blocs/auth/auth_bloc.dart';
import 'package:firebase_post/pages/sign_in_page.dart';
import 'package:firebase_post/services/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showWarningDialog(BuildContext ctx) {
  final controller = TextEditingController();
  showDialog(
    context: ctx,
    builder: (context) {
      return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if(state is DeleteAccountSuccess) {
            Navigator.of(context).pop();
            if(ctx.mounted) {
              Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
            }
          }

          if(state is AuthFailure) {
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
                        decoration: const InputDecoration(
                            hintText: I18N.password),
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
                    child: const Text(I18N.cancel),),

                  /// #confirm #delete
                  ElevatedButton(
                    onPressed: () {
                      if(state is DeleteConfirmSuccess) {
                        context.read<AuthBloc>().add(DeleteAccountEvent(controller.text.trim()));
                      } else {
                        context.read<AuthBloc>().add(const DeleteConfirmEvent());
                      }
                    },
                    child: Text(state is DeleteConfirmSuccess
                        ? I18N.delete
                        : I18N.confirm),
                  ),
                ],
              ),

              if(state is AuthLoading) const Center(
                child: CircularProgressIndicator(),
              )
            ],
          );
        },
      );
    },
  );
}