part of 'post_bloc.dart';

class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

class LoadPostEvent extends PostEvent {
  final String? category;
  final String? status;
  final String? userId;
  final String? searchQuery;
  final int limit;
  final int page;

  const LoadPostEvent({
    this.category,
    this.status,
    this.userId,
    this.searchQuery,
    required this.limit,
    required this.page,
  });

  @override
  List<Object?> get props =>
      [category, status, userId, searchQuery, limit, page];
}

class LoadMorePostsEvent extends PostEvent {}

class AddPostEvent extends PostEvent {
  final PostModel post;
  final String token;
  final List<File> imageFiles; // بدل File imageFile

  const AddPostEvent(
      {required this.post, required this.token, required this.imageFiles});

  @override
  List<Object?> get props => [post, token, imageFiles];

  @override
  bool? get stringify => true;
}

class uploadPostEvent extends PostEvent {
  final UploadablePostModel post;

  const uploadPostEvent({required this.post});

  @override
  List<Object?> get props => [post];

  @override
  bool? get stringify => true;
}

class DeletePostEvent extends PostEvent {
  final PostEntity post;

  const DeletePostEvent({required this.post});
  @override
  List<Object?> get props => [post];

  @override
  bool? get stringify => true;
}

class FilterPostEvent extends PostEvent {
  final String category;

  const FilterPostEvent({required this.category});

  @override
  List<Object?> get props => [category];

  @override
  bool? get stringify => true;
}

class SearchPostEvent extends PostEvent {
  final String query;

  const SearchPostEvent({required this.query});

  @override
  List<Object?> get props => [query];

  @override
  bool? get stringify => true;
}

class SortPostEvent extends PostEvent {
  final String criteria;

  const SortPostEvent({required this.criteria});

  @override
  List<Object?> get props => [criteria];

  @override
  bool? get stringify => true;
}

class userbyid extends PostEvent {
  final String userId;

  const userbyid({required this.userId});

  @override
  List<Object?> get props => [userId];

  @override
  bool? get stringify => true;
}
