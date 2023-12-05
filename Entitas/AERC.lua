require("Core/Class")
require("Entitas/EntitasSetting")

local AERC = Class("AERC")

function AERC:Ctor(entity)
    self.m_Entity = entity

    self.m_RetainCount = 0

    self.m_Owners = {}
end

function AERC:GetCount()
    return self.m_RetainCount
end

function AERC:Retain(owner)
    if EntitasSetting.ENTITAS_FAST_AND_UNSAFE then
        local has = self.m_Owners[owner]
        
        if has then
            --TODO: Exception exist owner
        else
        
            self.m_Owners[owner] = true
            self.m_RetainCount = self.m_RetainCount + 1
        end
    else
        self.m_RetainCount = self.m_RetainCount + 1
    end
end

function AERC:Release(owner)
    if EntitasSetting.ENTITAS_FAST_AND_UNSAFE then
        local has = self.m_Owners[owner]

        if has then
            self.m_Owners[owner] = false
            self.m_RetainCount = self.m_RetainCount - 1
        else
            --TODO: Exception not exist owner
        end
    else
        self.m_RetainCount = self.m_RetainCount - 1
    end
end

return AERC