// ─────────────────────────────────────────────────────────────────────────────
// PalayPlan App Strings — English, Tagalog (Filipino), Bisaya (Cebuano)
//
// Usage:
//   final s = AppStrings.of(context);
//   Text(s.appName);
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../providers/language_provider.dart';

/// Convenience accessor so any Widget can call `AppStrings.of(context)`.
class AppStrings {
  final AppLanguage lang;
  const AppStrings._(this.lang);

  factory AppStrings.of(BuildContext context) {
    final lang = LanguageProvider.languageOf(context);
    return AppStrings._(lang);
  }

  // ── Meta ───────────────────────────────────────────────────────────────────
  String get appName => _pick('PalayPlan', 'PalayPlan', 'PalayPlan');
  String get tagline => _pick(
        'Your Crops, Decoded By AI',
        'Ang Iyong Pananim, Binibigyang-kahulugan ng AI',
        'Ang Imong Tanom, Gipaklaro sa AI',
      );
  String get splashSub => _pick(
        'From scanning to tracking — everything happens automatically.',
        'Mula sa pag-scan hanggang sa pagsubaybay — awtomatiko lahat.',
        'Gikan sa pag-scan hangtod sa pagsubaybay — awtomatiko tanan.',
      );
  String get getStarted => _pick('Get Started', 'Magsimula', 'Sugdi Na');
  String get offlineGuest => _pick('Continue offline as guest',
      'Magpatuloy offline bilang bisita', 'Padayon offline isip bisita');
  String get offlineGuestHint => _pick(
        'Your field profile and leaf scans stay on this device. Forecasts need an internet connection.',
        'Mananatili sa device na ito ang profile ng bukid at mga scan. Kailangan ng internet para sa forecast.',
        'Magpabilin dinhi sa device ang profile sa uma ug mga scan. Kinahanglan og internet para sa forecast.',
      );
  String offlineCachedAt(String date) => _pick(
        'Saved for offline use · Updated $date',
        'Naka-save para magamit offline · Na-update $date',
        'Na-save para magamit offline · Na-update $date',
      );
  String get offlineNoCachedData => _pick(
        'No saved advisories yet. Connect to the internet to load them.',
        'Wala pang naka-save na abiso. Kumonekta sa internet para makuha ang mga ito.',
        'Wala pay na-save nga tambag. Sumpayi ang internet aron makuha kini.',
      );
  String get offlineRetry =>
      _pick('Try again', 'Subukan muli', 'Sulayi pag-usab');

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  String get navHome => _pick('Home', 'Tahanan', 'Balay');
  String get navWeather => _pick('Weather', 'Panahon', 'Klima');
  String get navScan => _pick('Scan', 'I-scan', 'I-scan');
  String get navCalendar => _pick('Calendar', 'Kalendaryo', 'Kalendaryo');
  String get navAdvisory => _pick('Advisories', 'Abiso', 'Tambag');

  // ── Home Screen ────────────────────────────────────────────────────────────
  String get homeTitle => _pick('Dashboard', 'Dashboard', 'Dashboard');
  String get homeLocation => _pick('Ubay, Bohol', 'Ubay, Bohol', 'Ubay, Bohol');
  String get filterAll => _pick('All', 'Lahat', 'Tanan');
  String get filterVeg => _pick('Vegetative', 'Palaki', 'Pagtubo');
  String get filterWeather => _pick('Weather', 'Panahon', 'Klima');
  String get filterAdvisory => _pick('Advisories', 'Abiso', 'Tambag');
  String get heroTitle => _pick(
        'Your Crops,\nDecoded By AI',
        'Ang Iyong Pananim,\nSuri ng AI',
        'Ang Imong Tanom,\nSusi sa AI',
      );
  String get heroSubtitle => _pick(
        'Scan leaves in real-time to detect blight, blast, or brown spot instantly.',
        'I-scan ang dahon sa bukid para ma-detect agad ang blight, blast, o brown spot.',
        'I-scan ang dahon sa uma aron makita dayon ang blight, blast, o brown spot.',
      );
  String get accuracyBadge =>
      _pick('95.8% ACCURACY', '95.8% KATUMPAYAN', '95.8% KASIGUROAN');
  String get onDeviceAi =>
      _pick('On-Device AI', 'AI sa Cellphone', 'AI sa Cellphone');
  String get fieldStatusTitle => _pick("Today's Field Status",
      'Katayuan ng Bukid Ngayon', 'Kahimtang sa Uma Karon');
  String get seeAll => _pick('See All', 'Tingnan Lahat', 'Tan-awa Tanan');

  String get featFertilizer =>
      _pick('Fertilizer Schedule', 'Iskedyul ng Pataba', 'Iskedyul sa Abono');
  String get featFertilizerSub => _pick(
      'Nitrogen Top-Dress · Active Vegetative',
      'Paglalagay ng Nitroheno · Yugto ng Paglaki',
      'Pagbutang og Nitroheno · Yugto sa Pagtubo');
  String get featFertilizerBadge =>
      _pick('Optimal Today', 'Mainam Ngayon', 'Maayo Karon');

  String get featWeather =>
      _pick('7-Day Weather Forecast', '7-Araw na Panahon', '7-Adlaw nga Klima');
  String get featWeatherSub => _pick(
      '29°C · Rain likelihood low',
      '29°C · Mababa ang posibilidad ng ulan',
      '29°C · Gamay ang tsansa sa ulan');
  String get featWeatherBadge => _pick('Favorable', 'Paborable', 'Paborable');

