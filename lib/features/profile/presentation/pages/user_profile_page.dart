import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/primary_pill_button.dart';
import 'package:agrokaf/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrokaf/features/profile/presentation/widgets/profile_avatar_picker.dart';
import 'package:agrokaf/features/profile/presentation/widgets/profile_text_field.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  static const double _contentMaxWidth = 520;
  static const String _title = 'Personaliza tu perfil';
  static const String _description =
      'Estos datos nos ayudar\u00e1n a personalizar tu experiencia '
      'dentro de AgroKaf.';
  static const String _nameLabel = 'Nombre del usuario';
  static const String _nameHint = 'Ingresa tu nombre';
  static const String _farmLabel = 'Nombre de la finca';
  static const String _farmHint = 'Ingresa el nombre de tu finca';
  static const String _municipalityLabel = 'Municipio';
  static const String _municipalityHint = 'Ingresa tu municipio';
  static const String _varietyLabel = 'Variedad de caf\u00e9';
  static const String _varietyHint = 'Selecciona una variedad';
  static const String _otherVarietyHint = 'Escribe la variedad de caf\u00e9';
  static const String _continueLabel = 'Continuar';
  static const String _savingLabel = 'Guardando perfil...';
  static const String _nameRequiredError = 'Ingresa tu nombre';
  static const String _nameMinLengthError =
      'Tu nombre debe tener al menos 2 caracteres';
  static const String _farmRequiredError = 'Ingresa el nombre de tu finca';
  static const String _municipalityRequiredError = 'Ingresa tu municipio';
  static const String _varietyRequiredError =
      'Selecciona una variedad de caf\u00e9';
  static const String _otherVarietyRequiredError =
      'Escribe la variedad de caf\u00e9';
  static const String _photoRequiredError = 'Selecciona una foto de perfil';
  static const String _saveErrorMessage =
      'No se pudo guardar el perfil. Int\u00e9ntalo nuevamente.';
  static const int _nameMinLength = 2;

  final ProfileRepository _repository = ProfileRepositoryImpl();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _farmController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _otherVarietyController = TextEditingController();

  XFile? _pendingPhotoFile;
  String? _savedPhotoPath;
  bool _isNameValid = false;
  bool _isFarmValid = false;
  bool _isMunicipalityValid = false;
  bool _isCustomVarietyMode = false;
  bool _isPredefinedVarietyValid = false;
  bool _isOtherVarietyValid = true;
  bool _isSaving = false;

  String? get _displayPhotoPath => _pendingPhotoFile?.path ?? _savedPhotoPath;
  bool get _hasPhoto =>
      _displayPhotoPath != null && _displayPhotoPath!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _farmController.addListener(_onFarmChanged);
    _municipalityController.addListener(_onMunicipalityChanged);
    _varietyController.addListener(_onPredefinedVarietyChanged);
    _otherVarietyController.addListener(_onOtherVarietyChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadExistingForPrefillIfAny();
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _farmController.removeListener(_onFarmChanged);
    _farmController.dispose();
    _municipalityController.removeListener(_onMunicipalityChanged);
    _municipalityController.dispose();
    _varietyController.removeListener(_onPredefinedVarietyChanged);
    _varietyController.dispose();
    _otherVarietyController.removeListener(_onOtherVarietyChanged);
    _otherVarietyController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingForPrefillIfAny() async {
    if (!mounted) return;
    try {
      final UserProfile? existing = await _repository.getProfile();
      if (!mounted || existing == null) return;
      final bool hasAnyText =
          existing.userName.trim().isNotEmpty ||
          existing.farmName.trim().isNotEmpty ||
          existing.municipality.trim().isNotEmpty ||
          existing.coffeeVariety.trim().isNotEmpty;
      if (!hasAnyText) return;
      final bool isPredefined = UserProfile.coffeeVarieties.contains(
        existing.coffeeVariety,
      );
      setState(() {
        _nameController.text = existing.userName;
        _farmController.text = existing.farmName;
        _municipalityController.text = existing.municipality;
        if (isPredefined) {
          _varietyController.text = existing.coffeeVariety;
          _isCustomVarietyMode = false;
          _otherVarietyController.clear();
        } else {
          _isCustomVarietyMode = true;
          _otherVarietyController.text = existing.coffeeVariety;
          _varietyController.clear();
        }
        _savedPhotoPath = existing.profileImagePath;
        _pendingPhotoFile = null;
      });
    } catch (_) {}
  }

  void _onNameChanged() {
    final bool valid = _validateName(_nameController.text) == null;
    if (valid != _isNameValid && mounted) {
      setState(() => _isNameValid = valid);
    }
  }

  void _onFarmChanged() {
    final bool valid = _validateFarm(_farmController.text) == null;
    if (valid != _isFarmValid && mounted) {
      setState(() => _isFarmValid = valid);
    }
  }

  void _onMunicipalityChanged() {
    final bool valid =
        _validateMunicipality(_municipalityController.text) == null;
    if (valid != _isMunicipalityValid && mounted) {
      setState(() => _isMunicipalityValid = valid);
    }
  }

  void _onPredefinedVarietyChanged() {
    final bool valid = _isCustomVarietyMode
        ? _isPredefinedVarietyValid
        : _validatePredefinedVariety(_varietyController.text) == null;
    if (valid != _isPredefinedVarietyValid && mounted) {
      setState(() => _isPredefinedVarietyValid = valid);
    }
  }

  void _onOtherVarietyChanged() {
    if (!_isCustomVarietyMode) return;
    final bool valid =
        _validateOtherVariety(_otherVarietyController.text) == null;
    if (valid != _isOtherVarietyValid && mounted) {
      setState(() => _isOtherVarietyValid = valid);
    }
  }

  bool get _canContinue {
    if (_isSaving) return false;
    if (!_isNameValid) return false;
    if (!_isFarmValid) return false;
    if (!_isMunicipalityValid) return false;
    if (!_hasPhoto) return false;
    if (_isCustomVarietyMode) {
      return _isOtherVarietyValid;
    }
    return _isPredefinedVarietyValid;
  }

  String? _validateName(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return _nameRequiredError;
    if (v.length < _nameMinLength) return _nameMinLengthError;
    return null;
  }

  String? _validateFarm(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return _farmRequiredError;
    return null;
  }

  String? _validateMunicipality(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return _municipalityRequiredError;
    return null;
  }

  String? _validatePredefinedVariety(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return _varietyRequiredError;
    return null;
  }

  String? _validateOtherVariety(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return _otherVarietyRequiredError;
    return null;
  }

  Future<void> _handlePickImage() async {
    if (_isSaving) return;
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (!mounted || file == null) return;
      setState(() {
        _pendingPhotoFile = file;
      });
    } catch (_) {}
  }

  void _handleRemoveImage() {
    if (_isSaving) return;
    setState(() {
      _pendingPhotoFile = null;
      _savedPhotoPath = null;
    });
  }

  Future<void> _handleOpenVarietyPicker() async {
    if (_isSaving) return;
    final String? result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius2xl),
        ),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.md,
              AppSpacing.marginMobile,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    _varietyLabel,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: UserProfile.coffeeVarieties.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.50),
                    ),
                    itemBuilder: (BuildContext listCtx, int index) {
                      final String option = UserProfile.coffeeVarieties[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        visualDensity: VisualDensity.compact,
                        leading: option == UserProfile.coffeeVarietyOther
                            ? const Icon(Icons.edit_note_rounded)
                            : const Icon(Icons.eco_rounded),
                        iconColor: AppColors.primaryContainer,
                        title: Text(
                          option,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurface,
                              ) ??
                              TextStyle(
                                fontSize: 16,
                                height: 24 / 16,
                                color: AppColors.onSurface,
                              ),
                        ),
                        onTap: () => Navigator.pop(ctx, option),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || result == null) return;
    if (result == UserProfile.coffeeVarietyOther) {
      setState(() {
        _varietyController.clear();
        _isCustomVarietyMode = true;
        _isPredefinedVarietyValid = false;
        _isOtherVarietyValid =
            _validateOtherVariety(_otherVarietyController.text) == null;
      });
    } else {
      setState(() {
        _varietyController.text = result;
        _isCustomVarietyMode = false;
        _otherVarietyController.clear();
        _isPredefinedVarietyValid = true;
        _isOtherVarietyValid = true;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _handleExitCustomVariety() {
    if (_isSaving) return;
    setState(() {
      _isCustomVarietyMode = false;
      _otherVarietyController.clear();
      _isOtherVarietyValid = true;
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : AppColors.primaryContainer,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (_isSaving) return;
    final NavigatorState navigator = Navigator.of(context);
    FocusScope.of(context).unfocus();
    final bool formOk = _formKey.currentState?.validate() ?? false;
    if (!_hasPhoto) {
      _showSnack(_photoRequiredError, isError: true);
      return;
    }
    if (!formOk) return;
    if (!_canContinue) return;

    final String finalVariety = _isCustomVarietyMode
        ? _otherVarietyController.text.trim()
        : _varietyController.text.trim();
    final UserProfile candidate = UserProfile(
      userName: _nameController.text.trim(),
      farmName: _farmController.text.trim(),
      municipality: _municipalityController.text.trim(),
      coffeeVariety: finalVariety,
      profileImagePath: _savedPhotoPath,
    );

    setState(() => _isSaving = true);
    final bool ok = await _repository.saveProfile(
      profile: candidate,
      newProfileImage: _pendingPhotoFile,
    );
    if (!mounted) return;
    if (ok) {
      debugPrint('Perfil guardado exitosamente');
      navigator.pushReplacementNamed(AppRoutes.home);
    } else {
      setState(() => _isSaving = false);
      _showSnack(_saveErrorMessage, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  width: _contentMaxWidth,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                      vertical: AppSpacing.xl,
                    ).copyWith(top: AppSpacing.xxl, bottom: AppSpacing.xxl),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildTopAppBar(context),
                          const SizedBox(height: AppSpacing.lg),
                          _buildHeader(context),
                          const SizedBox(height: AppSpacing.xl),
                          ProfileAvatarPicker(
                            photoPath: _displayPhotoPath,
                            onPickImage: _handlePickImage,
                            onRemoveImage: _hasPhoto
                                ? _handleRemoveImage
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.xl + AppSpacing.sm),
                          _buildFields(constraints),
                          const SizedBox(height: AppSpacing.xl),
                          _buildContinueButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.eco, color: AppColors.primary, weight: 700, fill: 1),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'AgroKaf',
            style:
                textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ) ??
                TextStyle(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _title,
          style:
              textTheme.headlineSmall?.copyWith(color: AppColors.onSurface) ??
              TextStyle(
                fontSize: 28,
                height: 36 / 28,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _description,
          style:
              textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ) ??
              TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildFields(BoxConstraints constraints) {
    return Column(
      children: <Widget>[
        ProfileTextField(
          label: _nameLabel,
          hint: _nameHint,
          icon: Icons.person_outline_rounded,
          controller: _nameController,
          validator: _validateName,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileTextField(
          label: _farmLabel,
          hint: _farmHint,
          icon: Icons.agriculture_rounded,
          controller: _farmController,
          validator: _validateFarm,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileTextField(
          label: _municipalityLabel,
          hint: _municipalityHint,
          icon: Icons.location_on_outlined,
          controller: _municipalityController,
          validator: _validateMunicipality,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildVarietyField(),
      ],
    );
  }

  Widget _buildVarietyField() {
    return AnimatedSwitcher(
      duration: AppAnimations.fast,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: _isCustomVarietyMode
          ? ProfileTextField(
              key: const ValueKey<String>('variety-custom'),
              label: _varietyLabel,
              hint: _otherVarietyHint,
              icon: Icons.eco_rounded,
              controller: _otherVarietyController,
              validator: _validateOtherVariety,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              suffixIcon: Icons.close_rounded,
              onSuffixTap: _handleExitCustomVariety,
            )
          : ProfileTextField(
              key: const ValueKey<String>('variety-predefined'),
              label: _varietyLabel,
              hint: _varietyHint,
              icon: Icons.eco_rounded,
              controller: _varietyController,
              readOnly: true,
              onTap: _handleOpenVarietyPicker,
              validator: _validatePredefinedVariety,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
            ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: PrimaryPillButton(
        label: _continueLabel,
        variant: PillButtonVariant.filled,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        showShadow: true,
        isLoading: _isSaving,
        loadingLabel: _savingLabel,
        onTap: _canContinue ? () => _handleContinue(context) : null,
      ),
    );
  }
}
