module Carbon

export mass

function mass(element::String)
    if element == "C"
        return 12.01
    elseif element == "H"
        return 1.008
    else    
        return 0.0
    end
end

end