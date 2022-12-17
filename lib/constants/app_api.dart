import 'package:ordering_services/models/user.dart';

const baseURL = 'https://omega.dohappit.com/api/';

User activeUser;

String invoiceToken = '';
String invoiceUrl = '';
String activeToken = '';
String activeUserToken = '';

bool offlineTooLong = false;

int userId;
int userSubscription;
String userPhone;
int userProfile;
String userName;
String userAddress;
int categoryId;

double amountToPay = 5000;

String waveLaunchUrl = '';
String waveAPIKEY = '';
int paymentIsOn = 0;
String playStoreUrl =
    "https://play.google.com/store/apps/details?id=com.omegatech.omegacaisse";
