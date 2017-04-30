;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	ns.grup12.gsx. root.ns.grup12.gsx. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns.grup12.gsx.
ns	IN	A	172.17.12.1
@	IN	MX	10 correu.grup12.gsx.
correu	IN	A	172.17.12.15

smtp	IN	CNAME	correu
pop3	IN	CNAME	correu

router	IN	CNAME	ns.grup12.gsx.
dhcp	IN	CNAME	ns.grup12.gsx.


www.taller IN	A	172.17.12.2
www.tenda  IN	CNAME	www.taller
taller  IN	CNAME	www.taller
tenda  IN	CNAME	www.taller
