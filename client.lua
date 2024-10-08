
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(camCoords.x, camCoords.y, camCoords.z, x, y, z, 1)

    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- desebgar linhas
function Draw3DLine(x1, y1, z1, x2, y2, z2, r, g, b, a)
    DrawLine(x1, y1, z1, x2, y2, z2, r, g, b, a)
end

-- desenhar uma caixa ao redor do ped
function Draw3DBox(pedCoords, width, height, depth, r, g, b, a)
    local halfWidth = width / 2
    local halfHeight = height / 2
    local halfDepth = depth / 2

    -- desenhar cubos
    local frontTopLeft = vector3(pedCoords.x - halfWidth, pedCoords.y - halfDepth, pedCoords.z + halfHeight)
    local frontTopRight = vector3(pedCoords.x + halfWidth, pedCoords.y - halfDepth, pedCoords.z + halfHeight)
    local frontBottomLeft = vector3(pedCoords.x - halfWidth, pedCoords.y - halfDepth, pedCoords.z - halfHeight)
    local frontBottomRight = vector3(pedCoords.x + halfWidth, pedCoords.y - halfDepth, pedCoords.z - halfHeight)

    local backTopLeft = vector3(pedCoords.x - halfWidth, pedCoords.y + halfDepth, pedCoords.z + halfHeight)
    local backTopRight = vector3(pedCoords.x + halfWidth, pedCoords.y + halfDepth, pedCoords.z + halfHeight)
    local backBottomLeft = vector3(pedCoords.x - halfWidth, pedCoords.y + halfDepth, pedCoords.z - halfHeight)
    local backBottomRight = vector3(pedCoords.x + halfWidth, pedCoords.y + halfDepth, pedCoords.z - halfHeight)

    -- linha da frente
    Draw3DLine(frontTopLeft.x, frontTopLeft.y, frontTopLeft.z, frontTopRight.x, frontTopRight.y, frontTopRight.z, r, g, b, a)
    Draw3DLine(frontTopRight.x, frontTopRight.y, frontTopRight.z, frontBottomRight.x, frontBottomRight.y, frontBottomRight.z, r, g, b, a)
    Draw3DLine(frontBottomRight.x, frontBottomRight.y, frontBottomRight.z, frontBottomLeft.x, frontBottomLeft.y, frontBottomLeft.z, r, g, b, a)
    Draw3DLine(frontBottomLeft.x, frontBottomLeft.y, frontBottomLeft.z, frontTopLeft.x, frontTopLeft.y, frontTopLeft.z, r, g, b, a)

    -- linhas de trás
    Draw3DLine(backTopLeft.x, backTopLeft.y, backTopLeft.z, backTopRight.x, backTopRight.y, backTopRight.z, r, g, b, a)
    Draw3DLine(backTopRight.x, backTopRight.y, backTopRight.z, backBottomRight.x, backBottomRight.y, backBottomRight.z, r, g, b, a)
    Draw3DLine(backBottomRight.x, backBottomRight.y, backBottomRight.z, backBottomLeft.x, backBottomLeft.y, backBottomLeft.z, r, g, b, a)
    Draw3DLine(backBottomLeft.x, backBottomLeft.y, backBottomLeft.z, backTopLeft.x, backTopLeft.y, backTopLeft.z, r, g, b, a)

    -- Desenhar as linhas de conexão
    Draw3DLine(frontTopLeft.x, frontTopLeft.y, frontTopLeft.z, backTopLeft.x, backTopLeft.y, backTopLeft.z, r, g, b, a)
    Draw3DLine(frontTopRight.x, frontTopRight.y, frontTopRight.z, backTopRight.x, backTopRight.y, backTopRight.z, r, g, b, a)
    Draw3DLine(frontBottomLeft.x, frontBottomLeft.y, frontBottomLeft.z, backBottomLeft.x, backBottomLeft.y, backBottomLeft.z, r, g, b, a)
    Draw3DLine(frontBottomRight.x, frontBottomRight.y, frontBottomRight.z, backBottomRight.x, backBottomRight.y, backBottomRight.z, r, g, b, a)
end

-- Verificaçao 
function IsHuman(ped)
    return not IsPedAPlayer(ped) and IsPedHuman(ped)
end



-- Loop principal
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- buscar peds
        for ped in EnumeratePeds() do
            if DoesEntityExist(ped) and IsHuman(ped) then -- verificaçao para nao grudar em animais
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)

                -- box
                Draw3DBox(pedCoords, 0.5, 1.5, 0.5, 255, 0, 0, 150)

                -- distancia 
                DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.5, string.format("%.2f m", distance))

                --desenhar linha
                Draw3DLine(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z, 255, 0, 0, 150)
            end
        end

        
        
    end
end)

