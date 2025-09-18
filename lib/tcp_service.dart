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

  // 测试网络连通性
  Future<bool> testNetworkConnectivity() async {
    try {
      _log('测试网络连通性...');
      final result = await InternetAddress.lookup('192.168.4.1');
      _log('DNS解析成功: ${result.first.address}');
      return true;
    } catch (e) {
      _log('DNS解析失败: $e');
      _log('DNS错误类型: ${e.runtimeType}');
      return false;
    }
  }

  Future<bool> connect(String host, int port) async {
    try {
      _log('=== 开始TCP连接 ===');
      _log('目标地址: $host:$port');
      _log('当前时间: ${DateTime.now()}');
      
      // 1. 测试网络连通性
      _log('步骤1: 测试网络连通性');
      bool networkOk = await testNetworkConnectivity();
      if (!networkOk) {
        _log('网络连通性测试失败，但继续尝试TCP连接');
      }
      
      // 2. 尝试TCP连接
      _log('步骤2: 尝试TCP连接');
      _log('连接参数: host=$host, port=$port, timeout=30秒');
      
      _socket = await Socket.connect(
        host, 
        port, 
        timeout: Duration(seconds: 30),
      );
      
      _isConnected = true;
      _log('TCP连接成功！');
      _log('Socket信息: ${_socket.toString()}');
      
      // 监听数据接收
      _socket!.listen(
        (data) {
          String message = String.fromCharCodes(data).trim();
          _log('收到数据: $message');
        },
        onError: (error) {
          _log('接收数据错误: $error');
          _log('接收错误类型: ${error.runtimeType}');
          _disconnect();
        },
        onDone: () {
          _log('连接已断开');
          _disconnect();
        },
      );
      
      _log('=== TCP连接完成 ===');
      return true;
    } catch (e) {
      _log('=== TCP连接失败 ===');
      _log('错误信息: $e');
      _log('错误类型: ${e.runtimeType}');
      _log('错误详情: ${e.toString()}');
      
      // 如果是SocketException，提供更详细的信息
      if (e is SocketException) {
        _log('Socket异常详情:');
        _log('- 错误码: ${e.osError?.errorCode}');
        _log('- 错误消息: ${e.osError?.message}');
        _log('- 地址: ${e.address}');
        _log('- 端口: ${e.port}');
      }
      
      _isConnected = false;
      _log('=== TCP连接失败结束 ===');
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
        _log('断开错误类型: ${e.runtimeType}');
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
      _log('发送错误类型: ${e.runtimeType}');
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
      _log('指令错误类型: ${e.runtimeType}');
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