  String get featCalendar => _pick('Cropping Calendar',
      'Kalendaryo ng Pagtatanim', 'Kalendaryo sa Pagtanom');
  String get featCalendarSub => _pick(
      'Day 42 of 110 · Harvest in 68d',
      'Araw 42 sa 110 · Pag-ani sa 68 araw',
      'Adlaw 42 sa 110 · Ting-ani sa 68 ka adlaw');
  String get featCalendarBadge => _pick('Phase 2', 'Yugto 2', 'Yugto 2');

  String get featAdvisory =>
      _pick('All Advisories', 'Lahat ng Abiso', 'Tanan nga Tambag');
  String get featAdvisorySub => _pick('agronomic advisories active',
      'aktibong abiso sa pagsasaka', 'aktibong tambag sa pag-uma');
  String get featAdvisoryBadge =>
      _pick('Monitored', 'Binabantayan', 'Gibantayan');

  String get featScan => _pick('Scan Rice Leaf Disease',
      'I-scan ang Sakit ng Palay', 'I-scan ang Sakit sa Humay');

  // ── Scan Screen ────────────────────────────────────────────────────────────
  String get scanTitle => _pick('Rice Disease Scanner',
      'Tagasuri ng Sakit ng Palay', 'Tigsusi sa Sakit sa Humay');
  String get scanTip => _pick(
        'Take a close-up photo of a single rice leaf in bright, even lighting.',
        'Kumuha ng malapit na larawan ng isang dahon ng palay sa maliwanag na lugar.',
        'Kuhaa og duol nga hulagway sa usa ka dahon sa humay sa hayag nga dapit.',
      );
  String get scanBtnPhoto =>
      _pick('Take Photo', 'Kumuha ng Larawan', 'Kuhaa og Litrato');
  String get scanBtnGallery => _pick('Gallery', 'Galeriya', 'Galeriya');
  String get scanNoPhoto => _pick('No photo selected yet',
      'Wala pang larawang napili', 'Wala pay litratong napili');
  String get scanUploadPrompt => _pick(
      'Choose camera or upload from gallery',
      'Pumili sa camera o mag-upload sa gallery',
      'Pilia sa camera o pag-upload sa gallery');
  String get scanAnalyzing =>
      _pick('Analyzing leaf…', 'Sinusuri ang dahon…', 'Gisusi ang dahon…');

  // ── Result Screen ──────────────────────────────────────────────────────────
  String get resultTitle =>
      _pick('Diagnosis Result', 'Resulta ng Pagsusuri', 'Resulta sa Pagsusi');
  String get resultHealthy =>
      _pick('HEALTHY CROP', 'MALUSOG NA HALAMAN', 'HIMSOG ANG TANOM');
  String get resultDisease => _pick(
      'DISEASE DETECTED', 'MAY SAKIT NA NATUKLASAN', 'NAKIT-AN NGA MAY SAKIT');
  String get resultConfLabel => _pick('Confidence', 'Katiyakan', 'Kasiguroan');
  String get resultModelTag => _pick('On-Device TFLite Model',
      'TFLite Modelo sa Telepono', 'TFLite Modelo sa Telepono');
  String get resultAction => _pick('Recommended Action',
      'Inirekomendang Aksyon', 'Girekomendar nga Buhaton');
  String get resultMaintain =>
      _pick('Maintenance Tip', 'Tip sa Pangangalaga', 'Tip sa Pag-atiman');
  String get resultScanAgain => _pick(
      'Scan Another Leaf', 'I-scan ang Ibang Dahon', 'I-scan ang Laing Dahon');
  String get resultSaveReport =>
      _pick('Save Report', 'I-save ang Ulat', 'I-save ang Taho');
  String get resultDisclaimer => _pick(
        'This is a guide only. Always consult a licensed agricultural technician or your local DA office to confirm.',
        'Gabay lamang ito. Laging kumonsulta sa lisensyadong agriculturist o sa pinakamalapit na tanggapan ng DA para makasiguro.',
        'Giya lamang kini. Kanunay konsultaha ang lisensyadong agriculturist o ang pinakaduol nga opisina sa DA aron makasiguro.',
      );
  String get resultLowConf => _pick(
        'Not confident enough to diagnose',
        'Hindi sapat ang kumpiyansa para mag-diagnose',
        'Dili igo ang kasiguroan para mag-diagnose',
      );
  String get resultLowConfSub => _pick(
        'Try a clearer photo of a single rice leaf with good natural lighting, camera focused on the leaf surface.',
        'Subukan ang mas malinaw na larawan ng isang dahon ng palay na may magandang natural na liwanag, nakatutok sa ibabaw ng dahon.',
        'Sulayi og mas klaro nga hulagway sa usa ka dahon sa humay nga adunay maayong natural nga kahayag, nakatutok sa ibabaw sa dahon.',
      );
  String get resultSeverity =>
      _pick('Severity Level', 'Antas ng Panganib', 'Lebel sa Risgo');
  String get resultHighRisk =>
      _pick('High Risk', 'Mataas na Panganib', 'Taas nga Risgo');
  String get resultMedRisk =>
      _pick('Moderate Risk', 'Katamtamang Panganib', 'Kasarangan nga Risgo');
  String get resultLowRisk =>
      _pick('Low Risk', 'Mababang Panganib', 'Ubos nga Risgo');
  String get chipConsult => _pick('Consult Technician',
      'Kumonsulta sa Technician', 'Konsultaha ang Technician');
  String get chipFungicide =>
      _pick('Get Fungicide', 'Maghanda ng Fungicide', 'Pag-andam og Fungicide');
  String get chipRescan =>
      _pick('Scan Again', 'I-scan Ulit', 'I-scan Pag-usab');

