-- Sistema de Monitoramento de Inventário para CC:Tweaked
-- Computador Principal

local modem = peripheral.find("modem") or error("Nenhum modem encontrado")
local monitorInventario = {}
local config = {
    ladoBaú = "top", -- Mude para o lado onde está o baú
    ladoMonitor = "right", -- Lado do monitor (se tiver um)
    intervaloAtualizacao = 5, -- Atualizar a cada 5 segundos
    maxItensPorPagina = 10,
    nomeBaú = "Baú Principal de Armazenamento"
}

-- Inicializar o sistema
function monitorInventario.inicializar()
    -- Encontrar periféricos
    monitorInventario.baú = peripheral.wrap(config.ladoBaú)
    if not monitorInventario.baú then
        print("Erro: Nenhum baú encontrado no lado " .. config.ladoBaú)
        return false
    end
    
    -- Tentar encontrar um monitor
    monitorInventario.monitor = peripheral.find("monitor")
    if monitorInventario.monitor then
        monitorInventario.monitor.setTextScale(0.5)
        print("Monitor encontrado e configurado")
    else
        print("Nenhum monitor encontrado, usando terminal")
    end
    
    -- Abrir modem para comunicação de rede
    if modem then
        modem.open(12345) -- Abrir porta 12345
        print("Porta de rede 12345 aberta")
    end
    
    print("Sistema de Monitoramento de Inventário Inicializado")
    print("Baú: " .. config.nomeBaú)
    print("Intervalo de Atualização: " .. config.intervaloAtualizacao .. " segundos")
    return true
end

-- Escanear baú e contar todos os itens
function monitorInventario.escanearInventario()
    local itens = {}
    local contagemItens = {}
    local totalPilhas = 0
    local totalItens = 0
    
    -- Obter conteúdo do baú
    local conteudoBaú = monitorInventario.baú.list()
    
    -- Processar cada slot
    for slot, item in pairs(conteudoBaú) do
        local chaveItem = item.name .. ":" .. (item.damage or 0)
        
        if not itens[chaveItem] then
            itens[chaveItem] = {
                nome = item.name,
                nomeExibicao = item.displayName,
                quantidade = 0,
                tamanhoMaxPilha = item.maxCount or 64,
                slots = {},
                dano = item.damage
            }
        end
        
        itens[chaveItem].quantidade = itens[chaveItem].quantidade + item.count
        table.insert(itens[chaveItem].slots, slot)
        totalItens = totalItens + item.count
        totalPilhas = totalPilhas + 1
    end
    
    -- Converter para array ordenado
    local itensOrdenados = {}
    for _, dadosItem in pairs(itens) do
        table.insert(itensOrdenados, dadosItem)
    end
    
    -- Ordenar por quantidade (decrescente)
    table.sort(itensOrdenados, function(a, b)
        return a.quantidade > b.quantidade
    end)
    
    return {
        itens = itensOrdenados,
        totalPilhas = totalPilhas,
        totalItens = totalItens,
        dataHora = os.time(),
        nomeBaú = config.nomeBaú
    }
end

