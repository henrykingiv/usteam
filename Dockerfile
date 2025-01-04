FROM prom/prometheus:latest

# # Copy Prometheus configuration into the container
COPY prometheus.yml /etc/prometheus/prometheus.yml

# # Override the default entrypoint (if needed)
# CMD [ "/bin/prometheus", "--config.file=/etc/prometheus/prometheus.yml" ]