  // ── Weather Screen ─────────────────────────────────────────────────────────
  String get weatherTitle =>
      _pick('7-Day Forecast', '7-Araw na Panahon', '7-Adlaw nga Klima');
  String get weatherUpcoming => _pick(
      'Upcoming 7 Days', 'Paparating na 7 Araw', 'Mosunod nga 7 ka Adlaw');
  String get weatherSub => _pick('7-day outlook for your field',
      '7-araw na panahon sa inyong bukid', '7-adlaw nga klima sa imong uma');
  String get weatherSuitablePlant => _pick(
      'Suitable for planting', 'Angkop sa pagtatanim', 'Angay sa pagtanom');
  String get weatherMonitorPest => _pick(
      'Monitor for pests', 'Bantayan ang mga peste', 'Bantayan ang mga peste');
  String get weatherDelay => _pick(
      'Consider delaying farm work',
      'Isaalang-alang ang pagpapaliban ng gawain',
      'Hunahunaa ang pagpalangan sa trabaho sa uma');

  // ── Calendar Screen ────────────────────────────────────────────────────────
  String get calTitle => _pick('Cropping Calendar', 'Kalendaryo ng Pagtatanim',
      'Kalendaryo sa Pagtanom');
  String get calSeason => _pick('Wet Season', 'Tag-ulan', 'Ting-ulan');
  String get calStartDate =>
      _pick('Start Date', 'Petsa ng Simula', 'Petsa sa Pagsugod');
  String get calVariety => _pick('Variety', 'Klase ng Palay', 'Klase sa Humay');
  String get calPhaseNursery =>
      _pick('Nursery / Seedbed', 'Punla / Punlaan', 'Punla / Sabakan');
  String get calPhaseVeg =>
      _pick('Vegetative Stage', 'Yugto ng Paglaki', 'Yugto sa Pagtubo');
  String get calPhaseRep =>
      _pick('Reproductive Stage', 'Yugto ng Pagbubunga', 'Yugto sa Pagbunga');
  String get calPhaseMat => _pick('Maturity / Harvest', 'Pag-aani', 'Ting-ani');

  // ── Advisory Screen ────────────────────────────────────────────────────────
  String get advTitle =>
      _pick('All Advisories', 'Lahat ng Abiso', 'Tanan nga Tambag');
  String get advEmpty => _pick(
      'No advisories right now.\nCheck back tomorrow!',
      'Walang abiso ngayon.\nBumalik bukas!',
      'Walay tambag karon.\nBalik ugma!');
  String get advLoading => _pick('Fetching advisories…',
      'Kinukuha ang mga abiso…', 'Gikuha ang mga tambag…');

  // ── Smart Field Recommendation ───────────────────────────────────────────
  String get recTitle => _pick(
      "Today's Field Recommendation",
      'Matalinong Payo sa Bukid Ngayon',
      'Maalamong Tambag sa Uma Karon');
  String get recSubtitle => _pick(
      'PhilRice PalayCheck Agro-Decision Engine',
      'PhilRice PalayCheck Gabay sa Pagsasaka',
      'PhilRice PalayCheck Giya sa Pag-uma');
  String get recFertilizer =>
      _pick('Nutrient & Fertilizer', 'Pataba at Abono', 'Abono ug Nutrisyon');
  String get recWater => _pick(
      'Water & Irrigation (AWD)', 'Tubig at Patubig (AWD)', 'Tubig ug Patubig (AWD)');
  String get recPest => _pick(
      'Pest & Disease Scouting', 'Pagsusuri sa Peste at Sakit', 'Pagsusi sa Peste ug Sakit');
  String get recApplySafe => _pick(
      'Optimal Weather Window', 'Magandang Oras Maglagay', 'Maayong Panahon Ibutang');
  String get recDelayRain => _pick(
      'Delay Application (Rain Risk)', 'Ipantig Muna (Peligro sa Ulan)', 'I-oktaba Una (Peligro sa Ulan)');

  // ── Field Profile Settings ────────────────────────────────────────────────
  String get fieldSetupTitle =>
      _pick('My Field Profile', 'Profile ng Bukid', 'Profile sa Uma');
  String get fieldSetupSub => _pick(
        'Configure your location, rice variety, and planting date.',
        'I-set ang lokasyon, binhi, at petsa ng pagtatanim.',
        'I-set ang lokasyon, binhi, ug petsa sa pagtanom.',
      );
  String get fieldLocationLabel =>
      _pick('Field Location', 'Lokasyon ng Bukid', 'Lokasyon sa Uma');
  String get chooseOnMap => _pick(
        'Choose exact location on map',
        'Pumili ng eksaktong lokasyon sa mapa',
        'Pilia ang eksaktong lokasyon sa mapa',
      );
  String get mapPinSelected => _pick(
        'Map pin selected',
        'Napili ang pin sa mapa',
        'Napili ang pin sa mapa',
      );
  String get mapPickTitle => _pick(
        'Pin your field location',
        'I-pin ang lokasyon ng bukid',
        'I-pin ang lokasyon sa uma',
      );
  String get mapPickHint => _pick(
        'Tap the map to place the pin. Location access is only needed to use GPS.',
        'I-tap ang mapa para ilagay ang pin. Kailangan lang ng pahintulot sa lokasyon para magamit ang GPS.',
        'I-tap ang mapa aron ibutang ang pin. Kinahanglan lang ang pagtugot sa lokasyon aron magamit ang GPS.',
      );
  String get useCurrentLocation => _pick(
        'Use current location',
        'Gamitin ang kasalukuyang lokasyon',
        'Gamita ang kasamtangang lokasyon',
      );
  String get confirmFieldLocation => _pick(
        'Use this field location',
        'Gamitin ang lokasyong ito',
        'Gamita kini nga lokasyon',
      );
  String get locationPermissionDenied => _pick(
        'Location permission denied. Tap the map to choose manually.',
        'Tinanggihan ang pahintulot sa lokasyon. I-tap ang mapa para pumili nang mano-mano.',
        'Gibalibaran ang pagtugot sa lokasyon. I-tap ang mapa aron mopili sa mano-mano.',
      );
  String get locationServiceDisabled => _pick(
        'Location services are off. Turn them on or tap the map to choose manually.',
        'Naka-off ang serbisyo ng lokasyon. I-on ito o i-tap ang mapa para pumili nang mano-mano.',
        'Naka-off ang serbisyo sa lokasyon. I-on kini o i-tap ang mapa aron mopili sa mano-mano.',
      );
  String get locationRequestFailed => _pick(
        'Could not get your location. Tap the map to choose manually.',
        'Hindi makuha ang lokasyon mo. I-tap ang mapa para pumili nang mano-mano.',
        'Dili makuha ang imong lokasyon. I-tap ang mapa aron mopili sa mano-mano.',
      );
  String get fieldVarietyLabel =>
      _pick('Rice Variety', 'Binhi ng Palay', 'Binhi sa Humay');
  String get fieldDateLabel => _pick(
      'Sowing / Planting Date', 'Petsa ng Pagtatanim', 'Petsa sa Pagtanom');
  String get fieldAreaLabel => _pick('Field Area (Hectares)',
      'Laki ng Bukid (Ektarya)', 'Gidak-on sa Uma (Ektarya)');
  String get saveField =>
      _pick('Save Field Profile', 'I-save ang Profile', 'I-save ang Profile');
  String get fieldSavedSnackbar => _pick('Field profile updated!',
      'Nai-save na ang profile ng bukid!', 'Na-save na ang profile sa uma!');

