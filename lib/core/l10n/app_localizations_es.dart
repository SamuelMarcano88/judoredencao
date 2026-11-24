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
  String get loginAsParent => 'Responsable';

  @override
  String get loginAsStudent => 'Alumno';

  @override
  String get username => 'Usuario';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get googleSignInUnavailable =>
      'No se pudo iniciar el acceso con Google.';

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
  String get students => 'Alumnos';

  @override
  String get parents => 'Responsables';

  @override
  String get myChildren => 'Mis hijos';

  @override
  String get addStudent => 'Registrar alumno';

  @override
  String get editStudent => 'Editar alumno';

  @override
  String get save => 'Guardar';

  @override
  String get createStudent => 'Crear perfil y acceso del alumno';

  @override
  String get studentDetails => 'Datos del alumno';

  @override
  String get studentAccessDetails => 'Acceso individual del alumno';

  @override
  String get studentName => 'Nombre completo del alumno';

  @override
  String get studentNameRequired => 'Ingresa el nombre completo del alumno.';

  @override
  String get birthDateOptional => 'Fecha de nacimiento (opcional)';

  @override
  String get studentPassword => 'Contraseña del alumno';

  @override
  String get usernameRules =>
      '3 a 30 caracteres: letras, números, punto, guion o guion bajo.';

  @override
  String get relationshipOptional => 'Parentesco (opcional)';

  @override
  String get parent => 'Responsable';

  @override
  String get selectParent => 'Selecciona un responsable.';

  @override
  String get noParentsForAssignment =>
      'Primero registra una cuenta de responsable.';

  @override
  String get noStudents => 'Todavía no hay alumnos registrados.';

  @override
  String get noParents => 'No se encontraron cuentas de responsables.';

  @override
  String get studentCreationFailed => 'No se pudo registrar al alumno';

  @override
  String get studentUpdateFailed => 'No se pudo actualizar al alumno';

  @override
  String get dashboardLoadError => 'No se pudieron cargar los datos';

  @override
  String get retry => 'Reintentar';

  @override
  String get stageOne => 'Etapa 1: arquitectura y autenticación';

  @override
  String get invalidCredentials => 'Correo electrónico o contraseña inválidos.';

  @override
  String get unexpectedError => 'No fue posible completar la operación.';
}
