using HTTP
using Gumbo

url = "https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads"
cache_file = "cache.html"

if isfile(cache_file)
    body = open(f->read(f, String), cache_file)
else
    r = HTTP.request("GET", url)
    if r.status != 200
        return
    end

    body = String(r.body)
    open("cache.html", "w") do io
        write(io, body)
    end
end
