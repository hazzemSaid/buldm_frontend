# Keep TensorFlow Lite and GPU delegates
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# FlatBuffers used by TFLite
-keep class com.google.flatbuffers.** { *; }

# Reduce noise
-dontwarn org.tensorflow.**
-dontwarn org.checkerframework.**
