local all_categories = (function()
    local categories = {}
    for i = 1,16 do
        table.insert(categories, i)
    end
    return categories
end)()

-- based on objects in /obj dir
-- in the form of ObjName = {{...categories}, {...masks}}
return {
    Default = {{1}, {}},
    Ghost = {{16}, all_categories},
}