services:
  traefik:
    image: traefik:v3.7.11
    command:
      # Docker Swarm configuration
      - --providers.swarm=true
      - --providers.swarm.watch=true
      - --providers.swarm.exposedByDefault=false
      - --providers.swarm.network=traefik-public

      # Entrypoints
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443

      # HTTP to HTTPS redirect
      - --entrypoints.web.http.redirections.entrypoint.to=websecure
      - --entrypoints.web.http.redirections.entrypoint.scheme=https

      # Let's Encrypt configuration
      - --certificatesresolvers.letsencrypt.acme.email=${lets_encrypt_email}
      - --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.letsencrypt.acme.tlschallenge=true
%{ if environment != "prod" }
      - --certificatesresolvers.letsencrypt.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory
%{ endif }

      # Dashboard
      - --api.dashboard=true

      # Logging
      - --log.level=INFO
      - --accesslog=true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-certificates:/letsencrypt
    networks:
      - traefik-public
    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        # Dashboard
        - "traefik.enable=true"
        - "traefik.http.routers.traefik.rule=Host(`traefik.${domain}`)"
        - "traefik.http.routers.traefik.entrypoints=websecure"
        - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
        - "traefik.http.routers.traefik.service=api@internal"

        # Middleware de autenticação básica
        - "traefik.http.middlewares.traefik-auth.basicauth.users=${traefik_user}"
        - "traefik.http.routers.traefik.middlewares=traefik-auth"

        # Service (necessário para Swarm)
        - "traefik.http.services.traefik.loadbalancer.server.port=8080"
      restart_policy:
        # condition: any reinicia tambem em saida limpa (exit 0). Com on-failure
        # + max_attempts o servico ficava 0/1 permanentemente apos o Swarm desistir.
        condition: any
        delay: 5s
        window: 120s

  agent:
    image: portainer/agent:2.39.6
    environment:
      AGENT_CLUSTER_ADDR: tasks.agent
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - portainer-agent
    deploy:
      mode: global
      placement:
        constraints:
          - node.platform.os == linux
    depends_on:
      - traefik

  portainer:
    image: portainer/portainer-ce:2.39.6
    command: -H tcp://tasks.agent:9001 --tlsskipverify
    volumes:
      - portainer-data:/data
    networks:
      - portainer-agent
      - traefik-public
    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.portainer.rule=Host(`portainer.${domain}`)"
        - "traefik.http.routers.portainer.entrypoints=websecure"
        - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
        - "traefik.http.services.portainer.loadbalancer.server.port=9000"
      update_config:
        # O BoltDB do Portainer nao aceita duas instancias abertas no mesmo
        # volume: a nova morre com "failed opening store: timeout". stop-first
        # garante que a antiga encerre antes de a nova subir.
        order: stop-first
        failure_action: rollback
      restart_policy:
        # condition: any reinicia tambem em saida limpa (exit 0). Com on-failure
        # + max_attempts o servico ficava 0/1 permanentemente apos o Swarm desistir.
        condition: any
        delay: 5s
        window: 120s
    depends_on:
      - traefik

volumes:
  traefik-certificates:
  portainer-data:

networks:
  traefik-public:
    external: true
  portainer-agent:
    external: true
