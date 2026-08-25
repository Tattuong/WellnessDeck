import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessdeck/core/constants/iap_constants.dart';

void main() {
  test('ten coin packs and remove ads ids', () {
    expect(IapConstants.coinPackIds.length, 10);
    expect(IapConstants.coinPackIds.first, 'wd_pack_1');
    expect(IapConstants.coinPackIds.last, 'wd_pack_10');
    expect(IapConstants.removeAdsProductId, 'wd_remove_ads');
    expect(IapConstants.remoteConfigUrl, 'https://api2.blwsmartware.net/N251.json');
  });
}
