/*
 * Copyright (c) 2019 Larry Aasen. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:upgrader/upgrader.dart';

import 'mock_itunes_client.dart';

void main() {
  test('testing ITunesSearchAPI properties', () async {
    final iTunes = ITunesSearchAPI();
    expect(iTunes.debugEnabled, equals(false));
    iTunes.debugEnabled = true;
    expect(iTunes.debugEnabled, equals(true));
    expect(iTunes.iTunesDocumentationURL.length, greaterThan(0));
    expect(iTunes.lookupPrefixURL.length, greaterThan(0));
    expect(iTunes.searchPrefixURL.length, greaterThan(0));

    expect(
        iTunes.lookupURLByBundleId('com.google.Maps', useCacheBuster: false),
        equals(
            'https://itunes.apple.com/lookup?bundleId=com.google.Maps&country=US'));
    expect(iTunes.lookupURLById('585027354', useCacheBuster: false),
        equals('https://itunes.apple.com/lookup?id=585027354&country=US'));
    expect(
        iTunes.lookupURLByQSP({'id': '909253', 'entity': 'album'},
            useCacheBuster: false),
        equals('https://itunes.apple.com/lookup?id=909253&entity=album'));

    // Test the URL using the cache buster and remove it from the URL
    final testUrl =
        'https://itunes.apple.com/lookup?bundleId=com.google.Maps&country=US&_cb=';
    final url = iTunes
        .lookupURLByBundleId('com.google.Maps', useCacheBuster: true)!
        .substring(0, testUrl.length);

    expect(url, equals(testUrl));
  });

  test('testing lookupByBundleId', () async {
    final client = MockITunesSearchClient.setupMockClient();
    final iTunes = ITunesSearchAPI();
    iTunes.client = client;

    final response =
        await iTunes.lookupByBundleId('com.google.Maps', useCacheBuster: false);
    expect(response, isInstanceOf<Map>());
    final results = response!['results'];
    expect(results, isNotNull);
    expect(results.length, 1);
    final result0 = results[0];
    expect(result0, isNotNull);
    expect(result0['bundleId'], 'com.google.Maps');
    expect(result0['version'], '5.6');
    expect(ITunesResults.bundleId(response), 'com.google.Maps');
    expect(ITunesResults.releaseNotes(response), 'Bug fixes.');
    expect(ITunesResults.version(response), '5.6');
  }, skip: false);

  test('testing lookupByBundleId unknown app', () async {
    final client = MockITunesSearchClient.setupMockClient();
    final iTunes = ITunesSearchAPI();
    iTunes.client = client;

    final response = await iTunes.lookupByBundleId('com.google.MyApp',
        useCacheBuster: false);
    expect(response, isInstanceOf<Map>());
    final results = response!['results'];
    expect(results, isNotNull);
    expect(results.length, 0);
  }, skip: false);

  test('testing lookupById', () async {
    final client = MockITunesSearchClient.setupMockClient();
    final iTunes = ITunesSearchAPI();
    iTunes.client = client;

    final response =
        await iTunes.lookupById('585027354', useCacheBuster: false);
    expect(response, isInstanceOf<Map>());
    final results = response!['results'];
    expect(results, isNotNull);
    expect(results.length, 1);
    final result0 = results[0];
    expect(result0, isNotNull);
    expect(result0['bundleId'], 'com.google.Maps');
    expect(result0['releaseNotes'], 'Bug fixes.');
    expect(result0['version'], '5.6');
    expect(result0['currency'], 'USD');
    expect(ITunesResults.bundleId(response), 'com.google.Maps');
    expect(ITunesResults.releaseNotes(response), 'Bug fixes.');
    expect(ITunesResults.version(response), '5.6');
    expect(ITunesResults.currency(response), 'USD');
  }, skip: false);

  test('testing lookupById FR', () async {
    final client = MockITunesSearchClient.setupMockClient(country: 'FR');
    final iTunes = ITunesSearchAPI();
    iTunes.client = client;

    final response = await iTunes.lookupById('585027354',
        country: 'FR', useCacheBuster: false);
    expect(response, isInstanceOf<Map>());
    final results = response!['results'];
    expect(results, isNotNull);
    expect(results.length, 1);
    final result0 = results[0];
    expect(result0, isNotNull);
    expect(result0['bundleId'], 'com.google.Maps');
    expect(result0['version'], '5.6');
    expect(result0['currency'], 'EUR');
    expect(ITunesResults.bundleId(response), 'com.google.Maps');
    expect(ITunesResults.version(response), '5.6');
    expect(ITunesResults.currency(response), 'EUR');
  }, skip: false);
}