  // ── Language Settings ──────────────────────────────────────────────────────
  String get langPickerTitle =>
      _pick('Select Language', 'Piliin ang Wika', 'Pilia ang Sinultian');
  String get langPickerSub => _pick('Choose your preferred language',
      'Piliin ang nais mong wika', 'Pilia ang gusto nimong sinultian');
  String get langEn => 'English';
  String get langFil => 'Filipino (Tagalog)';
  String get langCeb => 'Bisaya (Cebuano)';

  // ── App Settings ───────────────────────────────────────────────────────────
  String get settingsTitle => _pick('Settings', 'Mga Setting', 'Mga Setting');
  String get settingsAccount => _pick('Account', 'Account', 'Account');
  String get settingsGuest => _pick(
      'You are using PalayPlan as a guest',
      'Ginagamit mo ang PalayPlan bilang bisita',
      'Gigamit nimo ang PalayPlan isip bisita');
  String get settingsLanguage => _pick('Language', 'Wika', 'Sinultian');
  String get settingsLanguageSubtitle => _pick(
      'Choose the language used in the app',
      'Piliin ang wikang gagamitin sa app',
      'Pilia ang sinultian nga gamiton sa app');
  String get settingsPrivacy =>
      _pick('Privacy policy', 'Patakaran sa privacy', 'Patakaran sa privacy');
  String get settingsPrivacySubtitle => _pick(
      'How PalayPlan handles your information',
      'Paano ginagamit ng PalayPlan ang iyong impormasyon',
      'Giunsa pagdumala sa PalayPlan ang imong impormasyon');
  String get settingsAppUpdates =>
      _pick('App updates', 'Mga update sa app', 'Mga update sa app');
  String get settingsAppUpdatesSubtitle => _pick(
        'Check for the latest Android APK',
        'Tingnan ang pinakabagong Android APK',
        'Susiha ang pinakabag-ong Android APK',
      );
  String get settingsCheckForUpdates => _pick(
      'Check for updates', 'Tingnan ang mga update', 'Susiha ang mga update');
  String get settingsCheckingForUpdates => _pick('Checking for updates…',
      'Sinusuri ang mga update…', 'Nagsusi sa mga update…');
  String settingsUpdateAvailable(String version) => _pick(
        'Version $version is available.',
        'Available na ang bersyon $version.',
        'Anaa na ang bersyon $version.',
      );
  String get settingsNoUpdateAvailable => _pick(
        'You have the latest version.',
        'Nasa iyo na ang pinakabagong bersyon.',
        'Bag-o na ang imong bersyon.',
      );
  String get settingsUpdateCheckError => _pick(
        'Could not check for updates. Check your connection and try again.',
        'Hindi masuri ang mga update. Suriin ang koneksyon at subukan muli.',
        'Dili masusi ang mga update. Susiha ang koneksyon ug sulayi pag-usab.',
      );
  String get settingsDownloadError => _pick(
        'Could not open the APK download.',
        'Hindi mabuksan ang pag-download ng APK.',
        'Dili maablihan ang pag-download sa APK.',
      );
  String get settingsUpdateDialogTitle =>
      _pick('Update available', 'May bagong update', 'Adunay update');
  String get settingsUpdateNow =>
      _pick('Download APK', 'I-download ang APK', 'I-download ang APK');
  String get settingsNotNow => _pick('Not now', 'Mamaya na', 'Dili karon');
  String get settingsReleaseNotes => _pick(
        'Release notes',
        'Mga tala ng release',
        'Mga tala sa release',
      );
  String get settingsSignOut =>
      _pick('Sign out', 'Mag-sign out', 'Pag-sign out');
  String get settingsSignOutPrompt => _pick('Sign out of PalayPlan?',
      'Mag-sign out sa PalayPlan?', 'Mogawas sa PalayPlan?');
  String get settingsSignOutMessage => _pick(
      'Your locally saved field profile and offline data will remain on this device.',
      'Mananatili sa device na ito ang profile ng bukid at offline na data.',
      'Magpabilin sa device ang profile sa uma ug offline nga datos.');
  String get settingsCancel => _pick('Cancel', 'Kanselahin', 'Kanselahon');
  String get settingsSignOutError => _pick(
      'Could not sign out. Please try again.',
      'Hindi makapag-sign out. Subukan muli.',
      'Dili maka-sign out. Sulayi pag-usab.');

