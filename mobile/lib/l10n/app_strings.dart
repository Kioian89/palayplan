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

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  String get navHome    => _pick('Home', 'Tahanan', 'Balay');
  String get navWeather => _pick('Weather', 'Panahon', 'Klima');
  String get navScan    => _pick('Scan', 'I-scan', 'I-scan');
  String get navCalendar => _pick('Calendar', 'Kalendaryo', 'Kalendaryo');
  String get navAdvisory => _pick('Advisories', 'Abiso', 'Tambag');

  // ── Home Screen ────────────────────────────────────────────────────────────
  String get homeTitle   => _pick('Dashboard', 'Dashboard', 'Dashboard');
  String get homeLocation => _pick('Ubay, Bohol', 'Ubay, Bohol', 'Ubay, Bohol');
  String get filterAll   => _pick('All', 'Lahat', 'Tanan');
  String get filterVeg   => _pick('Vegetative', 'Palaki', 'Pagtubo');
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
  String get accuracyBadge => _pick('95.8% ACCURACY', '95.8% KATUMPAYAN', '95.8% KASIGUROAN');
  String get onDeviceAi => _pick('On-Device AI', 'AI sa Cellphone', 'AI sa Cellphone');
  String get fieldStatusTitle => _pick("Today's Field Status", 'Katayuan ng Bukid Ngayon', 'Kahimtang sa Uma Karon');
  String get seeAll => _pick('See All', 'Tingnan Lahat', 'Tan-awa Tanan');

  String get featFertilizer => _pick('Fertilizer Schedule', 'Iskedyul ng Pataba', 'Iskedyul sa Abono');
  String get featFertilizerSub => _pick('Nitrogen Top-Dress · Active Vegetative', 'Paglalagay ng Nitroheno · Yugto ng Paglaki', 'Pagbutang og Nitroheno · Yugto sa Pagtubo');
  String get featFertilizerBadge => _pick('Optimal Today', 'Mainam Ngayon', 'Maayo Karon');

  String get featWeather    => _pick('7-Day Weather Forecast', '7-Araw na Panahon', '7-Adlaw nga Klima');
  String get featWeatherSub => _pick('29°C · Rain likelihood low', '29°C · Mababa ang posibilidad ng ulan', '29°C · Gamay ang tsansa sa ulan');
  String get featWeatherBadge => _pick('Favorable', 'Paborable', 'Paborable');

  String get featCalendar   => _pick('Cropping Calendar', 'Kalendaryo ng Pagtatanim', 'Kalendaryo sa Pagtanom');
  String get featCalendarSub => _pick('Day 42 of 110 · Harvest in 68d', 'Araw 42 sa 110 · Pag-ani sa 68 araw', 'Adlaw 42 sa 110 · Ting-ani sa 68 ka adlaw');
  String get featCalendarBadge => _pick('Phase 2', 'Yugto 2', 'Yugto 2');

  String get featAdvisory   => _pick('All Advisories', 'Lahat ng Abiso', 'Tanan nga Tambag');
  String get featAdvisorySub => _pick('agronomic advisories active', 'aktibong abiso sa pagsasaka', 'aktibong tambag sa pag-uma');
  String get featAdvisoryBadge => _pick('Monitored', 'Binabantayan', 'Gibantayan');

  String get featScan       => _pick('Scan Rice Leaf Disease', 'I-scan ang Sakit ng Palay', 'I-scan ang Sakit sa Humay');

  // ── Scan Screen ────────────────────────────────────────────────────────────
  String get scanTitle    => _pick('Rice Disease Scanner', 'Tagasuri ng Sakit ng Palay', 'Tigsusi sa Sakit sa Humay');
  String get scanTip      => _pick(
    'Take a close-up photo of a single rice leaf in bright, even lighting.',
    'Kumuha ng malapit na larawan ng isang dahon ng palay sa maliwanag na lugar.',
    'Kuhaa og duol nga hulagway sa usa ka dahon sa humay sa hayag nga dapit.',
  );
  String get scanBtnPhoto  => _pick('Take Photo', 'Kumuha ng Larawan', 'Kuhaa og Litrato');
  String get scanBtnGallery => _pick('Gallery', 'Galeriya', 'Galeriya');
  String get scanNoPhoto   => _pick('No photo selected yet', 'Wala pang larawang napili', 'Wala pay litratong napili');
  String get scanUploadPrompt => _pick('Choose camera or upload from gallery', 'Pumili sa camera o mag-upload sa gallery', 'Pilia sa camera o pag-upload sa gallery');
  String get scanAnalyzing => _pick('Analyzing leaf…', 'Sinusuri ang dahon…', 'Gisusi ang dahon…');

  // ── Result Screen ──────────────────────────────────────────────────────────
  String get resultTitle    => _pick('Diagnosis Result', 'Resulta ng Pagsusuri', 'Resulta sa Pagsusi');
  String get resultHealthy  => _pick('HEALTHY CROP', 'MALUSOG NA HALAMAN', 'HIMSOG ANG TANOM');
  String get resultDisease  => _pick('DISEASE DETECTED', 'MAY SAKIT NA NATUKLASAN', 'NAKIT-AN NGA MAY SAKIT');
  String get resultConfLabel => _pick('Confidence', 'Katiyakan', 'Kasiguroan');
  String get resultModelTag => _pick('On-Device TFLite Model', 'TFLite Modelo sa Telepono', 'TFLite Modelo sa Telepono');
  String get resultAction   => _pick('Recommended Action', 'Inirekomendang Aksyon', 'Girekomendar nga Buhaton');
  String get resultMaintain => _pick('Maintenance Tip', 'Tip sa Pangangalaga', 'Tip sa Pag-atiman');
  String get resultScanAgain => _pick('Scan Another Leaf', 'I-scan ang Ibang Dahon', 'I-scan ang Laing Dahon');
  String get resultSaveReport => _pick('Save Report', 'I-save ang Ulat', 'I-save ang Taho');
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
  String get resultSeverity => _pick('Severity Level', 'Antas ng Panganib', 'Lebel sa Risgo');
  String get resultHighRisk => _pick('High Risk', 'Mataas na Panganib', 'Taas nga Risgo');
  String get resultMedRisk  => _pick('Moderate Risk', 'Katamtamang Panganib', 'Kasarangan nga Risgo');
  String get resultLowRisk  => _pick('Low Risk', 'Mababang Panganib', 'Ubos nga Risgo');
  String get chipConsult   => _pick('Consult Technician', 'Kumonsulta sa Technician', 'Konsultaha ang Technician');
  String get chipFungicide => _pick('Get Fungicide', 'Maghanda ng Fungicide', 'Pag-andam og Fungicide');
  String get chipRescan    => _pick('Scan Again', 'I-scan Ulit', 'I-scan Pag-usab');

  // ── Weather Screen ─────────────────────────────────────────────────────────
  String get weatherTitle => _pick('7-Day Forecast', '7-Araw na Panahon', '7-Adlaw nga Klima');
  String get weatherUpcoming => _pick('Upcoming 7 Days', 'Paparating na 7 Araw', 'Mosunod nga 7 ka Adlaw');
  String get weatherSub   => _pick('7-day outlook for your field', '7-araw na panahon sa inyong bukid', '7-adlaw nga klima sa imong uma');
  String get weatherSuitablePlant => _pick('Suitable for planting', 'Angkop sa pagtatanim', 'Angay sa pagtanom');
  String get weatherMonitorPest   => _pick('Monitor for pests', 'Bantayan ang mga peste', 'Bantayan ang mga peste');
  String get weatherDelay         => _pick('Consider delaying farm work', 'Isaalang-alang ang pagpapaliban ng gawain', 'Hunahunaa ang pagpalangan sa trabaho sa uma');

  // ── Calendar Screen ────────────────────────────────────────────────────────
  String get calTitle     => _pick('Cropping Calendar', 'Kalendaryo ng Pagtatanim', 'Kalendaryo sa Pagtanom');
  String get calSeason    => _pick('Wet Season', 'Tag-ulan', 'Ting-ulan');
  String get calStartDate => _pick('Start Date', 'Petsa ng Simula', 'Petsa sa Pagsugod');
  String get calVariety   => _pick('Variety', 'Klase ng Palay', 'Klase sa Humay');
  String get calPhaseNursery => _pick('Nursery / Seedbed', 'Punla / Punlaan', 'Punla / Sabakan');
  String get calPhaseVeg  => _pick('Vegetative Stage', 'Yugto ng Paglaki', 'Yugto sa Pagtubo');
  String get calPhaseRep  => _pick('Reproductive Stage', 'Yugto ng Pagbubunga', 'Yugto sa Pagbunga');
  String get calPhaseMat  => _pick('Maturity / Harvest', 'Pag-aani', 'Ting-ani');

  // ── Advisory Screen ────────────────────────────────────────────────────────
  String get advTitle     => _pick('All Advisories', 'Lahat ng Abiso', 'Tanan nga Tambag');
  String get advEmpty     => _pick('No advisories right now.\nCheck back tomorrow!', 'Walang abiso ngayon.\nBumalik bukas!', 'Walay tambag karon.\nBalik ugma!');
  String get advLoading   => _pick('Fetching advisories…', 'Kinukuha ang mga abiso…', 'Gikuha ang mga tambag…');

  // ── Field Profile Settings ────────────────────────────────────────────────
  String get fieldSetupTitle => _pick('My Field Profile', 'Profile ng Bukid', 'Profile sa Uma');
  String get fieldSetupSub   => _pick(
    'Configure your location, rice variety, and planting date.',
    'I-set ang lokasyon, binhi, at petsa ng pagtatanim.',
    'I-set ang lokasyon, binhi, ug petsa sa pagtanom.',
  );
  String get fieldLocationLabel => _pick('Field Location', 'Lokasyon ng Bukid', 'Lokasyon sa Uma');
  String get fieldVarietyLabel  => _pick('Rice Variety', 'Binhi ng Palay', 'Binhi sa Humay');
  String get fieldDateLabel     => _pick('Sowing / Planting Date', 'Petsa ng Pagtatanim', 'Petsa sa Pagtanom');
  String get fieldAreaLabel     => _pick('Field Area (Hectares)', 'Laki ng Bukid (Ektarya)', 'Gidak-on sa Uma (Ektarya)');
  String get saveField          => _pick('Save Field Profile', 'I-save ang Profile', 'I-save ang Profile');
  String get fieldSavedSnackbar => _pick('Field profile updated!', 'Nai-save na ang profile ng bukid!', 'Na-save na ang profile sa uma!');

  // ── Language Settings ──────────────────────────────────────────────────────
  String get langPickerTitle => _pick('Select Language', 'Piliin ang Wika', 'Pilia ang Sinultian');
  String get langPickerSub   => _pick('Choose your preferred language', 'Piliin ang nais mong wika', 'Pilia ang gusto nimong sinultian');
  String get langEn  => 'English';
  String get langFil => 'Filipino (Tagalog)';
  String get langCeb => 'Bisaya (Cebuano)';

  // ── Disease Display Names ──────────────────────────────────────────────────
  String diseaseName(String rawLabel) {
    final clean = rawLabel.toLowerCase().trim();
    switch (clean) {
      case 'blast':
      case 'leaf_blast':
        return _pick('Rice Leaf Blast', 'Rice Leaf Blast (Tukob)', 'Rice Leaf Blast (Tukob)');
      case 'brownspot':
      case 'brown_spot':
        return _pick('Brown Spot', 'Brown Spot (Mantsang Kayumanggi)', 'Brown Spot (Kagid sa Dahon)');
      case 'bacterial_leaf_blight':
        return _pick('Bacterial Leaf Blight', 'Bacterial Leaf Blight (BLB)', 'Bacterial Leaf Blight (BLB)');
      case 'healthy':
        return _pick('Healthy Leaf', 'Malusog na Dahon', 'Himsog nga Dahon');
      case 'leaf_scald':
        return _pick('Leaf Scald', 'Leaf Scald', 'Leaf Scald');
      case 'narrow_brown_spot':
        return _pick('Narrow Brown Spot', 'Narrow Brown Spot', 'Narrow Brown Spot');
      case 'neck_blast':
        return _pick('Neck Blast', 'Neck Blast', 'Neck Blast');
      case 'rice_hispa':
        return _pick('Rice Hispa', 'Rice Hispa (Peste sa Dahon)', 'Rice Hispa (Bakukang sa Dahon)');
      case 'sheath_blight':
        return _pick('Sheath Blight', 'Sheath Blight', 'Sheath Blight');
      case 'tungro':
        return _pick('Tungro Virus', 'Tungro Virus (Pula-pula)', 'Tungro Virus (Pula-pula)');
      default:
        return rawLabel
            .split('_')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
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
