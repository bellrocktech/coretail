# coretail
CoreDNS with Tailscale

## Use Cases

We've found this to be useful in a handful of scenarios:

  - CNAME resolution for Tailscale MagicDNS names where e.g. `foo.example.com` 
    is a CNAME for `foo.example.com.beta.tailscale.net`
  - Networks where it's not appropriate for Tailscale nodes to have MagicDNS enabled
  - Certain software that doesn't work well with modern DNS (GitHub action Runners/Node.js)

## CoreDNS

Note that the Dockerfile builds all the default plugins, plus the additional 
"alternate" plugin. You may wish to reduce that surface with your own plugin.cfg

The default (and only) Corefile stanza baked into the image queries Cloudflare's DNS
service @ 1.1.1.1 - to override this simply mount your own Corefile to `/Corefile`

## Tailscale

You will need to pass a Tailscale auth key using the env var `TS_AUTH_KEY`. The
Tailscale hostname may also be set with the `HOSTNAME` env var.

## Compose

An example compose file is included in the repository at example/docker-compose.yml
