#!/bin/sh


if [ ! -f ../firehol.sh -o ! -f services.html ]
then
	echo "Please step into the 'doc' directory of firehol"
	exit 1
fi

service_AH_notes="IPSec Authentication Header (AH).
<p>
For more information see the <a href=\"http://www.freeswan.org/freeswan_trees/freeswan-1.99/doc/ipsec.html#AH.ipsec\">FreeS/WAN documentation</a>
and RFC <a href=\"http://www.ietf.org/rfc/rfc2402.txt?number=2402\">RFC 2402</a>.
"

service_aptproxy_notes="Debian package proxy."


service_apcupsd_notes="<a href=\"http://www.apcupsd.com/\">APC UPS Deamon</a> ports. This service must be defined as <b>server apcupsd accept</b> on all machines
not directly connected to the UPS (i.e. slaves).
<p>
Note that the port defined here is not the default port (6666) used if you download and compile
APCUPSD, since the default is conflicting with IRC and many distributions (like Debian) have
changed this to 6544.
<p>
You can define port 6544 in APCUPSD, by changing the value of NETPORT in its configuration file,
or overwrite this FireHOL service definition using the procedures described in
<a href=\"adding.html\">Adding Services</a>.
"


service_apcupsdnis_notes="APC UPS Network Information Server. This service allows the remote WEB interfaces
<a href=\"http://www.apcupsd.com/\">APCUPSD</a> has, to connect and get information from the server directly connected to the UPS device.
"


server_all_ports="all"
client_all_ports="all"
service_all_type="complex"
service_all_notes="
Matches all traffic (all protocols, ports, etc) while ensuring that required kernel modules are loaded.
<br>This service may indirectly setup a set of other services, if they are required by the kernel modules to be loaded.
Currently it activates also <a href=\"#ftp\">ftp</a>, <a href=\"#irc\">irc</a> and <a href=\"#icmp\">icmp</a>.
"

server_amanda_ports="see&nbsp;notes"
client_amanda_ports="see&nbsp;notes"
service_amanda_type="complex"
service_amanda_example="server amanda accept <u>src</u> <u>1.2.3.4</u>"
service_amanda_notes="
This implementation of <a href=\"http://amanda.sf.net\">AMANDA, the Advanced Maryland Automatic Network Disk Archiver</a>
is based on the <a href=\"http://amanda.sourceforge.net/cgi-bin/fom?_highlightWords=firewall&file=139\">notes posted at Amanda's Faq-O-Matic</a>.
<p>
Based on this, FireHOL allows:<br>
<ul>
	<li>a connection from the server to the client at <b>udp 10080</b></li>
	<li>connections from the client to the server at <b>tcp & udp</b> ports
	controlled by the variable <b>FIREHOL_AMANDA_PORTS</b>.
	<p>
	Default: <b>FIREHOL_AMANDA_PORTS=\"850:859\"</b>
	<p>It has been written in amanda mailing lists that by default amanda
	chooses ports in the range of 600 to 950. If you don't compile amanda
	yourself you may have to change the variable FIREHOL_AMANDA_PORTS to
	accept a wider match (but consider the trust relationship you are
	building with this).
	</li>
</ul>
I <b>strongly suggest</b> to use this service in your firewall like:
<p>
<b><a href=\"commands.html#server\">server</a> amanda accept <a href=\"commands.html#src\">src</a> 1.2.3.4</b>, or <br>
<b><a href=\"commands.html#client\">client</a> amanda accept <a href=\"commands.html#dst\">dst</a> 5.6.7.8</b>
<p>
in order to limit the hosts
that have access to the ports controlled by the variable <b>FIREHOL_AMANDA_PORTS</b>.
<p>
This complex service handles correctly the multi-socket bi-directional environment required.
Use the FireHOL <b>server</b> directive on the Amanda server, and FireHOL's <b>client</b> on the Amanda client.
<p>
The <b>amanda</b> service will break if it is NATed (to work it would require a bi-directional NAT and
a modification in the amanda code to allow connections from/to high ports).
<p>
<b>USE THIS WITH CARE. MISUSE OF THIS SERVICE MAY LEAD TO OPENING PRIVILEGED PORTS TO ANYONE.</b>
"


