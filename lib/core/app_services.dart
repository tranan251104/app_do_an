import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/firebase_phone_auth_service.dart';
import '../features/beneficiary/data/beneficiary_repository.dart';
import '../features/catalog/data/catalog_repository.dart';
import '../features/notification/data/notification_repository.dart';
import '../features/payment/data/payment_repository.dart';
import '../features/qr/data/qr_repository.dart';
import '../features/transaction/data/transaction_repository.dart';
import '../features/transfer/data/transfer_repository.dart';
import '../features/user/data/user_repository.dart';
import '../features/wallet/data/wallet_repository.dart';
import 'network/api_client.dart';
import 'storage/token_storage.dart';

class AppServices {
  AppServices._();

  static const tokens = TokenStorage();
  static final api = ApiClient(tokens);

  static final phoneAuth = FirebasePhoneAuthService();
  static final auth = AuthRepository(api, tokens, phoneAuth);
  static final user = UserRepository(api);
  static final wallet = WalletRepository(api);
  static final transfer = TransferRepository(api);
  static final payment = PaymentRepository(api);
  static final transaction = TransactionRepository(api);
  static final beneficiary = BeneficiaryRepository(api);
  static final notification = NotificationRepository(api);
  static final catalog = CatalogRepository(api);
  static final qr = QrRepository(api);
}
