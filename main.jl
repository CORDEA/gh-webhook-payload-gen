using HTTP
using Gumbo

url = "https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads"

r = HTTP.request("GET", url)
if r.status != 200
    return
end