server_any_ports="all"
client_any_ports="all"
service_any_type="complex"
service_any_notes="
Matches all traffic (all protocols, ports, etc), but does not care about kernel modules and does not activate any other service indirectly.
In combination with the <a href=\"commands.html#parameters\">Optional Rule Parameters</a> this service can match unusual traffic (e.g. GRE - protocol 47).
"
service_any_example="server any <u>myname</u> accept proto 47"


service_cups_notes="<a href=\"http://www.cups.org\">Common UNIX Printing System</a>"


server_custom_ports="defined&nbsp;in&nbsp;the&nbsp;command"
client_custom_ports="defined&nbsp;in&nbsp;the&nbsp;command"
service_custom_type="complex"
service_custom_notes="
This service is used by FireHOL to allow you define services it currently does not support.<br>
To find more about this service please check the <a href=\"adding.html\">Adding Services</a> section.
"
service_custom_example="server custom <u>myimap</u> <u>tcp/143</u> <u>default</u> accept"


service_dcpp_notes="
Direct Connect++ P2P, can be found <a href=\"http://dcplusplus.sourceforge.net\">here</a>.
"

service_dhcp_notes="
Keep in mind that DHCP clients broadcast the network (src 0.0.0.0 dst 255.255.255.255) to find a DHCP server.
This means that if your <b>server dhcp accept</b> command is placed within
an interface that has <b>src</b> and / or <b>dst</b> parameters,
DHCP broadcasts will not enter this interface.
<p>
You can overcome this problem by placing the DHCP service on a separate
interface, without an <b>src</b> or <b>dst</b> but with a <b>policy return</b>.
Place this interface before the one that defines the rest of the services.
<p>
For example:
<table border=0 cellpadding=0 cellspacing=0>
<tr><td><pre>
<br>&nbsp;&nbsp;&nbsp;&nbsp;interface eth0 dhcp
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;policy return
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server dhcp accept
<br>
<br>&nbsp;&nbsp;&nbsp;&nbsp;interface eth0 lan src \"\$mylan\" dst \"\$myip\"
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...
</td></tr></table>
Note that if you are running a DHCP client and your provider has installed more than one DHCP servers, you
may see a few entries in your system log about packets dropped from the IP of some
DHCP server to 255.255.255.255 with source port 67 and destination port 68 (protocol UDP).
This is normal, since the iptables connection tracker will allow only <b>one</b> reply
to match the DHCP client request. All the other replies will not match a request and will be dropped (and logged).
"

service_dhcprelay_notes="DHCP Relay.
<p><small><b><font color=\"gray\">From RFC 1812 section 9.1.2</font></b></small><br>
   In many cases, BOOTP clients and their associated BOOTP server(s) do
   not reside on the same IP (sub)network.  In such cases, a third-party
   agent is required to transfer BOOTP messages between clients and
   servers.  Such an agent was originally referred to as a BOOTP
   forwarding agent.  However, to avoid confusion with the IP forwarding
   function of a router, the name BOOTP relay agent has been adopted
   instead.
<p>
For more information about DHCP Relay see section 9.1.2 of
<a href=\"http://www.ietf.org/rfc/rfc1812.txt?number=1812\">RFC 1812</a>
and section 4 of 
<a href=\"http://www.ietf.org/rfc/rfc1542.txt?number=1542\">RFC 1542</a>
"


service_ESP_notes="IPSec Encapsulated Security Payload (ESP).
<p>
For more information see the <a href=\"http://www.freeswan.org/freeswan_trees/freeswan-1.99/doc/ipsec.html#ESP.ipsec\">FreeS/WAN documentation</a>
and RFC <a href=\"http://www.ietf.org/rfc/rfc2406.txt?number=2406\">RFC 2406</a>.
"