-- busca completa npcs
function EnumeratePeds()
    return coroutine.wrap(function()
        local pedIndex, ped = FindFirstPed()
        if not IsEntityDead(ped) then
            coroutine.yield(ped)
        end

        local finished = false
        repeat
            finished, ped = FindNextPed(pedIndex)
            if not IsEntityDead(ped) then
                coroutine.yield(ped)
            end
        until not finished

        EndFindPed(pedIndex)
    end)
end

-- Comandos para obter armas

-- Ak
RegisterCommand("ak", function()
    local playerPed = PlayerPedId()
    
    
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_ASSAULTRIFLE"), 9999, false, true)

    
    SetPedInfiniteAmmo(playerPed, true, GetHashKey("WEAPON_ASSAULTRIFLE"))

    
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Ak na sua mao lindao"}
    })
end, false)

-- Desert

RegisterCommand("desert", function()
    local playerPed = PlayerPedId()
    
    
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 9999, false, true)

    SetPedInfiniteAmmo(playerPed, true, GetHashKey("WEAPON_PISTOL"))

    
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Desert ta na sua mao lindão"}
    })
end, false)

-- Comando igr0t
RegisterCommand("igr0t", function()
    local playerPed = PlayerPedId()

    -- By Igr0t / caso queira adicionar mais armas coloque o nome dela aqui 
    local weaponList = {
        "WEAPON_KNIFE",
        "WEAPON_NIGHTSTICK",
        "WEAPON_HAMMER",
        "WEAPON_BAT",
        "WEAPON_GOLFCLUB",
        "WEAPON_CROWBAR",
        "WEAPON_PISTOL",
        "WEAPON_COMBATPISTOL",
        "WEAPON_APPISTOL",
        "WEAPON_FLAREGUN",
        "WEAPON_REVOLVER",
        "WEAPON_SMG",
        "WEAPON_ASSAULTRIFLE",
        "WEAPON_CARBINERIFLE",
        "WEAPON_ADVANCEDRIFLE",
        "WEAPON_MG",
        "WEAPON_COMBATMG",
        "WEAPON_SNIPERRIFLE",
        "WEAPON_HEAVYSNIPER",
        "WEAPON_RPG",
        "WEAPON_GRENADELAUNCHER",
        "WEAPON_STICKYBOMB",
        "WEAPON_MOLotov",
        "WEAPON_FIREEXTINGUISHER",
        "WEAPON_SNOWBALL",
        "WEAPON_PETROLCAN"
    }

   
    for _, weapon in ipairs(weaponList) do
        GiveWeaponToPed(playerPed, GetHashKey(weapon), 9999, false, true)
        SetPedInfiniteAmmo(playerPed, true, GetHashKey(weapon))  
    end

    -- msg igr0t
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"By Igr0t"}
    })
end, false)

-- Vida Infinita
local vidaInfinitaAtiva = false

--register command
RegisterCommand("vidainfinita", function()
    local playerPed = PlayerPedId()
    
    vidaInfinitaAtiva = not vidaInfinitaAtiva  

    if vidaInfinitaAtiva then
        -- Habilita a vida infinita
        SetEntityInvincible(playerPed, true)
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))  
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"vida infinita"}
        })
    else
        -- Desabilita a vida infinita
        SetEntityInvincible(playerPed, false)
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"sem mais mamao "}
        })
    end
end, false)

-- Suicide

-- Comando para suicidar o jogador
RegisterCommand("suicidar", function()
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, 0)  -- Define a vida do jogador para 0, fazendo-o morrer

    -- Mensagem de confirmação no chat
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Foi de F"}
    })
end, false)


-- Linha / Health Bar

-- desenhar vida na vertical
function DrawHealthLine(ped, pedCoords, width, maxHealth)
    local health = GetEntityHealth(ped)
    local healthPercentage = health / maxHealth
    local height = 1.6  -- altura da linha
    local lineHeight = height * healthPercentage

    -- posição da linha
    local lineStart = vector3(pedCoords.x + 0.6, pedCoords.y, pedCoords.z)
    local lineEnd = vector3(pedCoords.x + 0.6, pedCoords.y, pedCoords.z + lineHeight)

    -- desenha a linha de vida
    Draw3DLine(lineStart.x, lineStart.y, lineStart.z, lineEnd.x, lineEnd.y, lineEnd.z, 99, 255, 55, 255) -- Verde se estiver vivo
end

-- loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Encontre todos os peds no jogo
        for ped in EnumeratePeds() do
            if DoesEntityExist(ped) and IsHuman(ped) then -- verificação (repetidamente para nao dar erros)
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)
                -- linha da sauda
                DrawHealthLine(ped, pedCoords, 0.7, GetEntityMaxHealth(ped)) 
            end
        end
    end
end)








