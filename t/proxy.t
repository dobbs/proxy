#!/bin/bash
set -euo pipefail
IFS=$'\t\n\r'

main() {
    setup
    test_default_config_with_top_domain
    test_default_config_with_subdomain
    setup_extra
    test_override_config_with_top_domain
    test_override_config_with_subdomain
    teardown
}

setup() {
    readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $DIR
    docker volume rm t_proxy.d &>/dev/null || true
    docker-compose up -d proxy web 2>/dev/null
    trap teardown SIGTERM
    printf "1..%d\n" 8
}

setup_extra() {
    docker cp subdomain.localtest.me.caddyfile \
           $(docker-compose ps -q proxy):/etc/proxy.d/
    docker-compose up -d subdomain 2>/dev/null
    docker-compose restart proxy 2>/dev/null
}

teardown() {
    docker-compose stop &>/dev/null
    docker-compose rm -f &>/dev/null
    docker volume rm t_proxy.d &>/dev/null
}

test_default_config_with_top_domain() {
    local response="$(request localtest.me)"
    assert_200_OK "$response" 'default config localtest.me'
    assert_content "$response" '<h1>Caddy web server.</h1>' 'Caddy default page'
}

test_default_config_with_subdomain() {
    local response="$(request subdomain.localtest.me)"
    assert_200_OK "$response" 'default config subdomain.localtest.me'
    assert_content "$response" '<h1>Caddy web server.</h1>' 'Caddy default page'
}

test_override_config_with_top_domain() {
    local response="$(request localtest.me)"
    assert_200_OK "$response" 'override config localtest.me'
    assert_content "$response" '<h1>Caddy web server.</h1>' 'Caddy default page'
}

test_override_config_with_subdomain() {
    local response="$(request subdomain.localtest.me)"
    assert_200_OK "$response" 'override config subdomain.localtest.me'
    assert_content "$response" '<h3>subdomain.localtest.me</h3>' 'overriden page'
}

# private

request() {
    local host="${1:-MISSING}"
    curl \
        --insecure \
        --include \
        --silent \
        --show-error \
        --resolve "$host:8000:127.0.0.1" \
        https://$host:8000
}

assert_200_OK() {
    local response="${1:-MISSING}"
    local message="${2:-}"
    if egrep -q '^HTTP/1.1 200 OK' <<<"$response"; then
        printf "ok - %s\n" "$message"
    else
        printf "not ok - %s\n" "$message"
    fi
}

assert_content() {
    local response="${1:-MISSING_RESPONSE}"
    local regexp="${2:-MISSING_PATTERN}"
    local message="${3:-}"
    if egrep -q "$regexp" <<<"$response"; then
        printf "ok - %s\n" "$message"
    else
        printf "not ok - %s\n" "$message"
    fi
}

main