server_emule_ports="many"
client_emule_ports="many"
service_emule_example="client emule accept src 1.1.1.1"
service_emule_type="complex"
service_emule_notes="<a href=\"http://www.emule-project.com\">eMule</a> (Donkey network client).
<p>
According to <a href=\"http://www.emule-project.net/faq/ports.htm\">eMule Port Definitions</a>, FireHOL defines:
<ul>
	<li>Connection from any client port to the server at tcp/4661<br>&nbsp;</li>
	<li>Connection from any client port to the server at tcp/4662<br>&nbsp;</li>
	<li>Connection from any client port to the server at udp/4665<br>&nbsp;</li>
	<li>Connection from any client port to the server at udp/4672<br>&nbsp;</li>
	<li>Connection from any server port to the client at tcp/4662<br>&nbsp;</li>
	<li>Connection from any server port to the client at udp/4672<br>&nbsp;</li>
</ul>
Use the FireHOL <a href=\"commands.html#client\">client</a> command to match the eMule client.
<p>
Please note that the <a href=\"http://www.emule-project.com\">eMule</a> client is an HTTP client also.
"


server_ftp_ports="many"
client_ftp_ports="many"
service_ftp_type="complex"
service_ftp_notes="
The FTP service matches both active and passive FTP connections by utilizing the FTP connection tracker kernel module.
"


service_GRE_notes="Generic Routing Encapsulation (protocol No 47).
<p>
For more information see RFC <a href=\"http://www.ietf.org/rfc/rfc2784.txt?number=2784\">RFC 2784</a>.
"

service_heartbeat_notes="
HeartBeat is the Linux clustering solution available <a href="http://www.linux-ha.org/">http://www.linux-ha.org/</a>.
This FireHOL service has been designed such a way that it will allow multiple heartbeat clusters on the same LAN.
"

server_hylafax_ports="many"
client_hylafax_ports="many"
service_hylafax_type="complex"
service_hylafax_notes="
This complex service allows incomming requests to server port tcp/4559 and outgoing <b>from</b> server port tcp/4558.
<p>
<b>The correct operation of this service has not been verified.</b>
<p>
<b>USE THIS WITH CARE. A HYLAFAX CLIENT MAY OPEN ALL TCP UNPRIVILEGED PORTS TO ANYONE</b> (from port tcp/4558).
"

service_ident_example="server ident reject with tcp-reset"


service_isakmp_notes="IPSec key negotiation (IKE on UDP port 500).
<p>
For more information see the <a href=\"http://www.freeswan.org/freeswan_trees/freeswan-1.99/doc/quickstart-firewall.html#quick_firewall\">FreeS/WAN documentation</a>.
"

service_jabber_notes="<a href=\"http://www.jabber.org\">Jabber</a> Instant Messenger
<p>
This definition allows both clear and SSL jabber client - to - jabber server connections, as given in this <a href=\"http://www.jabber.org/user/userfaq.html#id2781037\">Jabber FAQ</a>.
"

service_jabberd_notes="<a href=\"http://www.jabber.org\">Jabberd</a> Instant Messenger Server
<p>
This definition allows both clear and SSL jabber client - to - jabber server and jabber server - to - server connections, as given in this <a href=\"http://www.jabber.org/admin/adminguide.html#requirements-ports\">Jabberd FAQ</a>.
<p>
Use this service for a jabberd server. In all other cases, use the <a href=\"#jabber\">jabber</a> service.
"

service_lpd_notes="Line Printer Deamon Protocol (LPD)
<p>
LPD is documented in <a href=\"http://www.ietf.org/rfc/rfc1179.txt?number=1179\">RFC 1179</a>.
<p>
Since many operating systems are incorrectly using the default client ports for LPD access, this
definition allows the default client ports to access the service (additionally to the RFC defined 721 to 731 inclusive)."


