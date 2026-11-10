# AgroKaf

Aplicación móvil **sin conexión a internet** que detecta la **muerte descendente
del café (Phoma)** a partir de una foto de la hoja. Está pensada para los
caficultores de Taminango, Nariño (Colombia).

Proyecto de trabajo de grado — Dirkin Yohan Ojeda Rodríguez, Universidad
Cooperativa de Colombia.

> Esta herramienta es un apoyo y no reemplaza el diagnóstico de un técnico o
> agrónomo.

## Descargar la app (Android)

**[⬇️ Descargar AgroKaf.apk](https://github.com/DirkinYohan/AgroKaf/releases/latest/download/AgroKaf.apk)**

También puedes ver todas las versiones en la página de
[Releases](https://github.com/DirkinYohan/AgroKaf/releases).

Para instalarla: abre el archivo `.apk` en el celular y, si Android lo pide,
permite "instalar apps de fuentes desconocidas". Requiere Android 7.0 o
superior.

## Características principales

- **100 % sin internet.** La versión de release no tiene el permiso
  `INTERNET`; el modelo de inteligencia artificial se ejecuta en el celular con
  LiteRT (TensorFlow Lite).
- **Privacidad desde el diseño (Ley 1581 de 2012).** Pantalla de consentimiento
  antes de recoger cualquier dato, base de datos local cifrada (SQLCipher),
  fotos guardadas en una carpeta privada y sin datos EXIF/GPS, opción
  "Eliminar todos mis datos", sin analítica y sin copias en la nube.
- **Modelo v2.0.0:** MobileNetV3Large (aprendizaje por transferencia), TFLite
  en float16, con 3 clases: `healthy` (sana), `other` (otra) y `phoma`.
  `other` es una **clase de rechazo**: agrupa otras enfermedades, como la roya
  y el minador, e imágenes que no son hojas de café. El modelo se entrenó en
  un notebook de Google Colab (no incluido en este repositorio).
- **Plataformas:** Android 7.0+ (API 24) como prioridad; el código es
  compatible con iOS.

## Requisitos para desarrollar

| Herramienta | Versión usada |
|---|---|
| Flutter | 3.47 (stable), Dart 3.12 |
| Android SDK | 36, NDK 28.2.13676358, CMake 3.22.1 |
| Un celular con depuración USB, o un emulador | Android 7.0+ |

## Instalación del proyecto

```bash
flutter pub get
```

### 1. Archivos del modelo

Los tres archivos que genera el notebook de entrenamiento (Google Drive
`MyDrive/agrokaf/artifacts/` o `agrokaf_flutter_assets.zip`) van en
`assets/model/`:

```
assets/model/
├── labels.txt          # healthy, other, phoma (orden de salida del modelo)
├── model_fp16.tflite   # el clasificador
└── model_info.json     # contrato de preprocesamiento y métricas de prueba
```

Si faltan, la app funciona igual y muestra "Modelo no disponible".

### 2. Ejecutar en modo desarrollo

```bash
flutter run
```

### 3. Generar el APK

Un solo APK que funciona en todos los celulares (más pesado, ~130 MB):

```bash
flutter build apk --release
```

O un APK por arquitectura (mucho más liviano; en celulares modernos se instala
`app-arm64-v8a-release.apk`):

```bash
flutter build apk --release --split-per-abi
```

Los archivos quedan en `build/app/outputs/flutter-apk/`.

**Firma.** Si no existe `android/key.properties`, el APK de release se firma
con la clave de depuración (sirve para instalarlo en tu propio celular). Para
distribuirlo de forma oficial (por ejemplo en Google Play), crea un keystore y
el archivo `android/key.properties` (ambos están excluidos de git):

```properties
storePassword=...
keyPassword=...
keyAlias=agrokaf
storeFile=C:/ruta/a/agrokaf-release.jks
```

### 4. Regenerar el ícono y el splash nativo (solo si cambian las imágenes)

```bash
dart run flutter_launcher_icons
```

```bash
dart run flutter_native_splash:create
```

Las imágenes originales están en `assets/branding/`.

## Contrato de preprocesamiento de la IA

Se lee de `assets/model/model_info.json` y está implementado en
`lib/features/analysis/data/image_preprocessor.dart`:

1. Decodificar la imagen, aplicar su orientación EXIF y convertirla a RGB.
2. Redimensionar la imagen **completa** a 224×224 con interpolación
   **bilineal** (estirando: sin recorte central y sin bandas), igual que
   `tf.image.resize` de TensorFlow (centros de medio píxel) usado en el
   entrenamiento.
3. Tensor float32 `[1, 224, 224, 3]` con **valores de píxel sin normalizar,
   de 0 a 255** (no se divide entre 255: el modelo normaliza internamente).
4. Salida: softmax `[1, N]` en el orden de `labels.txt` (N = 3 en el modelo
   v2). Las clases se buscan siempre **por nombre**, nunca por posición.
5. Si la probabilidad más alta es menor que **0,70**, el resultado es
   "Resultado no concluyente — toma otra foto".

### Resultados que ve el usuario

| Salida del modelo (clase con mayor probabilidad, ≥ 0,70) | Resultado en la app |
|---|---|
| `healthy` | Hoja sana |
| `phoma` | Posible muerte descendente |
| `other` | No corresponde a muerte descendente (color gris neutro; la app **no** diagnostica otras enfermedades) |
| cualquier clase por debajo de 0,70 | Resultado no concluyente — toma otra foto |

La pantalla de resultado muestra la probabilidad de cada clase. Los análisis
guardados con el modelo v1 de 2 clases (sin probabilidad de `other`) se siguen
viendo bien: la base de datos se actualiza de la versión 1 a la 2 agregando la
columna opcional `other_prob`.

**Compatibilidad.** La app acepta el modelo de 2 clases (`healthy`, `phoma`) y
el de 3 clases (`healthy`, `other`, `phoma`). Si `labels.txt` trae una clase
desconocida, muestra **"Modelo incompatible"** en lugar de analizar; si faltan
los archivos, muestra **"Modelo no disponible"**.

El intérprete se carga una sola vez al iniciar y la inferencia corre en un
hilo en segundo plano (isolate). Antes de analizar se hace una revisión rápida
de la calidad de la foto (brillo y nitidez con la varianza del Laplaciano);
los umbrales están en `lib/core/constants/analysis_config.dart`.

## Arquitectura

Organizada por funcionalidades (feature-first), con Riverpod para el estado y
go_router con redirecciones según el estado guardado de la app
(onboarding → consentimiento de privacidad → perfil → inicio).

```
lib/
├── core/            tema (AppTheme, colores, espaciado, tipografía), widgets
│                    reutilizables, servicios (DatabaseService, ImageService,
│                    SettingsService, SecureKeyStore, PhotoPickerService),
│                    estado de la app, rutas y constantes
└── features/
    ├── splash/      arranque: base de datos y carga del modelo
    ├── onboarding/  3 páginas con un mismo widget de página
    ├── privacy/     pantalla de consentimiento y política de privacidad (Ley 1581)
    ├── profile/     crear/editar perfil, validación y foto
    ├── home/        saludo, tarjeta de análisis, estadísticas, recientes, consejos
    ├── analysis/    ClassifierService (LiteRT), preprocesamiento, revisión de
    │                calidad, vista previa/recorte y resultado
    ├── history/     lista, filtros, búsqueda, detalle y borrado
    └── settings/    ajustes, acerca de (métricas del modelo), borrar todos los datos
```

## Resumen de protección de datos

| Medida | Dónde |
|---|---|
| Consentimiento (fecha y versión de la política) antes de recoger datos | `features/privacy` |
| Base de datos SQLCipher con clave aleatoria de 256 bits en Android Keystore / iOS Keychain | `core/services/database_service.dart`, `secure_key_store.dart` |
| Fotos recodificadas sin EXIF/GPS, máximo 1280 px, en carpeta privada | `core/services/image_service.dart` |
| Permisos solo al momento de usarlos, con explicación y manejo de "denegado" | `core/widgets/photo_source_sheet.dart` |
| Borrar todos los datos (base de datos, fotos, claves y cachés) | Ajustes → Eliminar todos mis datos |
| `allowBackup="false"` y sin permiso `INTERNET` en release | `android/app/src/main/AndroidManifest.xml` |

Antes de publicar, configura el correo de contacto de privacidad en
`lib/core/constants/app_info.dart` (`privacyContactEmail`).

## Pruebas

```bash
flutter analyze
```

```bash
flutter test
```

Cubren: el contrato de preprocesamiento (valores bilineales de TensorFlow,
orden RGB, valores 0–255 sin normalizar, estiramiento), el `.tflite` real
ejecutándose con el preprocesamiento en Dart, el umbral y la asignación de
clases (incluida `other` y archivos de clases incompatibles), la actualización
de la base de datos de la versión 1 a la 2 con análisis antiguos, el flujo de
vista previa → resultado con el modelo real, la calidad de la foto, la
eliminación de EXIF/GPS, los repositorios de la base de datos (SQLite real
mediante FFI), las redirecciones de navegación, la validación del perfil, el
contraste WCAG de todos los pares de colores y pruebas de widgets de las
pantallas principales, incluidas las guías de accesibilidad de Flutter y el
texto al doble de tamaño.

El cifrado de SQLCipher necesita la librería nativa de Android/iOS, por lo
que se verifica en un dispositivo y no en las pruebas del computador.
