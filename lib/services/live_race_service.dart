import 'dart:async';
import '../core/api/f1_api.dart';

/// Service per gestire il rilevamento live delle gare F1 e lo stato della sessione
class LiveRaceService {
  static LiveRaceService? _instance;
  static LiveRaceService get instance => _instance ??= LiveRaceService._();
  LiveRaceService._();

  Timer? _monitoringTimer;
  StreamController<LiveRaceStatus>? _statusController;
  StreamController<List<RaceControlMessage>>? _raceControlController;
  StreamController<LiveRaceInfo>? _liveRaceInfoController;
  
  DateTime? _lastDataUpdate;
  int? _currentSessionKey;
  LiveRaceStatus _currentStatus = LiveRaceStatus.unknown;
  List<RaceControlMessage> _recentRaceControl = [];

  /// Stream dello stato live della gara
  Stream<LiveRaceStatus> get liveStatusStream {
    _statusController ??= StreamController<LiveRaceStatus>.broadcast();
    return _statusController!.stream;
  }

  /// Stream dei messaggi di controllo gara
  Stream<List<RaceControlMessage>> get raceControlStream {
    _raceControlController ??= StreamController<List<RaceControlMessage>>.broadcast();
    return _raceControlController!.stream;
  }

  /// Stream delle informazioni complete della gara live
  Stream<LiveRaceInfo> get liveRaceInfoStream {
    _liveRaceInfoController ??= StreamController<LiveRaceInfo>.broadcast();
    return _liveRaceInfoController!.stream;
  }

  /// Stato attuale della gara
  LiveRaceStatus get currentStatus => _currentStatus;

  /// Ultimi messaggi di controllo gara
  List<RaceControlMessage> get recentRaceControl => _recentRaceControl;

