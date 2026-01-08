-- Monitor de Inventario Simples para CC:Tweaked
-- Mostra apenas itens e quantidades

local config = {
    ladoBau = "top", -- Lado onde esta o bau
    intervalo = 3, -- Tempo entre atualizacoes (segundos)
    mostrarPilhas = true -- Mostrar numero de pilhas
}

-- Inicializar
function iniciar()
    -- Encontrar bau
    local bau = peripheral.wrap(config.ladoBau)
    if not bau then
        print("Erro: Nenhum bau encontrado no lado " .. config.ladoBau)
        return nil
    end
    
    print("Monitor de Inventario Iniciado")
    print("Bau conectado no lado: " .. config.ladoBau)
    print("Atualizando a cada " .. config.intervalo .. " segundos")
    print("Pressione Ctrl+T para parar")
    print(string.rep("-", 40))
    
    return bau
end

-- Escanear itens do bau
function escanearItens(bau)
    local itens = {}
    local totalItens = 0
    local totalPilhas = 0
    
    -- Pegar conteudo do bau
    local conteudo = bau.list()
    
    -- Contar cada item
    for slot, item in pairs(conteudo) do
        local nome = item.displayName or item.name
        
        if not itens[nome] then
            itens[nome] = 0
        end
        
        itens[nome] = itens[nome] + item.count
        totalItens = totalItens + item.count
        totalPilhas = totalPilhas + 1
    end
    
    -- Converter para lista ordenada
    local listaItens = {}
    for nome, quantidade in pairs(itens) do
        table.insert(listaItens, {nome = nome, quantidade = quantidade})
    end
    
    -- Ordenar por quantidade (maior primeiro)
    table.sort(listaItens, function(a, b)
        return a.quantidade > b.quantidade
    end)
    
    return {
        itens = listaItens,
        totalItens = totalItens,
        totalPilhas = totalPilhas,
        hora = os.date("%H:%M:%S")
    }
end

-- Mostrar itens na tela
function mostrarItens(dados)
    -- Limpar tela
    term.clear()
    term.setCursorPos(1, 1)
    
    -- Cabecalho
    print("=== INVENTARIO DO BAU ===")
    print("Total de Itens: " .. dados.totalItens)
    print("Total de Pilhas: " .. dados.totalPilhas)
    print("Itens Diferentes: " .. #dados.itens)
    print(string.rep("=", 30))
    
    -- Listar itens
    for i, item in ipairs(dados.itens) do
        local pilhas = math.ceil(item.quantidade / 64) -- Minecraft stack size padrao
        
        if config.mostrarPilhas then
            print(string.format("%-25s: %5d (%d pilhas)", 
                  string.sub(item.nome, 1, 25), item.quantidade, pilhas))
        else
            print(string.format("%-25s: %5d", 
                  string.sub(item.nome, 1, 25), item.quantidade))
        end
    end
    
    -- Rodape
    local linhasUsadas = 6 + #dados.itens
    if linhasUsadas < 19 then -- Se tiver espaco na tela
        term.setCursorPos(1, linhasUsadas + 1)
        print(string.rep("=", 30))
        print("Atualizado: " .. dados.hora)
        print("Pressione Ctrl+T para parar")
    else
        term.setCursorPos(1, 19)
        print("Atualizado: " .. dados.hora)
    end
end

-- Programa principal
function main()
    local bau = iniciar()
    if not bau then
        return -- Sai se nao encontrou bau
    end
    
    -- Loop principal
    while true do
        -- Escanear e mostrar
        local dados = escanearItens(bau)
        mostrarItens(dados)
        
        -- Esperar pelo intervalo
        sleep(config.intervalo)
    end
end

-- Versao simplificada (apenas 1 funcao)
function monitorarBau()
    -- Configuracoes
    local ladoBau = "top"
    local tempoEspera = 2
    
    -- Conectar ao bau
    local bau = peripheral.wrap(ladoBau)
    if not bau then
        print("Bau nao encontrado no lado " .. ladoBau)
        return
    end
    
    print("Monitorando bau... Ctrl+T para parar")
    sleep(1)
    
    -- Loop de monitoramento
    while true do
        -- Limpar tela
        term.clear()
        term.setCursorPos(1, 1)
        
        -- Pegar itens
        local itens = {}
        local total = 0
        local conteudo = bau.list()
        
        -- Contar itens
        for slot, item in pairs(conteudo) do
            local nome = item.displayName or item.name
            if not itens[nome] then
                itens[nome] = 0
            end
            itens[nome] = itens[nome] + item.count
            total = total + item.count
        end
        
        -- Mostrar resultados
        print("=== ITENS NO BAU ===")
        print("Total: " .. total .. " itens")
        print("=====================")
        
        -- Ordenar e mostrar
        local lista = {}
        for nome, quant in pairs(itens) do
            table.insert(lista, {nome = nome, quant = quant})
        end
        
        table.sort(lista, function(a, b)
            return a.quant > b.quant
        end)
        
        for i, item in ipairs(lista) do
            print(string.format("%-20s: %5d", 
                  string.sub(item.nome, 1, 20), item.quant))
        end
        
        -- Mostrar hora
        local linhas = 4 + #lista
        if linhas < 18 then
            term.setCursorPos(1, linhas + 1)
            print("=====================")
            print("Hora: " .. os.date("%H:%M:%S"))
        end
        
        -- Esperar
        sleep(tempoEspera)
    end
end

-- Iniciar automaticamente
print("=== MONITOR DE INVENTARIO ===")
print("1. Monitor completo (com mais informacoes)")
print("2. Monitor simples (apenas itens)")
print("3. Sair")
write("Escolha (1-3): ")

local escolha = read()
if escolha == "1" then
    -- Usar funcao principal
    local success, err = pcall(main)
    if err then
        print("Erro: " .. err)
    end
elseif escolha == "2" then
    -- Usar versao simplificada
    local success, err = pcall(monitorarBau)
    if err then
        print("Erro: " .. err)
    end
else
    print("Saindo...")
end
