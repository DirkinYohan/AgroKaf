import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_button.dart';
import 'package:agrokaf/core/widgets/app_logo.dart';
import 'package:agrokaf/core/widgets/app_text_field.dart';
import 'package:agrokaf/core/widgets/photo_source_sheet.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/domain/profile_validators.dart';
import 'package:agrokaf/features/profile/presentation/providers/profile_providers.dart';
import 'package:agrokaf/features/profile/presentation/widgets/profile_avatar_picker.dart';

/// Creates the profile (first run) or edits it ([isEditing], from Perfil).
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key, this.isEditing = false});

  final bool isEditing;

  static const String createTitle = 'Personaliza tu perfil';
  static const String editTitle = 'Editar perfil';
  static const String continueLabel = 'Continuar';
  static const String saveLabel = 'Guardar cambios';

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  static const String _description =
      'Solo tu nombre y tu municipio son obligatorios. Todo se guarda en tu celular.';
  static const String _nameLabel = 'Tu nombre';
  static const String _nameHint = 'Ej.: María Pérez';
  static const String _farmLabel = 'Nombre de la finca';
  static const String _farmHint = 'Ej.: La Esperanza';
  static const String _municipalityLabel = 'Municipio';
  static const String _varietyLabel = 'Variedad de café';
  static const String _varietyHint = 'Selecciona una variedad';
  static const String _otherVarietyLabel = '¿Cuál variedad?';
  static const String _otherVarietyHint = 'Escribe la variedad';
  static const String _photoSheetTitle = 'Foto de perfil';
  static const String _saved = 'Perfil actualizado';
  static const String _saveError =
      'No pudimos guardar tu perfil. Inténtalo de nuevo.';
  static const String _invalidImage =
      'No pudimos leer esa foto. Prueba con otra.';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _farmController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController(
    text: UserProfile.defaultMunicipality,
  );
  final TextEditingController _otherVarietyController = TextEditingController();

  String? _variety;
  String? _savedPhotoPath;
  String? _pendingPhotoPath;
  bool _isSaving = false;
  bool _isLoading = false;

  /// Rebuilds the dropdown after async prefill (it reads `initialValue` once).
  int _formVersion = 0;

  String? get _photoPath => _pendingPhotoPath ?? _savedPhotoPath;
  bool get _isOtherVariety => _variety == UserProfile.coffeeVarietyOther;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _prefill();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmController.dispose();
    _municipalityController.dispose();
    _otherVarietyController.dispose();
    super.dispose();
  }

  Future<void> _prefill() async {
    setState(() => _isLoading = true);
    final UserProfile? existing = await ref
        .read(profileRepositoryProvider)
        .getProfile();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (existing == null) return;
      _nameController.text = existing.userName;
      _farmController.text = existing.farmName;
      _municipalityController.text = existing.municipality;
      final String variety = existing.coffeeVariety;
      if (variety.isEmpty || UserProfile.coffeeVarieties.contains(variety)) {
        _variety = variety.isEmpty ? null : variety;
      } else {
        _variety = UserProfile.coffeeVarietyOther;
        _otherVarietyController.text = variety;
      }
      _savedPhotoPath = existing.profileImagePath;
      _formVersion++;
    });
  }

  Future<void> _choosePhoto() async {
    if (_isSaving) return;
    final PhotoAction? action = await showPhotoSourceSheet(
      context,
      title: _photoSheetTitle,
      canRemove: _photoPath != null,
    );
    if (!mounted || action == null) return;
    if (action == PhotoAction.remove) {
      setState(() {
        _pendingPhotoPath = null;
        _savedPhotoPath = null;
      });
      return;
    }
    final String? path = await pickPhotoWithFeedback(
      context,
      ref.read(photoPickerServiceProvider),
      action == PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (mounted && path != null) setState(() => _pendingPhotoPath = path);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final UserProfile profile = UserProfile(
      userName: _nameController.text.trim(),
      farmName: _farmController.text.trim(),
      municipality: _municipalityController.text.trim(),
      coffeeVariety: _isOtherVariety
          ? _otherVarietyController.text.trim()
          : (_variety ?? ''),
      profileImagePath: _savedPhotoPath,
    );

    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .saveProfile(profile, newPhotoSourcePath: _pendingPhotoPath);
    } on InvalidImageException {
      _fail(_invalidImage);
      return;
    } catch (_) {
      _fail(_saveError);
      return;
    }
    if (!mounted) return;
    ref.invalidate(profileProvider);

    if (widget.isEditing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(_saved)));
      context.pop();
    } else {
      // The router moves on to Inicio when the state changes.
      ref.read(appStateProvider.notifier).markProfileCreated();
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool editing = widget.isEditing;
    return Scaffold(
      appBar: editing
          ? AppBar(title: const Text(ProfileSetupPage.editTitle))
          : null,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.contentMaxWidth,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      children: <Widget>[
                        if (!editing) ...<Widget>[
                          const Center(
                            child: AppLogo(
                              height: AppSizes.logoHeader,
                              framed: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            ProfileSetupPage.createTitle,
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        Text(_description, style: textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.lg),
                        ProfileAvatarPicker(
                          photoPath: _photoPath,
                          name: _nameController.text,
                          onPickImage: _choosePhoto,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: _nameLabel,
                          hint: _nameHint,
                          icon: Icons.person_outline_rounded,
                          controller: _nameController,
                          validator: ProfileValidators.name,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          maxLength: UserProfile.nameMaxLength,
                          autofillHints: const <String>[AutofillHints.name],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: _farmLabel,
                          hint: _farmHint,
                          icon: Icons.agriculture_outlined,
                          controller: _farmController,
                          isOptional: true,
                          textCapitalization: TextCapitalization.words,
                          maxLength: UserProfile.textMaxLength,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: _municipalityLabel,
                          icon: Icons.location_on_outlined,
                          controller: _municipalityController,
                          validator: ProfileValidators.municipality,
                          textCapitalization: TextCapitalization.words,
                          maxLength: UserProfile.textMaxLength,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppDropdownField<String>(
                          key: ValueKey<int>(_formVersion),
                          label: _varietyLabel,
                          hint: _varietyHint,
                          icon: Icons.eco_outlined,
                          isOptional: true,
                          items: UserProfile.coffeeVarieties,
                          itemLabel: (String v) => v,
                          value: _variety,
                          onChanged: (String? v) =>
                              setState(() => _variety = v),
                        ),
                        AnimatedSize(
                          duration: AppDurations.fast,
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: _isOtherVariety
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.md,
                                  ),
                                  child: AppTextField(
                                    label: _otherVarietyLabel,
                                    hint: _otherVarietyHint,
                                    icon: Icons.edit_outlined,
                                    controller: _otherVarietyController,
                                    validator: ProfileValidators.otherVariety,
                                    textInputAction: TextInputAction.done,
                                    maxLength: UserProfile.textMaxLength,
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: editing
                              ? ProfileSetupPage.saveLabel
                              : ProfileSetupPage.continueLabel,
                          icon: editing
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          trailingIcon: !editing,
                          isLoading: _isSaving,
                          expand: true,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
