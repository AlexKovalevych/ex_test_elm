defmodule Gt.Manager.Location do
    def create_location(conn) do
        scheme = conn.scheme
        host = conn.host
        port = conn.port
        query_string = create_query_string(conn.query_string)
        origin = create_origin(scheme, host, port)
        request_path = conn.request_path
        %{
            port_: port,
            host: create_host(host, port),
            hostname: host,
            pathname: request_path,
            origin: origin,
            search: query_string,
            hash: "",
            href: create_href(origin, request_path, query_string),
            protocol: scheme
        }
    end

    defp create_query_string(query_string) do
        case query_string do
            "" -> ""
            _ -> "?#{query_string}"
        end
    end

    defp create_href(origin, request_path, search) do
        "#{origin}#{request_path}#{search}"
    end

    defp create_host(host, port) do
        case port do
            80 -> host
            _ -> "#{host}:#{port}"
        end
    end

    defp create_origin(scheme, domain, port) do
        "#{scheme}://#{create_host(domain, port)}"
    end
end
