
# CDN77 - Deployment virtuální infrastruktury

Cílem tohoto projektu je vytvořit virtuální infrastrukturu, která bude plnit elementární úkony, které se v infrastruktuře CDN77 vyskytují. Deployment infrastruktury i následné testování funkčnosti jednotlivých služeb je plně automatizované.




## Služby

- Monitoring celé infrastruktury přes Grafanu
- Nginx webový sever hostující soubory z lokálního úložiště společně s další Nginx instancí, která slouží jako cachovací reverzní proxy
- Zookeeper + Kafka distribuovaný systém, který odolává výpadku 2 instancí
- Custom monitorovací skripty pro monitoring load average všech containerů a sbírání metrik z Nginx instancí. Běh monitorovacích skriptů je managovaný přes Deamontools. 

## Struktura projektu

    cdn77_infra # root složka
    |-- ansible # složka obsahující ansible playbooky + templaty
    |   |-- deploy_all.yml
    |   |-- deploy_daemontools.yml
    |   |-- deploy_kafka_compose.yml
    |   |-- deploy_monitoring_compose.yml
    |   |-- deploy_nginx_compose.yml
    |   |-- deploy_zookeeper_compose.yml
    |   |-- install_daemontools.yml
    |   |-- install_docker.yml
    |   |-- stop_all.yml
    |   |-- stop_kafka_compose.yml
    |   |-- stop_monitoring_compose.yml
    |   |-- stop_nginx_compose.yml
    |   |-- stop_zookeeper_compose.yml
    |   |-- templates # složka s jinja templaty
    |   |   `-- nginx_proxy_server_conf.j2 # jinja template pro konfiguraci web server nginx instance
    |   |-- test_daemontools.yml
    |   |-- test_kafka.yml
    |   |-- test_nginx.yml
    |   `-- test_zookeeper.yml
    |-- daemontools # složka obsahující konfiguraci deamontools + potřebné skripty pro běh custom monitorovacích skriptů
    |   |-- init.d
    |   |   `-- svscanboot # init soubor pro svscanboot službu
    |   |-- scripts # složka se skripty pro monitoring load average + nginx instancí
    |   |   |-- monitor_load_average.sh
    |   |   `-- monitor_nginx_stub_status.sh
    |   `-- service # složka s run scripty, které se následně kopírují do /service/<service_name>/
    |       |-- load_average_monitoring
    |       |   |-- log
    |       |   |   `-- run
    |       |   `-- run
    |       `-- nginx_stub_status_monitoring
    |           |-- log
    |           |   `-- run
    |           `-- run
    |-- docker # složka obsahující dockerfiles a docker compose konfigurace
    |   |-- docker_compose # složka obsahující docker compose pro jednotlivé služby
    |   |   |-- kafka
    |   |   |   `-- kafka-docker-compose.yml
    |   |   |-- monitoring
    |   |   |   `-- monitoring-docker-compose.yml
    |   |   |-- nginx
    |   |   |   `-- nginx-docker-compose.yml
    |   |   `-- zookeeper
    |   |       `-- zookeeper-docker-compose.yml
    |   `-- dockerfiles # složka obsahující dockerfiles pro jednotlivé služby
    |       |-- kafka
    |       |   `-- Dockerfile
    |       |-- nginx
    |       |   `-- Dockerfile
    |       `-- zookeeper
    |           `-- Dockerfile
    |-- grafana # složka obsahující konfigurační soubory, které se používají při deploymentu grafany
    |   |-- dashboard.json # json soubor uchovávající setup dashboardu, který se při deploymentu grafany automaticky importuje
    |   |-- dashboard.yml # konfigurační soubor pro definici dashboardu
    |   `-- datasource.yml # konfigurační soubor pro definici datasource
    |-- kafka # složka obsahující soubory ke konfiguraci jednotlivých kafka instancí
    |   |-- server1.properties
    |   |-- server2.properties
    |   |-- server3.properties
    |   `-- server4.properties
    |-- nginx # složka obsahující soubory ke konfiguraci nginx instancí
    |   |-- proxy_server.conf # konfigurační soubor sloužící jako nginx.conf na proxy server instanci
    |   |-- proxy_server_nginx.conf # conf.d konfigurační soubor pro proxy server, který je v includu 
    |   |-- web_server.conf  # konfigurační soubor sloužící jako nginx.conf na web server instanci
    |   `-- web_server_nginx.conf # conf.d konfigurační soubor pro web server, který je v includu 
    |-- prometheus # složka s konfigurací pro deployment služby prometheus
    |   `-- prometheus.yml # soubor obsahující jednotlivé targety, které prometheus využívá
    `-- zookeeper # složka obsahující soubory k deploymentu služby zookeeper
        |-- myid1
        |-- myid2
        |-- myid3
        |-- myid4
        |-- myid5
        `-- zoo.cfg # konfigurační soubor zookeeperu, který obsahuje seznam všech zk instancí
