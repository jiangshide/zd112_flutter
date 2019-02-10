import 'dart:io';

class UploadFileInfo {
  UploadFileInfo(this.file, this.fileName, {this.contentType}):bytes=null;

  UploadFileInfo.fromBytes(this.bytes, this.fileName,{this.contentType}):file=null;

  final File file;

  final List<int> bytes;

  final String fileName;

  ContentType contentType = ContentType.binary;
}