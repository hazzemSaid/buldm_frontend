// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  Location get location => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<PredictedItem> get predictedItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get contactInfo => throw _privateConstructorUsedError;
  DateTime? get when => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call(
      {String title,
      String description,
      List<String>? images,
      Location location,
      String status,
      String category,
      List<PredictedItem> predictedItems,
      @JsonKey(name: 'user_id') String userId,
      String contactInfo,
      DateTime? when,
      DateTime createdAt,
      DateTime updatedAt});

  $LocationCopyWith<$Res> get location;
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? images = freezed,
    Object? location = null,
    Object? status = null,
    Object? category = null,
    Object? predictedItems = null,
    Object? userId = null,
    Object? contactInfo = null,
    Object? when = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      predictedItems: null == predictedItems
          ? _value.predictedItems
          : predictedItems // ignore: cast_nullable_to_non_nullable
              as List<PredictedItem>,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      contactInfo: null == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as String,
      when: freezed == when
          ? _value.when
          : when // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res> get location {
    return $LocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
          _$PostImpl value, $Res Function(_$PostImpl) then) =
      __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      List<String>? images,
      Location location,
      String status,
      String category,
      List<PredictedItem> predictedItems,
      @JsonKey(name: 'user_id') String userId,
      String contactInfo,
      DateTime? when,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $LocationCopyWith<$Res> get location;
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? images = freezed,
    Object? location = null,
    Object? status = null,
    Object? category = null,
    Object? predictedItems = null,
    Object? userId = null,
    Object? contactInfo = null,
    Object? when = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PostImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      predictedItems: null == predictedItems
          ? _value._predictedItems
          : predictedItems // ignore: cast_nullable_to_non_nullable
              as List<PredictedItem>,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      contactInfo: null == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as String,
      when: freezed == when
          ? _value.when
          : when // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl(
      {required this.title,
      required this.description,
      final List<String>? images,
      required this.location,
      required this.status,
      this.category = "other",
      final List<PredictedItem> predictedItems = const [],
      @JsonKey(name: 'user_id') required this.userId,
      this.contactInfo = "",
      this.when = null,
      required this.createdAt,
      required this.updatedAt})
      : _images = images,
        _predictedItems = predictedItems;

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Location location;
  @override
  final String status;
  @override
  @JsonKey()
  final String category;
  final List<PredictedItem> _predictedItems;
  @override
  @JsonKey()
  List<PredictedItem> get predictedItems {
    if (_predictedItems is EqualUnmodifiableListView) return _predictedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_predictedItems);
  }

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey()
  final String contactInfo;
  @override
  @JsonKey()
  final DateTime? when;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Post(title: $title, description: $description, images: $images, location: $location, status: $status, category: $category, predictedItems: $predictedItems, userId: $userId, contactInfo: $contactInfo, when: $when, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality()
                .equals(other._predictedItems, _predictedItems) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.contactInfo, contactInfo) ||
                other.contactInfo == contactInfo) &&
            (identical(other.when, when) || other.when == when) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      const DeepCollectionEquality().hash(_images),
      location,
      status,
      category,
      const DeepCollectionEquality().hash(_predictedItems),
      userId,
      contactInfo,
      when,
      createdAt,
      updatedAt);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(
      this,
    );
  }
}

