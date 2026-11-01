export 'disease_prediction.dart';
export 'disease_classifier_native.dart'
    if (dart.library.js_interop) 'disease_classifier_web.dart'
    if (dart.library.html) 'disease_classifier_web.dart';
