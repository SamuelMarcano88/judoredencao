// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MISIÓN PRÓXIMO CINTURÓN';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get createParentAccount => 'Crear cuenta de responsable';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get fullNameRequired => 'Ingresa tu nombre completo.';

  @override
  String get validEmailRequired => 'Ingresa un correo electrónico válido.';

  @override
  String get passwordMinimum =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get accountCreated => '¡Cuenta creada correctamente!';

  @override
  String get confirmEmailHint =>
      'Revisa tu correo para confirmar la cuenta y luego inicia sesión.';

  @override
  String get parentRegistrationHint =>
      'Regístrate como responsable para acompañar a tus hijos.';

  @override
  String get profileNotConfigured =>
      'Perfil no configurado. Contacta al administrador de la academia.';

  @override
  String get authResponseDecodeHint =>
      'Supabase no pudo completar el registro. Revisa SMTP y los Auth Logs del proyecto; el SMTP predeterminado solo envía a correos autorizados del equipo.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get configurationRequired => 'Se requiere configuración de Supabase';

  @override
  String get configurationHint => 'Informa SUPABASE_URL y SUPABASE_ANON_KEY.';

  @override
  String get welcome => '¡Hola!';

  @override
  String get adminDashboard => 'Panel administrativo';

  @override
  String get parentDashboard => 'Panel del responsable';

  @override
  String get studentDashboard => 'Panel del alumno';

  @override
  String get stageOne => 'Etapa 1: arquitectura y autenticación';

  @override
  String get invalidCredentials => 'Correo electrónico o contraseña inválidos.';

  @override
  String get unexpectedError => 'No fue posible completar la operación.';
}
