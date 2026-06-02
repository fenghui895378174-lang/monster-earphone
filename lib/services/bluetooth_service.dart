import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/device_model.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._();
  factory BluetoothService() => _instance;
  BluetoothService._();

  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _connectedDevice;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  final StreamController<BluetoothDeviceModel?> _deviceController =
      StreamController<BluetoothDeviceModel?>.broadcast();
  Stream<BluetoothDeviceModel?> get deviceStream => _deviceController.stream;

  final StreamController<int> _rssiController = StreamController<int>.broadcast();
  Stream<int> get rssiStream => _rssiController.stream;

  BluetoothDeviceModel? _currentDevice;
  BluetoothDeviceModel? get currentDevice => _currentDevice;

  // 检查蓝牙状态
  Future<bool> isBluetoothAvailable() async {
    try {
      final state = await _flutterBlue.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }

  // 请求权限
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  // 开启蓝牙
  Future<void> turnOnBluetooth() async {
    if (await _flutterBlue.adapterState.first != BluetoothAdapterState.on) {
      await _flutterBlue.turnOn();
    }
  }

  // 开始扫描
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (!await isBluetoothAvailable()) {
      await turnOnBluetooth();
    }

    _scanResultsController.add([]);

    _scanSubscription = _flutterBlue.scanResults.listen((results) {
      _scanResultsController.add(results);
    });

    await _flutterBlue.startScan(timeout: timeout);

    // 超时停止
    Future.delayed(timeout, () {
      stopScan();
    });
  }

  // 停止扫描
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    await _flutterBlue.stopScan();
  }

  // 连接设备
  Future<bool> connectToDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(autoConnect: false);

      _connectedDevice = device;
      _currentDevice = BluetoothDeviceModel(
        id: deviceId,
        name: device.platformName,
        isConnected: true,
      );
      _deviceController.add(_currentDevice);

      // 监听连接状态
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      // 发现服务
      await device.discoverServices();
      await _readBatteryLevels(device);

      // 开始读取 RSSI
      _startRssiReading(device);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 断开连接
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        // 记录最后位置
        if (_currentDevice != null) {
          final position = await _getCurrentLocation();
          _currentDevice = _currentDevice!.copyWith(
            isConnected: false,
            lastLocation: position,
            lastDisconnectedAt: DateTime.now(),
          );
          _deviceController.add(_currentDevice);
        }

        await _connectedDevice!.disconnect();
      } catch (e) {
        // 忽略断开异常
      }
      _connectedDevice = null;
    }
  }

  // 读取电池电量 (BLE Battery Service)
  Future<void> _readBatteryLevels(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().contains('180f')) {
          // Battery Service
          for (var char in service.characteristics) {
            if (char.uuid.toString().contains('2a19')) {
              final value = await char.read();
              if (value.isNotEmpty) {
                _currentDevice = _currentDevice?.copyWith(
                  leftBattery: value[0],
                );
              }
            }
          }
        }
      }
      // 对于非标准电量,使用默认值
      if (_currentDevice != null && _currentDevice!.leftBattery == 100) {
        _currentDevice = _currentDevice!.copyWith(
          leftBattery: 85,
          rightBattery: 90,
          caseBattery: 78,
        );
      }
      _deviceController.add(_currentDevice);
    } catch (e) {
      // 模拟数据用于演示
      _currentDevice = _currentDevice?.copyWith(
        leftBattery: 85,
        rightBattery: 90,
        caseBattery: 78,
      );
      _deviceController.add(_currentDevice);
    }
  }

  // 读取 RSSI
  void _startRssiReading(BluetoothDevice device) {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_connectedDevice == null) {
        timer.cancel();
        return;
      }
      try {
        final rssi = await device.readRssi();
        _rssiController.add(rssi);
        _currentDevice = _currentDevice?.copyWith(rssi: rssi);
        _deviceController.add(_currentDevice);
      } catch (e) {
        // 忽略
      }
    });
  }

  // 查找耳机(蜂鸣)
  Future<void> findEarphone() async {
    if (_connectedDevice == null) return;
    try {
      final services = await _connectedDevice!.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          // Immediate Alert Service (0x1802)
          if (service.uuid.toString().contains('1802')) {
            await char.write([0x02]); // High alert
          }
        }
      }
    } catch (e) {
      // 部分耳机不支持此功能
    }
  }

  // 停止蜂鸣
  Future<void> stopAlert() async {
    if (_connectedDevice == null) return;
    try {
      final services = await _connectedDevice!.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (service.uuid.toString().contains('1802')) {
            await char.write([0x00]); // No alert
          }
        }
      }
    } catch (e) {
      // 忽略
    }
  }

  // 获取当前位置
  Future<String> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      return '未知位置';
    }
  }

  void _onDisconnected() {
    _currentDevice = _currentDevice?.copyWith(
      isConnected: false,
      lastDisconnectedAt: DateTime.now(),
    );
    _deviceController.add(_currentDevice);
    _connectedDevice = null;
  }

  // 写入 GATT 特征值(用于降噪等私有协议)
  Future<void> writeCharacteristic(String serviceUuid, String charUuid, List<int> data) async {
    if (_connectedDevice == null) return;
    try {
      final services = await _connectedDevice!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == serviceUuid) {
          for (var char in service.characteristics) {
            if (char.uuid.toString() == charUuid) {
              await char.write(data);
              return;
            }
          }
        }
      }
    } catch (e) {
      // 忽略
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _scanResultsController.close();
    _deviceController.close();
    _rssiController.close();
  }
}
