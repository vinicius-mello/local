queue = {}

function queue.new ()
    local t={first = 0, last = -1}
    setmetatable(t,queue)
    return t
end

function queue.pushleft (q, value)
    local first = q.first - 1
    q.first = first
    q[first] = value
    return value
end


function queue.pushright (q, value)
    local last = q.last + 1
    q.last = last
    q[last] = value
    return value
end

function queue.empty (q)
    if q.first > q.last then return true end
    return false
end

function queue.popleft (q)
    local first = q.first
    if first > q.last then error("queue is empty") end
    local value = q[first]
    q[first] = nil        -- to allow garbage collection
    q.first = first + 1
    return value
end

function queue.popright (q)
    local last = q.last
    if q.first > last then error("queue is empty") end
    local value = q[last]
    q[last] = nil         -- to allow garbage collection
    q.last = last - 1
    return value
end

function queue.left (q)
    local first = q.first
    if first > q.last then error("queue is empty") end
    local value = q[first]
    return value
end

function queue.right (q)
    local last = q.last
    if q.first > last then error("queue is empty") end
    local value = q[last]
    return value
end


function queue.size (q)
    return q.last-q.first+1
end

queue.__index=queue

return queue
