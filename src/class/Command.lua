Command = {}
Command.__index = Command

function Command.new(Name, Description, Type, Function)
    if tostring(type(Type)) == 'function' and Function == nil then
        Function = Type
        Type = "Other"
    end
    return setmetatable({
        name = Name,
        desc = Description,
        type = Type,
        func = Function
    }, Command)
end

return Command
