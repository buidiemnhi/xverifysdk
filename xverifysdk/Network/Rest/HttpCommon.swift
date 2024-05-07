import Foundation

/// --------------------------------------
/// - name: HTTP Methods
/// --------------------------------------

public let httpRequestMethodGet: String = "GET"
public let httpRequestMethodHead: String = "HEAD"
public let httpRequestMethodDelete: String = "DELETE"
public let httpRequestMethodPost: String = "POST"
public let httpRequestMethodPut: String = "PUT"
public let httpRequestMethodPatch: String = "PATCH"

/// --------------------------------------
/// - name: HTTP Headers
/// --------------------------------------

public let httpRequestContentAll: String = "*/*"
public let httpRequestContentApplicationOctetStream: String = "application/octet-stream"
public let httpRequestContentBinaryOctetStream: String = "binary/octet-stream"
public let httpRequestContentEncodingGzip: String = "application/gzip"
public let httpRequestContentFormUrlEncoded: String = "application/x-www-form-urlencoded"
public let httpRequestContentImage: String = "image/*"
public let httpRequestContentJson: String = "application/json"
public let httpRequestContentKeepAlive: String = "Keep-Alive"
public let httpRequestContentMultipartFormData: String = "multipart/form-data"
public let httpRequestContentTextPlain: String = "text/plain"
public let httpRequestContentVimeoJson: String = "application/vnd.vimeo.*+json;version=3.4"
public let httpRequestContentXml: String = "application/xml; charset=utf-8"
public let httpRequestHeaderApplicationType: String = "application-type"
public let httpRequestHeaderAuthorization: String = "Authorization"
public let httpRequestHeaderConnection: String = "Connection"
public let httpRequestHeaderNameAccept: String = "Accept"
public let httpRequestHeaderNameContentEncoding: String = "Content-Encoding"
public let httpRequestHeaderNameContentLength: String = "Content-Length"
public let httpRequestHeaderNameContentType: String = "Content-Type"
public let httpRequestHeaderXApiKey: String = "X-API-KEY"
public let httpUrlRequestContentTypeVimeoJson: String = "application/vnd.vimeo.*+json;version=3.4"

/// --------------------------------------
/// - name: HTTP Status Codes
/// --------------------------------------

public let httpStatusCodeOk: Int = 200
public let httpStatusCodeCreated: Int = 201
public let httpStatusCodeAccepted: Int = 202
public let httpStatusCodeNoContent: Int = 204
public let httpStatusCodeMultipleChoices: Int = 300
public let httpStatusCodeUnauthorized: Int = 401
public let httpStatusCodeForbidden: Int = 403
public let httpStatusCodeNotFound: Int = 404
public let httpStatusCodeMethodNotAllowed: Int = 405
public let httpStatusCodeConflict: Int = 409
public let httpStatusCodeTimeout: Int = 408
public let httpStatusRequestTimeout: Int = -1001
public let httpStatusCodeConnectIssue: Int = -1020
public let httpStatusCodeConnectionOffline: Int = -1009
public let httpStatusCodeDeviceOffline: Int = -1005
public let httpStatusCodeInternalError: Int = 500
public let httpStatusAccountUnAuthorized: Int = 8000100

/// --------------------------------------
/// - name: Mime Types
/// --------------------------------------

public let httpMimeTypeTextPlain: String = "text/plain"
public let httpMimeTypeTextHtml: String = "text/html"
public let httpMimeTypeImageJpeg: String = "image/jpeg"
public let httpMimeTypeImagePng: String = "image/png"
public let httpMimeTypeAudioMpeg: String = "audio/mpeg"
public let httpMimeTypeAudioOgg: String = "audio/ogg"

/// --------------------------------------
/// - name: Scheme
/// --------------------------------------

public let httpScheme: String = "http"
public let httpSslScheme: String = "https"
