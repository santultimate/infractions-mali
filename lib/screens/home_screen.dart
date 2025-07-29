import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:infractions_mali/services/alert_service.dart';
import '../models/infraction.dart';
import '../services/infraction_service.dart';
import '../services/orange_money_service.dart';
import '../services/auth_service.dart';
import '../widgets/infraction_card.dart';
import '../widgets/app_background.dart';
import '../widgets/orange_money_donation_dialog.dart';
import 'community_map_screen.dart';
import 'login_screen.dart';
import 'interactive_map_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AlertService alertService;
  final AuthService authService;

  const HomeScreen({
    Key? key,
    required this.alertService,
    required this.authService,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InfractionService _infractionService = InfractionService();
  final OrangeMoneyService _orangeMoneyService = OrangeMoneyService();
  late final AuthService _authService;

  List<Infraction> _allInfractions = [];
  List<Infraction> _filteredInfractions = [];
  String _searchQuery = '';
  String _selectedVehicleType = 'Tous';
  String _selectedClass = 'Toutes';
  bool _isLoading = true;

  static const List<String> vehicleTypes = [
    'Tous',
    'Motorisés',
    'Cycles',
    'Cyclomoteurs',
    'Différencié'
  ];

  static const List<String> classes = [
    'Toutes',
    '1ère classe',
    '2ème classe',
    '3ème classe',
    'Sanctions non forfaitaires',
    'Délits'
  ];

  @override
  void initState() {
    super.initState();
    _authService = widget.authService;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadInfractions(),
      _initializeOrangeMoney(),
    ]);
  }

  Future<void> _initializeOrangeMoney() async {
    try {
      await _orangeMoneyService.initialize();
    } catch (e) {
      debugPrint('Orange Money initialization error: $e');
    }
  }

  Future<void> _loadInfractions() async {
    try {
      final infractions = await InfractionService.loadInfractions();
      setState(() {
        _allInfractions = infractions;
        _filteredInfractions = infractions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('error_loading_infractions'.tr(args: [e.toString()]));
    }
  }

  void _filterInfractions() {
    setState(() {
      _filteredInfractions = _allInfractions.where((infraction) {
        final matchesSearch = _searchQuery.isEmpty ||
            infraction.infraction
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            infraction.texte.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesVehicleType = _selectedVehicleType == 'Tous' ||
            (infraction.vehicleTypes?.contains(_selectedVehicleType) ?? false);

        final matchesClass =
            _selectedClass == 'Toutes' || infraction.classe == _selectedClass;

        return matchesSearch && matchesVehicleType && matchesClass;
      }).toList();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showOrangeMoneyDonation() {
    showDialog(
      context: context,
      builder: (context) => OrangeMoneyDonationDialog(
        orangeMoneyService: _orangeMoneyService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userName = user?.displayName?.split(' ').first;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: _buildDrawer(context),
        appBar: _buildAppBar(context, user, userName),
        body: _isLoading ? _buildLoadingIndicator() : _buildMainContent(),
        floatingActionButton: _buildFloatingActionButtons(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeaderWithFilters(),
        Expanded(child: _buildInfractionsList()),
      ],
    );
  }

  Widget _buildHeaderWithFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildFilterControls(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        _searchQuery = value;
        _filterInfractions();
      },
      decoration: InputDecoration(
        hintText: 'search_infraction_hint'.tr(),
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildFilterControls() {
    return Row(
      children: [
        Expanded(child: _buildVehicleTypeDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _buildClassDropdown()),
      ],
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return _buildDropdown(
      value: _selectedVehicleType,
      items: vehicleTypes,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedVehicleType = value);
          _filterInfractions();
        }
      },
    );
  }

  Widget _buildClassDropdown() {
    return _buildDropdown(
      value: _selectedClass,
      items: classes,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedClass = value);
          _filterInfractions();
        }
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfractionsList() {
    return _filteredInfractions.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredInfractions.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InfractionCard(
                infraction: _filteredInfractions[index],
                onTap: () =>
                    _showInfractionDetails(_filteredInfractions[index]),
              ),
            ),
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'no_infractions_found'.tr(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, User? user, String? userName) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.cyan],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Text(
        'app_title'.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        if (user != null) _buildUserProfile(user, userName),
        _buildAboutButton(),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildUserProfile(User user, String? userName) {
    return Row(
      children: [
        if (user.photoURL != null)
          CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL!),
            radius: 16,
          )
        else
          const CircleAvatar(
            child: Icon(Icons.person, size: 16),
            radius: 16,
          ),
        const SizedBox(width: 8),
        Text(
          userName ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAboutButton() {
    return IconButton(
      icon: const Icon(Icons.info_outline, color: Colors.white),
      onPressed: _showAboutScreen,
    );
  }

  Widget _buildLoginButton() {
    return IconButton(
      icon: const Icon(Icons.login, color: Colors.white),
      tooltip: 'login'.tr(),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildStatisticsTile(context),
          _buildSettingsTile(context),
          _buildDonationTile(),
          _buildAboutTile(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.cyan.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            'app_title'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bar_chart),
      title: Text('statistics'.tr()),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StatisticsScreen()),
        );
      },
    );
  }

  Widget _buildSettingsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: Text('settings'.tr()),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      },
    );
  }

  Widget _buildDonationTile() {
    return ListTile(
      leading: const Icon(Icons.volunteer_activism, color: Colors.orange),
      title: Text('support_project'.tr()),
      onTap: () {
        Navigator.pop(context);
        _showOrangeMoneyDonation();
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text('about'.tr()),
      onTap: () {
        Navigator.pop(context);
        _showAboutScreen();
      },
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'community_map',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityMapScreen()),
          ),
          backgroundColor: Colors.red[700],
          child: const Icon(Icons.map, color: Colors.white),
          tooltip: 'map'.tr(),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'interactive_map',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InteractiveMapScreen()),
          ),
          backgroundColor: Colors.blue[700],
          child: const Icon(Icons.public, color: Colors.white),
          tooltip: 'interactive_map'.tr(),
        ),
      ],
    );
  }

  void _showInfractionDetails(Infraction infraction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('infraction_details'.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                infraction.infraction,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('class_label'
                  .tr(args: [infraction.classe ?? 'unspecified'.tr()])),
              const SizedBox(height: 8),
              Text('article_label'.tr(args: [infraction.texte])),
              if (infraction.amende.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('fine_amount_label'.tr(args: [infraction.amende])),
              ],
              if (infraction.vehicleTypes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text('affected_vehicles_label'
                    .tr(args: [infraction.vehicleTypes!.join(', ')])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() async {
    final url = Uri.parse('privacy_policy_url'.tr());
    try {
      final canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossible d\'ouvrir l\'URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Erreur lors de l\'ouverture de la politique de confidentialité'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutScreen() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('about'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user,
                  size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Infractions Routières Mali',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'road_safety_description'.tr(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'developed_by'.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Yacouba Santara',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'flutter_developer'.tr(),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'support_project'.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'donation_description'.tr(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.volunteer_activism),
                label: Text('make_donation'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showOrangeMoneyDonation();
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'privacy_policy'.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'privacy_policy_description'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text('view_privacy_policy'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => _openPrivacyPolicy(),
              ),
              const SizedBox(height: 24),
              Text(
                '© 2024 Yacouba Santara',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }
}
