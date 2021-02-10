import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('repoName')
    ..addOption('orgName')
    ..addOption('testCmd')
    ..addOption('packageName');
  final parsedArgs = parser.parse(args);

  if (parsedArgs['repoName'] == null) {
    throw ProcessException('consumer_tests.dart', parsedArgs.arguments, '--repoName must be provided', -1);
  }

  if (parsedArgs['orgName'] == null) {
    throw ProcessException('consumer_tests.dart', parsedArgs.arguments, '--orgName must be provided', -1);
  }

  if (parsedArgs['testCmd'] == null) {
    throw ProcessException('consumer_tests.dart', parsedArgs.arguments, '--testCmd must be provided', -1);
  }

  final String repoName = parsedArgs['repoName'];
  final String orgName = parsedArgs['orgName'];
  final String testCmdStr = parsedArgs['testCmd'];
  final String packageName = parsedArgs['packageName'] ?? parsedArgs['repoName'];

  final reactGitSha = Process.runSync('git', ['rev-parse', 'HEAD']).stdout;
  print('Running $packageName tests while consuming react-dart at $reactGitSha ...\n');

  final rootDir = Directory.current;
  final tmpDir = Directory('consumer_testing_temp');
  if (tmpDir.existsSync()) {
    tmpDir.deleteSync(recursive: true);
  }
  tmpDir.createSync(recursive: true);
  Directory.current = tmpDir;
  final gitCloneProcess = await Process.start(
      'git',
      [
        'clone',
        'https://github.com/$orgName/$repoName.git',
        '--progress',
        '--branch',
        'master',
        '--depth',
        '1',
      ],
      mode: ProcessStartMode.inheritStdio);
  await gitCloneProcess.exitCode;
  Directory.current = Directory(repoName);
  final repoGitSha = Process.runSync('git', ['rev-parse', 'HEAD']).stdout;
  print('Successfully checked out $repoName master at $repoGitSha');
  final dependencyOverrides = '''
dependency_overrides:
  react:
    git:
      url: https://github.com/cleandart/react-dart.git
      ref: $reactGitSha
''';

  final pubspec = File('pubspec.yaml');
  var pubspecSrc = pubspec.readAsStringSync();
  pubspecSrc = pubspecSrc.replaceFirst('dependencies:', '${dependencyOverrides}dependencies:');
  pubspec.writeAsStringSync(pubspecSrc);
  final pubGetProcess = await Process.start('pub', ['get'], mode: ProcessStartMode.inheritStdio);
  await pubGetProcess.exitCode;

  final testArgs = testCmdStr.split(' ');
  final consumerTestProcess =
      await Process.start(testArgs[0], [...testArgs..removeAt(0)], mode: ProcessStartMode.inheritStdio);
  await consumerTestProcess.exitCode;

  Directory.current = rootDir;
  if (tmpDir.existsSync()) {
    tmpDir.deleteSync(recursive: true);
  }
}