## Deployment infrastruktury
## Instalace Ansiblu

Aby bylo možné provést automatický deploy celé infrastruktury, tak je v první řadě nutné nainstalovat Ansible. Pro instalaci Ansiblu spusťe následující commandy. 

```bash
  apt-get update
```
```bash
  apt-get install ansible
```

## Instalace Dockeru

Celá infrastruktura je navržená tak, aby běžela v Dockeru. Pro automatickou instalaci Dockeru byl vytvořen Ansible playbook install_docker.yml

```bash
  ansible-playbook install_docker.yml
```
## Instalace Deamontools

Infrastruktura používá Deamontools pro management custom monitorovacích skriptů. Pro automatickou instalaci byl vytvořen Ansible playbook install_deamontools.yml

```bash
  ansible-playbook install_daemontools.yml
```
## Deployment jednotlivých služeb
Všechny služby lze spouštět jednotlivě, nebo lze všechny služby spustit zároveň. V případě, že chceme spustit všechny služby najednou, tak spustíme následující command.
```bash
  ansible-playbook deploy_all.yml
```
V případě, že bychom chtěli deployment jednotlivých služeb rozdělit, tak služby budeme spouštět v následujícím pořadí.
```bash
  ansible-playbook deploy_monitoring_compose.yml
```
```bash
  ansible-playbook deploy_nginx_compose.yml
```
```bash
  ansible-playbook deploy_zookeeper_compose.yml
```
```bash
  ansible-playbook deploy_kafka_compose.yml
```
```bash
  ansible-playbook deploy_daemontools.yml
```
Jestli všechny containery běží můžeme následně zkontrolovat commandem:
```bash
  docker ps
```
Dohromady bychom měli vidět tyto containery:
- prometheus
- cadvisor
- grafana
- nginx_proxy_server
- nginx_web_server
- zookeeper1
- zookeeper2
- zookeeper3
- zookeeper4
- zookeeper5
- kafka1
- kafka2
- kafka3
- kafka4

## Monitoring
Stav všech containerů lze sledovat přes Grafanu, která má v rámci deploymentu importovaný datasource + dashborad. Grafana pro sběr metrik používá Prometheus, který využívá exporter Cadvisor.

Port Grafany je přesměrovaný na 9100. Tudíž lze ke Grafaně přistupovat například přes localhost:9100

Port Prometheuse je 9090 a i kněmu lze přistupovat přes localhost:9090

Metriky z containerů lze získat i přímo ze serveru, kde běží Docker a commandem:

```bash
 curl -X GET http://host.docker.internal:8082/metrics -H "Accept: application/json"
```
## Test funkčnosti jednotlivých služeb
Pro ověření funkčnosti jednotlivých služeb byly vytvořeny playbooky s prefixem test_. Tyto playbooky mají za úkol provést základní operace, která by měla každá služba provádět.
### Nginx
Služba Nginx obsahuje 2 instance. Jedna instance je webový server, který hostuje soubory z lokálního úložiště a druhá instance je cachovací reverzní proxy server, který využívá první instanci jako loadbalancer. 

Spuštění testu obou instancí se provede tímto commandem:
```bash
 ansible-playbook test_nginx.yml
```
Test se skládá z těchto částí:
- Pošle se GET request na <web_server_ip>/data/ a zobrazí se obsah.
- Z web serveru se stáhne soubor /data/nginx/error.log
- Zobrazí se obsah host.access.log souboru, který je na webovém serveru, abychom si mohli ověřit, že jsme úspěšně soubor stáhli.
- Soubor /data/nginx/error.log se stáhne znovu, ale přes reverzní proxy server
- Zobrazí se obsah /data/nginx/cache složky na instanci reverzní proxy, která uchovává dříve stažené soubory v cache.
- Provede se GET request, včetně zobrazení hlavičky na <proxy_server_ip>/data/nginx/error.log, abychom přes parametr X-Proxy-Cache ověřili, že je soubor v cache. Pokud je parametr X-Proxy-Cache roven HIT, tak je soubor v cache.
### Zookeeper
Služba Zookeeper se skládá z 5 instancí, aby odolávala výpadku 2 instancí. Zookeeper pro zvolení leader instance potřebuje mít quorum ( lichý počet serverů s minimálním počtem 3 instancí ).

Spuštění testu se provede tímto commandem:
```bash
 ansible-playbook test_zookeeper.yml
```
Test se skládá z těchto částí:
- Zobrazí se status všech instancí, aby bylo možné detekovat, jestli je jedna instance leader.
- Provede se simulace failu 2 instancí.
- Zobrazí se aktuálně běžící Zookeeper containery.
- Zobrazí se status všech běžících instancí, abychom si ověřili, že se zvolil nový leader.
- Na jedné z instancí se vytvoří znode s názvem zk_test.
- Na jiné instanci se pomocí Zookeeper konzole zobrazí všechny existující znody. Tím si ověříme, že se nově vytvořená znode replikuje i na další instance.
- Instance, které byly v rámci testování vypnuty jsou uvedeny zpět do provozu. 

