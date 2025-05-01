# ram.jl

"""
  get_rss_mb()

Return the current resident set size (VmRSS) of this process in MB.
"""
function get_rss_mb()
    for line in eachline("/proc/self/status")
        if startswith(line, "VmRSS:")
            # line looks like "VmRSS:   123456 kB"
            kb = parse(Int, split(strip(line))[2])
            return kb/1024
        end
    end
    error("VmRSS not found in /proc/self/status")
end

"""
  @ram expr

Run `expr`, then print how much RSS increased and what the RSS is now.
"""
macro ram(expr)
    quote
        before = get_rss_mb()
        result = $(esc(expr))
        after = get_rss_mb()
        println("ΔRSS = ", round(after-before, digits=2), " MB  |  current RSS = ", round(after, digits=2), " MB")
        result
    end
end
