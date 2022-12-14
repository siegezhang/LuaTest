---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by z1178.
--- DateTime: 03/11/2022 14:56
---
---http://lua-users.org/wiki/DecoratorsAndDocstrings
--Pattern: Decorators, Annotators and Docstrings
--At times we want to associate some metadata with an object, such as the documentation or type information on the object. It may be possible to store this in a field inside the object, thereby modifying the implementation of the object, but that may be something to avoid, especially if the object belongs to someone else (information hiding). In fact, it might not be possible to modify the object if the object is a function or a read-only table.
--
--One solution is basically to create a global table that maps objects (as keys) to their annotations (as values). By definition, objects have unique identities and therefore can serve as unique keys in a table. In this way, the objects themselves are not modified. This interferes a bit with garbage collection since the global table holds references to the objects, but we can use a "weak table" in Lua for this purpose (see the book Programming in Lua in LuaBooks).
--
--Here's a way to apply docstrings [1] to Lua objects.
--弱引用table有3种类型
--1、具有弱引用key的table；
--2、具有弱引用value的table；
--3、同时具有弱引用key和value的table；
--
--table的弱引用类型是通过其元表中的__mode字段来决定的。
--这个字段的值应为一个字符串：
--如果包含’k’，那么这个table的key是弱引用的；
--如果包含’v’，那么这个table的value是弱引用的；

local docstrings = setmetatable({}, { __mode = "kv" })

function document(str)
    return function(obj)
        docstrings[obj] = str;
        return obj
    end
end

function help(obj)
    print(docstrings[obj])
end

document [[Print the documentation for a given object]](help)
document [[Add a string as documentation for an object]](document)

f = document [[Print a hello message]](
        function()
            print("hello")
        end
)
f()
help(f)

--Note: garbage collection can fail if the annotation is an object that refers back to the object it annotates (see GarbageCollectingWeakTables).
--
--A somewhat similar pattern is applied in Perl "inside out objects".
--
--This pattern can be applied to other situations in which you wish to apply metadata to objects without making any change to those objects. These include function decorators as used in Python [2] [3].
--
--The following alternative syntax for applying function decorators to functions could be preferable:
function typecheck(...)
    return setmetatable({ ... }, mt)
end

function docstring(...)
    return setmetatable({ ... }, mt)
end
mt = { __concat = function(a, f)
    return function(...)
        print("decorator", table.concat(a, ","), ...)
        return f(...)
    end
end
}
random = docstring [[Compute random number.]] ..
        typecheck("number", '->', "number") ..
        function(n)
            return math.random(n)
        end
--The function decorators can be implemented basically in this way:

random(12)


--The use of an operator (..) here between the function decorator and the function avoids the parenthesis around the function and makes chaining decorators nicer. We want this operator to have right associativity, so the only choices for this operator are .. and ^.
--
--See also LuaTypeChecking for specific use of decorators for expressing function parameter and return types.