  /// Inizia il monitoraggio live
  Future<void> startLiveMonitoring() async {
    // Ottieni la sessione corrente
    _currentSessionKey = await F1Api.getCurrentSessionKey();
    
    if (_currentSessionKey != null) {      
      // Avvia il timer di monitoraggio ogni 3 secondi
      _monitoringTimer?.cancel();
      _monitoringTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkLiveStatus());
      
      // Prima verifica immediata
      await _checkLiveStatus();
    } else {
      _updateStatus(LiveRaceStatus.noSession);
    }
  }

  /// Ferma il monitoraggio live
  void stopLiveMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Verifica lo stato live della gara
  Future<void> _checkLiveStatus() async {
    if (_currentSessionKey == null) return;

    try {
      // 1. Verifica se ci sono dati recenti (ultimi 10 secondi)
      final hasRecentData = await _checkRecentData();
      
      // 2. Ottieni messaggi di controllo gara
      await _updateRaceControlMessages();
      
      // 3. Verifica se le macchine stanno gareggiando
      final carsRacing = await _checkCarsRacing();
      
      // 4. Determina lo stato della gara
      final newStatus = _determineRaceStatus(hasRecentData, carsRacing);
      
      if (newStatus != _currentStatus) {
        _updateStatus(newStatus);
      }

    } catch (e) {
      _updateStatus(LiveRaceStatus.error);
    }
  }

  /// Verifica se ci sono dati recenti dalle API
  Future<bool> _checkRecentData() async {
    try {
      // Prova a ottenere dati recenti dalle API
      final latestPositions = await F1Api.getLatestPositions();
      final latestCarData = await F1Api.getLatestCarData();
      
      // Se ci sono dati, la sessione potrebbe essere live
      if (latestPositions.isNotEmpty || latestCarData.isNotEmpty) {
        _lastDataUpdate = DateTime.now();
        return true;
      }
      
      // Controlla se abbiamo avuto dati recenti (ultimi 30 secondi)
      if (_lastDataUpdate != null) {
        final timeSinceLastUpdate = DateTime.now().difference(_lastDataUpdate!);
        return timeSinceLastUpdate.inSeconds < 30;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Aggiorna i messaggi di controllo gara
  Future<void> _updateRaceControlMessages() async {
    try {
      final messages = await F1Api.getRaceControlMessages(
        sessionKey: _currentSessionKey!,
        dateGte: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      );

      _recentRaceControl = messages
          .map((msg) => RaceControlMessage.fromJson(msg))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Più recenti prima

      _raceControlController?.add(_recentRaceControl);
    } catch (e) {
      // Errore silenzioso per race control messages
    }
  }

  /// Verifica se le macchine stanno gareggiando
  Future<bool> _checkCarsRacing() async {
    try {
      final latestCarData = await F1Api.getLatestCarData();
      
      if (latestCarData.isEmpty) return false;

      // Conta quante macchine stanno effettivamente correndo
      int racingCars = 0;
      
      for (final carData in latestCarData) {
        final speed = carData['speed'] ?? 0;
        final rpm = carData['rpm'] ?? 0;
        final gear = carData['n_gear'] ?? 0;
        
        // Considera una macchina "in corsa" se ha velocità > 50 km/h O rpm > 5000 O marcia > 1
        if (speed > 50 || rpm > 5000 || gear > 1) {
          racingCars++;
        }
      }

      // Se almeno 5 macchine stanno correndo, considera la gara live
      return racingCars >= 5;
    } catch (e) {
      return false;
    }
  }

  /// Determina lo stato della gara basandosi sui dati
  LiveRaceStatus _determineRaceStatus(bool hasRecentData, bool carsRacing) {
    // Controlla i messaggi di race control per stati speciali
    final recentMessages = _recentRaceControl.take(5).toList();
    
    // Verifica bandiera rossa
    if (recentMessages.any((msg) => msg.flag?.contains('RED') == true)) {
      return LiveRaceStatus.redFlag;
    }
    
    // Verifica safety car
    if (recentMessages.any((msg) => 
        msg.category?.toLowerCase().contains('safety') == true ||
        msg.message?.toLowerCase().contains('safety car') == true)) {
      return LiveRaceStatus.safetyCar;
    }
    
    // Verifica virtual safety car
    if (recentMessages.any((msg) => 
        msg.message?.toLowerCase().contains('virtual safety car') == true ||
        msg.message?.toLowerCase().contains('vsc') == true)) {
      return LiveRaceStatus.virtualSafetyCar;
    }
    
    // Verifica bandiera a scacchi
    if (recentMessages.any((msg) => msg.flag?.contains('CHEQUERED') == true)) {
      return LiveRaceStatus.finished;
    }
    
    // Se ci sono dati recenti e macchine che corrono
    if (hasRecentData && carsRacing) {
      // Verifica se ci sono bandiere gialle
      if (recentMessages.any((msg) => msg.flag?.contains('YELLOW') == true)) {
        return LiveRaceStatus.yellowFlag;
      }
      
      return LiveRaceStatus.racing;
    }
    
    // Se ci sono dati recenti ma poche macchine in movimento
    if (hasRecentData && !carsRacing) {
      return LiveRaceStatus.paused;
    }
    
    // Nessun dato recente
    return LiveRaceStatus.notLive;
  }

  /// Aggiorna lo stato e notifica i listener
  void _updateStatus(LiveRaceStatus status) {
    _currentStatus = status;
    _statusController?.add(status);
    
    // Invia anche le informazioni complete
    final raceInfo = getCurrentRaceInfo();
    _liveRaceInfoController?.add(raceInfo);
  }

  /// Ottieni il testo descrittivo dello stato
  String _getStatusText(LiveRaceStatus status) {
    switch (status) {
      case LiveRaceStatus.racing:
        return 'Gara in corso';
      case LiveRaceStatus.paused:
        return 'Gara in pausa';
      case LiveRaceStatus.yellowFlag:
        return 'Bandiera gialla';
      case LiveRaceStatus.redFlag:
        return 'Bandiera rossa';
      case LiveRaceStatus.safetyCar:
        return 'Safety Car';
      case LiveRaceStatus.virtualSafetyCar:
        return 'Virtual Safety Car';
      case LiveRaceStatus.finished:
        return 'Gara terminata';
      case LiveRaceStatus.notLive:
        return 'Non in diretta';
      case LiveRaceStatus.noSession:
        return 'Nessuna sessione';
      case LiveRaceStatus.error:
        return 'Errore';
      case LiveRaceStatus.unknown:
        return 'Stato sconosciuto';
    }
  }

  /// Ottieni informazioni dettagliate sullo stato attuale
  LiveRaceInfo getCurrentRaceInfo() {
    return LiveRaceInfo(
      status: _currentStatus,
      statusText: _getStatusText(_currentStatus),
      sessionKey: _currentSessionKey,
      lastUpdate: _lastDataUpdate,
      recentRaceControl: _recentRaceControl.take(3).toList(),
      isLive: [
        LiveRaceStatus.racing,
        LiveRaceStatus.yellowFlag,
        LiveRaceStatus.safetyCar,
        LiveRaceStatus.virtualSafetyCar,
        LiveRaceStatus.redFlag,
      ].contains(_currentStatus),
    );
  }

  /// Pulisci le risorse
  void dispose() {
    _monitoringTimer?.cancel();
    _statusController?.close();
    _raceControlController?.close();
    _liveRaceInfoController?.close();
    _statusController = null;
    _raceControlController = null;
    _liveRaceInfoController = null;
  }
}

/// Enum per i diversi stati della gara
enum LiveRaceStatus {
  unknown,
  noSession,
  notLive,
  racing,
  paused,
  yellowFlag,
  redFlag,
  safetyCar,
  virtualSafetyCar,
  finished,
  error,
}

/// Classe per rappresentare un messaggio di controllo gara
class RaceControlMessage {
  final String? category;
  final DateTime date;
  final int? driverNumber;
  final String? flag;
  final int? lapNumber;
  final String? message;
  final String? scope;
  final int? sector;

  RaceControlMessage({
    this.category,
    required this.date,
    this.driverNumber,
    this.flag,
    this.lapNumber,
    this.message,
    this.scope,
    this.sector,
  });

  factory RaceControlMessage.fromJson(Map<String, dynamic> json) {
    return RaceControlMessage(
      category: json['category'],
      date: DateTime.parse(json['date']),
      driverNumber: json['driver_number'],
      flag: json['flag'],
      lapNumber: json['lap_number'],
      message: json['message'],
      scope: json['scope'],
      sector: json['sector'],
    );
  }

  /// Ottieni l'icona appropriata per il messaggio
  String get icon {
    if (flag != null) {
      if (flag!.contains('RED')) return '🔴';
      if (flag!.contains('YELLOW')) return '🟡';
      if (flag!.contains('GREEN')) return '🟢';
      if (flag!.contains('CHEQUERED')) return '🏁';
      if (flag!.contains('BLACK')) return '⚫';
    }
    
    if (category?.toLowerCase().contains('safety') == true || 
        message?.toLowerCase().contains('safety car') == true) {
      return '🚗';
    }
    
    if (message?.toLowerCase().contains('virtual safety car') == true ||
        message?.toLowerCase().contains('vsc') == true) {
      return '🟨';
    }
    
    return 'ℹ️';
  }

  /// Ottieni il colore appropriato per il messaggio
  int get color {
    if (flag != null) {
      if (flag!.contains('RED')) return 0xFFE53E3E;
      if (flag!.contains('YELLOW')) return 0xFFD69E2E;
      if (flag!.contains('GREEN')) return 0xFF38A169;
      if (flag!.contains('BLACK')) return 0xFF2D3748;
    }
    
    if (category?.toLowerCase().contains('safety') == true) {
      return 0xFFD69E2E;
    }
    
    return 0xFF4A5568;
  }
}

/// Classe per informazioni complete sullo stato della gara
class LiveRaceInfo {
  final LiveRaceStatus status;
  final String statusText;
  final int? sessionKey;
  final DateTime? lastUpdate;
  final List<RaceControlMessage> recentRaceControl;
  final bool isLive;

  LiveRaceInfo({
    required this.status,
    required this.statusText,
    this.sessionKey,
    this.lastUpdate,
    required this.recentRaceControl,
    required this.isLive,
  });

  /// Alias per recentRaceControl per compatibilità
  List<RaceControlMessage> get raceControlMessages => recentRaceControl;
}
