class BaseResponse {
  final String? status;
  final String? message;
  final int? statusCode;
  final String? requestID;
  final dynamic responce;
  final ResponseDataObject? responceDataObject; // intentionally misspelled
  final String? activity;

  const BaseResponse({
    this.status,
    this.message,
    this.statusCode,
    this.requestID,
    this.responce,
    this.responceDataObject,
    this.activity,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      status: json['status'] as String?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : int.tryParse('${json['statusCode']}'),
      requestID: json['requestID'] as String?,
      responce: json['responce'],
      responceDataObject: json['responceDataObject'] is Map<String, dynamic>
          ? ResponseDataObject.fromJson(json['responceDataObject'] as Map<String, dynamic>)
          : null,
      activity: json['activity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'message': message,
      'statusCode': statusCode,
      'requestID': requestID,
      'responce': responce,
      'responceDataObject': responceDataObject?.toJson(),
      'activity': activity,
    };
  }
}

class ResponseDataObject {
  final String? message;
  final int? result;
  final Data? data;

  const ResponseDataObject({
    this.message,
    this.result,
    this.data,
  });

  factory ResponseDataObject.fromJson(Map<String, dynamic> json) {
    return ResponseDataObject(
      message: json['message'] as String?,
      result: json['result'] is int ? json['result'] as int : int.tryParse('${json['result']}'),
      data: json['data'] is Map<String, dynamic> ? Data.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'result': result,
      'data': data?.toJson(),
    };
  }
}

class Data {
  final bool? isVerified;
  final String? accessToken;
  final String? systemRole;
  final String? accessContext;
  final String? platformTeamRole;
  final List<dynamic>? builderContexts;

  const Data({
    this.isVerified,
    this.accessToken,
    this.systemRole,
    this.accessContext,
    this.platformTeamRole,
    this.builderContexts,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      isVerified: json['isVerified'] as bool?,
      accessToken: json['accessToken'] as String?,
      systemRole: json['systemRole'] as String?,
      accessContext: json['accessContext'] as String?,
      platformTeamRole: json['platformTeamRole'] as String?,
      builderContexts: json['builderContexts'] is List ? (json['builderContexts'] as List<dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isVerified': isVerified,
      'accessToken': accessToken,
      'systemRole': systemRole,
      'accessContext': accessContext,
      'platformTeamRole': platformTeamRole,
      'builderContexts': builderContexts,
    };
  }
}

