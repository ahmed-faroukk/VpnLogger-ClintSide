import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _Urlcontroller = TextEditingController();
  String defaultVpnUsername = "remusr_ahmedfarouk1";
  String defaultVpnPassword = "Ak@kW7w*a7asz225";
  String defaultVpnUsername2 = "remusr_test1";
  String defaultVpnPassword2 = "1Qasdzxc";

  late OpenVPN engine;
  VpnStatus? status;
  String? stage;
  bool _granted = false;
  var serverUrl = "";

  @override
  void initState() {
    engine = OpenVPN(
      onVpnStatusChanged: (data) {
        setState(() {
          status = data;
        });
      },
      onVpnStageChanged: (data, raw) {
        setState(() {
          stage = raw;
        });
      },
    );

    engine.initialize(
      groupIdentifier: "group.com.laskarmedia.vpn",
      providerBundleIdentifier:
          "id.laskarmedia.openvpnFlutterExample.VPNExtension",
      localizedDescription: "VPN by Nizwar",
      lastStage: (stage) {
        setState(() {
          this.stage = stage.name;
          print("open vpn last stage is " + this.stage.toString());
        });
      },
      lastStatus: (status) {
        setState(() {
          this.status = status;
          print("open vpn last status is " + this.status.toString());
        });
      },
    );
    super.initState();
  }

  Future<void> initPlatformState() async {
    engine.connect(
      _controller.text,
      "192.168.12.253 [ertaqy]",
      username: defaultVpnUsername2,
      password: defaultVpnPassword2,
      certIsRequired: true,
    );
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:  Text('Ertaqy Vpn Logger ' , style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle("Server URL file : "),
                _buildServerUrlInput(),
                _buildTitle("Configuration file : "),
                _buildConfigFileInput(),
                const SizedBox(height: 10),
                _buildConfigFileButton(),
                const SizedBox(height: 10),
                _buildTitle("Status : "),
                Divider(),
                _buildStatusText(),
                Divider(),
                const SizedBox(height: 10),
                _buildTitle("last Stage : "),
                Divider(),
                _buildStageText(),
                Divider(),
                const SizedBox(height: 10),
                _buildControlButtons(),
                const SizedBox(height: 10),
                _buildTitle("Vpn Permission : "),
                Divider(),
                if (Platform.isAndroid) _buildPermissionButton(),
                Divider(),

              ],
            ),
          )
        ),
      ),
    );
  }

  Widget _buildConfigFileInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200.0, // Set the maximum height
        ),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter config file',
          ),
          maxLines: null, // Allows for multi-line input
        ),
      ),
    );
  }

  Widget _buildServerUrlInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200.0, // Set the maximum height
        ),
        child: TextField(
          controller: _Urlcontroller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter Server URL',
          ),
          maxLines: 1, // Allows for multi-line input
        ),
      ),
    );
  }


  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.black , fontWeight: FontWeight.bold ,fontSize: 15),
          )
        ],
      ),
    );
  }
  Widget _buildTitleForStatus(String text) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.black ),
          )
        ],
      ),
    );
  }

  Widget _buildConfigFileButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Button background color
          shadowColor: Colors.grey, // Shadow color
          elevation: 5, // Elevation for shadow effect
        ),
        child: const Text( "get Config file ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        onPressed: () async {
          _controller.text = "loading........";
          var configFile = await fetchVpnConfig("server1");
          _controller.text = configFile;
        },
      ),

    );

  }

  Widget _buildStageText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        stage?.toString() ?? VPNStage.disconnected.toString(),
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child : Column(
            children: [
              _buildRow("Duration :", status?.duration.toString() ?? ''),
              _buildRow("Connected On :", status?.connectedOn.toString() ?? ''),
              _buildRow("Byte In :", status?.byteIn ?? ''),
              _buildRow("Byte Out :", status?.byteOut ?? ''),
              _buildRow("Packets In :", status?.packetsIn ?? ''),
              _buildRow("Packets Out :", status?.packetsOut ?? ''),
            ],
          ),
      ),
    );
  }
  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTitleForStatus(label),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              value,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Button background color
              shadowColor: Colors.grey, // Shadow color
              elevation: 5, // Elevation for shadow effect
            ),
            child: const Text( "connect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            onPressed: () async {
              try {
                await initPlatformState();
                print(defaultVpnUsername);
                print(defaultVpnPassword);
                print(config_new);
              } catch (e) {
                print("Error: $e");
              }
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Button background color
              shadowColor: Colors.grey, // Shadow color
              elevation: 5, // Elevation for shadow effect
            ),
            child: const Text( "disconnect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            onPressed: () {
              status = VpnStatus.empty();
              engine.disconnect();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        child: Text(
          _granted ? "Granted" : "Request Permission",
          style: TextStyle(color: _granted ? Colors.green : Colors.red),
        ),
        onPressed: () {
          engine.requestPermissionAndroid().then((value) {
            setState(() {
              _granted = value;
            });
          });
        },
      ),
    );
  }

  Future<String> fetchVpnConfig(String serverName) async {
    final Dio dio = Dio();
    final String url =
        'https://api.ertaqy.com/mobile-app/com.ertaqy.app/vpn-$serverName-config.txt';
    try {
      final response = await dio.get<String>(url);
      if (response.statusCode == 200) {
        print("config resopnse  ==");
        print(response.data);
        return response.data ?? '';
      } else {
        print("config resopnse in exception   ==");

        throw Exception('Failed to load VPN config');
      }
    } catch (e) {
      print("config resopnse in exception   ==");

      print('Error: $e');
      return '';
    }
  }


  String config_new = '''
client
dev tun3
proto tcp
remote 192.168.12.253 8301
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC
data-ciphers-fallback AES-256-CBC
fast-io
route-delay 2
redirect-gateway
route 192.168.112.12 255.255.255.255
<ca>
-----BEGIN CERTIFICATE-----
MIIDujCCAqKgAwIBAgIICa3M/VIXoZwwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NjA5MTYxMDA2WhcNMzgwMTE4MDMxNDA3WjBhMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQswCQYDVQQDDAJDQTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAO2sl51GPS/kfe0TvpN9YhuwSDrn4fBR19hYTMreatsID6Hn
JdH0oF8jXwCK9rNhSEqIUvxVytzRljDhVVtGL5m3gjIdFp5vTz03SH19urXS4mwH
uUrIDkn8KUdFbm19x6UGUSlUkMBFtksvhY1ylk+YexR7b1G17PU3+IZCyLf3ZKbq
4vQ1vukylSp5k3pPfL5aKGAk03W8e31VYJYvcZJUPo/gYn7ktf8HhC7sL7rIXlgE
HKBo5MXBfAUrOui+ditvVIWlWd5q8sDxXStxwV7nEHc0uiAMudKw3nfxThLc8etH
WgjnJWr6hfmgClsUnJQl2ULkg0dQWQLn2rcJym0CAwEAAaN2MHQwDwYDVR0TAQH/
BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFIgIRiSvvXzUJg74XQS/
lsEg5OKVMDIGA1UdHwQrMCkwJ6AloCOGIWh0dHA6Ly9jZG4yLmVydGFxeS5jb20v
Y3JsLzU4LmNybDANBgkqhkiG9w0BAQsFAAOCAQEAmnd9YPoLdMsHLZqrz5mhBuaS
AII1Qaul8C5f+LgfmaYvMA/48oatDwF0Q8yq64iHBm8pqxzHEAr4SI9ivILXVHY6
mcNfugDT8d196Ntc8a9W4SICa++rUCVzUaPWjYPzYumUFfAtF8P1+Z+B7Frp26nS
9+GCbyIi4xJuUe2ioAu/MGFnnFNLlXpHEIc2hwvAaMrg7/6dMJqvPdpcwfLGCJc7
CEhH1thoj2q89OEfTkI/svgwm5luyT2B6BZ9BBUE8/R59eMkF9VifCbMGQUVVW3N
llT1wMV9eOq6XeVrsjsahiWjDZHnq/rIezgTM09twAs9v3s4hMHTB4/Kre7C+Q==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIIZL9CL3fXwCEwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NjA5MTYxMjQyWhcNMzgwMTE4MDMxNDA3WjBlMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQ8wDQYDVQQDDAZDbGllbnQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCceEW0qFQh907K4TRQ5P2TigChqtB/8VLxeDrMUm8P
RbvPD4YPE+uB6dKlUZjcBtCjUxAoWm8OknGVc/qXWWHAGNuU1n0XgWjqe0s1ymmu
WX3KQcyzJEcRVKekPHZ09lAQ0U/hsHTfY3YCbjh54wUQXczHmTSsxtLl3kSfqNTX
CPbli0Z/eTWeiN5vl48WZw6qJPXetZHUIk0fOgKE6D1iyMS/0KG+kDueemn0jhIm
DH6qBzke645AAF5pwcuHQM9E+vWUgcLFC2kGIwFhsO6cB7uN3DbczLm9r5ZUCzy3
+5QkbbHp00PHt9lw3BOcjd3w/s20Cz+6c0PQ1b1MrQYZAgMBAAGjVzBVMBMGA1Ud
JQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQWBBTJSPYDd2jkcxmHodTAi8vmpz4tfTAf
BgNVHSMEGDAWgBSICEYkr7181CYO+F0Ev5bBIOTilTANBgkqhkiG9w0BAQsFAAOC
AQEApL2GXGK/Ko0ani2KJtkm1+2A7v+CmXNcSkPnITEZ4fdcFbVAfEOPW0IpuEFQ
tLeFuI4dkf8DqjivqKtBbPD9vLDmkoV1WhWPcpAWtLRbL1S/MaSfa6NQwlWZUm6J
4N4INIGRGP5Ui09C/ccrc8XxI5Ew8lmPgtjJJHmtPxUDqRK0/OOKqL7e+hk+Um3y
PXkW7nbSTQvb8DXVrlKBgq+33KRBLy2cI018zzT2x0Sqe6o/CatMBJMaNu7ysZyV
7cvJUps8I//kMisNd+EY/6vs2SsCT/2GKGFZNeQo/0hFEg7UCkEo1+ySI+dwUSlK
zYz9yaa5/VGr6IUiHP5cDDrfWw==
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCceEW0qFQh907K
4TRQ5P2TigChqtB/8VLxeDrMUm8PRbvPD4YPE+uB6dKlUZjcBtCjUxAoWm8OknGV
c/qXWWHAGNuU1n0XgWjqe0s1ymmuWX3KQcyzJEcRVKekPHZ09lAQ0U/hsHTfY3YC
bjh54wUQXczHmTSsxtLl3kSfqNTXCPbli0Z/eTWeiN5vl48WZw6qJPXetZHUIk0f
OgKE6D1iyMS/0KG+kDueemn0jhImDH6qBzke645AAF5pwcuHQM9E+vWUgcLFC2kG
IwFhsO6cB7uN3DbczLm9r5ZUCzy3+5QkbbHp00PHt9lw3BOcjd3w/s20Cz+6c0PQ
1b1MrQYZAgMBAAECggEAUBa7zymtzqjwWqYFCjb7mG41vopZKHPUeaaJqhWzpQST
ifuvKb6PeDK/0EDA1jZiyoZ0qcMIP1Qz8USpCpkEkLfohPl4k/R4SDUNnR3bFBPY
cBNX/IXgHn3PRSBxnZKKDuGkWqfgWotlVv8lxzWtXOA2NiA0Nw+Z2XD4fSSEtP+j
xNshoiF5jTjcGGjqWKufSm1EqEUOy2Gwd0C9BoM6v0udc4LSKmEX6vhyjAV9Td5G
qtWTI8PVUriT67TB3oSwZczTjHp2eAVzC5wqX2YVWDvfvALm5A4r8M52wlCJK+JN
qsiWHQAk1YAIyXtQsKRxc9YrjV0f4nfhDkDosBB1RQKBgQDJMr9z7w3jxehVR4KU
LbZH9sQ5yu/6gh4aONN10CuK6PuIxXZUYJAQRp5vZ4b4tqD83FAwfBj5EfmS0CNC
i3ItyhFBT9MjldmpfqCHB0eU8S2rO0e5QVsnR9SIXc6vrb0Q5HFoP6NUdQHgtWvV
7O2YHWGpkN4TswRpA5EjtZu32wKBgQDHFq20aPDAgX6iUNGr+qXVNTd0fUHVAqjz
HbRtaDqdl4YWXmZwV0xWYnTrH7x13Z9h1Y7wFTBlhjO9fLiZnFMfYax3TiMznTYT
IeTk+BdGZyiL+DunE8rkRUkU7l+wwpKhhgqFd/wp67dxOvIHfLcNW9UCOfWFWgfu
h0GpikyGGwKBgAg8np/laoEnqgJLwinE0VCS5qejCj4MM6VJLEcHdbDjJuELjHOZ
3Gv+KCBRcbIe7+pKLrI9clxIAxqikL75rHv5aMlutisfyGBrAbFld+W+FeuLqr0H
0u6Bv06x4HNKvpHBeG8XI92iSKhlZPvGDlgK4+OoPZ861fRio/99QNm/AoGBAMQC
HPTxGI6/L3kJDtU+ScS2xylGJOld3A63oSrSIluDkf015a8XE8480xWmQjrc/o0o
37iZc/OQhCI7x9dcpC3SUSWI5Xlsf4+ooB2Z7/hdmfrsY3akMu45FLGp2sZBWnHy
cStkrPxs2Ud+nEkozWQ2lGnDvGkU8ZgyzD/qLFsfAoGAcBWaM89+WxBMuzZNXtm7
XQpVbM6W2p27OS9Ka8C/hWSd3Wv0hmbvEASCaAJEJz+29V/hUv5sr7nDy96R9Vs0
NT0jxeBUjQOI39u/jttHNkrGM9dI16Or3NGFPjzJ2OIdUvsqrXSv45/4oCpn2TEh
8yAihSH/662i8YcstIDGZjk=
-----END PRIVATE KEY-----
</key>
''';

  String get config => '''
client
# dev tun
dev tun 
# proto tcp
proto tcp-client

  remote cdn2.ertaqy.com
# remote cdn.ertaqy.com
# remote 192.168.12.253
port 8301
route 192.168.112.12 255.255.255.255 


tls-client
remote-cert-tls server

# data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC
data-ciphers AES-256-CBC
cipher AES-256-CBC
auth SHA1
auth-nocache
# auth-user-pass

# pull
# ncp-disable  # confirmed not working 

# ping 1 # confirmed not working
# inactive 120 10000000


# ??
# resolv-retry infinite
nobind
keepalive 10 30
connect-retry 5 10

comp-lzo # Do not use compression. It doesn't work with RouterOS (at least up to RouterOS 3.0rc9)

# More reliable detection when a system loses its connection.
# ping 15
# ping-restart 45
# ping-timer-rem
persist-tun
persist-key


# Silence  the output of replay warnings, which are a common false
# alarm on WiFi networks.  This option preserves the  security  of
# the replay protection code without the verbosity associated with
# warnings about duplicate packets.
mute-replay-warnings

# Verbosity level. default: 3
# 0 = quiet, 1 = mostly quiet, 3 = medium output, 9 = verbose
verb 9

ca [inline]
cert [inline]
key [inline]

<ca>
-----BEGIN CERTIFICATE-----
MIIDhjCCAm6gAwIBAgIIEH++OKM6x5IwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NTA3MTg1MzE2WhcNMzgwMTE4MDMxNDA3WjBhMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQswCQYDVQQDDAJDQTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAL+eleD6RplgHgl/VBmKeNPAQdGq9XZo4A8IzooxMBBA+tVe
2sCfWQcFY6Za1qmQfAoFUswbtuyvuXv/CA8uyEzS5t3MDCv8gZ8/e8yAELdz8Z9Y
iO/Go00LH9cH2yDwzyMv9ebdFn5WhCVxpEi0eWbd3cHC0woeQ6eyweT0XOM5z8TM
cS3JVyNiRVoilyQweR51c51zNBgnNCpzY4CQv1E18xDI/LtntnRlWBSBIM4OfhjA
rEZC8IS1T2VBbrXJ+d6GtU/BotCNuioXdhVmGhE/lVXyniZ8rDkZVckRMs0wXNTw
vRtXFfoPS5yeybOV1JDe44n2GZ3vRYdNCdy854kCAwEAAaNCMEAwDwYDVR0TAQH/
BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFNMJ1LJSuX1mImI8OTJk
x01FAbwbMA0GCSqGSIb3DQEBCwUAA4IBAQAeNplwYxnp1H296umiLx4QH1OpQv1z
EGr708zLP9lsaJjFUafKM4H9HRK2sV7i3JvuGbKTWDT+HYKG4PVgOzMy+LVWvftB
6qwaHtm1nwOzBshe8C95gmAMlij6pUGuuZuF414ajcf1pWmrR4kVDG8ZGmGfX0RR
GpreNZgTFqbQdCYqjinaBzwKAZ7KeucQRnv2N87ba/0Udom7YiJjtM6A9dV5elRa
pHFgKJVqKqDHdPEjamf80nT7YetEwqGIoBPU8SqSwOhFbO7AIcEaWqlfN1dEddKs
i+WMfuXcleoYjR8sQaPPYMOrOEQRBeHTHVgniY3om/poTCu54MgAg1Y1
-----END CERTIFICATE-----
</ca>

<cert>
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIIZFNr0qHoqjUwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NTA3MTg1NTEyWhcNMzgwMTE4MDMxNDA3WjBlMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQ8wDQYDVQQDDAZDbGllbnQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCer/KB9b4gjXOPwTEPl1aft5lnksaRqnaQ0yE9Zwaa
s5vrtxbqhOYY2euYi3q5Oz980h9JeIPkOCRxociGJIiXdfktfpW/0rmjlxtPQ6zq
x7w2o+24bhZap8nyvQ32xswiQ0nyJqHBrTbh6WlZVHyW5iCzY0RMj3oc62jD8CC9
eGCwO5wucUXcUknCiz4/8sAWbn+aErPGST+NKIabhK3KEh6zHifR/KcUbFkUXEPR
9J+SZOA2ttqUeWAyXzOOWBojz/b+ZQAqsLJ1EIGwGb8eiFHJgALbWxHaDjEJQA8S
T7h43Zq0o3Libpb/I0d1Xj9c3BQjCBFZq0IuopT1AwOXAgMBAAGjVzBVMBMGA1Ud
JQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQWBBRf+1fQE/I87AZwNpU28dJnKb/iyzAf
BgNVHSMEGDAWgBTTCdSyUrl9ZiJiPDkyZMdNRQG8GzANBgkqhkiG9w0BAQsFAAOC
AQEAHxvdWSABisE2RtE0QxXgple5ySflAFp9ZCNzE70XzmOakKm1JA30eondVnna
QggjkSwNjYDZbA3v4euow8vXzZV2a0h6dRa2hTuV1fsdrn4wYe0s1H5Gpf76aT5b
E/w8CNZAy9rJNBtF+UibS3zmF9z+HXb+4uu9xX55SGxs9D2vOO9jy3fJv5Lj7zGn
QqefHnaQW6UjB9wNef4jMRCWIM53kB11ywQcOdaMK+EsX5ElyaFsUAKeWo4R+QXs
zKyzs3sPSrHh1bX+I5vsWls4zB1isugnJAcyj+Fk6FFwHXzAVNkVozRBsqxXaCOV
C5Q6+fVpR7MefZqMT9lHp+rgYg==
-----END CERTIFICATE-----
</cert>

<key>
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAnq/ygfW+II1zj8ExD5dWn7eZZ5LGkap2kNMhPWcGmrOb67cW
6oTmGNnrmIt6uTs/fNIfSXiD5DgkcaHIhiSIl3X5LX6Vv9K5o5cbT0Os6se8NqPt
uG4WWqfJ8r0N9sbMIkNJ8iahwa024elpWVR8luYgs2NETI96HOtow/AgvXhgsDuc
LnFF3FJJwos+P/LAFm5/mhKzxkk/jSiGm4StyhIesx4n0fynFGxZFFxD0fSfkmTg
NrbalHlgMl8zjlgaI8/2/mUAKrCydRCBsBm/HohRyYAC21sR2g4xCUAPEk+4eN2a
tKNy4m6W/yNHdV4/XNwUIwgRWatCLqKU9QMDlwIDAQABAoIBAFBvOMn9CQExEcll
EHwppsPQaVahhDsjn3OrQOcByMwzjC3/oQMAmC0ykIPC91LaoEShsTApgRj2CCr8
6UptTDsRllskFb2kj2pHVpVn5UcgNNuxXfak/nm3INsETwauH5yiZOH0CPvF09LQ
4BBijcBjJ2ImR+FSvH/aJ0Fh/wZqKJsj6fqCMmwd1VcMiPe7/h+7Hgm4hJDDKoxC
a//Li5UbClbdP7inEypdl/vJZ1R06PPsl/dRwLw9Y1iP94YTHY9zjZB3i1y9WgI4
WSPrVMg75GGjAixME9ODJAzORJpcWIk8DxMzRwlB+gnecqpIuiQyCVAkoUrvPrU5
IiDpeoECgYEAzsqHgHQH63sfmTwL8FbPbYKit80jHQWCS7fLgKdqnjDgRLx0JKP1
BxkWo9n6b2xQQgAl+EViQ2pJQcdVGmI9h4RIAwkQlONRbTvWo1jq6BJsP1PorqQe
8/5ip+lU2FJYfD9K/aXfxRJ4htRA2YCXHYyDCs409GGJ6rBsKcJZ3UECgYEAxHL9
QcGTwR6S7IlJuKxtUCjeDeBaEQNwm3HxYrDptTZc1aAjsz/bOMwE5z1oZQhOvm9I
/p2eHAQcCf8X0Kt6f149xU2s68oBj+b1BjA/FmXE0KxTsOoBuVqcVY+0s/9nz8aG
yCB+gRKHfS0bn18zX5TeQO6PjCk5SdVnhXvzstcCgYBPZDA7n9B+lsmd4hDPV/TR
HWttV4OYm8nXWhv2K9BiJW+k1BlfC9eBvx8TDxf3+USi4j2xoKnGKiMv7uB8faUT
xzSCfdNw5gkX//Y6xmOBb7lBYuydSANeN5cW0h0x5AN2yDH5SdqsZZgCY7D2EEl0
HcMdvedUv7HceZk9OxGXQQKBgQC5saxdhNri+MCPIHL0QuENnaPQ4Bqi7Gp8NWek
D3DLH3j/YeF9JcZWWNvlrXFJ12F/t3f7Xgg/mU7b0Cq1z/H6BZ5EK9liBNAXM4y3
bdGknUw+qDZwC7LXf6Q5aJ66apm5mIJ9F+IcpeQ22fW7X2UTW4f/PsGoDquddEDn
t7QzfwKBgFEVOxL23CyASDJvZscil+WoaLoGfJM27gzgK3mqYL86jOkksgbMPi6L
OOPLEmU4gOaUJ5Ix64GG6ljOljKt2E7UeWOgPua6qMaL9MlxFy/yh4/Mu+29tBzt
RA5qtsuXYjjjPR9eotFk69BYuOyb17BK9Jyj1N5iM7oDx6B76CIQ
-----END RSA PRIVATE KEY-----
</key>

''';

