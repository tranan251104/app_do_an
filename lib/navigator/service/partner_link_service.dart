import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerLinkService {
  PartnerLinkService._();

  // Keep a local fallback so partner links still work when the catalog API is
  // unavailable and to preserve the synchronous lookup used by existing UI.
  static const Map<String, String> _partnerUrls = {
    'grab': 'https://www.grab.com/vn/',
    'be': 'https://be.com.vn/',
    'cgv': 'https://www.cgv.vn/',
    'galaxy cinema': 'https://www.galaxycine.vn/',
    'lotte cinema': 'https://www.lottecinemavn.com/',
    'garena': 'https://napthe.vn/',
    'fpt play': 'https://fptplay.vn/',
    'shopee': 'https://shopee.vn/',
    'lazada': 'https://www.lazada.vn/',
    'shopeefood': 'https://shopeefood.vn/',
    'traveloka': 'https://www.traveloka.com/vi-vn/',
    'agoda': 'https://www.agoda.com/vi-vn/',
    'spx': 'https://spx.vn/vi',
    'ticketbox': 'https://ticketbox.vn/',
    'vieon': 'https://vieon.vn/',
    'đường sắt việt nam': 'https://dsvn.vn/',
    'lotte mart': 'https://www.lottemart.vn/',
    'kfc': 'https://www.kfcvietnam.com.vn/',
    'highlands coffee': 'https://www.highlandscoffee.com.vn/',
    'tiki': 'https://tiki.vn/',
    'winmart': 'https://winmart.vn/',
    'apple store': 'https://www.apple.com/vn/store',
    'fpt shop': 'https://fptshop.com.vn/',
    'canifa': 'https://canifa.com/',
    'h&m': 'https://www2.hm.com/vi_vn/index.html',
    'guardian': 'https://www.guardian.com.vn/',
    'pharmacity': 'https://www.pharmacity.vn/',
    'decathlon': 'https://www.decathlon.vn/',
    'the coffee house': 'https://thecoffeehouse.com/',
    'green sm food': 'https://www.greensm.com/vn-vi/greensm-ngon',
    "pizza 4p's": 'https://pizza4ps.com/vn/',
    'starbucks': 'https://www.starbucks.vn/',
    'burger king': 'https://burgerking.vn/',
    'sapporo beer': 'https://sapporovietnam.com.vn/',
    'xe khách phương trang': 'https://futabus.vn/',
    'metro hà nội': 'https://metrohanoi.vn/',
    'netflix': 'https://www.netflix.com/vn/',
    'thế giới di động': 'https://www.thegioididong.com/',
    'điện máy xanh': 'https://www.dienmayxanh.com/',
    'cellphones': 'https://cellphones.com.vn/',
    'uniqlo': 'https://www.uniqlo.com/vn/vi/',
    'zara': 'https://www.zara.com/vn/',
    'vinpearl': 'https://vinpearl.com/vi',
    'furama resort đà nẵng': 'https://furamavietnam.com/',
    'vietnam airlines': 'https://www.vietnamairlines.com/vn/vi/home',
    'bệnh viện vinmec': 'https://www.vinmec.com/vie/',
    'medic hòa hảo': 'https://medic.com.vn/',
    'california fitness': 'https://fit.cali.vn/',
    'coursera': 'https://www.coursera.org/',
    'ielts fighter': 'https://ielts-fighter.com/',
    'cg3d': 'https://cg3d.com.vn/',
    'con cưng': 'https://concung.com/',
    'petmart': 'https://www.petmart.vn/',
  };

  static const Map<String, String> _aliases = {
    'galaxy': 'galaxy cinema',
    'becar': 'be',
    'vinmart': 'winmart',
    'baemin': 'green sm food',
    'phở 24': "pizza 4p's",
    'resort đà nẵng': 'furama resort đà nẵng',
    'phòng khám hòa hảo': 'medic hòa hảo',
    'cg art school': 'cg3d',
  };

  static Uri? urlFor(String partnerName) {
    final normalizedName = partnerName.trim().toLowerCase();
    final lookupName = _aliases[normalizedName] ?? normalizedName;
    final url = _partnerUrls[lookupName];
    return url == null ? null : Uri.parse(url);
  }

  static Future<bool> open(String partnerName) async {
    AppLogger.action('Open partner link', {'partner': partnerName});
    final normalized = partnerName.trim().toLowerCase();
    Map<String, dynamic>? partner;

    try {
      final partners = await AppServices.catalog.partners();
      for (final item in partners) {
        if ((item['name']?.toString().trim().toLowerCase() ?? '') ==
            normalized) {
          partner = item;
          break;
        }
      }
    } catch (error) {
      AppLogger.warning('PARTNER', 'Backend partner catalog unavailable; using local fallback', {'partner': partnerName, 'error': error.toString()});
      // The bundled URL below remains usable while the backend is offline.
    }

    final candidates = <String?>[
      if (partner != null &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android)
        partner['androidDeepLink']?.toString(),
      if (partner != null &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.iOS)
        partner['iosDeepLink']?.toString(),
      partner?['webUrl']?.toString(),
      partner?['fallbackUrl']?.toString(),
      urlFor(partnerName)?.toString(),
    ];

    for (final raw in candidates) {
      if (raw == null || raw.trim().isEmpty) continue;
      final uri = Uri.tryParse(raw);
      if (uri == null) continue;
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          AppLogger.repo('PARTNER', 'Launch URL result', {'partner': partnerName, 'launched': launched, 'scheme': uri.scheme});
          return launched;
        }
      } catch (error) {
        AppLogger.warning('PARTNER', 'Candidate URL launch failed', {'partner': partnerName, 'error': error.toString()});
      }
    }
    AppLogger.error('PARTNER', 'No partner URL could be opened', data: {'partner': partnerName});
    return false;
  }
}
