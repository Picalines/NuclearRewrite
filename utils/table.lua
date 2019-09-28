function table.len(self)
    local c = 0
    for i, t in pairs(self) do
        c = c + 1
    end
    return c
end

function table.count(t)
    local c = 0
    for k, v in pairs(t) do
        c = c + 1
    end
    return c
end

function table.copy(t)
    local nt = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            nt[k] = table.copy(v)
        else
            nt[k] = v
        end
    end
    return nt
end

function table.reverse(self)
    local reversered = {}
    for k, v in ipairs(self) do
        reversered[#self + 1 - k] = v
    end
    return reversered
end

function table.random(t, min, max)
    return t[math.random(min or 1, max or #t)]
end

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k, v
        end
    end
    return false
end