// https://forums.openvpn.net/viewtopic.php?t=29411 </tls-auth>
  /*
 * <tls-crypt>
-----BEGIN OpenVPN Static key V1-----
ASLk3eW#7!\$Tm-i8q
-----END OpenVPN Static key V1-----
</tls-crypt>
* tls-auth
*
* */

  String free_openvpn_server_username = "vpnbook";
  String free_openvpn_server_pass = "dnx97sa";
  String free_openvpn_server_config = """
client
dev tun3
proto tcp
remote 5.196.64.200 80
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
cipher AES-256-CBC
fast-io
pull
route-delay 2
redirect-gateway
<ca>
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIUJdJ6+6lTiYZBvpl2P40Lgx3BeHowDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLdnBuYm9vay5jb20wHhcNMjMwMjIwMTk0NTM1WhcNMzMw
MjE3MTk0NTM1WjAWMRQwEgYDVQQDDAt2cG5ib29rLmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcVK+hYl6Wl57YxXIVy7Jlgglj42LaC2sUWK3ls
aRcKQfs/ridG6+9dSP1ziCrZ1f5pOLz34gMYXChhUOc/x9rSIRGHao4gHeXmEoGs
twjxA+kRBSv5xqeUgaTKAhdwiV5SvBE8EViWe3rlHLoUbWBQ7Kky/L4cg7u+ma1V
31PgOPhWY3RqZJLBMu3PHCctaaHQyoPLDNDyCz7Zb2Wos+tjIb3YP5GTfkZlnJsN
va0HdSGEyerTQL5fqW2V6IZ4t2Np2kVnJcfEWgJF0Kw1nqoPfKjxM44bR+K1EGGW
ir1rs/RFPg8yFVxd4ZHpqoCo2lXZjc6oP1cwtIswIHb6EbsCAwEAAaOBkDCBjTAd
BgNVHQ4EFgQULgM8Z91cLOSHl6EDF8jalx3piqQwUQYDVR0jBEowSIAULgM8Z91c
LOSHl6EDF8jalx3piqShGqQYMBYxFDASBgNVBAMMC3ZwbmJvb2suY29tghQl0nr7
qVOJhkG+mXY/jQuDHcF4ejAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjANBgkq
hkiG9w0BAQsFAAOCAQEAT5hsP+dz11oREADNMlTEehXWfoI0aBws5c8noDHoVgnc
BXuI4BREP3k6OsOXedHrAPA4dJXG2e5h33Ljqr5jYbm7TjUVf1yT/r3TDKIJMeJ4
+KFs7tmXy0ejLFORbk8v0wAYMQWM9ealEGePQVjOhJJysEhJfA4u5zdGmJDYkCr+
3cTiig/a53JqpwjjYFVHYPSJkC/nTz6tQOw9crDlZ3j+LLWln0Cy/bdj9oqurnrc
xUtl3+PWM9D1HoBpdGduvQJ4HXfss6OrajukKfDsbDS4njD933vzRd4E36GjOI8Q
1VKIe7kamttHV5HCsoeSYLjdxbXBAY2E0ZhQzpZB7g==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDYDCCAkigAwIBAgIQP/z/mAlVNddzohzjQghcqzANBgkqhkiG9w0BAQsFADAW
MRQwEgYDVQQDDAt2cG5ib29rLmNvbTAeFw0yMzAyMjAyMzMwNDlaFw0zMzAyMTcy
MzMwNDlaMB0xGzAZBgNVBAMMEmNsaWVudC52cG5ib29rLmNvbTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBANPiNyyYH6yLXss6AeHLzJ6/9JfUzVAs7ttq
8OWJRkBjKuEPW3MUVjpMgptm6+zJohM4IdSo/ES6H81sLK4AWiUUOzeOt8xAzgib
NrLss5px0D0Pm+uXH8hGOle386JH5oyOQ6ub2O3ro0TeTF4rg43TF1oOz2AVS/gc
sB3d6AG73otZ4C6/wabiGz4rFO8xl4S4PBKX73Eb7cdSoACc8AIrqcR+PEDHOZYt
1qp4lM87+5ADEXelpe9vLTaoXonIuZElqA9rwFi/KQmPCHsl7eEnmSo1iOg0y3iP
0CRHzv8FkvhhpB9Z3i3TUxq8XvnLtEQ38eD5Dw20WMYPmPShtXMCAwEAAaOBojCB
nzAJBgNVHRMEAjAAMB0GA1UdDgQWBBQKO5Ub8pRCA8iTdRIxUIeMpNX2vzBRBgNV
HSMESjBIgBQuAzxn3Vws5IeXoQMXyNqXHemKpKEapBgwFjEUMBIGA1UEAwwLdnBu
Ym9vay5jb22CFCXSevupU4mGQb6Zdj+NC4MdwXh6MBMGA1UdJQQMMAoGCCsGAQUF
BwMCMAsGA1UdDwQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAQEAel1YOAWHWFLH3N41
SCIdQNbkQ18UFBbtZz4bzV6VeCWHNzPtWQ6UIeADpcBp0mngS09qJCQ8PwOBMvFw
MizhDz2Ipz817XtLJuEMQ3Io51LRxPP394mlw46e8KFOh06QI8jnC/QlBH19PI+M
OeQ3Gx6uYK41HHmyu/Z7dUE4c4s2iiHA7UgD98dkrU0rGAv1R/d2xRXqEm4PrwDj
MlC1TY8LrIJd6Ipt00uUfHVAzhX3NKR528azYH3bud5NV+KEiQZSyirUyoMbMQeO
UXh+GEDX5GBPElzQmPOsLete/PMH9Ayg6Gh/sccqwgH7BxjqcVLKXg2S4jL5BUPd
kI3/sg==
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDT4jcsmB+si17L
OgHhy8yev/SX1M1QLO7bavDliUZAYyrhD1tzFFY6TIKbZuvsyaITOCHUqPxEuh/N
bCyuAFolFDs3jrfMQM4Imzay7LOacdA9D5vrlx/IRjpXt/OiR+aMjkOrm9jt66NE
3kxeK4ON0xdaDs9gFUv4HLAd3egBu96LWeAuv8Gm4hs+KxTvMZeEuDwSl+9xG+3H
UqAAnPACK6nEfjxAxzmWLdaqeJTPO/uQAxF3paXvby02qF6JyLmRJagPa8BYvykJ
jwh7Je3hJ5kqNYjoNMt4j9AkR87/BZL4YaQfWd4t01MavF75y7REN/Hg+Q8NtFjG
D5j0obVzAgMBAAECggEAAV/BLdfatLq+paC9rGIu9ISYKHfn0PJJpkCeSU7HltlN
yOHZnPhvyrb+TdWwB/wSwf8mMQPbhvKSDDn8XDCCZSUpcSXKyVdOPr4K78QbMhA0
4oB8aV20hg72h+UYfl/q/dRaWf2LvZc+ms66Pg4YL05EI4BfFedtc7Fz7u2meIRl
Wm0b7/QQ10wrR1I7PonZzgnU9diB1cKxptJ06AfJmCGobymjq/A1JsAr/NFnJlmu
yq3n5tcRpfc8K+XsfnpwDQJo3kKwLGIoBmUkGEcHgQhVwOL5+P+3pTYr1bt4cAUp
FxbExqcxW0es//g3x2Z80icUpa4/OvSTAa0XF3J4UQKBgQDv4E/3/r5lULYIksNC
zO1yRp7awv41ZAUpDSglNtWsehnhhUsiVE/Ezmyz4E0qjsW2+EUxUZ990T4ZVK4b
9cEhB/TDBc6PBPd498aIGiiqznWXMdsU2o6xrvkQeWdmXoVjvWTcRWlfAQ+PQBOJ
tJ3wR7ZoHgu0P/yzIzn0eQ+BiQKBgQDiIDgRtlQBw8tZc66OzxWOuJh6M5xUF5zY
S0SLXFWlKVkfGACaerHUlFwZKID39BBifgXO1VOQ6AzalDd2vaIU9CHo2bFpTY7S
EkkcIt9Gpl5o1sjEyJChXBIz+s48XBMXlqFN7AdhX/H6R43g8eS/YlzqSBxkUcAa
V3tt8n+sGwKBgD+aSXnnKNKyWOHjEDUJIzh2sy4sH71GXPvqiid756II6g3bCvX6
RwBW/4meQrezDYebQrV2AAUbUwziYBv3yJKainKfeop/daK0iAaUcQ4BGjrRtFZO
MSG51D5jAmCpVVMB59lj6jGPlXGVOtj7dBk+2oW22cGcacOR5o8E/nCJAoGBALVP
KCXrj8gqea4rt1cCbEKXeIrjPwGePUCgeUFUs8dONAteb31ty5CrtHznoSEvLMQM
UBPbsLmLlmLcXOx0eLVcWqQdiMbqTQ3bY4uP2n8HfsOJFEnUl0MKU/4hp6N2IEjV
mlikW/aTu632Gai3y7Y45E9lqn41nlaAtpMd0YjpAoGBAL8VimbhI7FK7X1vaxXy
tnqLuYddL+hsxXXfcIVNjLVat3L2WN0YKZtbzWD8TW8hbbtnuS8F8REg7YvYjkZJ
t8VO6ZmI7I++borJBNmbWS4gEk85DYnaLI9iw4oF2+Dr0LKKAaUL+Pq67wmvufOn
hTobb/WAAcA75GKmU4jn5Ln2
-----END PRIVATE KEY-----
</key>
 """;

  String configFile = """
 ###############################################################################
 # OpenVPN 2.0 Sample Configuration File
 # for PacketiX VPN / SoftEther VPN Server
 #
 # !!! AUTO-GENERATED BY SOFTETHER VPN SERVER MANAGEMENT TOOL !!!
 #
 # !!! YOU HAVE TO REVIEW IT BEFORE USE AND MODIFY IT AS NECESSARY !!!
 #
 # This configuration file is auto-generated. You might use this config file
 # in order to connect to the PacketiX VPN / SoftEther VPN Server.
 # However, before you try it, you should review the descriptions of the file
 # to determine the necessity to modify to suitable for your real environment.
 # If necessary, you have to modify a little adequately on the file.
 # For example, the IP address or the hostname as a destination VPN Server
 # should be confirmed.
 #
 # Note that to use OpenVPN 2.0, you have to put the certification file of
 # the destination VPN Server on the OpenVPN Client computer when you use this
 # config file. Please refer the below descriptions carefully.


 ###############################################################################
 # Specify the type of the layer of the VPN connection.
 #
 # To connect to the VPN Server as a "Remote-Access VPN Client PC",
 #  specify 'dev tun'. (Layer-3 IP Routing Mode)
 #
 # To connect to the VPN Server as a bridging equipment of "Site-to-Site VPN",
 #  specify 'dev tap'. (Layer-2 Ethernet Bridgine Mode)

 dev tun


 ###############################################################################
 # Specify the underlying protocol beyond the Internet.
 # Note that this setting must be correspond with the listening setting on
 # the VPN Server.
 #
 # Specify either 'proto tcp' or 'proto udp'.

  proto tcp
 # keepalive 10 30
  keepalive 10 30
  connect-retry 5 10

 ###############################################################################
 # The destination hostname / IP address, and port number of
 # the target VPN Server.
 #
 # You have to specify as 'remote <HOSTNAME> <PORT>'. You can also
 # specify the IP address instead of the hostname.
 #
 # Note that the auto-generated below hostname are a "auto-detected
 # IP address" of the VPN Server. You have to confirm the correctness
 # beforehand.
 #
 # When you want to connect to the VPN Server by using TCP protocol,
 # the port number of the destination TCP port should be same as one of
 # the available TCP listeners on the VPN Server.
 #
 # When you use UDP protocol, the port number must same as the configuration
 # setting of "OpenVPN Server Compatible Function" on the VPN Server.

 # remote cdn2.ertaqy.com 8301
  remote 192.168.12.253 8301


 ###############################################################################
 # The HTTP/HTTPS proxy setting.
 #
 # Only if you have to use the Internet via a proxy, uncomment the below
 # two lines and specify the proxy address and the port number.
 # In the case of using proxy-authentication, refer the OpenVPN manual.

 ;http-proxy-retry
 ;http-proxy [proxy server] [proxy port]


 ###############################################################################
 # The encryption and authentication algorithm.
 #
 # Default setting is good. Modify it as you prefer.
 # When you specify an unsupported algorithm, the error will occur.
 #
 # The supported algorithms are as follows:
 #  cipher: [NULL-CIPHER] NULL AES-128-CBC AES-192-CBC AES-256-CBC BF-CBC
 #          CAST-CBC CAST5-CBC DES-CBC DES-EDE-CBC DES-EDE3-CBC DESX-CBC
 #          RC2-40-CBC RC2-64-CBC RC2-CBC
 #  auth:   SHA SHA1 MD5 MD4 RMD160

 auth SHA1

 data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC
 cipher AES-256-CBC
 ncp-disable

 ###############################################################################
 # Other parameters necessary to connect to the VPN Server.
 #
 # It is not recommended to modify it unless you have a particular need.

 resolv-retry infinite
 nobind
 persist-key
 persist-tun
 client
 verb 3
 
 
###############################################################################
# Authentication with credentials.
#
# Comment the line out in case you want to use the certificate authentication.
  auth-user-pass
# route 192.168.112.12/32
  route 192.168.112.12 255.255.255.255 
# route 192.168.112.12 255.255.255.255 172.21.1.1
# route 10.0.0.0 255.255.255.0 10.3.0.1
 ###############################################################################
 # The certificate file of the destination VPN Server.
 #
 # The CA certificate file is embedded in the inline format.
 # You can replace this CA contents if necessary.
 # Please note that if the server certificate is not a self-signed, you have to
 # specify the signer's root certificate (CA) here.

<ca>

-----BEGIN CERTIFICATE-----
MIIDhjCCAm6gAwIBAgIISxsiOeetdzcwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTkVUV09SSzELMAkGA1UEAwwCQ0EwHhcNMjQw
NDE3MDg1MTEwWhcNMjUwNDE3MDg1MTEwWjBhMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdORVRXT1JLMQswCQYDVQQDDAJDQTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBANPmrYZk14Xzm61Ytd02/jyEOfK5eItPnWmemcUhcVGJR/mh
ZkL8RZ19eVf1SdwPoQwUIzpNq74DzwxzM4Ft8GKNSkkPOLox/BSkWFqNahy6/ucJ
0ykCPqIU599OgifGKXzMxvPExqonGokerBKJHpmIOcjgtBAjS6NsZpZi01IizJQJ
BQ57xlPvl2nAg5gEAJiV7hb6jdgY5MNU3+s0boawXc/wEN3MJno9jaG8z2481on0
dWBb94GbHGCgFgqHwJheGjSl5gWM/bzIYOHN00YAnZFD2j0mqa9/qYmbt4g/u12h
UswmZ4zSWLW5VI5l+CqZ0j3ijgtrxoI059mZLkUCAwEAAaNCMEAwDwYDVR0TAQH/
BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFOQdomwbY5itt42w7lFn
nBuHUu1PMA0GCSqGSIb3DQEBCwUAA4IBAQBSzIMg8trmBLYQHwDRPwH1YuCPcWxS
8/MsFT6TqYKxciI+N6yuXWPKBYVeTuPTdp614PecERcH7bYFp5Ah07VIV/B2Uxcd
BlVeyG052EHvqnxc+GdzIFEaNPZCl6fPohebvzFy0+4Nz9/ms3DcjgBhawuOSQ7z
TUBl33VAkSV28DP6kOT9/OHEauTtKkGWK9kmbjtZOvpsYEJxR8821nT082YVY5DB
2oJA8d/U3zvqkG/N5NTPFmLKOQli6LtWiuo4BFmgjuqOZ8i8L5DO8P3tOV5o017Q
7GEIeDzVQlhSRZGluiB0sqWlcJzq0ePQ2ALQSNV6nufDFXnjPhoRo/n3
-----END CERTIFICATE-----

</ca>

<cert>

-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIIdmHBbo0B0a8wDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTkVUV09SSzELMAkGA1UEAwwCQ0EwHhcNMjQw
NDE3MDg1NTEwWhcNMzgwMTE4MDMxNDA3WjARMQ8wDQYDVQQDDAZDbGllbnQwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0t4lIk4yBRX/Oscvq3+DbY/KS
iXNJzJWykWMx9e6q4PQb0hHGMbD66tzPT3R14iXOV5ozrQMiosV3I7S8TFzKjBsZ
5nD+25lKGHVfQDMwUejOItcLZK0gMaZcBkpEOxPUelHHqcPH2v7xHbB19SXEPqpG
2116wPm96Rm/MLuDtWckXY4VVcZsE4wnhOLsU/NCjcb+EfejFhwy2N45ImyEgMcK
1xTV6zlw8IpMCLz5LQpP+FkVQxK+f56muSe1m7n9EKruKvwgM+cBtiA8DPYl90md
y2xBaX1EJbGbGA/nN6eLFTIeXI3W0Mx//vTborot+otGr6Pl1xAxsL2bnO+7AgMB
AAGjVzBVMBMGA1UdJQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQWBBTmOkqLCJWqUt/I
kzj4YBkAr1awODAfBgNVHSMEGDAWgBTkHaJsG2OYrbeNsO5RZ5wbh1LtTzANBgkq
hkiG9w0BAQsFAAOCAQEAV3LUzNZLLHx+bLsP1EWjKkFf26us5+mVdZeU0ygHV9LC
Yk0EYya+QUBwyS7QAbK7GQV2p8n8OrMCdV3urVf/sIdN55uxLNKM+YYRJrwwDhqb
/BhJVA5joAG78d5Olnf4LGfSTS43Y7Khl8hql77Yi7l7fjFcp2MXqpp3A1rm2lg8
Fzd4CaBiNLaXOQTsFPrtHRrDb66fA48tU7orjFCL8Tlncabp0OPb6asfDaVPwUE5
ootkXu3jf55THezjX9585AUdSyeaLfc+lbBRZH91CDv5dZqDcjhVGtGYXgDFtHtR
7PwaRVf5IvSIJ36IIdd1PEJxZsYDSPw0WLSCkuTYTw==
-----END CERTIFICATE-----

</cert>

<key>
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAtLeJSJOMgUV/zrHL6t/g22PykolzScyVspFjMfXuquD0G9IR
xjGw+urcz090deIlzleaM60DIqLFdyO0vExcyowbGeZw/tuZShh1X0AzMFHoziLX
C2StIDGmXAZKRDsT1HpRx6nDx9r+8R2wdfUlxD6qRttdesD5vekZvzC7g7VnJF2O
FVXGbBOMJ4Ti7FPzQo3G/hH3oxYcMtjeOSJshIDHCtcU1es5cPCKTAi8+S0KT/hZ
FUMSvn+eprkntZu5/RCq7ir8IDPnAbYgPAz2JfdJnctsQWl9RCWxmxgP5zenixUy
HlyN1tDMf/7026K6LfqLRq+j5dcQMbC9m5zvuwIDAQABAoIBADx14yI66xkczWOz
rEuKV0pPKArKnZ2lKrgxWASRCSZ2WHUuVPAAE/v+s51QMeB2prtgJ6D+Uzw1ROdV
NNSCn9DMCw0hQdCiW6ikgjA55GZYIRFGKrgPGLTap5PGLvag5UODIPUx4ORuajj0
++Ka/+WmKYXHQoEdKvDUmd6TSUkIyX6Nb8sAKAuakWefHEDb1psST2oRKiVQtKVS
0B1posDxTMbVfyXY6gkch554UqQjptvYWM25C/gka5JDyYg6tD13K1k9q45unoX9
0Um89ttqCFkR9GTmmdtDgZ9M6bKrcMPpFosrmphJh2Drd+sl6Q//60xcqzDLZ0AN
DBjxIxECgYEA6Dywx49KUHMeu++d+R1vqQp5d7hELyauorhvdTIRIELPuWqOHrW0
ou3jJZ3xyuKazKClQCDmhpKLniQOyjH9QRv249W+9jwvdx+VDT5BtG8/76Bp3Va9
4E0eDZdbRuvWo6XOpQTjKfCS+RUgqCrOTYoOU7mVH7F3LiGjgtreUy8CgYEAxzVO
mIQ5VXhmf7ls7X9/EYL0x57n0TyxJfNIxZDpvSc75zYybXtaPyeOMLwxyWGqX+CC
+73Emrqf9s/HZK7K82y/ifT8dvTUBMmJTKCkjoL7ljMn0RuIb/H+UCySk+LS0ARD
sm9nt0+3vyqqczCWKtxf6Esu7j+9W5DUmdbj+TUCgYBdPxET73q9NpveheV+As20
p9oBseDetb9k4n0OJ14s/+Z74kbSGc8/pBiSIArXlYjmJJJ1X0BwRCL/CidOFChF
nj7RWB9mqt+8CthECv1Cv3CCfHxFPPDcQNqSRnWF0mfKKWcBZyb2zfuVO2BzZUyU
YZxDDb7MjOr3gNYwUkT2TQKBgBHNmM2Wm40g6oAlsS90goWtH3UrpWoUs3xBxtIp
RkpqVDcwp8cTDBiyz0lZuFVYDiLtbKdU6VourZcgMKC14lto76FDrMBw1vXqkQOx
I6O83wEoZzmP7Vyb0u+VXDAtSEvg5a/vtuQyEqjaBkuvHuyLr2KSPYp7Vc/2HJn3
E361AoGAecpulg2/1kw/3PN86jDK9LToibmhnq+qctWALOU03JBalGIm4PWI3Qn0
FeJavrBuhoVzczoyakzcrqy9O6UWAYt98wwYJYURTeNm4GjuCOmTvZeirZr1/shd
SnUvNFsctUlBTVoNsQhtrpiuRwRq+uGtgS7UwfepFBy+VekbQts=
-----END RSA PRIVATE KEY-----

</key>

""";

  String configFile1 = """
 ###############################################################################
 # OpenVPN 2.0 Sample Configuration File
 # for PacketiX VPN / SoftEther VPN Server
 #
 # !!! AUTO-GENERATED BY SOFTETHER VPN SERVER MANAGEMENT TOOL !!!
 #
 # !!! YOU HAVE TO REVIEW IT BEFORE USE AND MODIFY IT AS NECESSARY !!!
 #
 # This configuration file is auto-generated. You might use this config file
 # in order to connect to the PacketiX VPN / SoftEther VPN Server.
 # However, before you try it, you should review the descriptions of the file
 # to determine the necessity to modify to suitable for your real environment.
 # If necessary, you have to modify a little adequately on the file.
 # For example, the IP address or the hostname as a destination VPN Server
 # should be confirmed.
 #
 # Note that to use OpenVPN 2.0, you have to put the certification file of
 # the destination VPN Server on the OpenVPN Client computer when you use this
 # config file. Please refer the below descriptions carefully.


 ###############################################################################
 # Specify the type of the layer of the VPN connection.
 #
 # To connect to the VPN Server as a "Remote-Access VPN Client PC",
 #  specify 'dev tun'. (Layer-3 IP Routing Mode)
 #
 # To connect to the VPN Server as a bridging equipment of "Site-to-Site VPN",
 #  specify 'dev tap'. (Layer-2 Ethernet Bridgine Mode)

 dev tun


 ###############################################################################
 # Specify the underlying protocol beyond the Internet.
 # Note that this setting must be correspond with the listening setting on
 # the VPN Server.
 #
 # Specify either 'proto tcp' or 'proto udp'.

  proto tcp
 # keepalive 10 30
  keepalive 10 30
  connect-retry 5 10


 ###############################################################################
 # The destination hostname / IP address, and port number of
 # the target VPN Server.
 #
 # You have to specify as 'remote <HOSTNAME> <PORT>'. You can also
 # specify the IP address instead of the hostname.
 #
 # Note that the auto-generated below hostname are a "auto-detected
 # IP address" of the VPN Server. You have to confirm the correctness
 # beforehand.
 #
 # When you want to connect to the VPN Server by using TCP protocol,
 # the port number of the destination TCP port should be same as one of
 # the available TCP listeners on the VPN Server.
 #
 # When you use UDP protocol, the port number must same as the configuration
 # setting of "OpenVPN Server Compatible Function" on the VPN Server.

 # remote cdn2.ertaqy.com 8301
 # remote 192.168.12.253 8301
 remote cdn.ertaqy.com 8301



 ###############################################################################
 # The HTTP/HTTPS proxy setting.
 #
 # Only if you have to use the Internet via a proxy, uncomment the below
 # two lines and specify the proxy address and the port number.
 # In the case of using proxy-authentication, refer the OpenVPN manual.

 ;http-proxy-retry
 ;http-proxy [proxy server] [proxy port]


 ###############################################################################
 # The encryption and authentication algorithm.
 #
 # Default setting is good. Modify it as you prefer.
 # When you specify an unsupported algorithm, the error will occur.
 #
 # The supported algorithms are as follows:
 #  cipher: [NULL-CIPHER] NULL AES-128-CBC AES-192-CBC AES-256-CBC BF-CBC
 #          CAST-CBC CAST5-CBC DES-CBC DES-EDE-CBC DES-EDE3-CBC DESX-CBC
 #          RC2-40-CBC RC2-64-CBC RC2-CBC
 #  auth:   SHA SHA1 MD5 MD4 RMD160

 auth SHA1

 data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC
 cipher AES-256-CBC
 ncp-disable


 ###############################################################################
 # Other parameters necessary to connect to the VPN Server.
 #
 # It is not recommended to modify it unless you have a particular need.
 
 resolv-retry infinite
 nobind
 persist-key
 persist-tun
 client
 verb 3
 
 
###############################################################################
# Authentication with credentials.
#
# Comment the line out in case you want to use the certificate authentication.
  auth-user-pass
# route 192.168.112.12/32
  route 192.168.112.12 255.255.255.255 
# route 192.168.112.12 255.255.255.255 172.21.1.1
# route 10.0.0.0 255.255.255.0 10.3.0.1
 ###############################################################################
 # The certificate file of the destination VPN Server.
 #
 # The CA certificate file is embedded in the inline format.
 # You can replace this CA contents if necessary.
 # Please note that if the server certificate is not a self-signed, you have to
 # specify the signer's root certificate (CA) here.

<ca>
-----BEGIN CERTIFICATE-----
MIIDuDCCAqCgAwIBAgIIL6QxTuKN94IwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NzA1MTM0OTA5WhcNMzgwMTE4MDMxNDA3WjBhMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQswCQYDVQQDDAJDQTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBALl9ZZLLJBjQrCFOBfAvQ1dnlg06DmYhmRjOQqLXywHVjbfk
Jpk/uBx48V+xPyWxdBd+Poqt25MqyCPsPdxYLpZs2d+W/XTPnqn8iFWV0SZ/DvHi
YiK9u7ZZ5VJ+jTVtxE1s+c3oZruqKx0Q6/TPvFXFR2zgq44BoGyhUoo7KSYyT2e6
NY41ZwYFvQTQE1qmLHHsi7NV060j9bAjgX+N7S7tcpcf9PAqcRBORWHAwvEcq1BR
JMuHsttMhwGAnt2Qzn4Vto+XNOOHhxFAdB6WH985/vxvivtYgu8sdpN8g4Vdl9jV
at75rGZTpfm7oRlzMZWBTaGmxViK5lTQZvPpOmcCAwEAAaN0MHIwDwYDVR0TAQH/
BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFPahmpHRc3paOH+Cypl7
SZjVfBEYMDAGA1UdHwQpMCcwJaAjoCGGH2h0dHA6Ly9jZG4uZXJ0YXF5LmNvbS9j
cmwvNS5jcmwwDQYJKoZIhvcNAQELBQADggEBAGbYkN63JKNShEiK0No+t3Sht15j
xXmSniykecExSe9ec/aSZX6+giMrOIsWKM0agX9VRLpzYM5kJgqFvFvVYYeIz29Q
mxR93a59HVMvNbLRsi8CJcZy20HlLgDpHc1l59KCj9H37zFL3uESknMEq7JmcRIW
6NogFxTizQzI6lI9Bb9Nicbqe8IM6ZmiCTdW9N1UTS5FYYxariYmJm4PzPhO/PxJ
ko+niIMQLN+5S9BxAtN1fnuVSNnAS4eeOB8UvizV+Sussv2iv8f0UQJFEz/PuwhE
mNiUkap4OeB50tc3bh9cXRH2Dki8mVeO4GOmtzsEAm6xx8XJwXh7ARGfm1o=
-----END CERTIFICATE-----

</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIID6sWRxs3VtQwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NzA1MTM1MzA0WhcNMzgwMTE4MDMxNDA3WjBlMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQ8wDQYDVQQDDAZDbGllbnQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDPIWTIpXsOC12irdVBYPFWwkewopEYrqgTYyl4Y5ZD
iePFYdCCf6x9gCyN7PRClK7vGWyp7RQgQJFJVOYpeeqdCEwzzdNsrGEMYXpl/MNW
qon743MTC7nG3AQMoimX5p1aFowV1eQFnzUZ1GkxfjeB7DYte9K3z0sl6fVPTvFC
cJK8GVLPqEiLD455KiuD+Toqxz9nu7fYOqLVexjtyh/H43IW2m0iJ8ruGgPKkuhB
BQ3Z5RePHo4e0dkOQnvv+hneRYXnTERYzLjwxu4pkQLCoqPUHFzc40glnFM1MekG
Tj5Ruvw7BhW8gMwbKvk2QvGazpDhIPswlRPuTWUXt85TAgMBAAGjVzBVMBMGA1Ud
JQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQWBBS1tsXglKJpPZ4RAvAfzXrIqBNJJjAf
BgNVHSMEGDAWgBT2oZqR0XN6Wjh/gsqZe0mY1XwRGDANBgkqhkiG9w0BAQsFAAOC
AQEAMQs9TQhqD25izMvntxHJuxFUoqYPeEzM8Qsg19bGN1sr0Nf24KzX6BJHF9QD
+qFtSEUMv6BK5tO9Y60hKRKNx+4erZfjNRck+vLAo1VuoQKZfvkr8CPSVFCRyt8H
3/97HIRGbBqNg1+XWfW6+/wNa69XIQD53kb7UltTOU7lO7K/iuVSIk44uGFQCDTw
9+V9yHzsudoHc6XtVs0uUWhtM2vvj8zroWbjz78AvHYH7kCVqDto4s+xj/nkp7gc
5CfU0/keEVlYL/1k7kQRrOHFl9XBz1DHjHNaYmJoLPKLkmaMLJyQTCaUlyVajs5G
5v8mEYNcsiOHX4wB/LQU251Raw==
-----END CERTIFICATE-----

</cert>
<key>
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAzyFkyKV7Dgtdoq3VQWDxVsJHsKKRGK6oE2MpeGOWQ4njxWHQ
gn+sfYAsjez0QpSu7xlsqe0UIECRSVTmKXnqnQhMM83TbKxhDGF6ZfzDVqqJ++Nz
Ewu5xtwEDKIpl+adWhaMFdXkBZ81GdRpMX43gew2LXvSt89LJen1T07xQnCSvBlS
z6hIiw+OeSorg/k6Ksc/Z7u32Dqi1XsY7cofx+NyFtptIifK7hoDypLoQQUN2eUX
jx6OHtHZDkJ77/oZ3kWF50xEWMy48MbuKZECwqKj1Bxc3ONIJZxTNTHpBk4+Ubr8
OwYVvIDMGyr5NkLxms6Q4SD7MJUT7k1lF7fOUwIDAQABAoIBAQCw3lkLJJMxaO8p
7Lo/O6KZbQh+gjLYGrwW4gQVcyRqw6Ild+LurEsEV6C0CHSDLic6sEEj0PfwmnH1
ZnOrUxnNwbogOk+haojsY4h68h1zMejlmFE5IDgg4NrsVsShmyEePkaclqpBSrOz
PLgetSJ85NFWgXdr0azf0SnR8Rz+l0y40zf6lc6l1VUBLDvRuDALSeisAyiZZPXk
LAXD7+rHg9RCPMFFXjjKG4OYXvc8GOIhF2b6tg+QN12dzviTUI43DNrhZx2AiqE6
iF4BtdnJUec0+dGA410d0logiwuiLON5x5A69F/hBQ4sSg386ij+uml8N+JOd7wg
Umn+ygQRAoGBAOtoku6zF6GdSwt9VtEBqmkKuQpYKJgD2c1ul/I9N4OPQouUbwWs
amPmjlMC2tchDwoWRLclqXZGcGlSIP0UB+pv0G0aNGwuNEaRQqpSqD8405OmKSS4
6IgYbgXxfbzIcoSrxQWTmd2E62pRxSzkgxzLCLNd+Y7cEuaRmlBxtcltAoGBAOE/
mTwFckMrRIozMwCjUVMndRIFMPhps8E9x+x+IqZcaGDnxKx/inNaDPDVUjP4AakR
0QfwoUzYMYFZweUr/sR0CI/UTXjaXeJ4pqdj3pn8r5jfJPzvB6Z+Iz2m7eAK6fZ1
hVj8XCG462oR0hN3mS1JxO5crQihkiYURedF0t6/AoGBAMtqI3zreEIInu4gskIM
RGpb/6T2pK0mtq+THu0NBMlDo2blLkIiyBPnB5inYN6ADHTU5S+09YfkOgJoG2VU
R7rGP73m5OGN01Ie9xIiNova2Mg+zlKTDSt8oKW2FMZqFrqZirfU4SHPV3UZj13J
X5ojvzLuw1Q0yog9zLAycbjJAoGAceXJ40rRu1s+ni9Dg/gRYF3cWc9cMtCoP3ex
B0nE1aB2e0HW9m7LoIaRcpo7peGrXUWQEFbCCWxso/6yB+MWQVp3FduBjTHGNYVS
p+PdJLpcRI3ZUzi/ApZX1Y36TMbYBXLpidSZ9cde6tS2CHf6cacSuIEOUgX5M94e
dtKczVsCgYAmqOfjIUERpvU6y6KBT8ua4hwGtKd1YY+Q/vfJLFQxi7Y4Ga3CmSGy
z2w72t0sdthdiiGHUUcvIo9TEp45qC1qAG8avaKqCjvKNJAuL/4eFJOhfVPQ+X79
/QLnZWpAs/pza00agVLnjq0bPEgGDCVJU2OUlaN+GEsz+FJ9rS3yAQ==
-----END RSA PRIVATE KEY-----

</key>



""";

  String configFile2 = """
 ###############################################################################
 # OpenVPN 2.0 Sample Configuration File
 # for PacketiX VPN / SoftEther VPN Server
 #
 # !!! AUTO-GENERATED BY SOFTETHER VPN SERVER MANAGEMENT TOOL !!!
 #
 # !!! YOU HAVE TO REVIEW IT BEFORE USE AND MODIFY IT AS NECESSARY !!!
 #
 # This configuration file is auto-generated. You might use this config file
 # in order to connect to the PacketiX VPN / SoftEther VPN Server.
 # However, before you try it, you should review the descriptions of the file
 # to determine the necessity to modify to suitable for your real environment.
 # If necessary, you have to modify a little adequately on the file.
 # For example, the IP address or the hostname as a destination VPN Server
 # should be confirmed.
 #
 # Note that to use OpenVPN 2.0, you have to put the certification file of
 # the destination VPN Server on the OpenVPN Client computer when you use this
 # config file. Please refer the below descriptions carefully.


 ###############################################################################
 # Specify the type of the layer of the VPN connection.
 #
 # To connect to the VPN Server as a "Remote-Access VPN Client PC",
 #  specify 'dev tun'. (Layer-3 IP Routing Mode)
 #
 # To connect to the VPN Server as a bridging equipment of "Site-to-Site VPN",
 #  specify 'dev tap'. (Layer-2 Ethernet Bridgine Mode)

 dev tun


 ###############################################################################
 # Specify the underlying protocol beyond the Internet.
 # Note that this setting must be correspond with the listening setting on
 # the VPN Server.
 #
 # Specify either 'proto tcp' or 'proto udp'.

  proto tcp
 # keepalive 10 30
  keepalive 10 30
  connect-retry 5 10

 ###############################################################################
 # The destination hostname / IP address, and port number of
 # the target VPN Server.
 #
 # You have to specify as 'remote <HOSTNAME> <PORT>'. You can also
 # specify the IP address instead of the hostname.
 #
 # Note that the auto-generated below hostname are a "auto-detected
 # IP address" of the VPN Server. You have to confirm the correctness
 # beforehand.
 #
 # When you want to connect to the VPN Server by using TCP protocol,
 # the port number of the destination TCP port should be same as one of
 # the available TCP listeners on the VPN Server.
 #
 # When you use UDP protocol, the port number must same as the configuration
 # setting of "OpenVPN Server Compatible Function" on the VPN Server.

 # remote cdn2.ertaqy.com 8301
  remote 192.168.12.253 8301

 ###############################################################################
 # The HTTP/HTTPS proxy setting.
 #
 # Only if you have to use the Internet via a proxy, uncomment the below
 # two lines and specify the proxy address and the port number.
 # In the case of using proxy-authentication, refer the OpenVPN manual.

 ;http-proxy-retry
 ;http-proxy [proxy server] [proxy port]


 ###############################################################################
 # The encryption and authentication algorithm.
 #
 # Default setting is good. Modify it as you prefer.
 # When you specify an unsupported algorithm, the error will occur.
 #
 # The supported algorithms are as follows:
 #  cipher: [NULL-CIPHER] NULL AES-128-CBC AES-192-CBC AES-256-CBC BF-CBC
 #          CAST-CBC CAST5-CBC DES-CBC DES-EDE-CBC DES-EDE3-CBC DESX-CBC
 #          RC2-40-CBC RC2-64-CBC RC2-CBC
 #  auth:   SHA SHA1 MD5 MD4 RMD160

 auth SHA1
 data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC
 cipher AES-256-CBC
 ncp-disable

 ###############################################################################
 # Other parameters necessary to connect to the VPN Server.
 #
 # It is not recommended to modify it unless you have a particular need.

 resolv-retry infinite
 nobind
 persist-key
 persist-tun
 client
 verb 3
 
 
###############################################################################
# Authentication with credentials.
#
# Comment the line out in case you want to use the certificate authentication.
  auth-user-pass
# route 192.168.112.12/32
  route 192.168.112.12 255.255.255.255 
# route 192.168.112.12 255.255.255.255 172.21.1.1
# route 10.0.0.0 255.255.255.0 10.3.0.1
 ###############################################################################
 # The certificate file of the destination VPN Server.
 #
 # The CA certificate file is embedded in the inline format.
 # You can replace this CA contents if necessary.
 # Please note that if the server certificate is not a self-signed, you have to
 # specify the signer's root certificate (CA) here.

<ca>
-----BEGIN CERTIFICATE-----
MIIDhjCCAm6gAwIBAgIIEH++OKM6x5IwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NTA3MTg1MzE2WhcNMzgwMTE4MDMxNDA3WjBhMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQswCQYDVQQDDAJDQTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAL+eleD6RplgHgl/VBmKeNPAQdGq9XZo4A8IzooxMBBA+tVe
2sCfWQcFY6Za1qmQfAoFUswbtuyvuXv/CA8uyEzS5t3MDCv8gZ8/e8yAELdz8Z9Y
iO/Go00LH9cH2yDwzyMv9ebdFn5WhCVxpEi0eWbd3cHC0woeQ6eyweT0XOM5z8TM
cS3JVyNiRVoilyQweR51c51zNBgnNCpzY4CQv1E18xDI/LtntnRlWBSBIM4OfhjA
rEZC8IS1T2VBbrXJ+d6GtU/BotCNuioXdhVmGhE/lVXyniZ8rDkZVckRMs0wXNTw
vRtXFfoPS5yeybOV1JDe44n2GZ3vRYdNCdy854kCAwEAAaNCMEAwDwYDVR0TAQH/
BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFNMJ1LJSuX1mImI8OTJk
x01FAbwbMA0GCSqGSIb3DQEBCwUAA4IBAQAeNplwYxnp1H296umiLx4QH1OpQv1z
EGr708zLP9lsaJjFUafKM4H9HRK2sV7i3JvuGbKTWDT+HYKG4PVgOzMy+LVWvftB
6qwaHtm1nwOzBshe8C95gmAMlij6pUGuuZuF414ajcf1pWmrR4kVDG8ZGmGfX0RR
GpreNZgTFqbQdCYqjinaBzwKAZ7KeucQRnv2N87ba/0Udom7YiJjtM6A9dV5elRa
pHFgKJVqKqDHdPEjamf80nT7YetEwqGIoBPU8SqSwOhFbO7AIcEaWqlfN1dEddKs
i+WMfuXcleoYjR8sQaPPYMOrOEQRBeHTHVgniY3om/poTCu54MgAg1Y1
-----END CERTIFICATE-----
</ca>

<cert>
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIIZFNr0qHoqjUwDQYJKoZIhvcNAQELBQAwYTELMAkGA1UE
BhMCRUcxCzAJBgNVBAgMAkRLMREwDwYDVQQHDAhNYW5zb3VyYTETMBEGA1UECgwK
RVJUQVFZIExMQzEQMA4GA1UECwwHTmV0d29yazELMAkGA1UEAwwCQ0EwHhcNMjQw
NTA3MTg1NTEyWhcNMzgwMTE4MDMxNDA3WjBlMQswCQYDVQQGEwJFRzELMAkGA1UE
CAwCREsxETAPBgNVBAcMCE1hbnNvdXJhMRMwEQYDVQQKDApFUlRBUVkgTExDMRAw
DgYDVQQLDAdOZXR3b3JrMQ8wDQYDVQQDDAZDbGllbnQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCer/KB9b4gjXOPwTEPl1aft5lnksaRqnaQ0yE9Zwaa
s5vrtxbqhOYY2euYi3q5Oz980h9JeIPkOCRxociGJIiXdfktfpW/0rmjlxtPQ6zq
x7w2o+24bhZap8nyvQ32xswiQ0nyJqHBrTbh6WlZVHyW5iCzY0RMj3oc62jD8CC9
eGCwO5wucUXcUknCiz4/8sAWbn+aErPGST+NKIabhK3KEh6zHifR/KcUbFkUXEPR
9J+SZOA2ttqUeWAyXzOOWBojz/b+ZQAqsLJ1EIGwGb8eiFHJgALbWxHaDjEJQA8S
T7h43Zq0o3Libpb/I0d1Xj9c3BQjCBFZq0IuopT1AwOXAgMBAAGjVzBVMBMGA1Ud
JQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQWBBRf+1fQE/I87AZwNpU28dJnKb/iyzAf
BgNVHSMEGDAWgBTTCdSyUrl9ZiJiPDkyZMdNRQG8GzANBgkqhkiG9w0BAQsFAAOC
AQEAHxvdWSABisE2RtE0QxXgple5ySflAFp9ZCNzE70XzmOakKm1JA30eondVnna
QggjkSwNjYDZbA3v4euow8vXzZV2a0h6dRa2hTuV1fsdrn4wYe0s1H5Gpf76aT5b
E/w8CNZAy9rJNBtF+UibS3zmF9z+HXb+4uu9xX55SGxs9D2vOO9jy3fJv5Lj7zGn
QqefHnaQW6UjB9wNef4jMRCWIM53kB11ywQcOdaMK+EsX5ElyaFsUAKeWo4R+QXs
zKyzs3sPSrHh1bX+I5vsWls4zB1isugnJAcyj+Fk6FFwHXzAVNkVozRBsqxXaCOV
C5Q6+fVpR7MefZqMT9lHp+rgYg==
-----END CERTIFICATE-----
</cert>

<key>
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAnq/ygfW+II1zj8ExD5dWn7eZZ5LGkap2kNMhPWcGmrOb67cW
6oTmGNnrmIt6uTs/fNIfSXiD5DgkcaHIhiSIl3X5LX6Vv9K5o5cbT0Os6se8NqPt
uG4WWqfJ8r0N9sbMIkNJ8iahwa024elpWVR8luYgs2NETI96HOtow/AgvXhgsDuc
LnFF3FJJwos+P/LAFm5/mhKzxkk/jSiGm4StyhIesx4n0fynFGxZFFxD0fSfkmTg
NrbalHlgMl8zjlgaI8/2/mUAKrCydRCBsBm/HohRyYAC21sR2g4xCUAPEk+4eN2a
tKNy4m6W/yNHdV4/XNwUIwgRWatCLqKU9QMDlwIDAQABAoIBAFBvOMn9CQExEcll
EHwppsPQaVahhDsjn3OrQOcByMwzjC3/oQMAmC0ykIPC91LaoEShsTApgRj2CCr8
6UptTDsRllskFb2kj2pHVpVn5UcgNNuxXfak/nm3INsETwauH5yiZOH0CPvF09LQ
4BBijcBjJ2ImR+FSvH/aJ0Fh/wZqKJsj6fqCMmwd1VcMiPe7/h+7Hgm4hJDDKoxC
a//Li5UbClbdP7inEypdl/vJZ1R06PPsl/dRwLw9Y1iP94YTHY9zjZB3i1y9WgI4
WSPrVMg75GGjAixME9ODJAzORJpcWIk8DxMzRwlB+gnecqpIuiQyCVAkoUrvPrU5
IiDpeoECgYEAzsqHgHQH63sfmTwL8FbPbYKit80jHQWCS7fLgKdqnjDgRLx0JKP1
BxkWo9n6b2xQQgAl+EViQ2pJQcdVGmI9h4RIAwkQlONRbTvWo1jq6BJsP1PorqQe
8/5ip+lU2FJYfD9K/aXfxRJ4htRA2YCXHYyDCs409GGJ6rBsKcJZ3UECgYEAxHL9
QcGTwR6S7IlJuKxtUCjeDeBaEQNwm3HxYrDptTZc1aAjsz/bOMwE5z1oZQhOvm9I
/p2eHAQcCf8X0Kt6f149xU2s68oBj+b1BjA/FmXE0KxTsOoBuVqcVY+0s/9nz8aG
yCB+gRKHfS0bn18zX5TeQO6PjCk5SdVnhXvzstcCgYBPZDA7n9B+lsmd4hDPV/TR
HWttV4OYm8nXWhv2K9BiJW+k1BlfC9eBvx8TDxf3+USi4j2xoKnGKiMv7uB8faUT
xzSCfdNw5gkX//Y6xmOBb7lBYuydSANeN5cW0h0x5AN2yDH5SdqsZZgCY7D2EEl0
HcMdvedUv7HceZk9OxGXQQKBgQC5saxdhNri+MCPIHL0QuENnaPQ4Bqi7Gp8NWek
D3DLH3j/YeF9JcZWWNvlrXFJ12F/t3f7Xgg/mU7b0Cq1z/H6BZ5EK9liBNAXM4y3
bdGknUw+qDZwC7LXf6Q5aJ66apm5mIJ9F+IcpeQ22fW7X2UTW4f/PsGoDquddEDn
t7QzfwKBgFEVOxL23CyASDJvZscil+WoaLoGfJM27gzgK3mqYL86jOkksgbMPi6L
OOPLEmU4gOaUJ5Ix64GG6ljOljKt2E7UeWOgPua6qMaL9MlxFy/yh4/Mu+29tBzt
RA5qtsuXYjjjPR9eotFk69BYuOyb17BK9Jyj1N5iM7oDx6B76CIQ
-----END RSA PRIVATE KEY-----
</key>
""";
}