Pokud bude chtít uživatel provést manuální test pomocí Zookeeper konzole na kterékoliv Zookeeper instanci, tak může použít následující command:
```bash
 docker exec <zk_container_name> /opt/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181 <zk_cli_command>
```
### Kafka
Služba Kafka se skládá ze 4 instancí. 2 instance slouží jako producer a 2 jako consumer. 4 instance má Kafka pro to, aby při výpadku 2 Kafka instancí bylo možné Kafku stále používat.

Spuštění testu se provede tímto commandem:
```bash
 ansible-playbook test_kafka.yml
```
Test se skládá z těchto částí:
- Vytvoří se topic s názvem quickstart-events.
- Přes Zookeeper konzoli se zobrazí všechny znody, aby bylo možné ověřit, že Kafka využívá Zookeeper, který jsme si nakonfigurovali. Mezi znody bychom měli vidět například znode brokers, nebo consumers.
- Ze 2 producerů se pošlou messages do vytvořeného topicu. 
- Ze 2 consumerů se z topicu přečtou messages, které produceři odeslali. 

V případě manuálního testování lze použít tyto commandy:

- Vytvoření topicu
```bash
 docker exec <kafka_container_name> /opt/kafka/bin/kafka-topics.sh --create --topic <topic_name> --bootstrap-server localhost:9092
```
- Odeslání message do topicu
```bash
 docker exec <kafka_container_name> sh -c "echo '<message>' | /opt/kafka/bin/kafka-console-producer.sh --topic <topic_name> --bootstrap-server localhost:9092"
```
- Čtení messages z topicu
```bash
 docker exec <kafka_container_name> /opt/kafka/bin/kafka-console-consumer.sh --topic <topic_name> --from-beginning --bootstrap-server localhost:9092
```
### Daemontools
Služba Daemontools drží při běhu 2 custom scripty, které běží periodicky každých 15 sekund pro monitoring load average všech docker containerů a monitoring zatížení Nginx instancí, pomocí dotazování na location, kde je nastavený modul stub_status. 

Spuštění testu, jestli custom skripty logují provedeme commandem:
```bash
 ansible-playbook test_daemontools.yml
```
Test se skládá z těchto částí:
- Z logu skriptu pro získávání load average všech Docker containerů se získá posledních 15 řádků, které se následně zobrazí jako output. 
- Z logu skriptu pro monitoring Nginx instancí se získá posledních 15 řádků, které se následně zobrazí jako output. 

V případě manuálního testování lze použít tyto commandy:

Simulace zatížení Nginx serveru posíláním X requestů z Y connections. Argument -n určuje počet requestů a argument -c určuje počet aktivních connections. (Pokud chcete sledovat log pro zatížení Nginx serverů v reálném čase, tak tyto commandy spusťte v novém terminálu.)

```bash
 apt-get install apache2-utils
 ab -n 100000 -c 100 <nginx_instance_ip>/basic_status
```

IP adresa Docker containeru lze získat commandem:

```bash
 docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <docker_instance>
```

Sledování logu pro monitoring zatížení obou Nginx instancí:

```bash
 tail -f /service/nginx_stub_status_monitoring/log/main/current
```

Sledování logu pro monitoring load average všech Docker containerů:


```bash
 tail -f /service/load_average_monitoring/log/main/current
```

## Vypnutí jednotlivých služeb
Všechny služby lze vypnout jednotlivě, nebo lze všechny služby vypnout zároveň. V případě, že chceme vypnout všechny služby najednou, tak spustíme následující command.
```bash
  ansible-playbook stop_all.yml
```
V případě, že bychom chtěli vypnutí jednotlivých služeb rozdělit, tak služby budeme vypínat v následujícím pořadí.
```bash
  ansible-playbook stop_kafka_compose.yml
```
```bash
  ansible-playbook stop_zookeeper_compose.yml
```
```bash
  ansible-playbook stop_nginx_compose.yml
```
```bash
  ansible-playbook stop_monitoring_compose.yml
```




## Dodatečné informace

V tomto virtuálním prostředí bohužel není funkční automatické zapnutí služeb po rebootu systému, kvůli issues s konfigurací /etc/init.d. Doufám, že fix přijde v dalším releasu :)

### Kroky, které je nutné podniknout po rebootu

Manuální spuštění služby Docker:

```bash
  service docker start
```

Manuální spuštění Daemontools:

```bash
  csh -cf '/command/svscanboot &'
```

## Feedback

V případě jakýchkoliv připomínek, nebo dotazů neváhejte napsat na david.maletinsky@post.cz


