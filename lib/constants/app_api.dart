import 'package:ordering_services/models/user.dart';

const baseURL = 'https://omega.dohappit.com/api/';

User activeUser;

String invoiceToken = '';
String invoiceUrl = '';
String activeToken = '';
String activeUserToken = '';

int userId;
int userSubscription;
String userPhone;
int userProfile;
String userName;
String userAddress;

String appStoreUrl = "https://apps.apple.com/us/app/sendkwe/id1600051085";
String playStoreUrl =
    "https://play.google.com/store/apps/details?id=com.rasool.sendkwe";

String paydunyaMasterKey =
    'ktGGfOBC-bXKN-M0Hg-BiAt-wH5Jd08yw4WW'; // 'WgedBb3h-KMie-lsNN-XCTj-jMUg1tcPkHs8';
String paydunyaPrivateKey =
    'live_private_2otWQ954DnvfE8X0iIpPK3Kl5c4'; // 'live_private_LjGl1jBePaFHmJMPQcBsYWoNWgg';
String paydunyaToken = 'ilaUrfT6Tqdwm0aL3gLw'; // '7v1HHSJSbyT2kR8xjrkr';
String cancelUrl = baseURL + 'api/payment/cancel';
String returnUrl = baseURL + 'api/payment/return';
String callbackUrl = baseURL + 'api/callback';
