# Functions supporting trendline identification (support/resistance, zigzag, elliot waves, etc.)

function maxima{Float64}(x::Vector{Float64}; threshold::Float64=0.0, order::Int=1)
    @assert threshold >= 0.0 "Threshold must be positive."
    @assert order > 0 "Order must be a positive integer."
    n = size(x,1)
    crit = falses(n)
    @inbounds for i=2:n-1
        if (x[i]-x[i-1] >= threshold) && (x[i]-x[i+1] >= threshold)
            crit[i] = true
        end
    end
    while order > 1
        idx = find(crit)
        crit[idx[!maxima(x[crit], threshold=threshold)]] = false
        order -= 1
    end
    return crit
end

function minima{Float64}(x::Vector{Float64}; threshold::Float64=0.0, order::Int=1)
    @assert threshold <= 0.0 "Threshold must be negative."
    @assert order > 0 "Order must be a positive integer."
    n = size(x,1)
    crit = falses(n)
    @inbounds for i=2:n-1
        if (x[i]-x[i-1] <= threshold) && (x[i]-x[i+1] <= threshold)
            crit[i] = true
        end
    end
    while order > 1
        idx = find(crit)
        crit[idx[!minima(x[crit], threshold=threshold)]] = false
        order -= 1
    end
    return crit
end

function interpolate(x1::Int, x2::Int, y1::Float64, y2::Float64)
	m = (y2-y1)/(x2-x1)
	b = y1 - m*x1
	x = collect(x1:1.0:x2)
	y = m*x + b
	return y
end

function resistance{Float64}(x::Vector{Float64}; order::Int=1, threshold::Float64=0.0)
    out = zeros(x)
    crit = maxima(x, threshold=threshold, order=order)
    out[.!crit] = NaN
    idx = find(crit)
    @inbounds for i=2:length(idx)
        out[idx[i-1]:idx[i]] = interpolate(idx[i-1], idx[i], x[i-1], x[i])
    end
    return out
end

function support{Float64}(x::Vector{Float64}; order::Int=1, threshold::Float64=0.0)
    out = zeros(x)
    crit = minima(x, threshold=threshold, order=order)
    out[.!crit] = NaN
    idx = find(crit)
    @inbounds for i=2:length(idx)
        out[idx[i-1]:idx[i]] = interpolate(idx[i-1], idx[i], x[i-1], x[i])
    end
    return out
end
