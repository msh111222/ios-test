import 'dart:io';
import 'dart:async';

class TcpService {
  Socket? _socket;
  bool _isConnected = false;
  final List<Function(String)> _logListeners = [];

  bool get isConnected => _isConnected;

  void addLogListener(Function(String) listener) {
    _logListeners.add(listener);
  }

  void _log(String message) {
    print('TCP: $message');
    for (var listener in _logListeners) {
      listener(message);
    }
  }

  Future<bool> connect(String host, int port) async {
    try {
      _log('正在连接到 $host:$port...');
      
      _socket = await Socket.connect(host, port, timeout: Duration(seconds: 10));
      _isConnected = true;
      
      _log('连接成功！');
      
      // 监听数据接收
      _socket!.listen(
        (data) {
          String message = String.fromCharCodes(data).trim();
          _log('收到数据: $message');
        },
        onError: (error) {
          _log('接收数据错误: $error');
          _disconnect();
        },
        onDone: () {
          _log('连接已断开');
          _disconnect();
        },
      );
      
      return true;
    } catch (e) {
      _log('连接失败: $e');
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      try {
        await _socket!.close();
        _log('主动断开连接');
      } catch (e) {
        _log('断开连接时出错: $e');
      }
    }
    _disconnect();
  }

  void _disconnect() {
    _isConnected = false;
    _socket = null;
  }

  Future<bool> sendMessage(String message) async {
    if (!_isConnected || _socket == null) {
      _log('未连接，无法发送消息');
      return false;
    }

    try {
      _socket!.write(message);
      _log('发送消息: $message');
      return true;
    } catch (e) {
      _log('发送消息失败: $e');
      return false;
    }
  }

  // 发送LED控制指令
  Future<bool> sendLEDCommand(String command) async {
    if (!_isConnected || _socket == null) {
      _log('未连接，无法发送指令');
      return false;
    }

    try {
      _socket!.write(command);
      _log('发送LED指令: $command');
      return true;
    } catch (e) {
      _log('发送指令失败: $e');
      return false;
    }
  }

  // LED控制方法 - 使用正确的指令格式
  Future<bool> turnOnLED1() async {
    return await sendLEDCommand('+IPD,0,8:ESPKLED1GBK');
  }

  Future<bool> turnOffLED1() async {
    return await sendLEDCommand('+IPD,0,8:ESPKLED1GBK'); // 可能需要相同的指令来切换
  }

  Future<bool> turnOnLED2() async {
    return await sendLEDCommand('+IPD,0,8:ESPKLED2GBK');
  }

  Future<bool> turnOffLED2() async {
    return await sendLEDCommand('+IPD,0,8:ESPKLED2GBK'); // 可能需要相同的指令来切换
  }

  void dispose() {
    disconnect();
    _logListeners.clear();
  }
}