abstract class _Post implements Post {
  const factory _Post(
      {required final String title,
      required final String description,
      final List<String>? images,
      required final Location location,
      required final String status,
      final String category,
      final List<PredictedItem> predictedItems,
      @JsonKey(name: 'user_id') required final String userId,
      final String contactInfo,
      final DateTime? when,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  List<String>? get images;
  @override
  Location get location;
  @override
  String get status;
  @override
  String get category;
  @override
  List<PredictedItem> get predictedItems;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get contactInfo;
  @override
  DateTime? get when;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  String get type => throw _privateConstructorUsedError;
  List<double> get coordinates => throw _privateConstructorUsedError;
  String get placeName => throw _privateConstructorUsedError;

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call({String type, List<double> coordinates, String placeName});
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? coordinates = null,
    Object? placeName = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<double>,
      placeName: null == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
          _$LocationImpl value, $Res Function(_$LocationImpl) then) =
      __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, List<double> coordinates, String placeName});
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
      _$LocationImpl _value, $Res Function(_$LocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? coordinates = null,
    Object? placeName = null,
  }) {
    return _then(_$LocationImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<double>,
      placeName: null == placeName
          ? _value.placeName
          : placeName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  const _$LocationImpl(
      {this.type = "Point",
      required final List<double> coordinates,
      this.placeName = ""})
      : _coordinates = coordinates;

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  final List<double> _coordinates;
  @override
  List<double> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  @JsonKey()
  final String placeName;

  @override
  String toString() {
    return 'Location(type: $type, coordinates: $coordinates, placeName: $placeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type,
      const DeepCollectionEquality().hash(_coordinates), placeName);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(
      this,
    );
  }
}

abstract class _Location implements Location {
  const factory _Location(
      {final String type,
      required final List<double> coordinates,
      final String placeName}) = _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  String get type;
  @override
  List<double> get coordinates;
  @override
  String get placeName;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PredictedItem _$PredictedItemFromJson(Map<String, dynamic> json) {
  return _PredictedItem.fromJson(json);
}

/// @nodoc
mixin _$PredictedItem {
  String get label => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;

  /// Serializes this PredictedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PredictedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictedItemCopyWith<PredictedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictedItemCopyWith<$Res> {
  factory $PredictedItemCopyWith(
          PredictedItem value, $Res Function(PredictedItem) then) =
      _$PredictedItemCopyWithImpl<$Res, PredictedItem>;
  @useResult
  $Res call({String label, double confidence, String category});
}

/// @nodoc
class _$PredictedItemCopyWithImpl<$Res, $Val extends PredictedItem>
    implements $PredictedItemCopyWith<$Res> {
  _$PredictedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? confidence = null,
    Object? category = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PredictedItemImplCopyWith<$Res>
    implements $PredictedItemCopyWith<$Res> {
  factory _$$PredictedItemImplCopyWith(
          _$PredictedItemImpl value, $Res Function(_$PredictedItemImpl) then) =
      __$$PredictedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double confidence, String category});
}

/// @nodoc
class __$$PredictedItemImplCopyWithImpl<$Res>
    extends _$PredictedItemCopyWithImpl<$Res, _$PredictedItemImpl>
    implements _$$PredictedItemImplCopyWith<$Res> {
  __$$PredictedItemImplCopyWithImpl(
      _$PredictedItemImpl _value, $Res Function(_$PredictedItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PredictedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? confidence = null,
    Object? category = null,
  }) {
    return _then(_$PredictedItemImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictedItemImpl implements _PredictedItem {
  const _$PredictedItemImpl(
      {required this.label, required this.confidence, this.category = "other"});

  factory _$PredictedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictedItemImplFromJson(json);

  @override
  final String label;
  @override
  final double confidence;
  @override
  @JsonKey()
  final String category;

  @override
  String toString() {
    return 'PredictedItem(label: $label, confidence: $confidence, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictedItemImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, confidence, category);

  /// Create a copy of PredictedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictedItemImplCopyWith<_$PredictedItemImpl> get copyWith =>
      __$$PredictedItemImplCopyWithImpl<_$PredictedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictedItemImplToJson(
      this,
    );
  }
}

abstract class _PredictedItem implements PredictedItem {
  const factory _PredictedItem(
      {required final String label,
      required final double confidence,
      final String category}) = _$PredictedItemImpl;

  factory _PredictedItem.fromJson(Map<String, dynamic> json) =
      _$PredictedItemImpl.fromJson;

  @override
  String get label;
  @override
  double get confidence;
  @override
  String get category;

  /// Create a copy of PredictedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictedItemImplCopyWith<_$PredictedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
