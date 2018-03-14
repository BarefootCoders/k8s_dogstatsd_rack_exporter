require 'datadog/statsd'
require 'time'

module Rack
  class DogstatsdExporter
    REQUEST_TIME_METRIC_NAME  = "http_request_time".freeze
    REQUEST_COUNT_METRIC_NAME = "http_request_count".freeze

    def initialize(app, options={})
      @app = app
      @statsd_host = options[:statsd_host] || "localhost"
      @statsd_port = Integer(options[:statsd_port]) || 8125
    end

    def call(env)
      start_time = Time.now

      status, headers, body = @app.call(env)

      end_time = Time.now
      elapsed_time = end_time - start_time

      metric_tags = [
        "code:#{status}",
        "instance:#{pod_ip}",
        "job:#{container_name}",
        "pod:#{pod_name}",
        "namespace:#{namespace}",
      ]

      statsd_client.batch do |batch|
        batch.histogram(
          REQUEST_TIME_METRIC_NAME,
          elapsed_time,
          tags: metric_tags,
        )
        batch.increment(
          REQUEST_COUNT_METRIC_NAME,
          tags: metric_tags,
        )
      end

      [status, headers, body]
    end

    private

    def statsd_client
      @statsd_client ||= Datadog::Statsd.new(
        @statsd_host,
        @statsd_port,
      )
    end

    def container_name
      ENV.fetch("K8S_CONTAINER_NAME", nil)
    end

    def namespace
      ENV.fetch("K8S_NAMESPACE", nil)
    end

    def node_name
      ENV.fetch("K8S_NODE_NAME", nil)
    end

    def pod_ip
      ENV.fetch("K8S_POD_IP", nil)
    end

    def pod_name
      ENV.fetch("K8S_POD_NAME", nil)
    end
  end
end

