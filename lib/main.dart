import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_sandbox/channel_list_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

import 'app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initSendBird();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SendbirdUIKit.provider(
          child: Navigator(
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (context) => child!),
          ),
        );
      },
      home: HomeScreen(), // Separate screen widget
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userIdController = TextEditingController(
      text: "sendbird_desk_agent_id_6991b122-6fb9-4415-83da-0c3331b7c9ac",
    );
    final TextEditingController userNameController = TextEditingController(
      text: "VIKO",
    );
    final TextEditingController accessTokenController = TextEditingController(
      text: "9da79284f51b09f4382efb3837420b968a76efab",
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sendbird Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userNameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accessTokenController,
                decoration: InputDecoration(
                  labelText: 'Access Token',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final userId = userIdController.text;
                  final userName = userNameController.text;
                  final accessToken = accessTokenController.text;
                  print(
                    'User ID: $userId, User Name: $userName, Access Token: $accessToken',
                  );

                  if (userId.isNotEmpty && userName.isNotEmpty) {
                    // Connect to Sendbird with the provided credentials
                    SendbirdUIKit.connect(
                          userId,
                          accessToken: accessToken,
                          nickname: userName,
                        )
                        .then((_) {
                          // On successful login, navigate to channel list
                          moveToChannelListScreen(context);
                        })
                        .catchError((error) {
                          // Show error message if login fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Login failed: ${error.toString()}',
                              ),
                            ),
                          );
                        });
                  } else {
                    // Show validation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID and User Name are required'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void moveToChannelListScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(body: ChannelListScreen()),
    ),
  );
}

void moveToGroupChannelCreateScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelCreateScreen(
            onChannelCreated: (channel) {
              moveToGroupChannelScreen(context, channel.channelUrl);
            },
          ),
        ),
      ),
    ),
  );
}

void moveToGroupChannelScreen(BuildContext context, String channelUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelScreen(
            channelUrl: channelUrl,
            onInfoButtonClicked: (messageCollectionNo) {
              final collection = SendbirdUIKit.getMessageCollection(
                messageCollectionNo,
              );
              moveToGroupChannelInfoScreen(
                context,
                channelUrl,
                messageCollectionNo,
              );
            },
            onListItemClicked: (channel, message) async {
              try {
                if (message is UserMessage && message.ogMetaData != null) {
                  final url = message.ogMetaData?.url;
                  if (url != null) {
                    print('Opening URL: $url');
                  }
                } else if (message is FileMessage &&
                    message.secureUrl.isNotEmpty) {
                  if (message.type != null) {
                    if (message.type!.startsWith('image')) {
                      print('Opening image: ${message.secureUrl}');
                    } else if (message.type!.startsWith('video')) {
                      print('Opening video: ${message.secureUrl}');
                    }
                  }
                } else if (message is AdminMessage) {
                  print('Admin message: ${message.message}');
                } else {
                  print('Unknown message type: $message');
                }
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            on1On1ChannelCreated: (p0) {
              print('1-on-1 channel created: $p0');
            },
            onChannelDeleted: (p0) {
              print('Channel deleted: $p0');
            },
            onMessageCollectionReady: (messageCollectionNo) {},
          ),
        ),
      ),
    ),
  );
}

void moveToGroupChannelInfoScreen(
  BuildContext context,
  String channelUrl,
  int messageCollectionNo,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelInformationScreen(
            messageCollectionNo: messageCollectionNo,
            onMembersButtonClicked: (p0) {
              moveToChannelMembersScreen(
                context,
                channelUrl,
                messageCollectionNo,
              );
            },
            onModerationsButtonClicked: (p0) {
              print('Moderations button clicked: $p0');
            },
            onChannelLeft: (p0) {
              print('Channel left: $p0');
            },
          ),
        ),
      ),
    ),
  );
}

void moveToChannelMembersScreen(
  BuildContext context,
  String channelUrl,
  int messageCollectionNo,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelMembersScreen(
            messageCollectionNo: messageCollectionNo, // Required parameter
            onInviteButtonClicked: (channel) {
              moveToInviteUsersScreen(context, messageCollectionNo);
            },
          ),
        ),
      ),
    ),
  );
}

void moveToInviteUsersScreen(BuildContext context, int messageCollectionNo) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelInviteScreen(
            messageCollectionNo: messageCollectionNo,
          ),
        ),
      ),
    ),
  );
}