  // ── Privacy Policy ─────────────────────────────────────────────────────────
  String get privacyTitle =>
      _pick('Privacy policy', 'Patakaran sa privacy', 'Patakaran sa privacy');
  String get privacyIntro => _pick(
        'This policy explains what information PalayPlan uses and how it is handled in the current app.',
        'Ipinapaliwanag ng patakarang ito kung anong impormasyon ang ginagamit ng PalayPlan at paano ito pinangangasiwaan sa kasalukuyang app.',
        'Gipasabot niini nga patakaran unsang impormasyon ang gigamit sa PalayPlan ug giunsa kini pagdumala sa kasamtangang app.',
      );
  String get privacyInfoTitle => _pick(
      'Information used', 'Impormasyong ginagamit', 'Impormasyong gigamit');
  String get privacyInfoBody => _pick(
        'Firebase Authentication handles your account email and sign-in. Your field profile (location, rice variety, planting date, field area, and crop details) and language preference are saved on this device. The app asks for location permission only if you choose Use current location; it does not track location in the background. Map tiles are provided by OpenStreetMap. When you request forecasts or advisories, the app sends your municipality and field coordinates to the PalayPlan server. Yield estimates also use the crop details you submit.',
        'Pinangangasiwaan ng Firebase Authentication ang email at pag-sign in sa account mo. Naka-save sa device na ito ang profile ng bukid (lokasyon, uri ng palay, petsa ng pagtatanim, laki ng bukid, at mga detalye ng pananim) at piniling wika. Humihingi lang ang app ng pahintulot sa lokasyon kapag pinili mo ang paggamit ng kasalukuyang lokasyon; hindi nito sinusubaybayan ang lokasyon sa background. Nagmumula sa OpenStreetMap ang mga tile ng mapa. Kapag humiling ka ng forecast o abiso, ipinapadala ng app sa server ng PalayPlan ang munisipalidad at mga coordinate ng bukid. Ginagamit din sa pagtataya ng ani ang mga detalye ng pananim na isinumite mo.',
        'Gidumala sa Firebase Authentication ang email ug pag-sign in sa imong account. Gitipigan sa device ang profile sa uma (lokasyon, klase sa humay, petsa sa pagtanom, gidak-on sa uma, ug mga detalye sa tanom) ug piniling sinultian. Mangayo lang og pagtugot sa lokasyon ang app kon pilion nimo ang paggamit sa kasamtangang lokasyon; dili kini mosubay sa lokasyon sa background. Gikan sa OpenStreetMap ang mga tile sa mapa. Kon mangayo ka og forecast o tambag, ipadala sa app sa server sa PalayPlan ang munisipyo ug mga koordinasyon sa uma. Gigamit usab sa banabana sa ani ang mga detalye sa tanom nga imong gihatag.',
      );
  String get privacyProcessingTitle => _pick('How information is used',
      'Paggamit ng impormasyon', 'Paggamit sa impormasyon');
  String get privacyProcessingBody => _pick(
        'The PalayPlan server processes forecast, advisory, and yield-estimate requests. It sends field coordinates to OpenWeatherMap to retrieve weather data. On Android and iOS, rice-leaf photos are analyzed by the model on your device; the scan flow does not upload those photos.',
        'Pinoproseso ng server ng PalayPlan ang mga kahilingan para sa forecast, abiso, at pagtataya ng ani. Ipinapadala nito sa OpenWeatherMap ang mga coordinate ng bukid para kumuha ng datos ng panahon. Sa Android at iOS, sinusuri sa device mo ng modelo ang mga larawan ng dahon ng palay; hindi ina-upload ng proseso ng pag-scan ang mga larawang ito.',
        'Giproseso sa server sa PalayPlan ang mga hangyo alang sa forecast, tambag, ug banabana sa ani. Ipadala niini sa OpenWeatherMap ang mga koordinasyon sa uma aron makakuha og datos sa panahon. Sa Android ug iOS, susihon sa modelo sa imong device ang mga litrato sa dahon sa humay; dili i-upload sa proseso sa pag-scan ang maong mga litrato.',
      );
  String get privacyStorageTitle => _pick('Storage and offline data',
      'Pag-iimbak at offline na data', 'Pagtipig ug offline nga datos');
  String get privacyStorageBody => _pick(
        'Your field profile, language choice, and cached forecasts or advisories are stored in local app storage. Cached responses remain until replaced or you clear PalayPlan app data in your device settings. Signing out does not remove these local items.',
        'Nakaimbak sa lokal na storage ng app ang profile ng bukid, piniling wika, at naka-cache na forecast o abiso. Mananatili ang naka-cache na sagot hanggang mapalitan o burahin mo ang data ng PalayPlan sa settings ng device. Hindi inaalis ng pag-sign out ang mga lokal na item na ito.',
        'Gitipigan sa lokal nga storage sa app ang profile sa uma, piniling sinultian, ug naka-cache nga forecast o tambag. Magpabilin ang naka-cache nga tubag hangtod mapulihan o limpyohan nimo ang datos sa PalayPlan sa settings sa device. Dili tangtangon sa pag-sign out kining lokal nga mga butang.',
      );
  String get privacySharingTitle => _pick(
      'Service providers', 'Mga service provider', 'Mga service provider');
  String get privacySharingBody => _pick(
        'PalayPlan uses Firebase Authentication (and Google Sign-In if you choose it) for account access, OpenWeatherMap for weather data, and the PalayPlan server to provide app services. This version does not include in-app advertising or analytics SDKs. Those providers handle information under their own privacy policies.',
        'Ginagamit ng PalayPlan ang Firebase Authentication (at Google Sign-In kung pipiliin mo ito) para sa account, OpenWeatherMap para sa datos ng panahon, at server ng PalayPlan para sa mga serbisyo ng app. Walang in-app advertising o analytics SDK ang bersyong ito. Pinangangasiwaan ng mga provider na iyon ang impormasyon ayon sa sarili nilang mga patakaran sa privacy.',
        'Gigamit sa PalayPlan ang Firebase Authentication (ug Google Sign-In kon pilion nimo) alang sa account, OpenWeatherMap alang sa datos sa panahon, ug ang server sa PalayPlan alang sa mga serbisyo sa app. Walay in-app advertising o analytics SDK kining bersyona. Gidumala sa maong mga provider ang impormasyon sumala sa ilang kaugalingong mga patakaran sa privacy.',
      );
  String get privacyChoicesTitle =>
      _pick('Your choices', 'Mga pagpipilian mo', 'Imong mga kapilian');
  String get privacyChoicesBody => _pick(
        'You can edit your field profile in the app and clear locally stored profile and cached data by clearing the app data in your device settings. Signing out ends the current session but does not delete your account. The app does not currently have an in-app account or server-data deletion control; contact the publisher through the official support channel where you got the app to ask about deletion.',
        'Maaari mong baguhin ang profile ng bukid sa app at burahin ang lokal na profile at naka-cache na data sa pamamagitan ng pag-clear ng app data sa settings ng device. Tinatapos ng pag-sign out ang kasalukuyang session ngunit hindi nito binubura ang account. Wala pang kontrol sa app para burahin ang account o data sa server; makipag-ugnayan sa publisher sa opisyal na support channel kung saan mo nakuha ang app para magtanong tungkol sa pagbura.',
        'Mahimo nimong usbon ang profile sa uma sa app ug limpyohan ang lokal nga profile ug naka-cache nga datos pinaagi sa paglimpyo sa datos sa app sa settings sa device. Tapuson sa pag-sign out ang kasamtangang session apan dili niini papason ang account. Wala pay kontrol sa app aron papason ang account o datos sa server; kontaka ang publisher pinaagi sa opisyal nga support channel diin nimo nakuha ang app aron mangutana bahin sa pagtangtang.',
      );
  String get privacyContactTitle =>
      _pick('Contact', 'Pakikipag-ugnayan', 'Pakigkontak');
  String get privacyContactBody => _pick(
        'For privacy questions or data-deletion requests, contact the PalayPlan publisher using the official support details provided with the app distribution.',
        'Para sa mga tanong tungkol sa privacy o kahilingan sa pagbura ng data, makipag-ugnayan sa publisher ng PalayPlan gamit ang opisyal na support details na kasama sa pamamahagi ng app.',
        'Alang sa mga pangutana bahin sa privacy o hangyo sa pagtangtang sa datos, kontaka ang publisher sa PalayPlan gamit ang opisyal nga detalye sa suporta nga gihatag uban sa pag-apod-apod sa app.',
      );
  String get privacyLastUpdated => _pick(
      'Last updated: November 2026',
      'Huling na-update: Nobyembre 2026',
      'Kataposang gi-update: Nobyembre 2026');

