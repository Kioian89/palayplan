/// Disease prediction data model and advice library.
///
/// Covers the 3 classes from the current TFLite model
/// (bacterial_leaf_blight, blast, brownspot) plus all 10 legacy classes
/// so the same service works with either model without code changes.
class DiseasePrediction {
  final String label;
  final double confidence; // 0.0 to 1.0
  final List<DiseaseCandidate> candidates;

  const DiseasePrediction({
    required this.label,
    required this.confidence,
    this.candidates = const [],
  });

  /// User-friendly capitalized name, e.g. "Bacterial Leaf Blight"
  String get displayName {
    final clean = label.toLowerCase().trim();
    switch (clean) {
      case 'blast':
      case 'leaf_blast':
        return 'Rice Leaf Blast';
      case 'brownspot':
      case 'brown_spot':
        return 'Brown Spot';
      case 'bacterial_leaf_blight':
        return 'Bacterial Leaf Blight';
      case 'healthy':
        return 'Healthy Leaf';
      case 'leaf_scald':
        return 'Leaf Scald';
      case 'narrow_brown_spot':
        return 'Narrow Brown Spot';
      case 'neck_blast':
        return 'Neck Blast';
      case 'rice_hispa':
        return 'Rice Hispa';
      case 'sheath_blight':
        return 'Sheath Blight';
      case 'tungro':
        return 'Tungro Virus';
      default:
        // Fallback: title-case underscore-separated words
        return label
            .split('_')
            .map((w) =>
                w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
    }
  }

  /// Plain-language practical tip with Filipino farming context.
  String get treatmentTip {
    switch (label.toLowerCase().trim()) {
      // ── 3-class model labels ──────────────────────────────────────────────
      case 'bacterial_leaf_blight':
        return 'Ang bacterial leaf blight ay kumakalat sa tubig at sugat ng halaman. '
            'Bawasan ang nitrogen fertilizer, patuyuin ang palayan ng 3–5 araw, '
            'at iwasan ang pagtatapon ng tubig mula sa nahawaang bukid. '
            'Magtanim ng disease-resistant varieties (e.g., NSIC Rc 222).';

      case 'blast':
      case 'leaf_blast':
        return 'Ang rice blast (piricularia) ay mabilis kumalat sa malamig at maulap na panahon. '
            'Huwag labisan ng urea — mag-split application. '
            'Panatilihing mababaw ang tubig (2–3 cm). '
            'Mag-spray ng tricyclazole o isoprothiolane kung may sintomas na.';

      case 'brownspot':
      case 'brown_spot':
        return 'Ang brown spot ay kadalasang tanda ng kulang na sustansya, lalo na potassium at zinc. '
            'Mag-apply ng complete NPK fertilizer at zinc sulfate. '
            'I-treat ang binhi ng fungicide bago magtanim para sa susunod na season.';

      case 'healthy':
        return 'Ang dahon ay mukhang malusog! '
            'Ipagpatuloy ang regular na pagmamasid sa bukid, wastong pag-iwan ng tubig, '
            'at balanseng pataba. Magtala ng kondisyon ng taniman para sa mas mabuting pamamahala.';

      // ── Legacy 10-class model labels ─────────────────────────────────────
      case 'leaf_scald':
        return 'Ang leaf scald ay madalas makita sa tag-ulan o sa mga halamang mahina ang resistansya. '
            'Gumamit ng certified disease-free seeds. Bawasan ang pataba at dagdagan ang agwat ng tanim '
            'para bumaba ang halumigmig sa loob ng palayan.';

      case 'narrow_brown_spot':
        return 'Ang narrow brown spot ay karaniwang dulot ng kulang na potash. '
            'Mag-apply ng potassium chloride (muriate of potash). '
            'Mag-spray ng systemic fungicide (e.g., propiconazole) kung matindi na ang impeksyon.';

      case 'neck_blast':
        return 'KRITIKAL: Ang neck blast ay tumatama sa booting hanggang heading stage. '
            'Mag-spray ng systemic fungicide (tricyclazole o azoxystrobin) '
            'kapag 5% na ang namumunga (heading stage) para maprotektahan ang panicle. '
            'Maaaring mawalan ng buong ani kung hindi agad na gamutin.';

      case 'rice_hispa':
        return 'Ang rice hispa beetle ay kumakain sa dahon at naglalagay ng itlog sa loob nito. '
            'I-clip ang mga apektadong tip ng dahon at itapon. '
            'Kung matindi, mag-spray ng registered insecticide (e.g., cartap hydrochloride). '
            'Magtanim sa tamang panahon para maiwasan ang peak ng pesteng ito.';

      case 'sheath_blight':
        return 'Ang sheath blight (Rhizoctonia solani) ay lumalala sa masiksik na tanim '
            'at mataas na temperatura. Bawasan ang density ng tanim para magkaroon ng hangin. '
            'Panatilihing sapat ang potassium at mag-apply ng validamycin o hexaconazole '
            'sa sheath area ng halaman.';

      case 'tungro':
        return 'Ang tungro ay virus na dala ng green leafhopper (Nephotettix spp.). '
            'Alisin at sunugin ang mga nahawaang halaman (roguing). '
            'Kontrolin ang leafhopper gamit ang registered insecticide. '
            'Magtanim ng resistant varieties (NSIC Rc 160, IR64) at iwasang magtanim '
            'sa panahon ng mataas na leafhopper population.';

      default:
        return 'Patuloy na subaybayan ang kondisyon ng iyong bukid at kumonsulta '
            'sa pinakamalapit na DA Agricultural Technologist para sa wastong pagsusuri.';
    }
  }

  /// Short severity note used in UI chips (1–4 words)
  String get severityHint {
    switch (label.toLowerCase().trim()) {
      case 'neck_blast':
        return 'Treat Immediately';
      case 'tungro':
        return 'Remove Plants';
      case 'blast':
      case 'leaf_blast':
      case 'sheath_blight':
        return 'Apply Fungicide';
      case 'bacterial_leaf_blight':
        return 'Drain Field';
      case 'brownspot':
      case 'brown_spot':
      case 'narrow_brown_spot':
        return 'Add Fertilizer';
      case 'leaf_scald':
        return 'Improve Spacing';
      case 'rice_hispa':
        return 'Remove & Spray';
      case 'healthy':
        return 'Keep Monitoring';
      default:
        return 'Consult Technician';
    }
  }
}

class DiseaseCandidate {
  final String label;
  final double confidence;

  const DiseaseCandidate({
    required this.label,
    required this.confidence,
  });

  String get displayName =>
      DiseasePrediction(label: label, confidence: confidence).displayName;
}
