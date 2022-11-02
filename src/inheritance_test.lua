---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by z1178.
--- DateTime: 02/11/2022 16:41
---

--- A base class
Account = { balance = 0 }

-- Lua hide `self` when using *colon operator*, a syntactic sugar
function Account:new(o)
    -- A hidden `self` refers to table `Account`
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Account:deposit(v)
    self.balance = self.balance + v
end

function Account.withdraw(self, v)
    if v > self.balance then
        error "insufficient funds"
    end
    self.balance = self.balance - v
end

-- creates an instance of Account
a = Account:new { balance = 0 }
a:deposit(100.00)   -- syntactic sugar of `a.deposit(a, 100.00)`

--- Inheritance
-- `SpecialAccount` is just an instance of `Account` up to now.
SpecialAccount = Account:new()
s = SpecialAccount:new { limit = 1000.00 }   -- `self` refers to `SpecialAcount`
-- the metatable of `s` is `SpecialAcccount`.
-- `s` is a table and Lua cannot find a `deposit` field in it, so it look
-- into `SpecialAccount`; it cannot find a `deposit` field there, too, so
-- it looks into `Account` and there it finds the original implementation
-- for a `deposit`
s:deposit(100.00)

-- What makes a `SpecialAccount` special is that we can redefine any method
-- inherited from its superclass.
function SpecialAccount:withdraw(v)
    if v - self.balance >= self:getLimit() then
        error "insufficient funds"
    end
    self.balance = self.balance - v
end

function SpecialAccount:getLimit()
    return self.limit or 0
end

-- Lua does not go to `Account`, because it finds the new `withdraw` method
-- in `SpecialAccount` first.
s:withdraw(200.00)