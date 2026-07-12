import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/sales_remote_data_source.dart';
import '../../domain/entities/buyer_offer.dart';

/// Buyer unit-sale offers for the Home screen and offer detail flow.
class OffersProvider extends ChangeNotifier {
  final SalesRemoteDataSource dataSource;

  OffersProvider({required this.dataSource});

  bool _loaded = false;
  bool _loading = false;
  bool get isLoading => _loading;

  List<BuyerOfferSummary> _offers = [];
  List<BuyerOfferSummary> get offers => _offers;

  final Set<String> _busy = {};

  bool isBusy(String saleId) => _busy.contains(saleId);

  Future<void> ensureLoaded() async {
    if (_loaded || _loading) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      _offers = await dataSource.listOffers();
      _loaded = true;
    } catch (_) {
      // Retry on next appearance.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<BuyerOfferDetail?> loadDetail(String saleId) async {
    return _mutate(saleId, () => dataSource.getOffer(saleId));
  }

  Future<BuyerOfferPreview?> loadPreview(String saleId) async {
    return _mutate(saleId, () => dataSource.previewOffer(saleId));
  }

  Future<String?> accept(String saleId) async {
    final detail = await _mutate(saleId, () => dataSource.acceptOffer(saleId));
    if (detail == null) return 'Could not accept the offer';
    _upsertSummary(detail);
    return null;
  }

  Future<String?> decline(String saleId) async {
    final detail = await _mutate(saleId, () => dataSource.declineOffer(saleId));
    if (detail == null) return 'Could not decline the offer';
    _upsertSummary(detail);
    return null;
  }

  Future<String?> claim(String saleId, String token) async {
    if (token.trim().isEmpty) return 'Please enter the claim token';
    final detail =
        await _mutate(saleId, () => dataSource.claimOffer(saleId, token));
    if (detail == null) return 'Could not claim the offer';
    _upsertSummary(detail);
    return null;
  }

  Future<T?> _mutate<T>(String saleId, Future<T> Function() action) async {
    if (_busy.contains(saleId)) return null;
    _busy.add(saleId);
    notifyListeners();
    try {
      return await action();
    } on ServerException catch (e) {
      throw e;
    } on NetworkException catch (e) {
      throw e;
    } finally {
      _busy.remove(saleId);
      notifyListeners();
    }
  }

  void _upsertSummary(BuyerOfferDetail detail) {
    final summary = BuyerOfferSummary(
      saleId: detail.saleId,
      status: detail.status,
      projectName: detail.projectName,
      unitLabel: detail.unitLabel,
      totalCost: detail.totalCost,
    );
    final idx = _offers.indexWhere((o) => o.saleId == detail.saleId);
    if (idx >= 0) {
      _offers = List.of(_offers)..[idx] = summary;
    } else {
      _offers = [summary, ..._offers];
    }
    notifyListeners();
  }
}