-- Exibir resultados no monitor ou terminal
function monitorInventario.exibirResultados(dadosInventario, pagina)
    pagina = pagina or 1
    local inicioIndice = (pagina - 1) * config.maxItensPorPagina + 1
    local fimIndice = math.min(inicioIndice + config.maxItensPorPagina - 1, #dadosInventario.itens)
    
    if monitorInventario.monitor then
        -- Exibir no monitor
        monitorInventario.monitor.clear()
        monitorInventario.monitor.setCursorPos(1, 1)
        monitorInventario.monitor.write("=== " .. config.nomeBaú .. " ===")
        monitorInventario.monitor.setCursorPos(1, 2)
        monitorInventario.monitor.write("Total de Itens: " .. dadosInventario.totalItens)
        monitorInventario.monitor.setCursorPos(1, 3)
        monitorInventario.monitor.write("Total de Pilhas: " .. dadosInventario.totalPilhas)
        monitorInventario.monitor.setCursorPos(1, 4)
        monitorInventario.monitor.write("Itens Únicos: " .. #dadosInventario.itens)
        monitorInventario.monitor.setCursorPos(1, 5)
        monitorInventario.monitor.write("Página: " .. pagina .. "/" .. math.ceil(#dadosInventario.itens / config.maxItensPorPagina))
        monitorInventario.monitor.setCursorPos(1, 6)
        monitorInventario.monitor.write(string.rep("=", 30))
        
        local posY = 7
        for i = inicioIndice, fimIndice do
            if posY > 25 then break end
            
            local item = dadosInventario.itens[i]
            local pilhas = math.ceil(item.quantidade / item.tamanhoMaxPilha)
            
            monitorInventario.monitor.setCursorPos(1, posY)
            local textoExibicao = string.sub(item.nomeExibicao or item.nome, 1, 20)
            monitorInventario.monitor.write(string.format("%-20s: %6d (%d pilhas)", textoExibicao, item.quantidade, pilhas))
            posY = posY + 1
        end
        
        -- Mostrar data/hora
        monitorInventario.monitor.setCursorPos(1, 27)
        monitorInventario.monitor.write("Atualizado: " .. os.date("%H:%M:%S", dadosInventario.dataHora))
    else
        -- Exibir no terminal
        term.clear()
        term.setCursorPos(1, 1)
        print("=== " .. config.nomeBaú .. " ===")
        print("Total de Itens: " .. dadosInventario.totalItens)
        print("Total de Pilhas: " .. dadosInventario.totalPilhas)
        print("Itens Únicos: " .. #dadosInventario.itens)
        print("Página: " .. pagina .. "/" .. math.ceil(#dadosInventario.itens / config.maxItensPorPagina))
        print(string.rep("=", 50))
        
        for i = inicioIndice, fimIndice do
            local item = dadosInventario.itens[i]
            local pilhas = math.ceil(item.quantidade / item.tamanhoMaxPilha)
            
            local textoExibicao = item.nomeExibicao or item.nome
            print(string.format("%-30s: %8d itens (%3d pilhas)", 
                  string.sub(textoExibicao, 1, 30), item.quantidade, pilhas))
        end
        
        print(string.rep("=", 50))
        print("Atualizado: " .. os.date("%d/%m/%Y %H:%M:%S", dadosInventario.dataHora))
        print("Pressione N/P para próxima/página anterior, Q para sair, R para atualizar")
    end
end

-- Enviar dados de inventário pela rede
function monitorInventario.enviarAtualizacaoRede(dadosInventario)
    if modem then
        local dados = {
            tipo = "atualizacao_inventario",
            nomeBaú = config.nomeBaú,
            totalItens = dadosInventario.totalItens,
            totalPilhas = dadosInventario.totalPilhas,
            itensUnicos = #dadosInventario.itens,
            dataHora = dadosInventario.dataHora,
            itensAmostra = {}
        }
        
        -- Incluir top 5 itens na transmissão
        for i = 1, math.min(5, #dadosInventario.itens) do
            table.insert(dados.itensAmostra, {
                nome = dadosInventario.itens[i].nome,
                quantidade = dadosInventario.itens[i].quantidade
            })
        end
        
        modem.transmit(12345, 12345, dados)
    end
end

-- Exportar dados para arquivo
function monitorInventario.exportarParaArquivo(dadosInventario)
    local nomeArquivo = "inventario_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    local arquivo = fs.open(nomeArquivo, "w")
    
    arquivo.writeLine("=== EXPORTAÇÃO DE INVENTÁRIO ===")
    arquivo.writeLine("Baú: " .. config.nomeBaú)
    arquivo.writeLine("Data/Hora: " .. os.date("%d/%m/%Y %H:%M:%S", dadosInventario.dataHora))
    arquivo.writeLine("Total de Itens: " .. dadosInventario.totalItens)
    arquivo.writeLine("Total de Pilhas: " .. dadosInventario.totalPilhas)
    arquivo.writeLine("Itens Únicos: " .. #dadosInventario.itens)
    arquivo.writeLine("")
    arquivo.writeLine("=== LISTA DE ITENS ===")
    
    for _, item in ipairs(dadosInventario.itens) do
        local pilhas = math.ceil(item.quantidade / item.tamanhoMaxPilha)
        arquivo.writeLine(string.format("%s: %d itens (%d pilhas)", 
            item.nomeExibicao or item.nome, item.quantidade, pilhas))
    end
    
    arquivo.close()
    print("Inventário exportado para " .. nomeArquivo)
end

-- Loop principal de monitoramento
function monitorInventario.executar()
    local paginaAtual = 1
    local ultimoTempoEscaneamento = 0
    
    while true do
        local evento, param1, param2, param3 = os.pullEvent()
        
        if evento == "timer" and param1 == ultimoTempoEscaneamento then
            -- Hora de atualizar
            local dadosInventario = monitorInventario.escanearInventario()
            monitorInventario.exibirResultados(dadosInventario, paginaAtual)
            monitorInventario.enviarAtualizacaoRede(dadosInventario)
            
            -- Agendar próxima atualização
            ultimoTempoEscaneamento = os.startTimer(config.intervaloAtualizacao)
            
        elseif evento == "key" then
            -- Processar entrada do teclado
            if param1 == keys.q then
                break -- Sair
            elseif param1 == keys.n then
                -- Próxima página
                local dadosInventario = monitorInventario.escanearInventario()
                local maxPaginas = math.ceil(#dadosInventario.itens / config.maxItensPorPagina)
                paginaAtual = math.min(paginaAtual + 1, maxPaginas)
                monitorInventario.exibirResultados(dadosInventario, paginaAtual)
            elseif param1 == keys.p then
                -- Página anterior
                paginaAtual = math.max(1, paginaAtual - 1)
                local dadosInventario = monitorInventario.escanearInventario()
                monitorInventario.exibirResultados(dadosInventario, paginaAtual)
            elseif param1 == keys.r then
                -- Atualizar
                local dadosInventario = monitorInventario.escanearInventario()
                monitorInventario.exibirResultados(dadosInventario, paginaAtual)
            elseif param1 == keys.e then
                -- Exportar para arquivo
                local dadosInventario = monitorInventario.escanearInventario()
                monitorInventario.exportarParaArquivo(dadosInventario)
                print("Pressione qualquer tecla para continuar...")
                os.pullEvent("key")
                local dadosInventario = monitorInventario.escanearInventario()
                monitorInventario.exibirResultados(dadosInventario, paginaAtual)
            end
            
        elseif evento == "modem_message" then
            -- Processar mensagens de rede
            local _, _, mensagem = param1, param2, param3
            if mensagem and mensagem.tipo == "solicitar_inventario" then
                local dadosInventario = monitorInventario.escanearInventario()
                modem.transmit(12345, 12345, {
                    tipo = "resposta_inventario",
                    dados = dadosInventario
                })
            end
        end
        
        -- Configuração inicial do timer
        if ultimoTempoEscaneamento == 0 then
            ultimoTempoEscaneamento = os.startTimer(0) -- Primeiro escaneamento imediato
        end
    end
end

-- Interface de linha de comando
function monitorInventario.cli()
    print("Sistema de Monitoramento de Inventário - CLI")
    print("Comandos disponíveis:")
    print("  escanear - Escanear e exibir inventário")
    print("  exportar - Exportar inventário para arquivo")
    print("  monitorar - Iniciar monitoramento contínuo")
    print("  config - Mostrar configuração atual")
    print("  ajuda - Mostrar esta ajuda")
    print("  sair - Sair do programa")
    
    while true do
        write("> ")
        local comando = read()
        
        if comando == "escanear" then
            local dadosInventario = monitorInventario.escanearInventario()
            monitorInventario.exibirResultados(dadosInventario, 1)
            
        elseif comando == "exportar" then
            local dadosInventario = monitorInventario.escanearInventario()
            monitorInventario.exportarParaArquivo(dadosInventario)
            
        elseif comando == "monitorar" then
            print("Iniciando monitoramento contínuo...")
            print("Pressione Q para sair, N/P para próxima/página anterior")
            monitorInventario.executar()
            
        elseif comando == "config" then
            print("Configuração Atual:")
            for chave, valor in pairs(config) do
                print("  " .. chave .. ": " .. tostring(valor))
            end
            
        elseif comando == "ajuda" then
            print("Comandos: escanear, exportar, monitorar, config, ajuda, sair")
            
        elseif comando == "sair" then
            break
            
        else
            print("Comando desconhecido. Digite 'ajuda' para comandos disponíveis.")
        end
    end
end

-- Iniciar o sistema
if monitorInventario.inicializar() then
    print("\nSistema pronto!")
    print("Digite 'monitorInventario.cli()' para iniciar a interface de comandos")
    print("Ou execute comandos individuais:")
    print("  monitorInventario.escanearInventario() - Escanear uma vez")
    print("  monitorInventario.executar() - Iniciar monitoramento")
else
    print("Falha ao inicializar o sistema. Verifique os periféricos.")
end
