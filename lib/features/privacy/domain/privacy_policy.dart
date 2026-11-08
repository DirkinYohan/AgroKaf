import 'package:flutter/material.dart';

import 'package:agrokaf/core/constants/app_info.dart';

/// One section of the privacy policy.
class PolicySection {
  const PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// Privacy policy of AgroKaf (Ley 1581 de 2012 — Habeas Data, Colombia).
///
/// Plain, simple Spanish so farmers can understand it.
class PrivacyPolicy {
  PrivacyPolicy._();

  static const String title = 'Política de privacidad';

  static String get _contact => AppInfo.privacyContactEmail.isEmpty
      ? 'a través de la ${AppInfo.university}'
      : 'escribiendo a ${AppInfo.privacyContactEmail}';

  /// Short version shown on the consent screen.
  static const List<PolicySection> summary = <PolicySection>[
    PolicySection(
      icon: Icons.person_outline_rounded,
      title: 'Qué datos guardamos',
      body:
          'Tu nombre, tu finca, tu municipio, la variedad de café, tu foto de '
          'perfil (si la agregas) y las fotos de las hojas que analices.',
    ),
    PolicySection(
      icon: Icons.track_changes_rounded,
      title: 'Para qué los usamos',
      body:
          'Solo para personalizar la app, analizar tus hojas y guardar tu '
          'historial. Nunca para publicidad.',
    ),
    PolicySection(
      icon: Icons.phone_android_rounded,
      title: 'Todo se queda en tu celular',
      body:
          'Tus datos se guardan cifrados únicamente en este celular. AgroKaf '
          'no usa internet y no envía nada a ninguna parte.',
    ),
    PolicySection(
      icon: Icons.verified_user_outlined,
      title: 'Tú tienes el control',
      body:
          'Puedes ver, corregir o borrar tus datos cuando quieras desde '
          'Perfil y Ajustes.',
    ),
  ];

  /// Full text shown on the policy screen.
  static List<PolicySection> get sections => <PolicySection>[
    PolicySection(
      icon: Icons.badge_outlined,
      title: '1. Responsable',
      body:
          'AgroKaf es un proyecto de trabajo de grado de ${AppInfo.author}, '
          'estudiante de la ${AppInfo.university}. Es el responsable del '
          'tratamiento de tus datos. Puedes contactarlo $_contact.',
    ),
    const PolicySection(
      icon: Icons.person_outline_rounded,
      title: '2. Datos que guardamos',
      body:
          '• Nombre (obligatorio) y municipio.\n'
          '• Nombre de la finca, variedad de café y foto de perfil (opcionales).\n'
          '• Fotos de hojas de café, el resultado de cada análisis, la fecha y '
          'las notas o el lote que tú escribas.\n'
          'No pedimos datos sensibles, documentos de identidad, teléfono ni '
          'ubicación.',
    ),
    const PolicySection(
      icon: Icons.track_changes_rounded,
      title: '3. Para qué los usamos',
      body:
          'Para personalizar la aplicación, analizar las fotos con '
          'inteligencia artificial dentro de tu celular y mostrarte tu '
          'historial. No vendemos, no compartimos y no usamos tus datos para '
          'publicidad.',
    ),
    const PolicySection(
      icon: Icons.lock_outline_rounded,
      title: '4. Dónde y cómo se guardan',
      body:
          'Todo se guarda solo en este celular, en una base de datos cifrada '
          '(SQLCipher, AES-256). La clave se guarda en el almacenamiento '
          'seguro del sistema. Las fotos se guardan en la carpeta privada de '
          'la app y se les borran los datos ocultos, como la ubicación GPS. '
          'La aplicación no tiene permiso para usar internet y no hace copias '
          'en la nube.',
    ),
    const PolicySection(
      icon: Icons.photo_camera_outlined,
      title: '5. Cámara y galería',
      body:
          'AgroKaf solo usa la cámara o la galería cuando tú lo pides, para '
          'tomar o elegir una foto. Si niegas el permiso, puedes seguir '
          'usando el resto de la app.',
    ),
    const PolicySection(
      icon: Icons.verified_user_outlined,
      title: '6. Tus derechos (Ley 1581 de 2012)',
      body:
          'Tienes derecho a conocer, actualizar, corregir y borrar tus datos, '
          'y a retirar tu autorización:\n'
          '• Ver y corregir: en Perfil > Editar perfil.\n'
          '• Borrar todo y retirar la autorización: en Ajustes > Eliminar '
          'todos mis datos.\n'
          'También puedes presentar una queja ante la Superintendencia de '
          'Industria y Comercio (SIC).',
    ),
    const PolicySection(
      icon: Icons.schedule_rounded,
      title: '7. Por cuánto tiempo',
      body:
          'Tus datos se guardan hasta que los borres desde la app o '
          'desinstales AgroKaf. Al desinstalarla, el sistema borra todo.',
    ),
    const PolicySection(
      icon: Icons.update_rounded,
      title: '8. Cambios en esta política',
      body:
          'Si esta política cambia, la app te mostrará la nueva versión y te '
          'pedirá aceptarla de nuevo antes de seguir.',
    ),
  ];
}
