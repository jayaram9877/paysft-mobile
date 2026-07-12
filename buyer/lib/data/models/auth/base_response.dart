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
  final Map<String, dynamic>? data;

  const ResponseDataObject({
    this.message,
    this.result,
    this.data,
  });

  factory ResponseDataObject.fromJson(Map<String, dynamic> json) {
    return ResponseDataObject(
      message: json['message'] as String?,
      result: json['result'] is int ? json['result'] as int : int.tryParse('${json['result']}'),
      data: json['data'] is Map<String, dynamic> ? (json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'result': result,
      'data': data,
    };
  }
}