  // ── Disease Display Names ──────────────────────────────────────────────────
  String diseaseName(String rawLabel) {
    final clean = rawLabel.toLowerCase().trim();
    switch (clean) {
      case 'blast':
      case 'leaf_blast':
        return _pick('Rice Leaf Blast', 'Rice Leaf Blast (Tukob)',
            'Rice Leaf Blast (Tukob)');
      case 'brownspot':
      case 'brown_spot':
        return _pick('Brown Spot', 'Brown Spot (Mantsang Kayumanggi)',
            'Brown Spot (Kagid sa Dahon)');
      case 'bacterial_leaf_blight':
        return _pick('Bacterial Leaf Blight', 'Bacterial Leaf Blight (BLB)',
            'Bacterial Leaf Blight (BLB)');
      case 'healthy':
        return _pick('Healthy Leaf', 'Malusog na Dahon', 'Himsog nga Dahon');
      case 'leaf_scald':
        return _pick('Leaf Scald', 'Leaf Scald', 'Leaf Scald');
      case 'narrow_brown_spot':
        return _pick(
            'Narrow Brown Spot', 'Narrow Brown Spot', 'Narrow Brown Spot');
      case 'neck_blast':
        return _pick('Neck Blast', 'Neck Blast', 'Neck Blast');
      case 'rice_hispa':
        return _pick('Rice Hispa', 'Rice Hispa (Peste sa Dahon)',
            'Rice Hispa (Bakukang sa Dahon)');
      case 'sheath_blight':
        return _pick('Sheath Blight', 'Sheath Blight', 'Sheath Blight');
      case 'tungro':
        return _pick('Tungro Virus', 'Tungro Virus (Pula-pula)',
            'Tungro Virus (Pula-pula)');
      default:
        return rawLabel
            .split('_')
            .map((w) =>
                w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
    }
  }

  // ── Disease Treatment Tips ─────────────────────────────────────────────────
  String diseaseTreatmentTip(String rawLabel) {
    final clean = rawLabel.toLowerCase().trim();
    switch (clean) {
      case 'bacterial_leaf_blight':
        return _pick(
          'Bacterial leaf blight spreads through water and plant wounds. '
              'Reduce nitrogen fertilizer, drain the field for 3–5 days, '
              'and avoid transferring floodwater from infected plots. '
              'Plant resistant varieties (e.g. NSIC Rc 222). Consult your local DA Agricultural Technologist.',
          'Ang bacterial leaf blight ay kumakalat sa tubig at sugat ng halaman. '
              'Bawasan ang nitrogen fertilizer, patuyuin ang palayan ng 3–5 araw, '
              'at iwasan ang pagtatapon ng tubig mula sa nahawaang bukid. '
              'Magtanim ng disease-resistant varieties (e.g., NSIC Rc 222). Kumonsulta sa DA Agricultural Technologist.',
          'Ang bacterial leaf blight mokaylap pinaagi sa tubig ug samad sa tanom. '
              'Menosi ang nitrogen nga abono, pahubsi ang basakan og 3–5 ka adlaw, '
              'ug likayi ang pagpasulod og tubig gikan sa nataptan nga umahan. '
              'Pagtanom og resistant varieties (e.g., NSIC Rc 222). Konsultaha ang DA Agricultural Technologist.',
        );

      case 'blast':
      case 'leaf_blast':
        return _pick(
          'Rice blast spreads rapidly in cool, overcast, and humid conditions. '
              'Avoid excessive nitrogen — use split application. '
              'Maintain shallow water (2–3 cm) and spray systemic fungicides (e.g. tricyclazole) upon early symptoms.',
          'Ang rice blast (piricularia) ay mabilis kumalat sa malamig at maulap na panahon. '
              'Huwag labisan ng nitrogen / urea — mag-split application. '
              'Panatilihing mababaw ang tubig (2–3 cm). '
              'Mag-spray ng tricyclazole o isoprothiolane kung may sintomas na.',
          'Ang rice blast (piricularia) dali kaayong mokaylap sa bugnaw ug madag-um nga panahon. '
              'Ayaw palabii ang nitrogen / urea — pag-split application. '
              'Hupti nga mabaw ang tubig (2–3 cm). '
              'Pag-spray og tricyclazole o isoprothiolane kung adunay timailhan.',
        );

      case 'brownspot':
      case 'brown_spot':
        return _pick(
          'Brown spot indicates nutrient deficiency, particularly potassium and zinc. '
              'Apply balanced NPK fertilizer and zinc sulfate. '
              'Treat seeds with fungicide before planting for the next crop cycle.',
          'Ang brown spot ay kadalasang tanda ng kulang na sustansya, lalo na potassium at zinc. '
              'Mag-apply ng complete NPK fertilizer at zinc sulfate. '
              'I-treat ang binhi ng fungicide bago magtanim para sa susunod na season.',
          'Ang brown spot kasagarang timaan sa kakulang sa sustansya, ilabina ang potassium ug zinc. '
              'Pagbutang og kumpletong NPK nga abono ug zinc sulfate. '
              'Tambali ang binhi og fungicide sa dili pa itanom alang sa sunod nga tingtanom.',
        );

      case 'healthy':
        return _pick(
          'The leaf appears healthy! Continue regular field inspections, maintain adequate water levels, and apply balanced fertilizer.',
          'Ang dahon ay mukhang malusog! Ipagpatuloy ang regular na pagmamasid sa bukid, wastong pag-iwan ng tubig, at balanseng pataba.',
          'Ang dahon maayo ug himsog tan-awon! Padayona ang regular nga pagbisita sa umahan, saktong pagdumala sa tubig, ug timbang nga pag-abono.',
        );

      case 'leaf_scald':
        return _pick(
          'Leaf scald is prevalent during rainy weather. Use certified clean seeds, avoid high nitrogen doses, and increase planting distance for airflow.',
          'Ang leaf scald ay madalas makita sa tag-ulan. Gumamit ng certified seeds, bawasan ang nitrogen, at dagdagan ang agwat ng tanim.',
          'Ang leaf scald kasagaran sa ting-ulan. Gamit og certified seeds, menosi ang nitrogen, ug dugangi ang agwat sa tanom.',
        );

      case 'narrow_brown_spot':
        return _pick(
          'Narrow brown spot is linked to potassium deficiency. Apply muriate of potash and spray systemic fungicide if infection is severe.',
          'Ang narrow brown spot ay dulot ng kulang na potash. Mag-apply ng potassium chloride at mag-spray ng systemic fungicide kung matindi.',
          'Ang narrow brown spot tungod sa kakulang sa potash. Pagbutang og potassium chloride ug pag-spray og systemic fungicide kung grabe.',
        );

      case 'neck_blast':
        return _pick(
          'CRITICAL: Neck blast damages panicles during heading. Spray systemic fungicide (tricyclazole) right at 5% heading to protect yield.',
          'KRITIKAL: Ang neck blast ay tumatama sa heading stage. Mag-spray ng tricyclazole kapag 5% na ang namumunga para maprotektahan ang ani.',
          'KRITIKAL: Ang neck blast moigo sa heading stage. Pag-spray og tricyclazole inig 5% na nga namunga aron mapanalipdan ang abot.',
        );

      case 'rice_hispa':
        return _pick(
          'Rice hispa beetles scrape green leaf tissue. Clip and destroy damaged leaf tips, or spray registered insecticide if threshold is exceeded.',
          'Ang rice hispa beetle ay kumakain ng berdeng dahon. Putulin at sunugin ang dulo ng apektadong dahon o mag-spray ng rehistradong pamatay-peste.',
          'Ang bakukang nga rice hispa mokaon sa berdeng dahon. Putla ug sunoga ang apektadong dahon o pag-spray og rehistradong insecticide.',
        );

      case 'sheath_blight':
        return _pick(
          'Sheath blight thrives in dense, humid canopies. Improve aeration, ensure adequate potassium, and apply validamycin as needed.',
          'Ang sheath blight ay lumalala sa masiksik na tanim. Bawasan ang density para mahanginan, tiyaking may potassium, at mag-apply ng validamycin.',
          'Ang sheath blight mograbe sa dasok nga tanom. Hatagi og kahigayonan nga mahanginan, siguroa ang potassium, ug pag-apply og validamycin.',
        );

      case 'tungro':
        return _pick(
          'Tungro is transmitted by green leafhoppers. Rogue and destroy infected yellow plants, control leafhoppers, and plant resistant varieties.',
          'Ang tungro ay virus na dala ng green leafhopper. Bunutin at sunugin ang dilaw na halaman, kontrolin ang insekto, at magtanim ng matitibay na binhi.',
          'Ang tungro usa ka virus nga dala sa green leafhopper. Ibta ug sunoga ang dalag nga tanom, patya ang leafhopper, ug pagtanom og lig-on nga binhi.',
        );

      default:
        return _pick(
          'Continue monitoring your field conditions and consult a local DA Agricultural Technologist for proper diagnosis.',
          'Patuloy na subaybayan ang kondisyon ng iyong bukid at kumonsulta sa pinakamalapit na DA Agricultural Technologist para sa wastong pagsusuri.',
          'Padayon sa pagbantay sa kahimtang sa imong uma ug konsultaha ang pinakaduol nga DA Agricultural Technologist alang sa saktong pagsusi.',
        );
    }
  }

  // ── Weather Descriptions ──────────────────────────────────────────────────
  String get wdSunny => _pick('Sunny & Clear', 'Mainit at Maliwanag', 'Adlawon ug Maayo');
  String get wdHotSunny => _pick('Hot & Sunny', 'Mainit Kaayo', 'Mainit ug Adlawon');
  String get wdPartlyCloudy => _pick('Partly Cloudy', 'May Ulap', 'May Panganod');
  String get wdHumidCloudy => _pick('Humid & Overcast', 'Maulap at Mahalumigmig', 'Maulanon ug Mainit');
  String get wdRainy => _pick('Rainy', 'Maulan', 'Maulanon');
  String get wdStormyRain => _pick('Stormy Rain', 'Mabagyong Ulan', 'Bagyo ug Ulan');
  String get wdHeavyRain => _pick('Heavy Rain', 'Malakas na Ulan', 'Kusog nga Ulan');
  String get wdWindy => _pick('Windy', 'Malakas ang Hangin', 'Kusog ang Hangin');

  // ── Yield Estimation Screen ───────────────────────────────────────────────
  String get yieldTitle => _pick(
      'Yield Estimator', 'Tagasukat ng Ani', 'Tagabanabana sa Abot');
  String get yieldFieldSummary => _pick(
      'ACTIVE FIELD', 'AKTIBONG BUKID', 'AKTIBONG UMA');
  String get yieldEstimateBtn => _pick(
      'Estimate Yield', 'Tantiyahin ang Ani', 'Bantayi ang Abot');
  String get yieldCalculating => _pick(
      'Calculating…', 'Kinakalkula…', 'Ginakalkula…');
  String get yieldEstimate => _pick('Estimated Yield', 'Tinatayang Ani', 'Tinantyang Abot');
  String get yieldCavans => _pick('cavans', 'cavans', 'cavans');
  String get yieldForField => _pick('For field', 'Para sa bukid', 'Para sa uma');
  String get yieldConfidence => _pick('Model Confidence', 'Katiyakan ng Modelo', 'Kasiguroan sa Modelo');
  String get yieldRiskFactors => _pick('Risk Factors', 'Mga Panganib', 'Mga Risgo');
  String get yieldRecommendations => _pick(
      'Yield Improvement Tips', 'Mga Tip para Mapabuti ang Ani', 'Mga Tip aron Mapauswag ang Abot');
  String get yieldDisclaimer => _pick(
      'Estimates are generated by the PalayPlan heuristic model using your field profile and 7-day forecast data. Always validate with your local DA agronomist.',
      'Ang mga tantiya ay ginawa ng modelong heuristic ng PalayPlan gamit ang profile ng bukid at 7-araw na forecast. Palaging i-validate sa inyong DA agronomist.',
      'Ang mga banabana gihimo sa heuristic nga modelo sa PalayPlan gamit ang profile sa uma ug 7-adlaw nga forecast. Kanunay i-validate sa imong DA agronomist.');
  String get yieldHowTitle => _pick('How It Works', 'Paano Gumagana', 'Giunsa Kini Nagtrabaho');
  String get yieldStep1 => _pick(
      'Your field profile (variety, area, growth stage) is submitted to the backend.',
      'Ang profile ng bukid (binhi, laki, yugto) ay isinumite sa backend.',
      'Ang profile sa uma (binhi, gidak-on, yugto) gi-submit sa backend.');
  String get yieldStep2 => _pick(
      'Live 7-day weather data for your location is fetched from Open-Meteo.',
      'Ang live 7-araw na datos ng panahon para sa iyong lokasyon ay kinukuha mula sa Open-Meteo.',
      'Ang live 7-adlaw nga datos sa panahon sa imong lokasyon gikuha sa Open-Meteo.');
  String get yieldStep3 => _pick(
      'The heuristic model returns estimated cavans, climate risk level, and improvement tips.',
      'Ang heuristic na modelo ay nagbabalik ng tinatayang cavans, antas ng panganib, at mga tip.',
      'Ang heuristic nga modelo nagbalik og tinantyang cavans, lebel sa risgo, ug mga tip.');

  // ── Internal helper ───────────────────────────────────────────────────────
  String _pick(String en, String fil, String ceb) {
    switch (lang) {
      case AppLanguage.english:
        return en;
      case AppLanguage.filipino:
        return fil;
      case AppLanguage.bisaya:
        return ceb;
    }
  }
}
