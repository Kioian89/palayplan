import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../providers/language_provider.dart';

class FieldRecommendation {
  final String stageName;
  final int currentDay;
  final String headline;
  final String fertilizerTitle;
  final String fertilizerDetail;
  final bool delayFertilizer;
  final String waterTitle;
  final String waterDetail;
  final String pestTitle;
  final String pestDetail;

  const FieldRecommendation({
    required this.stageName,
    required this.currentDay,
    required this.headline,
    required this.fertilizerTitle,
    required this.fertilizerDetail,
    required this.delayFertilizer,
    required this.waterTitle,
    required this.waterDetail,
    required this.pestTitle,
    required this.pestDetail,
  });
}

class RecommendationService {
  static FieldRecommendation generate({
    required FieldProfile profile,
    required AppLanguage lang,
    WeatherForecast? forecast,
  }) {
    final day = profile.currentDay;
    final totalDays = profile.daysToMaturity;

    // Rain risk detection from forecast
    final todayRain = forecast?.dailyForecast.isNotEmpty == true
        ? forecast!.dailyForecast.first.rainProbabilityPct
        : 20.0;
    final rainRisk = todayRain >= 50.0;
    final highHumidity = forecast?.dailyForecast.isNotEmpty == true
        ? forecast!.dailyForecast.first.humidityPct >= 80
        : false;

    if (day <= 14) {
      // Phase 1: Seedbed & Early Transplanting
      return FieldRecommendation(
        stageName: _pick(lang, 'Seedbed & Establishment', 'Punlaan at Pagtatanim', 'Semilyahan ug Pagtanom'),
        currentDay: day,
        headline: _pick(
          lang,
          'Focus on uniform seedling establishment and snail protection.',
          'Tutukan ang pantay na pagtubo ng punla at proteksyon laban sa kuhol.',
          'Tutoki ang maayong pagtubo sa semilya ug panalipod batok sa kuhol.',
        ),
        fertilizerTitle: _pick(lang, 'Basal Fertilization (14-14-14)', 'Basal Application (14-14-14)', 'Basal Application (14-14-14)'),
        delayFertilizer: rainRisk,
        fertilizerDetail: rainRisk
            ? _pick(
                lang,
                'Rain chance is elevated ($todayRain%). Pause basal application to prevent runoff.',
                'Mataas ang tsansa ng ulan ($todayRain%). Ipantig muna ang pag-aabono upang hindi maanod.',
                'Taas ang tsansa sa ulan ($todayRain%). I-oktaba una ang abono aron dili maanod.',
              )
            : _pick(
                lang,
                'Soil is receptive. Incorporate complete fertilizer thoroughly during final harrowing.',
                'Magandang oras maglagay. Ihalo ang complete fertilizer sa huling pagsusuyod.',
                'Nindot nga panahon magbutang. Isagol ang complete fertilizer sa kataposang pagsuyod.',
              ),
        waterTitle: _pick(lang, 'Shallow Water (2-3 cm)', 'Mababaw na Tubig (2-3 cm)', 'Mababaw nga Tubig (2-3 cm)'),
        waterDetail: _pick(
          lang,
          'Keep water shallow to prevent submerging tender seedlings while deterring weeds.',
          'Panatilihing 2-3 cm ang lalim ng tubig upang hindi malunod ang batang tanim.',
          'Pabilina nga 2-3 cm ang giladmon sa tubig aron dili malumos ang tanom.',
        ),
        pestTitle: _pick(lang, 'Golden Apple Snail Alert', 'Bantayan ang Golden Kuhol', 'Bantayi ang Golden Kuhol'),
        pestDetail: _pick(
          lang,
          'Handpick snails early in the morning and install screens at water inlets.',
          'Pumulot ng kuhol tuwing umaga at maglagay ng sala-sala sa lagusan ng tubig.',
          'Pamunit og kuhol sayo sa buntag ug pagbutang og salaan sa agianan sa tubig.',
        ),
      );
    } else if (day <= 45) {
      // Phase 2: Vegetative & Active Tillering
      return FieldRecommendation(
        stageName: _pick(lang, 'Vegetative & Active Tillering', 'Palaki at Pagsusuwi', 'Pagtubo ug Pangsanga'),
        currentDay: day,
        headline: _pick(
          lang,
          'Maximize productive tillers through AWD intermittent irrigation.',
          'Pabilisin ang pagdami ng suwi gamit ang kontroladong patubig (AWD).',
          'Padaghanon ang mga sanga gamit ang sakto nga patubig (AWD).',
        ),
        fertilizerTitle: _pick(lang, 'Early Nitrogen Topdress (Urea)', 'Topdress na Nitroheno (Urea)', 'Topdress nga Nitroheno (Urea)'),
        delayFertilizer: rainRisk,
        fertilizerDetail: rainRisk
            ? _pick(
                lang,
                'Rain probability is $todayRain%. Delay urea application by 24h to avoid nitrogen leaching.',
                'May $todayRain% posibilidad ng ulan. Iantig muna ang Urea ng 24 oras upang hindi masayang.',
                'Adunay $todayRain% tsansa sa ulan. I-oktaba una ang Urea og 24 oras aron dili masayang.',
              )
            : _pick(
                lang,
                'Weather window is clear. Broadcast Urea early morning when dew has dried from leaves.',
                'Maaliwalas ang panahon. Mag-abono ng Urea sa umaga kapag tuyo na ang hamog sa dahon.',
                'Hayag ang panahon. Sabwag og Urea sa buntag kon uga na ang yamog sa dahon.',
              ),
        waterTitle: _pick(lang, 'AWD Water Cycling', 'AWD Pagpapalubog at Pagpapatuyo', 'AWD Pagpasulod ug Pagpa-uga'),
        waterDetail: _pick(
          lang,
          'Allow water to naturally drop 5 cm below surface before re-flooding to strengthen roots.',
          'Hayaang bumaba ang tubig ng 5 cm bago magpapasok muli upang lumalim ang ugat.',
          'Tugoti nga moubos ang tubig og 5 cm sa dili pa magpatubig pag-usab aron molig-on ang gamot.',
        ),
        pestTitle: _pick(lang, 'Stem Borer & Leaf Blast Watch', 'Bantay sa Stem Borer at Blast', 'Bantay sa Stem Borer ug Blast'),
        pestDetail: highHumidity
            ? _pick(
                lang,
                'High humidity detected. Inspect leaf collars for blast lesions and deadhearts.',
                'Mataas ang halumigmig. Suriin ang dahon kung may blast at patay na dulo (deadheart).',
                'Taas ang kaumog. Susiha ang dahon kon dunay blast ug patay nga tumoy.',
              )
            : _pick(
                lang,
                'Low pest pressure. Continue weekly field walk inspections.',
                'Mababa ang banta ng peste. Magpatuloy sa lingguhang pag-iinspeksyon sa bukid.',
                'Ubos ang hulga sa peste. Padayon sa sinemana nga pagsusi sa umahan.',
              ),
      );
    } else if (day <= totalDays - 20) {
      // Phase 3: Reproductive / Panicle Initiation & Flowering
      return FieldRecommendation(
        stageName: _pick(lang, 'Reproductive & Panicle Initiation', 'Pagbubunga at Paglilihi', 'Pagbunga ug Pagmabdos'),
        currentDay: day,
        headline: _pick(
          lang,
          'Critical grain filling stage. Ensure continuous water depth and balanced potash.',
          'Maselang yugto ng paglilihi. Siguraduhing may sapat na tubig at potassium.',
          'Delikado nga yugto sa pagmabdos. Siguroha ang saktong tubig ug potassium.',
        ),
        fertilizerTitle: _pick(lang, 'Panicle Topdress (Urea + 0-0-60)', 'Abotong Pampalaki ng Butil (Urea + Potash)', 'Abono Pampadako sa Butil (Urea + Potash)'),
        delayFertilizer: rainRisk,
        fertilizerDetail: rainRisk
            ? _pick(
                lang,
                'Rain expected ($todayRain%). Postpone topdressing to prevent nutrient runoff.',
                'May inaasahang ulan ($todayRain%). Ipantig muna ang pagpapataba upang hindi maagos.',
                'Adunay gitagna nga ulan ($todayRain%). I-oktaba una ang pag-abono aron dili maanod.',
              )
            : _pick(
                lang,
                'Ideal conditions. Apply Muriate of Potash to enhance grain filling and reduce empty spikelets.',
                'Magandang panahon. Maglagay ng Potash upang maiwasan ang ipa at mapataba ang butil.',
                'Maayong panahon. Pagbutang og Potash aron malikayan ang upa ug manambok ang butil.',
              ),
        waterTitle: _pick(lang, 'Continuous Water (3-5 cm)', 'Tuloy-tuloy na Tubig (3-5 cm)', 'Padayon nga Tubig (3-5 cm)'),
        waterDetail: _pick(
          lang,
          'Do NOT allow soil to dry out during flowering. Drought stress now directly causes empty grains.',
          'HUWAG patuyuin ang lupa sa panahong ito. Ang kakulangan sa tubig ay nagdudulot ng ipa.',
          'AYAW paugha ang yuta niining panahona. Ang kauhaw moresulta sa daghang upa.',
        ),
        pestTitle: _pick(lang, 'Bacterial Blight & Bug Shield', 'Panangga sa Sakit at Rice Bug', 'Panalipod sa Sakit ug Dangaw'),
        pestDetail: _pick(
          lang,
          'Scout for rice bugs (tiangaw) at dusk and dawn. Maintain clean bunds and weed barriers.',
          'Magmatyag sa atangya/tiangaw tuwing madaling araw at dapithapon. Linisin ang pilapil.',
          'Bantayi ang dangaw/tiangaw sayo sa kabuntagon ug hapon. Hinloi ang mga pilapil.',
        ),
      );
    } else {
      // Phase 4: Ripening & Harvest
      final daysLeft = totalDays - day;
      return FieldRecommendation(
        stageName: _pick(lang, 'Ripening & Harvest Prep', 'Pahinog at Pag-aani', 'Pahinog ug Ting-ani'),
        currentDay: day,
        headline: _pick(
          lang,
          'Grains turning golden straw. Prepare for terminal drainage and combine harvest.',
          'Dumidilaw na ang mga butil. Maghanda sa huling pagpapatuyo at paggapas.',
          'Nagdalag na ang mga butil. Pangandam sa kataposang pagpa-uga ug pag-ani.',
        ),
        fertilizerTitle: _pick(lang, 'No Chemical Fertilizers Needed', 'Wala Nang Kailangang Pataba', 'Wala nay Gikinahanglang Abono'),
        delayFertilizer: false,
        fertilizerDetail: _pick(
          lang,
          'Chemical intake has ceased. Any fertilizer applied now is wasted.',
          'Tapos na ang pagsipsip ng sustansya. Huwag nang maglagay ng anumang pataba.',
          'Nahuman na ang pagsuyop sa sustansya. Ayaw na pagbutang og bisan unsa nga abono.',
        ),
        waterTitle: _pick(lang, 'Terminal Drainage (7-10 Days Before)', 'Pagtuyo ng Bukid (7-10 Araw Bago)', 'Pagpa-uga sa Umahan (7-10 Adlaw Sa Dili Pa)'),
        waterDetail: _pick(
          lang,
          'Cut water inflow and drain field completely to allow machinery entry and uniform drying.',
          'Isara ang patubig at patuyuin ang palayan upang makapasok ang makina sa pag-ani.',
          'Sirad-i ang patubig ug paugha ang basakan aron makasulod ang makina sa pag-ani.',
        ),
        pestTitle: _pick(lang, 'Harvest Timing & Storage', 'Tamang Oras ng Pag-ani', 'Saktong Oras sa Pag-ani'),
        pestDetail: _pick(
          lang,
          'Harvest when 85% of panicles are golden straw colored (~$daysLeft days remaining). Sun dry within 24h.',
          'Mag-ani kapag 85% ng uhay ay kulay ginto na (~$daysLeft araw na lang). Patuyuin sa loob ng 24 oras.',
          'Pag-ani kon 85% sa uhay kolor bulawan na (~$daysLeft ka adlaw nabilin). Pa-ugaha sulod sa 24 oras.',
        ),
      );
    }
  }

  static String _pick(AppLanguage lang, String en, String fil, String ceb) {
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
