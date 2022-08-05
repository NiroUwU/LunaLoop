Command = {}
Command.__index = Command

function Command:new(Name, Aliases, Description, Type, Function)
    if tostring(type(Type)) == 'function' and Function == nil then
        Function = Type
        Type = "Other"
    end
    return setmetatable({
        name = Name,
        aliases = Aliases,
        desc = Description,
        type = Type,
        func = Function
    }, Command)
end

return Command
