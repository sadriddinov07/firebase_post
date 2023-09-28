import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_post/models/message_model.dart';
import 'package:firebase_post/services/db_service.dart';

part 'post_event.dart';

part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitial()) {
    on<CreatePostEvent>(_createPost);
    on<PostIsPublicEvent>(_changePublic);
    on<DeletePostEvent>(_deletePost);
    on<UpdatePostEvent>(_updatePost);
    on<ViewImagePostEvent>(_viewImage);
    on<WriteCommentPostEvent>(_writeComment);
    on<DeleteCommentPostEvent>(_deleteComment);
    on<LikePostEvent>(_likePost);
    on<ViewPostEvent>(_viewPost);
  }

  void _createPost(CreatePostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result = await DBService.storePost(
        event.title, event.content, event.isPublic, event.file);
    if (result) {
      emit(CreatePostSuccess());
    } else {
      emit(const PostFailure("Something error, tyr again later!!!"));
    }
  }

  void _changePublic(PostIsPublicEvent event, Emitter emit) {
    emit(PostIsPublicState(event.isPublic));
  }

  void _viewImage(ViewImagePostEvent event, Emitter emit) {
    emit(ViewImagePostSuccess(event.file));
  }

  void _deletePost(DeletePostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result = await DBService.deletePost(event.postId);

    if (result) {
      emit(DeletePostSuccess());
    } else {
      emit(const PostFailure("Something error"));
    }
  }

  void _updatePost(UpdatePostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result = await DBService.updatePost(
        event.postId, event.title, event.content, event.isPublic);
    if (result) {
      emit(UpdatePostSuccess());
    } else {
      emit(const PostFailure("Something error, tyr again later!!!"));
    }
  }

  void _writeComment(WriteCommentPostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result =
        await DBService.writeMessage(event.postId, event.message, event.old);
    if (result) {
      emit(const WriteCommentPostSuccess());
    } else {
      emit(const PostFailure("Something error, tyr again later!!!"));
    }
  }

  void _deleteComment(DeleteCommentPostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result = await DBService.deleteMessage(
      event.postId,
      event.messageId,
      event.old,
    );
    if (result) {
      emit(const DeleteCommentPostSuccess());
    } else {
      emit(const PostFailure("Something error, tyr again later!!!"));
    }
  }

  void _likePost(LikePostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result = await DBService.likePost(
      event.postId,
      event.likedUserId,
      event.oldLikedUser,
    );
    if (result) {
      emit(const LikePostSuccess());
    } else {
      emit(const PostFailure("Something error, tyr again later!!!"));
    }
  }

  void _viewPost(ViewPostEvent event, Emitter emit) async {
    emit(PostLoading());
    final result = await DBService.viewPost(
      event.postId,
      event.viewedUserId,
      event.oldViewedUser,
    );
    if (result) {
      emit(const ViewPostSuccess());
    } else {
      emit(const PostFailure("Something error, tyr again later!!!"));
    }
  }
}