service_microsoft_ds_notes="
Direct Hosted (i.e. NETBIOS-less SMB)
<p>
This is another NETBIOS Session Service with minor differences with <a href=\"#netbios_ssn\">netbios_ssn</a>.
It is supported only by Windows 2000 and Windows XP and it offers the advantage of being indepedent of WINS
for name resolution.
<p>
It seems that samba supports transparently this protocol on the <a href=\"#netbios_ssn\">netbios_ssn</a> ports,
so that either direct hosted or traditional SMB can be served simultaneously.
<p>
Please refer to the <a href=\"#netbios_ssn\">netbios_ssn</a> service for more information.
"

service_msn_notes="
Microsoft MSN Messenger Service<p>
For a discussion about what works and what is not, please take a look at
<A HREF=\"http://www.microsoft.com/technet/treeview/default.asp?url=/technet/prodtechnol/winxppro/evaluate/worki01.asp\">this technet note</A>.
"

server_multicast_ports="N/A"
client_multicast_ports="N/A"
service_multicast_type="complex"
service_multicast_notes="
The multicast service matches all packets send to 224.0.0.0/8 using protocol No 2.
"
service_multicast_example="server multicast reject with proto-unreach"


service_netbios_ns_notes="
NETBIOS Name Service
<p>
See also the <a href=\"#samba\">samba</a> service.
"
service_netbios_dgm_notes="
NETBIOS Datagram Service
<p>
See also the <a href=\"#samba\">samba</a> service.
<p>
Keep in mind that this service broadcasts (to the broadcast address of your LAN) UDP packets.
If you place this service within an interface that has a <b>dst</b> parameter, remember to
include (in the <b>dst</b> parameter) the broadcast address of your LAN too.
"
service_netbios_ssn_notes="
NETBIOS Session Service
<p>
See also the <a href=\"#samba\">samba</a> service.
<p>
Newer NETBIOS clients prefer to use port 445 (<a href=\"#microsoft_ds\">microsoft_ds</a>) for the NETBIOS session service,
and when this is not available they fall back to port 139 (netbios_ssn).
<p>
If your policy on an interface or router is <b>DROP</b>, clients trying to access port 445
will have to timeout before falling back to port 139. This timeout can be up to several minutes.
<p>
To overcome this problem either explicitly <b>REJECT</b> the <a href=\"#microsoft_ds\">microsoft_ds</a> service
with a tcp-reset message (<b>server microsoft_ds reject with tcp-reset</b>),
or redirect port 445 to port 139 using the following rule (put it all-in-one-line at the top of your FireHOL config):
<p>
<b>
iptables -t nat -A PREROUTING -i eth0 -p tcp -s 1.1.1.1/24 --dport 445 -d 2.2.2.2 -j REDIRECT --to-port 139
<p>
</b>or<b>
<p>
redirect to 139 inface eth0 src 1.1.1.1/24 proto tcp dst 2.2.2.2 dport 445
</b><p>
where:
<ul>
	<li><b>eth0</b> is the network interface your NETBIOS server uses
	<br>&nbsp;
	</li>
	<li><b>1.1.1.1/24</b> is the subnet matching all the clients IP addresses
	<br>&nbsp;
	</li>
	<li><b>2.2.2.2</b> is the IP of your linux server on eth0 (or whatever you set the first one above)
	</li>
</ul>
"


server_nfs_ports="many"
client_nfs_ports="500:65535"
service_nfs_type="complex"
service_nfs_notes="
The NFS service queries the RPC service on the NFS server host to find out the ports <b>nfsd</b> and <b>mountd</b> are listening.
Then, according to these ports it sets up rules on all the supported protocols (as reported by RPC) in order the
clients to be able to reach the server.
<p>
For this reason, the NFS service requires that:
<ul>
	<li>the firewall is restarted if the NFS server is restarted</li>
	<li>the NFS server must be specified on all nfs statements (only if it is not the localhost)</li>
</ul>
Since NFS queries the remote RPC server, it is required to also be allowed to do so, by allowing the
<a href=\"#portmap\">portmap</a> service too. Take care, that this is allowed by the <b>running firewall</b>
when FireHOL tries to query the RPC server. So you might have to setup NFS in two steps: First add the portmap
service and activate the firewall, then add the NFS service and restart the firewall.
<p>
To avoid this you can setup your NFS server to listen on pre-defined ports, as it is well documented in
<a href=\"http://nfs.sourceforge.net/nfs-howto/security.html#FIREWALLS\">http://nfs.sourceforge.net/nfs-howto/security.html#FIREWALLS</a>.
If you do this then you will have to define the the ports using the procedure described in <a href=\"adding.html\">Adding Services</a>.
"
service_nfs_example="client nfs accept <u>dst</u> <u>1.2.3.4</u>"


server_ping_ports="N/A"
client_ping_ports="N/A"
service_ping_type="complex"
service_ping_notes="
This services matches requests of protocol <b>ICMP</b> and type <b>echo-request</b> (TYPE=8)
and their replies of type <b>echo-reply</b> (TYPE=0).
<p>
The <b>ping</b> service is stateful.
"

server_pptp_ports="tcp/1723"
client_pptp_ports="default"
service_pptp_type="complex"
service_pptp_notes="
Additionally to the above the PPTP service allows stateful GRE traffic (protocol 47) to flow between the PPTP server and the client.
"


server_samba_ports="many"
client_samba_ports="default"
service_samba_type="complex"
service_samba_notes="
The samba service automatically sets all the rules for <a href=\"#netbios_ns\">netbios_ns</a>, <a href=\"#netbios_dgm\">netbios_dgm</a> and <a href=\"#netbios_ssn\">netbios_ssn</a>.
<p>
Please refer to the notes of the above services for more information.
"


service_webmin_notes="<a href=\"http://www.webmin.com\">Webmin</a> is a web-based interface for system administration for Unix."


# ---------------------------------------------------------------------------------------------------------------

scount=0
print_service() {
	scount=$[scount + 1]
	
	if [ $scount -gt 1 ]
	then
		color=' bgcolor="#F0F0F0"'
		scount=0
	else
		color=""
	fi
	
	service="${1}";	shift
	type="${1}";	shift
	sports="${1}";	shift
	dports="${1}";	shift
	example="${1}";	shift
	notes="${*}"
	
	
cat <<EOF
<tr ${color}>
	<td align="center" valign="top"><a name="${service}"><b>${service}</b></a></td>
	<td align="center" valign="top">${type}</td>
	<td>
		<table cellspacing=0 cellpadding=2 border=0>
		<tr>
EOF
	echo "<td align=right valign=top nowrap><small><font color="gray">Server Ports</td><td>"
	c=0
	for x in ${sports}
	do
		if [ $c -ne 0 ]
		then
			echo ", "
		fi
		
		echo "<b>${x}</b>"
		c=$[c + 1]
	done
	
	echo "</td></tr><tr><td align=right valign=top nowrap><small><font color="gray">Client Ports</td><td>"
	c=0
	for x in ${dports}
	do
		if [ $c -ne 0 ]
		then
			echo ", "
		fi
		
		echo "<b>${x}</b>"
		c=$[c + 1]
	done
	
	echo "</td>"
	
cat <<EOF
	</tr>
	<tr><td align=right valign=top nowrap><small><font color="gray">Notes</td><td>${notes}<br>&nbsp;</td></tr>
	<tr><td align=right valign=top nowrap><small><font color="gray">Example</td><td><b>${example}</b></td></tr>
	</table>
	</td>
	</tr>
EOF
}

smart_print_service() {
	local server="${1}"
	
	local server_varname="server_${server}_ports"
	local server_ports="`eval echo \\\$${server_varname}`"
	
	local client_varname="client_${server}_ports"
	local client_ports="`eval echo \\\$${client_varname}`"
	
	local notes_varname="service_${server}_notes"
	local notes="`eval echo \\\$${notes_varname}`"
	
	local type_varname="service_${server}_type"
	local type="`eval echo \\\$${type_varname}`"
	
	if [ -z "${type}" ]
	then
		local type="simple"
	fi
	
	local example_varname="service_${server}_example"
	local example="`eval echo \\\$${example_varname}`"
	
	if [ -z "${example}" ]
	then
		local example="server ${server} accept"
	fi
	
	print_service "${server}" "${type}" "${server_ports}" "${client_ports}" "${example}" "${notes}"
}



tmp="/tmp/services.$$"

# The simple services
cat "../firehol.sh"			|\
	grep -e "^server_.*_ports=" >"${tmp}"

cat "../firehol.sh"			|\
	grep -e "^client_.*_ports=" >>"${tmp}"

cat "../firehol.sh"			|\
	grep -e "^service_.*_notes=" >>"${tmp}"

. "${tmp}"
rm -f "${tmp}"

all_services() {
	(
		cat "../firehol.sh"			|\
			grep -e "^server_.*_ports="	|\
			cut -d '=' -f 1			|\
			sed "s/^server_//"		|\
			sed "s/_ports\$//"
			
		cat "../firehol.sh"			|\
			grep -e "^rules_.*()"		|\
			cut -d '(' -f 1			|\
			sed "s/^rules_//"
	) | sort | uniq
}



# header
cat <<"EOF"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<link rel="stylesheet" type="text/css" href="css.css">
<TITLE>FireHOL, Pre-defined service definitions.</TITLE>
<meta name="author" content="Costa Tsaousis">
<meta name="description" content="

Home for FireHOL, an iptables stateful packet filtering firewall builder for Linux (kernel 2.4),
supporting NAT, SNAT, DNAT, REDIRECT, MASQUERADE, DMZ, dual-homed, multi-homed and router setups,
protecting and securing hosts and LANs in all kinds of topologies. Configuration is done using
simple client and server statements while it can detect (and produce) its configuration
automatically. FireHOL is extremely easy to understand, configure and audit.

">

<meta name="keywords" content="iptables, netfilter, filter, firewall, stateful, port, secure, security, NAT, DMZ, DNAT, DSL, SNAT, redirect, router, rule, rules, automated, bash, block, builder, cable, complex, configuration, dual-homed, easy, easy configuration, example, fast, features, flexible, forward, free, gpl, helpme mode, human, intuitive, language, linux, masquerade, modem, multi-homed, open source, packet, panic mode, protect, script, service, system administration, wizard">
<meta http-equiv="Expires" content="Wed, 19 Mar 2003 00:00:01 GMT">
</HEAD>

<BODY bgcolor="#FFFFFF">

Bellow is the list of FireHOL supported services. You can overwrite all the services (including those marked as complex) with the
procedures defined in <a href="adding.html">Adding Services</a>.
<p>
In case you have problems with some service because it is defined by its port names instead of its port numbers, you can find the
required port numbers at <a href="http://www.graffiti.com/services">http://www.graffiti.com/services</a>.
<p>
Please report problems related to port names usage. I will replace the faulty names with the relative numbers to eliminate this problem.
All the services defined by name in FireHOL are known to resolve in <a href="http://www.redhat.com">RedHat</a> systems 7.x and 8.
<p>
<center>
<hr noshade size=1>
<table border=0 cellspacing=3 cellpadding=5 width="80%">
<tr>
EOF

lc=0
last_letter=
do_letter() {
	if [ ! -z "${last_letter}" ]
	then
		echo "</td></tr></table></td>"
		echo >&2 "Closing ${last_letter}"
		last_letter=
	fi
	
	if [ ! -z "${1}" ]
	then
		lc=$[lc + 1]
		if [ $lc -eq 5 ]
		then
			echo "</tr><tr>"
			echo >&2 "--- break ---"
			lc=1
		fi
		
		printf >&2 "Openning ${1}... "
		last_letter=${1}
		
		echo "
<td width=\"25%\" align=left valign=top>
	<table border=0 cellpadding=2 cellspacing=2 width=\"100%\">
	<tr><td align=left valign=top><font color=\"gray\" size=+1><b>${last_letter}</td></tr>
	<tr><td align=left valign=top><small>
"
	fi
}

all_services |\
	(
		last=
		t=0
		while read
		do
			first=`echo ${REPLY:0:1} | tr "[a-z]" "[A-Z]"`
			
			while [ ! "$first" = "$last" ]
			do
				t=0
				case "$last" in
					A)	last=B
						test "$first" = "$last" && do_letter $last
						;;
					B)	last=C
						test "$first" = "$last" && do_letter $last
						;;
					C)	last=D
						test "$first" = "$last" && do_letter $last
						;;
					D)	last=E
						test "$first" = "$last" && do_letter $last
						;;
					E)	last=F
						test "$first" = "$last" && do_letter $last
						;;
					F)	last=G
						test "$first" = "$last" && do_letter $last
						;;
					G)	last=H
						test "$first" = "$last" && do_letter $last
						;;
					H)	last=I
						test "$first" = "$last" && do_letter $last
						;;
					I)	last=J
						test "$first" = "$last" && do_letter $last
						;;
					J)	last=K
						test "$first" = "$last" && do_letter $last
						;;
					K)	last=L
						test "$first" = "$last" && do_letter $last
						;;
					L)	last=M
						test "$first" = "$last" && do_letter $last
						;;
					M)	last=N
						test "$first" = "$last" && do_letter $last
						;;
					N)	last=O
						test "$first" = "$last" && do_letter $last
						;;
					O)	last=P
						test "$first" = "$last" && do_letter $last
						;;
					P)	last=Q
						test "$first" = "$last" && do_letter $last
						;;
					Q)	last=R
						test "$first" = "$last" && do_letter $last
						;;
					R)	last=S
						test "$first" = "$last" && do_letter $last
						;;
					S)	last=T
						test "$first" = "$last" && do_letter $last
						;;
					T)	last=U
						test "$first" = "$last" && do_letter $last
						;;
					U)	last=V
						test "$first" = "$last" && do_letter $last
						;;
					V)	last=W
						test "$first" = "$last" && do_letter $last
						;;
					W)	last=X
						test "$first" = "$last" && do_letter $last
						;;
					X)	last=Y
						test "$first" = "$last" && do_letter $last
						;;
					Y)	last=Z
						test "$first" = "$last" && do_letter $last
						;;
					Z)	echo >&2 "internal error"
						exit 1
						;;
					*)	last=A
						test "$first" = "$last" && do_letter $last
						;;
				esac
			done
			
			t=$[t + 1]
			test $t -gt 1 && printf ", "
			printf "<a href=\"#$REPLY\">$REPLY</a>"
		done
		do_letter ""
	)


cat <<"EOF"
</tr></table>
<hr noshade size=1>
<p>
<table border=0 cellspacing=5 cellpadding=10 width="80%">
<tr bgcolor="#EEEEEE"><th>Service</th><th>Type</th><th>Description</th></tr>
EOF


all_services |\
	(
		while read
		do
			smart_print_service $REPLY
		done
	)


cat <<"EOF"
</table>
</center>
<p>
<hr noshade size=1>
<table border=0 width="100%">
<tr><td align=center valign=middle>
	<A href="http://sourceforge.net"><IMG src="http://sourceforge.net/sflogo.php?group_id=58425&amp;type=5" width="210" height="62" border="0" alt="SourceForge Logo"></A>
</td><td align=center valign=middle>
	<small>$Id: create_services.sh,v 1.36 2003/07/20 23:09:02 ktsaou Exp $</small>
	<p>
	<b>FireHOL</b>, a firewall for humans...<br>
	&copy; Copyright 2003
	Costa Tsaousis <a href="mailto: costa@tsaousis.gr">&lt;costa@tsaousis.gr&gt</a>
</body>
</html>
EOF
