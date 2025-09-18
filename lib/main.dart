import 'package:flutter/material.dart';
import 'tcp_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 LED控制',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TcpService _tcpService = TcpService();
  final List<String> _logs = [];
  bool _isConnected = false;
  bool _led1Status = false;
  bool _led2Status = false;

  @override
  void initState() {
    super.initState();
    _tcpService.addLogListener(_onLogReceived);
  }

  void _onLogReceived(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $log');
    });
  }

  void _connectToServer() async {
    await _tcpService.connect('192.168.4.1', 5000);
    setState(() {
      _isConnected = _tcpService.isConnected;
    });
  }

  void _disconnectFromServer() async {
    await _tcpService.disconnect();
    setState(() {
      _isConnected = _tcpService.isConnected;
      _led1Status = false;
      _led2Status = false;
    });
  }

  // LED控制方法 - 与Android版本完全一致
  void _toggleLED1() async {
    if (await _tcpService.turnOnLED1()) {
      setState(() {
        _led1Status = !_led1Status; // 切换状态
      });
    }
  }

  void _toggleLED2() async {
    if (await _tcpService.turnOnLED2()) {
      setState(() {
        _led2Status = !_led2Status; // 切换状态
      });
    }
  }

  @override
  void dispose() {
    _tcpService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP8266 LED控制'),
        backgroundColor: _isConnected ? Colors.green : Colors.red,
      ),
      body: Column(
        children: [
          // 连接状态和控制按钮
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '连接状态: ${_isConnected ? "已连接" : "未连接"}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isConnected ? null : _connectToServer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('连接服务器'),
                    ),
                    ElevatedButton(
                      onPressed: _isConnected ? _disconnectFromServer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('断开连接'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // LED控制区域
                if (_isConnected) ...[
                  Text(
                    'LED控制',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  // LED1控制
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('LED1: ${_led1Status ? "开启" : "关闭"}'),
                      ElevatedButton(
                        onPressed: _toggleLED1,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _led1Status ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_led1Status ? '关闭LED1' : '开启LED1'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // LED2控制
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('LED2: ${_led2Status ? "开启" : "关闭"}'),
                      ElevatedButton(
                        onPressed: _toggleLED2,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _led2Status ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_led2Status ? '关闭LED2' : '开启LED2'),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 10),
                Text(
                  '服务器: 192.168.4.1:5000',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Divider(),
          // 日志显示区域
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '日志输出:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              _logs[index],
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '日志条数: ${_logs.length}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _logs.clear();
                          });
                        },
                        child: Text('清空日志'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}