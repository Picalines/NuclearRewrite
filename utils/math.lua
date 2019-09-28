function math.clamp(min, val, max)
    return math.max(min, math.min(val, max))
end

function math.percent(a, perc)
    return (a * perc) / 100
end

function math.digitsCount(n)
    local c = 0
    n = math.abs(n)
    while n > 0 do
        n = math.floor(n / 10)
        c = c + 1
    end
    return c
end

function math.sign(n)
    return n > 0 and 1 or n < 0 and -1 or 1
end

function math.randomFloat(min, max)
    return min + math.random()  * (max - min);
end

function math.inrange(v, min, max)
    return v >= min and v <= max
end

function math.inrange2d(x, y, sx, sy, w, h)
    return math.inrange(x, sx, sx+w) and math.inrange(y, sy, sy+h)
end