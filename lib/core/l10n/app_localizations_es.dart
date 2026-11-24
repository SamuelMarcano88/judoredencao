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
