import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'app_config.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSendBird();
  runApp(const MyApp());
}

Future<void> initSendBird() async {
  if (!AppConfig.isConfigured) {
    throw Exception(
      'Sendbird App ID not configured. Please set SENDBIRD_APP_ID environment variable.',
    );
  }
  await SendbirdUIKit.init(
    appId: AppConfig.sendbirdAppId,
    useOGTag: true,
    useMarkAsUnread: true,
    choosePhoto: () async {
      return await _chooseFile(fileType: FileType.image);
    },
    chooseMedia: () async {
      return await _chooseFile(fileType: FileType.media);
    },
    chooseDocument: () async {
      return await _chooseFile(fileType: FileType.any);
    },
    takePhoto: () async {
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);
      if (photo?.path != null) {
        return FileInfo.fromFile(
          file: File(photo!.path),
          fileName: photo.name,
          mimeType: 'image/*',
        );
      }
      return null;
    },
    takeVideo: () async {
      final photo = await ImagePicker().pickVideo(source: ImageSource.camera);
      if (photo?.path != null) {
        return FileInfo.fromFile(
          file: File(photo!.path),
          fileName: photo.name,
          mimeType: 'video/*',
        );
      }
      return null;
    },
    useReaction: true,
    downloadFile: kIsWeb
        ? null
        : (fileUrl, fileName, downloadCompleted) async {
            await _downloadFile(fileUrl, fileName, downloadCompleted);
          },
  );
}

DownloadTask? backgroundDownloadTask;

StreamSubscription<TaskUpdate>? downloadSubscription;
Future<void> _downloadFile(
  String fileUrl,
  String? fileName,
  void Function() downloadCompleted,
) async {
  try {
    if (!kIsWeb && Platform.isAndroid) {
      await _getPermission(PermissionType.androidSharedStorage);
    }
    await _getPermission(PermissionType.notifications);

    String? newFileName = fileName;
    String? directory;

    if (Platform.isAndroid) {
      directory = '/storage/emulated/0/Download';
    } else {
      directory = (await getApplicationDocumentsDirectory()).path;
    }

    if (fileName != null && fileName.isNotEmpty) {
      bool isExists = false;
      int number = 2;
      final ext = _getFileExtension(fileName);
      final name = fileName.substring(0, fileName.length - ext.length);

      do {
        final filePath = '$directory/$newFileName';
        isExists = await File(filePath).exists();
        if (isExists) {
          newFileName = '$name ($number)$ext';
          number++;
        }
      } while (isExists);
    }

    backgroundDownloadTask = DownloadTask(
      url: fileUrl,
      filename: newFileName,
      baseDirectory: BaseDirectory.root,
      directory: directory,
      updates: Updates.statusAndProgress,
      retries: 3,
      allowPause: true,
    );

    debugPrint(
      '[FileDownloader][filePath()] ${await backgroundDownloadTask?.filePath()}',
    );

    downloadSubscription ??= FileDownloader().updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate():
          debugPrint('[FileDownloader][Status] ${update.status}');
          if (update.status == TaskStatus.complete) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              downloadCompleted();
            });
          }
          break;

        case TaskProgressUpdate():
          debugPrint('[FileDownloader][Progress] ${update.progress}');
          break;
      }
    });

    await FileDownloader().enqueue(backgroundDownloadTask!);
  } catch (e) {
    debugPrint('[FileDownloader][Error] ${e.toString()}');
  }
}

String _getFileExtension(String fileName) {
  try {
    return '.${fileName.split('.').last}';
  } catch (_) {
    return '';
  }
}

Future<FileInfo?> _chooseFile({required FileType fileType}) async {
  try {
    if (!kIsWeb && Platform.isAndroid) {
      await _getPermission(PermissionType.androidSharedStorage);
    }

    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowMultiple: false,
      compressionQuality: 0, // for Android 10
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (kIsWeb) {
        if (file.bytes != null) {
          return FileInfo.fromFileBytes(
            fileBytes: file.bytes,
            fileName: file.name,
            mimeType: 'image/*',
          );
        }
      } else {
        if (file.path != null) {
          return FileInfo.fromFile(
            file: File(file.path!),
            fileName: file.name,
            mimeType: 'image/*',
          );
        }
      }
    }
  } catch (e) {
    debugPrint('[FilePicker][Error] ${e.toString()}');
  }
  return null;
}

Future<void> _getPermission(PermissionType permissionType) async {
  var status = await FileDownloader().permissions.status(permissionType);
  if (status != PermissionStatus.granted) {
    if (await FileDownloader().permissions.shouldShowRationale(
      permissionType,
    )) {
      debugPrint('[FileDownloader] Showing some rationale');
    }
    status = await FileDownloader().permissions.request(permissionType);
    debugPrint('[FileDownloader] Permission for $permissionType was $status');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SendbirdUIKit.provider(
          child: Navigator(
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (context) => child!),
          ),
        );
      },
      initialRoute: Routes.home,
      getPages: AppPages.pages,
    );
  }
}
