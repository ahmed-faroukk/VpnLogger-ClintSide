 import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:openvpn_flutter/openvpn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OpenVPN engine;
  VpnStatus? status;
  String? stage;
  bool _granted = false;
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
      providerBundleIdentifier: "id.laskarmedia.openvpnFlutterExample.VPNExtension",
      localizedDescription: "VPN by Nizwar",
      lastStage: (stage) {
        setState(() {
          this.stage = stage.name;
        });
      },
      lastStatus: (status) {
        setState(() {
          this.status = status;
        });
      },
    );
    super.initState();
  }

  Future<void> initPlatformState() async {
    engine.connect(
      configFile,
      "USA",
      username: defaultVpnUsername,
      password: defaultVpnPassword,
      certIsRequired: true,
    );
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ertaqy Vpn'),
          backgroundColor: Colors.blue,

        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(stage?.toString() ?? VPNStage.disconnected.toString() , style: const TextStyle(color: Colors.green , fontWeight: FontWeight.bold),),
                const SizedBox(height: 10),
                Text(status?.toJson().toString() ?? "", style: const TextStyle(color: Colors.blue), ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: const Text("Start"),
                      onPressed: () async {
                        try{
                          await initPlatformState();
                        } catch(e){
                          print("error is ------------------------------------$e");
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("STOP"),
                      onPressed: () {
                        engine.disconnect();
                      },
                    ),
                  ],
                ),

                if (Platform.isAndroid)
                  TextButton(
                    child: Text(_granted ? "Granted" : "Request Permission"),
                    onPressed: () {
                      engine.requestPermissionAndroid().then((value) {
                        setState(() {
                          _granted = value;
                        });
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String defaultVpnUsername = "remusr_ahmedfarouk1";
const String defaultVpnPassword = "Ak@kW7w*a7asz225";

String get config => """
client
dev tun
proto tcp
persist-key
persist-tun
tls-client
remote-cert-tls server
auth-nocache
mute 10
remote cdn2.ertaqy.com 8301
auth SHA1
cipher AES-128-CBC
auth-user-pass

ca [inline]
cert [inline]
key [inline]

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
// https://forums.openvpn.net/viewtopic.php?t=29411
String configFile =
"""
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