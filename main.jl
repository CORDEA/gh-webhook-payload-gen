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

html = parsehtml(body).root
b = first(filter(e -> tag(e) == :body, html.children))

function visitor(source::HTMLElement, predicate::Function, ans::Vector{HTMLElement})
    for e in source.children
        if !isa(e, HTMLElement)
            continue
        end
        if predicate(e)
            push!(ans, e)
        end
        visitor(e, predicate, ans)
    end
end

blocks = HTMLElement[]
visitor(b, (e) -> getattr(e, "class", "") == "hljs language-json" && tag(e) == :code, blocks)
