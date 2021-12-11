using HTTP
using Gumbo

url = "https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads"
cache_dir = "cache"
cache_file = "$cache_dir/cache.html"

if isfile(cache_file)
    body = open(f->read(f, String), cache_file)
else
    r = HTTP.request("GET", url)
    if r.status != 200
        return
    end

    body = String(r.body)
    open(cache_file, "w") do io
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

raw_titles = HTMLElement[]
raw_blocks = HTMLElement[]
visitor(b,
        (e) -> tag(e) == :h2 &&
            getattr(e, "class", "") == "" &&
            getattr(e, "id", "") != "webhook-payload-object-common-properties",
        raw_titles)
visitor(b,
        (e) -> tag(e) == :code &&
            getattr(e, "class", "") == "hljs language-json",
        raw_blocks)

function extractor(source::HTMLElement)
    result = ""
    for e in source.children
        if !isa(e, HTMLText)
            result *= extractor(e)
            continue
        end
        result *= e.text
    end
    return result
end

titles = map(extractor, raw_titles)
blocks = map(extractor, raw_blocks)

for (t, b) in zip(titles, blocks)
    open("$cache_dir/$t.json", "w") do io
        write(io, b)
    end
end
